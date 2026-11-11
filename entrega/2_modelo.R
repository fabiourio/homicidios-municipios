# =============================================================================
# Fatores associados aos homicídios nos municípios brasileiros
# Parte 2 - Ajuste do modelo de regressão linear múltipla
#
# Entrada: dados/base_analitica.csv e dados/variaveis_extras.csv
#          (municípios com 30 mil hab. ou mais)
# Saída:   resultados/modelagem/ (figuras, tabelas e valores_modelo.txt)
# Rodar com a pasta entrega/ como diretório de trabalho.
# =============================================================================

rm(list = ls())

library(ggplot2)
library(MASS)     # boxcox
library(car)      # vif
library(lmtest)   # bptest

set.seed(16)
dir.create("resultados/modelagem", recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Leitura dos dados
# -----------------------------------------------------------------------------
d <- read.csv("dados/base_analitica.csv")

# Variáveis de educação e migração (INEP 2022 e Censo 2022), em arquivo à parte
extras <- read.csv("dados/variaveis_extras.csv")
d <- merge(d, extras[, c("cod_ibge", "abandono_em", "distorcao_em", "pct_migr_10anos")], by = "cod_ibge")

# Escopo do modelo: municípios com 30 mil habitantes ou mais (percentil 80 da população).
# Abaixo disso a taxa é dominada pelo acaso (poucos casos): ver confiabilidade_porte.csv
POP_MIN <- 30000
# Campos do Jordão-SP fica fora: 1 homicídio registrado e 36 óbitos de intenção indeterminada (indício de sub-registro)
FORA <- 3509700
d <- d[d$pop >= POP_MIN & d$cod_ibge != FORA, ]

# Só para os testes da seção 5.3 (variáveis testadas e retiradas): ln(densidade) padronizado e
# % de óbitos de intenção indeterminada com os homicídios fora do total de causas externas
d$dens_z <- (d$log_dens - mean(d$log_dens)) / sd(d$log_dens)
d$indet_sem_hom <- 100 * d$intencao_indeterminada / (d$total_causas_externas - d$hom)

# Região como variável categórica: 5 classes -> 4 indicadoras, com o Sudeste como referência
d$regiao <- relevel(factor(d$regiao, levels = c("N", "NE", "CO", "SE", "S"),
                           labels = c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul")), ref = "Sudeste")

# Resposta: taxa de homicídios por 100 mil hab./ano (2021-2023)
d$y <- d$taxa

# Paleta igual à dos slides: azul do ODS 16, vermelho de destaque e azul-claro de preenchimento
AZUL <- "#00689D"; VERMELHO <- "#C8343B"; CINZA <- "#7A869A"; FUNDO <- "#FFFFFF"; CLARO <- "#D6E6F2"; MARINHO <- "#13294B"
th <- theme_minimal(base_size = 12) +
  theme(plot.background = element_rect(fill = FUNDO, colour = NA), panel.grid.minor = element_blank())
milhar <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)

# -----------------------------------------------------------------------------
# 1. Regressão linear simples: taxa ~ ln(renda) (ponto de partida)
# -----------------------------------------------------------------------------
rls <- lm(y ~ log_rend, data = d)
summary(rls)

# -----------------------------------------------------------------------------
# 2. Transformação da resposta (Box-Cox)
# -----------------------------------------------------------------------------
f_base <- ~ log_rend + gini + desocup + pct_urbana + freq_15a17 + distorcao_em + pct_migr_10anos + regiao

m_y <- lm(update(f_base, y ~ .), data = d)

# Box-Cox exige resposta positiva: no escopo do modelo não há município com taxa zero
stopifnot(all(d$y > 0))
bc <- boxcox(lm(update(f_base, y ~ .), data = d), lambda = seq(-0.5, 1.2, 0.01), plotit = FALSE)
lambda <- bc$x[which.max(bc$y)]
lambda_ic <- range(bc$x[bc$y > max(bc$y) - qchisq(0.95, 1) / 2])     # IC 95% para lambda

# lambda estimado perto de 0: adotamos ln(Y), valor simples de interpretar (100 b = variação % aproximada da taxa)
d$ly <- log(d$y)
m_log <- lm(update(f_base, ly ~ .), data = d)

# Shapiro-Wilk (Ho: normal)
sw_y    <- shapiro.test(rstandard(m_y))
sw_log  <- shapiro.test(rstandard(m_log))

# -----------------------------------------------------------------------------
# 3. Multicolinearidade: renda, % pobres e alfabetização juntas
# -----------------------------------------------------------------------------
m_colin <- lm(ly ~ log_rend + pct_pobres + alfabet + gini + desocup + pct_urbana +
                freq_15a17 + distorcao_em + pct_migr_10anos + regiao, data = d)
summary(m_colin)

# Para a região (4 indicadoras) o car devolve o GVIF; GVIF^(1/(2*gl)) ao quadrado fica na escala do VIF
vif_colin <- vif(m_colin)[, "GVIF^(1/(2*Df))"]^2

# Mantemos só a renda. O termo quadrático usa a renda centralizada, para reduzir a correlação entre X e X²
d$rend_c  <- d$log_rend - mean(d$log_rend)
d$rend_c2 <- d$rend_c^2
cor_quad <- c(sem_centrar = cor(d$log_rend, d$log_rend^2), centrado = cor(d$rend_c, d$rend_c2))

# O Gini também é centralizado, por causa do termo Gini x renda: o coeficiente do Gini vale na renda média,
# e os da renda valem no Gini médio
d$gini_c <- d$gini - mean(d$gini)

# -----------------------------------------------------------------------------
# 4. Construção em blocos: somas de quadrados extras e teste F parcial
# -----------------------------------------------------------------------------
mA <- lm(ly ~ rend_c + rend_c2 + gini_c + desocup, data = d)                  # socioeconômico
mB <- update(mA, . ~ . + pct_urbana)                                           # + urbanização
mC <- update(mB, . ~ . + freq_15a17 + distorcao_em + pct_migr_10anos)          # + educação e migração
mD <- update(mC, . ~ . + regiao)                                               # + região
mE <- update(mD, . ~ . + rend_c:gini_c)                                        # + Gini x renda (interação)

anova_blocos <- anova(mA, mB, mC, mD, mE)
anova_blocos
write.csv(as.data.frame(anova_blocos), "resultados/modelagem/anova_blocos.csv")

# F parcial do termo quadrático (Ho: beta_renda² = 0)
F_quad  <- anova(update(mE, . ~ . - rend_c2), mE)

comp <- data.frame(
  modelo = c("A socioeconômico", "B + urbanização", "C + educação e migração", "D + região", "E + Gini x renda"),
  p   = sapply(list(mA, mB, mC, mD, mE), function(m) length(coef(m)) - 1),
  R2  = sapply(list(mA, mB, mC, mD, mE), function(m) summary(m)$r.squared),
  R2a = sapply(list(mA, mB, mC, mD, mE), function(m) summary(m)$adj.r.squared),
  MSE = sapply(list(mA, mB, mC, mD, mE), function(m) summary(m)$sigma^2))
write.csv(comp, "resultados/modelagem/comparacao_blocos.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 5. Modelo final (E): teste F global, coeficientes e intervalos de confiança
# -----------------------------------------------------------------------------
final <- mE
sf_ <- summary(final)
sf_
anova(final)
ic <- confint(final, level = 0.95)
vif_final <- vif(final)[, "GVIF^(1/(2*Df))"]^2

coefs <- data.frame(termo = rownames(sf_$coefficients), sf_$coefficients, ic, row.names = NULL)
names(coefs) <- c("termo", "b", "ep", "t", "p", "ic_inf", "ic_sup")
write.csv(coefs, "resultados/modelagem/coeficientes.csv", row.names = FALSE)

# Renda em que a taxa esperada é máxima, no Gini médio: derivada b1 + 2 b2 rend_c = 0
b <- coef(final)
pico_renda <- exp(mean(d$log_rend) - b["rend_c"] / (2 * b["rend_c2"]))

# Efeitos na escala da taxa: com ln(taxa), uma mudança delta em X multiplica a taxa por exp(b * delta)
mudancas <- data.frame(
  termo   = c("pct_urbana", "desocup", "freq_15a17", "distorcao_em", "pct_migr_10anos"),
  variavel = c("% urbana", "Desocupação", "Frequência escolar 15–17", "Distorção idade-série (EM)", "Migração recente"),
  mudanca = c("+10 pontos", "+1 ponto", "+5 pontos", "+10 pontos", "+5 pontos"),
  delta   = c(10, 1, 5, 10, 5))
mudancas$b <- b[mudancas$termo]
mudancas$p <- sf_$coefficients[mudancas$termo, 4]
mudancas$efeito_pct <- 100 * (exp(mudancas$b * mudancas$delta) - 1)
mudancas$ic_inf_pct <- 100 * (exp(ic[mudancas$termo, 1] * mudancas$delta) - 1)
mudancas$ic_sup_pct <- 100 * (exp(ic[mudancas$termo, 2] * mudancas$delta) - 1)
write.csv(mudancas, "resultados/modelagem/efeitos_percentuais.csv", row.names = FALSE)

# Efeito de +0,05 no Gini conforme a renda: (b_gini + b_interação * rend_c), com o erro-padrão dessa combinação linear
V <- vcov(final)
efeito_gini <- function(rend) {
  rc <- log(rend) - mean(d$log_rend)
  e  <- b["gini_c"] + b["rend_c:gini_c"] * rc
  ep <- sqrt(V["gini_c", "gini_c"] + rc^2 * V["rend_c:gini_c", "rend_c:gini_c"] + 2 * rc * V["gini_c", "rend_c:gini_c"])
  tc <- qt(0.975, final$df.residual)
  data.frame(renda = rend, efeito_pct = 100 * (exp(0.05 * e) - 1), ic_inf_pct = 100 * (exp(0.05 * (e - tc * ep)) - 1),
             ic_sup_pct = 100 * (exp(0.05 * (e + tc * ep)) - 1), p = 2 * pt(-abs(e / ep), final$df.residual))
}
gini_renda <- data.frame(percentil = c(10, 25, 50, 75, 90),
                         efeito_gini(quantile(d$rend_pc_media, c(.10, .25, .50, .75, .90))), row.names = NULL)
write.csv(gini_renda, "resultados/modelagem/efeito_gini_renda.csv", row.names = FALSE)
renda_gini_zero <- unname(exp(mean(d$log_rend) - b["gini_c"] / b["rend_c:gini_c"]))     # renda em que o efeito do Gini é zero

# Gráfico de efeito da renda: taxa prevista (IC 95%) ao longo da renda, demais variáveis na média (Gini médio).
# Uma curva para o Nordeste e outra para o Sudeste, cada uma só na faixa de renda observada na região (sem extrapolar).
grade <- do.call(rbind, lapply(c("Nordeste", "Sudeste"), function(rg) {
  lr <- d$log_rend[d$regiao == rg]
  data.frame(regiao = rg, rend = exp(seq(quantile(lr, .02), quantile(lr, .98), length.out = 100)))
}))
grade$rend_c <- log(grade$rend) - mean(d$log_rend); grade$rend_c2 <- grade$rend_c^2
for (v in c("desocup", "pct_urbana", "freq_15a17", "distorcao_em", "pct_migr_10anos")) grade[[v]] <- mean(d[[v]])
grade$gini_c <- 0
grade$regiao <- factor(grade$regiao, levels = levels(d$regiao))
pr <- predict(final, newdata = grade, interval = "confidence", level = 0.95)
grade$taxa <- exp(pr[, "fit"]); grade$lo <- exp(pr[, "lwr"]); grade$hi <- exp(pr[, "upr"])

# -----------------------------------------------------------------------------
# 5.1 Modelo com e sem a renda: a renda tem o maior VIF do modelo
# -----------------------------------------------------------------------------
sem_renda <- update(final, . ~ . - rend_c - rend_c2 - rend_c:gini_c)
F_renda <- anova(sem_renda, final)                    # Ho: beta_renda = beta_renda² = beta_interação = 0
vif_sem_renda <- vif(sem_renda)[, "GVIF^(1/(2*Df))"]^2
ss_ <- summary(sem_renda)
termos <- rownames(ss_$coefficients)[-1]
com_sem <- data.frame(termo = termos, b_com = b[termos], p_com = sf_$coefficients[termos, 4],
                      b_sem = ss_$coefficients[termos, 1], p_sem = ss_$coefficients[termos, 4], row.names = NULL)
write.csv(com_sem, "resultados/modelagem/com_sem_renda.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 5.2 Região x estado: os dois modelos lado a lado (o grupo escolheu a região)
# -----------------------------------------------------------------------------
d$uf <- relevel(factor(d$uf), ref = "SP")
com_estado <- update(final, . ~ . - regiao + uf)      # estado (26 indicadoras) no lugar da região
F_estado <- anova(final, com_estado)                  # Ho: os estados não acrescentam nada além da região
vif_estado <- vif(com_estado)[, "GVIF^(1/(2*Df))"]^2
se_ <- summary(com_estado)
termos_x <- grep("^regiao|Intercept", rownames(sf_$coefficients), value = TRUE, invert = TRUE)
regiao_estado <- data.frame(termo = termos_x, b_regiao = b[termos_x], p_regiao = sf_$coefficients[termos_x, 4],
                            b_estado = se_$coefficients[termos_x, 1], p_estado = se_$coefficients[termos_x, 4], row.names = NULL)
write.csv(regiao_estado, "resultados/modelagem/regiao_x_estado.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 5.3 Variáveis testadas e retiradas: F parcial de cada uma somada ao modelo (Ho: beta = 0)
# -----------------------------------------------------------------------------
testadas <- c(dens_z = "Densidade (ln, padronizada)", faixa_fronteira = "Faixa de fronteira",
              abandono_em = "Abandono no ensino médio", pct_h1529 = "% homens 15–29", amazonia_legal = "Amazônia Legal",
              indet_sem_hom = "% intenção indeterminada (sem os homicídios no total)")
retiradas <- do.call(rbind, lapply(names(testadas), function(v) {
  m <- update(final, as.formula(paste(". ~ . +", v)))
  a <- anova(final, m)
  data.frame(termo = v, variavel = testadas[[v]], F = a$F[2], p = a$`Pr(>F)`[2], R2a_com = summary(m)$adj.r.squared)
}))
write.csv(retiradas, "resultados/modelagem/testadas_retiradas.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 6. Diagnóstico pela análise dos resíduos
# -----------------------------------------------------------------------------
d$ajustado <- fitted(final)
d$residuo  <- residuals(final)
d$res_semi <- d$residuo / sqrt(sum(d$residuo^2) / final$df.residual)    # e* = e / sqrt(MSE)

bp <- bptest(final)                                   # Ho: variância constante
sw_final <- shapiro.test(rstandard(final))   # Ho: normalidade
outliers <- d[abs(d$res_semi) >= 4, c("municipio", "uf", "pop", "taxa", "ajustado", "res_semi")]

# -----------------------------------------------------------------------------
# Figuras
# -----------------------------------------------------------------------------
# M1. Log-verossimilhança de Box-Cox em função de lambda
p <- ggplot(data.frame(l = bc$x, ll = bc$y), aes(l, ll)) +
  geom_line(colour = AZUL, linewidth = .9) +
  geom_vline(xintercept = lambda, colour = CINZA, linetype = 2) +
  geom_vline(xintercept = 0, colour = VERMELHO, linewidth = .6) +
  annotate("text", x = lambda + .03, y = min(bc$y) + .1 * diff(range(bc$y)), hjust = 0, size = 3,
           label = paste0("λ máx. = ", sub(".", ",", sprintf("%.2f", lambda), fixed = TRUE))) +
  annotate("text", x = -.03, y = min(bc$y) + .1 * diff(range(bc$y)), hjust = 1, size = 3,
           colour = VERMELHO, label = "λ = 0 (ln Y)") +
  labs(x = "λ", y = "Log-verossimilhança") + th
ggsave("resultados/modelagem/m1_boxcox.png", p, width = 4.8, height = 3.0, dpi = 250)

# M2. Resíduos x ajustados e gráfico de quantis: Y original x ln Y
dd <- rbind(data.frame(m = "Y (taxa original)", fit = fitted(m_y), es = rstandard(m_y)),
            data.frame(m = "ln Y", fit = fitted(m_log), es = rstandard(m_log)))
dd$m <- factor(dd$m, levels = c("Y (taxa original)", "ln Y"))
p <- ggplot(dd, aes(fit, es)) + geom_point(size = .5, alpha = .25, colour = AZUL) +
  geom_hline(yintercept = 0, colour = CINZA, linetype = 2) + facet_wrap(~m, scales = "free_x") +
  labs(x = "Valor ajustado", y = "Resíduo padronizado") + th
ggsave("resultados/modelagem/m2a_residuos_y_transformada.png", p, width = 4.6, height = 2.6, dpi = 220)
p <- ggplot(dd, aes(sample = es)) + stat_qq(size = .5, alpha = .3, colour = AZUL) +
  stat_qq_line(colour = VERMELHO) + facet_wrap(~m) +
  labs(x = "Quantis teóricos (dist. normal)", y = "Quantis amostrais") + th
ggsave("resultados/modelagem/m2b_qq_y_transformada.png", p, width = 4.6, height = 2.6, dpi = 220)

# M3. Resíduos semi-studentizados x ajustados e x ln(renda)
p <- ggplot(d, aes(ajustado, res_semi)) + geom_point(size = .5, alpha = .25, colour = AZUL) +
  geom_hline(yintercept = c(-4, 0, 4), linetype = 2, colour = c(VERMELHO, CINZA, VERMELHO)) +
  labs(x = "Valor ajustado (ln taxa)", y = "Resíduo semi-studentizado") + th
ggsave("resultados/modelagem/m3a_residuos_ajustados.png", p, width = 4.6, height = 3.0, dpi = 250)
p <- ggplot(d, aes(log_rend, res_semi)) + geom_point(size = .5, alpha = .25, colour = AZUL) +
  geom_hline(yintercept = 0, linetype = 2, colour = CINZA) +
  labs(x = "ln Renda per capita", y = "Resíduo semi-studentizado") + th
ggsave("resultados/modelagem/m3b_residuos_renda.png", p, width = 3.2, height = 2.6, dpi = 220)

# M4. |Resíduo| x população (variável fora do modelo): variância não constante
p <- ggplot(d, aes(pop, abs(residuo))) + geom_point(size = .5, alpha = .2, colour = AZUL) +
  scale_x_log10(labels = milhar) +
  labs(x = "População (escala log)", y = "|resíduo|") + th + theme(plot.margin = margin(5, 20, 5, 5))
ggsave("resultados/modelagem/m4_residuo_pop.png", p, width = 6.4, height = 2.6, dpi = 220)

# M5. Histograma e gráfico de quantis dos resíduos padronizados
p <- ggplot(d, aes(rstandard(final))) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = AZUL, colour = FUNDO, linewidth = .15) +
  labs(x = "Resíduo padronizado", y = "Densidade") + th
ggsave("resultados/modelagem/m5a_hist_residuos.png", p, width = 3.2, height = 2.6, dpi = 220)
p <- ggplot(d, aes(sample = rstandard(final))) + stat_qq(size = .5, alpha = .3, colour = AZUL) +
  stat_qq_line(colour = VERMELHO) + labs(x = "Quantis teóricos (dist. normal)", y = "Quantis amostrais") + th
ggsave("resultados/modelagem/m5b_qq_final.png", p, width = 3.2, height = 2.6, dpi = 220)

# M7. Efeito da renda previsto pelo modelo, no Nordeste e no Sudeste (IC 95% da resposta esperada)
p <- ggplot(grade, aes(rend, taxa, group = regiao)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = CLARO, alpha = .7) +
  geom_line(aes(colour = regiao), linewidth = 1) +
  scale_colour_manual(values = c(Nordeste = AZUL, Sudeste = MARINHO), name = NULL) +
  geom_vline(xintercept = pico_renda, colour = VERMELHO, linetype = 2) +
  annotate("text", x = pico_renda * 1.05, y = max(grade$hi), hjust = 0, vjust = 1, size = 3.5, colour = VERMELHO,
           label = paste0("pico: R$ ", milhar(round(pico_renda)))) +
  scale_x_log10(labels = milhar) +
  labs(x = "Renda per capita (R$, escala log)", y = "Taxa prevista (/100 mil)") + th + theme(legend.position = "bottom")
ggsave("resultados/modelagem/m7_efeito_renda.png", p, width = 4.8, height = 3.0, dpi = 250)

# M8. Efeito de +0,05 no Gini ao longo da renda (IC 95%)
g8 <- efeito_gini(exp(seq(quantile(d$log_rend, .02), quantile(d$log_rend, .98), length.out = 100)))
p <- ggplot(g8, aes(renda, efeito_pct)) +
  geom_ribbon(aes(ymin = ic_inf_pct, ymax = ic_sup_pct), fill = CLARO, alpha = .7) +
  geom_line(colour = AZUL, linewidth = 1) +
  geom_hline(yintercept = 0, colour = CINZA, linetype = 2) +
  geom_vline(xintercept = renda_gini_zero, colour = VERMELHO, linetype = 2) +
  annotate("text", x = renda_gini_zero * 1.05, y = max(g8$ic_sup_pct), hjust = 0, vjust = 1, size = 3.5, colour = VERMELHO,
           label = paste0("efeito zero: R$ ", milhar(round(renda_gini_zero)))) +
  scale_x_log10(labels = milhar) +
  labs(x = "Renda per capita (R$, escala log)", y = "Efeito de +0,05 no Gini (% na taxa)") + th
ggsave("resultados/modelagem/m8_efeito_gini_renda.png", p, width = 4.8, height = 3.0, dpi = 250)

# -----------------------------------------------------------------------------
# Números citados na apresentação
# -----------------------------------------------------------------------------
write.csv(outliers, "resultados/modelagem/outliers.csv", row.names = FALSE)

sink("resultados/modelagem/valores_modelo.txt")
cat(sprintf("n = %d municípios | zeros: %d\n", nrow(d), sum(d$y == 0)))
cat("\n== 1. Regressão simples: taxa ~ ln(renda) ==\n"); print(summary(rls)$coefficients)
cat(sprintf("R² = %.3f\n", summary(rls)$r.squared))
cat("\n== 2. Box-Cox ==\n")
cat(sprintf("lambda = %.2f | IC 95%%: %.2f a %.2f | adotado: 0 (ln)\n", lambda, lambda_ic[1], lambda_ic[2]))
cat(sprintf("Shapiro-Wilk: Y W = %.3f | ln Y W = %.3f\n", sw_y$statistic, sw_log$statistic))
cat(sprintf("Breusch-Pagan: Y = %.1f | ln Y = %.1f\n", bptest(m_y)$statistic, bptest(m_log)$statistic))
cat("\n== 3. Multicolinearidade ==\n")
cat("VIF com renda, % pobres e alfabetização juntas:\n"); print(round(vif_colin, 2))
print(summary(m_colin)$coefficients[c("log_rend", "pct_pobres", "alfabet"), ])
cat(sprintf("cor(X, X²): sem centrar = %.4f | centrado = %.4f\n", cor_quad[1], cor_quad[2]))
cat("\n== 4. Blocos (F parcial) ==\n"); print(anova_blocos)
cat(sprintf("\nF parcial renda²: F = %.1f | p = %.2g\n", F_quad$F[2], F_quad$`Pr(>F)`[2]))
cat("\nR² e R² ajustado por bloco:\n"); print(comp, digits = 4, row.names = FALSE)
cat("\n== 5. Modelo final (E) ==\n"); print(sf_)
cat("Intervalos de confiança 95%:\n"); print(round(ic, 4))
cat("\nVIF do modelo final:\n"); print(round(vif_final, 2))
cat(sprintf("Renda per capita do pico da taxa esperada (no Gini médio): R$ %.0f\n", pico_renda))
cat(sprintf("\nEfeito de +0,05 no Gini conforme a renda (zero em R$ %.0f; %.0f%% dos municípios abaixo):\n",
            renda_gini_zero, 100 * mean(d$rend_pc_media < renda_gini_zero)))
print(gini_renda, digits = 3, row.names = FALSE)
cat("\n== 5.1 Modelo com e sem a renda ==\n")
cat(sprintf("F parcial da renda (renda, renda² e Gini x renda): F = %.1f (gl %d) | p = %.2g\n", F_renda$F[2], F_renda$Df[2], F_renda$`Pr(>F)`[2]))
cat(sprintf("R² ajustado: com = %.3f | sem = %.3f\n", sf_$adj.r.squared, ss_$adj.r.squared))
cat(sprintf("VIF máximo: com = %.2f | sem = %.2f\n", max(vif_final), max(vif_sem_renda)))
print(com_sem, digits = 3, row.names = FALSE)
cat("\n== 5.2 Região x estado ==\n")
cat(sprintf("Parâmetros: região = %d | estado = %d\n", length(coef(final)), length(coef(com_estado))))
cat(sprintf("R² ajustado: região = %.3f | estado = %.3f\n", sf_$adj.r.squared, se_$adj.r.squared))
cat(sprintf("VIF máximo: região = %.2f | estado = %.2f\n", max(vif_final), max(vif_estado)))
cat(sprintf("F parcial do estado além da região: F = %.1f (gl %d) | p = %.2g\n", F_estado$F[2], F_estado$Df[2], F_estado$`Pr(>F)`[2]))
cat(sprintf("Estados com menos de 10 municípios no estudo: %d\n", sum(table(d$uf) < 10)))
print(regiao_estado, digits = 3, row.names = FALSE)
cat("\n== 5.3 Variáveis testadas e retiradas (F parcial de cada uma somada ao modelo) ==\n")
print(retiradas[, -1], digits = 3, row.names = FALSE)
cat("\n== 6. Diagnóstico ==\n")
cat(sprintf("Breusch-Pagan = %.1f (gl %d) | p = %.2g\n", bp$statistic, bp$parameter, bp$p.value))
cat(sprintf("Shapiro-Wilk = %.3f | p = %.2g\n", sw_final$statistic, sw_final$p.value))
cat(sprintf("Possíveis outliers (|e*| >= 4): %d\n", nrow(outliers))); print(outliers, row.names = FALSE)
sink()
cat(readLines("resultados/modelagem/valores_modelo.txt"), sep = "\n")
