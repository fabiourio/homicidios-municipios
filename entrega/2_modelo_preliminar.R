# =============================================================================
# Fatores associados aos homicídios nos municípios brasileiros
# Parte 2 - Ajuste preliminar do modelo de regressão linear múltipla
#
# Entrada: dados/base_analitica.csv (modelo ajustado nos municípios com 20 mil hab. ou mais)
# Saída:   resultados/modelagem/ (figuras, tabelas e valores_modelo.txt)
# Rodar com a pasta entrega/ como diretório de trabalho.
# =============================================================================

rm(list = ls())

library(ggplot2)
library(dplyr)
library(MASS)     # boxcox
library(car)      # vif
library(lmtest)   # bptest, dwtest

set.seed(16)
dir.create("resultados/modelagem", recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Leitura dos dados
# -----------------------------------------------------------------------------
d <- read.csv("dados/base_analitica.csv")

# Escopo do modelo: municípios com 20 mil habitantes ou mais (1.710, 84% da população).
# Abaixo disso a taxa é dominada pelo acaso (poucos casos, muitos zeros): ver confiabilidade_porte.csv
d <- d[d$pop >= 20000, ]

# Ordem do código IBGE: municípios do mesmo estado ficam vizinhos na sequência (usado no Durbin-Watson)
d <- d[order(d$cod_ibge), ]

# Região: 5 classes -> 4 indicadoras, com o Sudeste como referência
# Estado (UF) como variável categórica: 27 classes -> 26 indicadoras, com SP como referência.
# Absorve diferenças entre estados (polícia, facções) que deixavam resíduos de vizinhos parecidos
d$uf <- relevel(factor(d$uf), ref = "SP")

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
f_base <- ~ log_rend + desig + desocup + pct_urbana + log_dens + pct_negra + pct_h1529 +
  faixa_fronteira + pct_indet + uf

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
m_colin <- lm(ly ~ log_rend + pct_pobres + alfabet + desig + desocup + pct_urbana + log_dens +
                pct_negra + pct_h1529 + faixa_fronteira + pct_indet + uf, data = d)
summary(m_colin)

# Para a região (4 indicadoras) o car devolve o GVIF; GVIF^(1/(2*gl)) ao quadrado fica na escala do VIF
vif_colin <- vif(m_colin)[, "GVIF^(1/(2*Df))"]^2

# Mantemos só a renda. O termo quadrático usa a renda centralizada, para reduzir a correlação entre X e X²
d$rend_c  <- d$log_rend - mean(d$log_rend)
d$rend_c2 <- d$rend_c^2
cor_quad <- c(sem_centrar = cor(d$log_rend, d$log_rend^2), centrado = cor(d$rend_c, d$rend_c2))

# -----------------------------------------------------------------------------
# 4. Construção em blocos: somas de quadrados extras e teste F parcial
# -----------------------------------------------------------------------------
mA <- lm(ly ~ rend_c + rend_c2 + desig + desocup, data = d)                    # socioeconômico
mB <- update(mA, . ~ . + pct_urbana + log_dens + pct_negra + pct_h1529)         # + demografia
mC <- update(mB, . ~ . + faixa_fronteira + pct_indet)                           # + contexto
mD <- update(mC, . ~ . + uf)                                                    # + estado
# Amazônia Legal fica de fora: com o estado no modelo ela só varia dentro do Maranhão

# Região x estado: a região é agregação dos estados (modelos aninhados)
mD_regiao <- update(mC, . ~ . + regiao)

anova_blocos <- anova(mA, mB, mC, mD)
anova_blocos
write.csv(as.data.frame(anova_blocos), "resultados/modelagem/anova_blocos.csv")

# F parcial do termo quadrático (Ho: beta_renda² = 0) e da interação (Ho: os 4 coeficientes = 0)
F_quad  <- anova(update(mD, . ~ . - rend_c2), mD)
F_uf <- anova(mD_regiao, mD)        # Ho: os estados não acrescentam nada além da região

comp <- data.frame(
  modelo = c("A socioeconômico", "B + demografia", "C + contexto", "D + estado", "D com região"),
  p   = sapply(list(mA, mB, mC, mD, mD_regiao), function(m) length(coef(m)) - 1),
  R2  = sapply(list(mA, mB, mC, mD, mD_regiao), function(m) summary(m)$r.squared),
  R2a = sapply(list(mA, mB, mC, mD, mD_regiao), function(m) summary(m)$adj.r.squared),
  MSE = sapply(list(mA, mB, mC, mD, mD_regiao), function(m) summary(m)$sigma^2),
  DW  = sapply(list(mA, mB, mC, mD, mD_regiao), function(m) unname(dwtest(m)$statistic)))
write.csv(comp, "resultados/modelagem/comparacao_blocos.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 5. Modelo preliminar (D): teste F global, coeficientes e intervalos de confiança
# -----------------------------------------------------------------------------
final <- mD
sf_ <- summary(final)
sf_
anova(final)
ic <- confint(final, level = 0.95)
vif_final <- vif(final)[, "GVIF^(1/(2*Df))"]^2

coefs <- data.frame(termo = rownames(sf_$coefficients), sf_$coefficients, ic, row.names = NULL)
names(coefs) <- c("termo", "b", "ep", "t", "p", "ic_inf", "ic_sup")
write.csv(coefs, "resultados/modelagem/coeficientes.csv", row.names = FALSE)

# Renda em que a taxa esperada é máxima: derivada b1 + 2 b2 rend_c = 0
b <- coef(final)
pico_renda <- exp(mean(d$log_rend) - b["rend_c"] / (2 * b["rend_c2"]))

# Efeitos na escala da taxa: com ln(taxa), uma mudança delta em X multiplica a taxa por exp(b * delta)
mudancas <- data.frame(
  termo   = c("desig", "pct_urbana", "pct_negra", "log_dens", "desocup", "pct_indet", "pct_h1529", "faixa_fronteira"),
  variavel = c("Desigualdade", "% urbana", "% preta ou parda", "Densidade", "Desocupação",
               "% intenção indeterminada", "% homens 15–29", "Faixa de fronteira"),
  mudanca = c("+0,1", "+10 pontos", "+10 pontos", "dobra", "+1 ponto", "+1 ponto", "+1 ponto", "sim x não"),
  delta   = c(0.1, 10, 10, log(2), 1, 1, 1, 1))
mudancas$b <- b[mudancas$termo]
mudancas$p <- sf_$coefficients[mudancas$termo, 4]
mudancas$efeito_pct <- 100 * (exp(mudancas$b * mudancas$delta) - 1)
mudancas$ic_inf_pct <- 100 * (exp(ic[mudancas$termo, 1] * mudancas$delta) - 1)
mudancas$ic_sup_pct <- 100 * (exp(ic[mudancas$termo, 2] * mudancas$delta) - 1)
write.csv(mudancas, "resultados/modelagem/efeitos_percentuais.csv", row.names = FALSE)

# Gráfico de efeito da renda: taxa esperada (IC 95%) ao longo da renda, demais variáveis na média
# (fronteira = não, estado = SP, a referência). O nível depende do estado; a forma não.
grade <- data.frame(rend = exp(seq(quantile(d$log_rend, .02), quantile(d$log_rend, .98), length.out = 100)))
grade$rend_c <- log(grade$rend) - mean(d$log_rend); grade$rend_c2 <- grade$rend_c^2
for (v in c("desig", "desocup", "pct_urbana", "log_dens", "pct_negra", "pct_h1529", "pct_indet")) grade[[v]] <- mean(d[[v]])
grade$faixa_fronteira <- 0
grade$uf <- factor("SP", levels = levels(d$uf))
pr <- predict(final, newdata = grade, interval = "confidence", level = 0.95)
grade$taxa <- exp(pr[, "fit"]); grade$lo <- exp(pr[, "lwr"]); grade$hi <- exp(pr[, "upr"])

# -----------------------------------------------------------------------------
# 6. Diagnóstico preliminar pela análise dos resíduos
# -----------------------------------------------------------------------------
d$ajustado <- fitted(final)
d$residuo  <- residuals(final)
d$res_semi <- d$residuo / sqrt(sum(d$residuo^2) / final$df.residual)    # e* = e / sqrt(MSE)

bp <- bptest(final)                                   # Ho: variância constante
dw <- dwtest(final, alternative = "two.sided")        # Ho: erros não correlacionados
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

# M2. Resíduos x ajustados e gráfico de quantis: Y original x √Y
dd <- rbind(data.frame(m = "Y (taxa original)", fit = fitted(m_y), es = rstandard(m_y)),
            data.frame(m = "ln Y", fit = fitted(m_log), es = rstandard(m_log)))
dd$m <- factor(dd$m, levels = c("Y (taxa original)", "ln Y"))
p <- ggplot(dd, aes(fit, es)) + geom_point(size = .5, alpha = .25, colour = AZUL) +
  geom_hline(yintercept = 0, colour = CINZA, linetype = 2) + facet_wrap(~m, scales = "free_x") +
  labs(x = "Valor ajustado", y = "Resíduo padronizado") + th
ggsave("resultados/modelagem/m2a_residuos_y_transformada.png", p, width = 6.4, height = 2.6, dpi = 220)
p <- ggplot(dd, aes(sample = es)) + stat_qq(size = .5, alpha = .3, colour = AZUL) +
  stat_qq_line(colour = VERMELHO) + facet_wrap(~m) +
  labs(x = "Quantis teóricos (dist. normal)", y = "Quantis amostrais") + th
ggsave("resultados/modelagem/m2b_qq_y_transformada.png", p, width = 6.4, height = 2.6, dpi = 220)

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
  labs(x = "População (escala log)", y = "|resíduo|") + th
ggsave("resultados/modelagem/m4_residuo_pop.png", p, width = 6.4, height = 2.6, dpi = 220)

# M5. Histograma e gráfico de quantis dos resíduos padronizados
p <- ggplot(d, aes(rstandard(final))) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, fill = AZUL, colour = FUNDO, linewidth = .15) +
  labs(x = "Resíduo padronizado", y = "Densidade") + th
ggsave("resultados/modelagem/m5a_hist_residuos.png", p, width = 3.2, height = 2.6, dpi = 220)
p <- ggplot(d, aes(sample = rstandard(final))) + stat_qq(size = .5, alpha = .3, colour = AZUL) +
  stat_qq_line(colour = VERMELHO) + labs(x = "Quantis teóricos (dist. normal)", y = "Quantis amostrais") + th
ggsave("resultados/modelagem/m5b_qq_final.png", p, width = 3.2, height = 2.6, dpi = 220)

# M6. Resíduos em sequência (ordem do código IBGE), por região
d$ordem <- seq_len(nrow(d))
d$regiao_nome <- factor(d$regiao, levels = c("N", "NE", "CO", "SE", "S"),
                        labels = c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul"))
p <- ggplot(d, aes(ordem, residuo, colour = regiao_nome)) + geom_point(size = .4, alpha = .4) +
  geom_hline(yintercept = 0, colour = CINZA, linetype = 2) +
  labs(x = "Municípios em ordem de código IBGE", y = "Resíduo", colour = "Região") + th
ggsave("resultados/modelagem/m6_residuos_sequencia.png", p, width = 6.4, height = 2.6, dpi = 220)

# M7. Efeito da renda previsto pelo modelo (curva em U invertido, com IC 95% da resposta esperada)
p <- ggplot(grade, aes(rend, taxa)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = CLARO) +
  geom_line(colour = AZUL, linewidth = 1) +
  geom_vline(xintercept = pico_renda, colour = VERMELHO, linetype = 2) +
  annotate("text", x = pico_renda * 1.05, y = max(grade$hi), hjust = 0, vjust = 1, size = 3.5, colour = VERMELHO,
           label = paste0("pico: R$ ", milhar(round(pico_renda)))) +
  scale_x_log10(labels = milhar) +
  labs(x = "Renda per capita (R$, escala log)", y = "Taxa esperada (/100 mil)") + th
ggsave("resultados/modelagem/m7_efeito_renda.png", p, width = 4.8, height = 3.0, dpi = 250)

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
cat(sprintf("F parcial estado além da região: F = %.2f (gl %d) | p = %.2g\n", F_uf$F[2], F_uf$Df[2], F_uf$`Pr(>F)`[2]))
cat("\nR² e R² ajustado por bloco:\n"); print(comp, digits = 4, row.names = FALSE)
cat("\n== 5. Modelo preliminar (D) ==\n"); print(sf_)
cat("Intervalos de confiança 95%:\n"); print(round(ic, 4))
cat("\nVIF do modelo preliminar:\n"); print(round(vif_final, 2))
cat(sprintf("Renda per capita do pico da taxa esperada: R$ %.0f\n", pico_renda))
cat("\n== 6. Diagnóstico ==\n")
cat(sprintf("Breusch-Pagan = %.1f (gl %d) | p = %.2g\n", bp$statistic, bp$parameter, bp$p.value))
cat(sprintf("Durbin-Watson = %.3f | p = %.2g\n", dw$statistic, dw$p.value))
cat(sprintf("Shapiro-Wilk = %.3f | p = %.2g\n", sw_final$statistic, sw_final$p.value))
cat(sprintf("Possíveis outliers (|e*| >= 4): %d\n", nrow(outliers))); print(outliers, row.names = FALSE)
sink()
cat(readLines("resultados/modelagem/valores_modelo.txt"), sep = "\n")
