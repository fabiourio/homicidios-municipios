# =============================================================================
# Fatores associados aos homicídios nos municípios brasileiros — modelagem
# Entradas: dados/tabelas/base_analitica.csv, dados/malha_mun.geojson | Saídas: resultados/modelagem/
# =============================================================================
# Rodar a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")
options(width = 200)
FONTE <- tryCatch(if ("Inter" %in% systemfonts::system_fonts()$family) "Inter" else "sans", error = function(e) "sans")
suppressMessages({
  library(MASS); library(car); library(lmtest); library(leaps)
  library(ggplot2); library(dplyr); library(sf); library(spdep)
})
set.seed(16)
dir.create("resultados/modelagem", recursive = TRUE, showWarnings = FALSE)
res <- list()                                 # números citados no relatório

# --------------------------------------------------------------------------
# Dados
# --------------------------------------------------------------------------
d <- read.csv("dados/tabelas/base_analitica.csv")
vars <- c("log_rend", "desig", "desocup", "pct_urbana", "log_dens", "pct_negra",
          "pct_h1529", "pct_pobres", "alfabet", "pct_indet")
d <- d[complete.cases(d[, c(vars, "pop", "taxa")]), ]
d$regiao <- relevel(factor(d$regiao), ref = "SE")       # c-1 dummies, base Sudeste
d$y  <- d$taxa                                          # homicídios /100 mil/ano (2021–23)
res$n <- nrow(d); res$zeros <- sum(d$y == 0)

# --------------------------------------------------------------------------
# RLS, resíduos e Box-Cox
# --------------------------------------------------------------------------
rls <- lm(y ~ log_rend, d)
res$rls_r2 <- summary(rls)$r.squared

f1 <- ~ log_rend + desig + desocup + pct_urbana + log_dens + pct_negra + pct_h1529 +
        amazonia_legal + faixa_fronteira + pct_indet + regiao
m_bruto <- lm(update(f1, y ~ .), d)
bc <- boxcox(lm(update(f1, I(y + 1) ~ .), d), lambda = seq(-0.5, 1.2, 0.01), plotit = FALSE)
res$lambda <- bc$x[which.max(bc$y)]
ci_l <- bc$x[bc$y > max(bc$y) - qchisq(0.95, 1) / 2]
res$lambda_ic <- range(ci_l)
d$ys <- sqrt(d$y)                                        # λ = 1/2 (interpretável)

sw <- function(m) shapiro.test(sample(rstandard(m), 5000))   # shapiro.test aceita n ≤ 5000
m_sqrt <- lm(update(f1, ys ~ .), d)
res$diag_bruto <- c(SW = unname(sw(m_bruto)$statistic), BP = unname(bptest(m_bruto)$statistic))
res$diag_sqrt  <- c(SW = unname(sw(m_sqrt)$statistic),  BP = unname(bptest(m_sqrt)$statistic))

# --------------------------------------------------------------------------
# multicolinearidade (VIF) — renda, pobreza e alfabetização juntas
# --------------------------------------------------------------------------
m_colin <- lm(ys ~ log_rend + pct_pobres + alfabet + desig + desocup + pct_urbana +
                log_dens + pct_negra + pct_h1529 + amazonia_legal + faixa_fronteira +
                pct_indet + regiao, d)
vif_colin <- vif(m_colin)[, "GVIF^(1/(2*Df))"]^2
res$cor_rend_pobres <- cor(d$log_rend, d$pct_pobres)
res$cor_rend_alf    <- cor(d$log_rend, d$alfabet)
write.csv(data.frame(var = names(vif_colin), vif = round(vif_colin, 2)), "resultados/modelagem/vif_com_colinearidade.csv", row.names = FALSE)

# --------------------------------------------------------------------------
# termo quadrático centrado (hierarquia) e interação
# --------------------------------------------------------------------------
d$rend_c  <- d$log_rend - mean(d$log_rend)               # centralização reduz colinearidade
d$rend_c2 <- d$rend_c^2
res$cor_lin_quad_sem_centrar <- cor(d$log_rend, d$log_rend^2)
res$cor_lin_quad_centrado    <- cor(d$rend_c, d$rend_c2)

# Blocos aninhados para somas de quadrados extras 
mA <- lm(ys ~ rend_c + rend_c2 + desig + desocup, d)                                  # socioeconômico
mB <- update(mA, . ~ . + pct_urbana + log_dens + pct_negra + pct_h1529)               # + demografia
mC <- update(mB, . ~ . + amazonia_legal + faixa_fronteira + pct_indet)                # + contexto
mD <- update(mC, . ~ . + regiao)                                                      # + região (dummies)
mE <- update(mD, . ~ . + rend_c:regiao)                                               # + interação renda×região
anova_blocos <- anova(mA, mB, mC, mD, mE)
write.csv(as.data.frame(anova_blocos), "resultados/modelagem/anova_blocos.csv")

# Teste F parcial do termo quadrático (H0: β_rend² = 0)
mD_sem_quad <- update(mD, . ~ . - rend_c2)
res$F_quad <- anova(mD_sem_quad, mD)$F[2]

# --------------------------------------------------------------------------
# seleção de variáveis (Cp, R²a, BIC, stepwise, PRESS)
# --------------------------------------------------------------------------
X <- model.matrix(mE)[, -1]
rs <- regsubsets(x = X, y = d$ys, nvmax = ncol(X), method = "exhaustive", really.big = TRUE)
srs <- summary(rs)
sel <- data.frame(p = seq_along(srs$cp), R2 = srs$rsq, R2a = srs$adjr2, Cp = srs$cp, BIC = srs$bic)
write.csv(sel, "resultados/modelagem/selecao_todos_subconjuntos.csv", row.names = FALSE)
res$p_bic <- which.min(srs$bic); res$p_cp <- which(srs$cp <= seq_along(srs$cp) + 1 + 0)[1]
res$vars_bic <- names(which(srs$which[res$p_bic, -1]))

step_both <- step(lm(ys ~ 1, d), scope = formula(mE), direction = "both", trace = 0)
res$step_vars <- attr(terms(step_both), "term.labels")
press <- function(m) sum((residuals(m) / (1 - hatvalues(m)))^2)
comp <- data.frame(
  modelo = c("A socioeconômico", "B + demografia", "C + contexto", "D + região", "E + interação"),
  p = sapply(list(mA, mB, mC, mD, mE), function(m) length(coef(m)) - 1),
  R2 = sapply(list(mA, mB, mC, mD, mE), function(m) summary(m)$r.squared),
  R2a = sapply(list(mA, mB, mC, mD, mE), function(m) summary(m)$adj.r.squared),
  AIC = sapply(list(mA, mB, mC, mD, mE), AIC),
  BIC = sapply(list(mA, mB, mC, mD, mE), BIC),
  PRESS = sapply(list(mA, mB, mC, mD, mE), press))
MSE_full <- summary(mE)$sigma^2
comp$Cp <- sapply(list(mA, mB, mC, mD, mE), function(m) sum(residuals(m)^2) / MSE_full + 2 * (length(coef(m))) - nrow(d))
write.csv(comp, "resultados/modelagem/comparacao_modelos.csv", row.names = FALSE)

# --------------------------------------------------------------------------
# Modelo escolhido (D) — inferência MQO
# --------------------------------------------------------------------------
final <- mD
sf_ <- summary(final)
res$F_global <- sf_$fstatistic; res$R2 <- sf_$r.squared; res$R2a <- sf_$adj.r.squared
res$vif_final <- vif(final)
res$vif_final_max <- max(res$vif_final[, "GVIF^(1/(2*Df))"]^2)

# --------------------------------------------------------------------------
# diagnóstico do modelo final
# --------------------------------------------------------------------------
d$fit <- fitted(final); d$e <- residuals(final); d$es <- rstandard(final)
res$sw_final <- sw(final)$statistic
res$bp_final <- bptest(final)
res$bp_pop   <- bptest(final, ~ log(pop), data = d)               # variância cai com a população?
res$outliers <- sum(abs(d$e / sf_$sigma) >= 4)

# Independência espacial (análogo espacial do Durbin-Watson): I de Moran dos resíduos
g <- st_read("dados/malha_mun.geojson", quiet = TRUE)
g$cod_ibge <- as.integer(g$codarea)
gd <- inner_join(g, d, by = "cod_ibge")
nb <- poly2nb(gd, queen = TRUE); lw <- nb2listw(nb, style = "W", zero.policy = TRUE)
res$moran_y   <- moran.test(gd$ys, lw, zero.policy = TRUE)
res$moran_res <- moran.test(gd$e, lw, zero.policy = TRUE)

# --------------------------------------------------------------------------
# medida corretiva — mínimos quadrados ponderados (MQP)
#   Var(√taxa) ≈ a + b/pop  (municípios pequenos têm taxas muito mais instáveis)
#   Passo 1: estimar a, b regredindo e² em 1/pop;  Passo 2: pesos w = 1/(a + b/pop)
# --------------------------------------------------------------------------
vf <- lm(I(e^2) ~ I(1 / pop), d)
a <- coef(vf)[1]; b <- coef(vf)[2]
res$var_fun <- c(a = unname(a), b = unname(b))
d$w <- 1 / pmax(a + b / d$pop, 1e-6)
wls <- lm(formula(final), d, weights = w)
d$ew <- residuals(wls) * sqrt(d$w)
res$bp_wls_pop <- bptest(lm(I(ew^2) ~ log(pop), d))   # auxiliar BP nos resíduos ponderados
aux_ols <- summary(lm(I(e^2) ~ log(pop), d))$r.squared * nrow(d)
aux_wls <- summary(lm(I(ew^2) ~ log(pop), d))$r.squared * nrow(d)
res$bp_lm_ols <- aux_ols; res$bp_lm_wls <- aux_wls
res$R2_wls <- summary(wls)$r.squared

coefs <- function(m, nome) {
  ci <- confint(m); s <- summary(m)$coefficients
  data.frame(modelo = nome, termo = rownames(s), b = s[, 1], ep = s[, 2], t = s[, 3], p = s[, 4],
             lo = ci[, 1], hi = ci[, 2], row.names = NULL)
}
tab <- rbind(coefs(final, "MQO"), coefs(wls, "MQP"))

# Coeficientes padronizados : b* = b · s_X / s_Y — só contínuas
cont <- c("rend_c", "desig", "desocup", "pct_urbana", "log_dens", "pct_negra", "pct_h1529", "pct_indet")
tab$b_pad <- NA
for (v in cont) for (mm in c("MQO", "MQP")) {
  i <- tab$modelo == mm & tab$termo == v; tab$b_pad[i] <- tab$b[i] * sd(d[[v]]) / sd(d$ys)
}
# Efeito na escala da taxa: d taxa/dX = 2·√ŷ·b, avaliado na média de √ŷ
mfit <- mean(fitted(wls))
tab$efeito_taxa_1dp <- NA
for (v in cont) { i <- tab$termo == v; tab$efeito_taxa_1dp[i] <- 2 * mfit * tab$b[i] * sd(d[[v]]) }
write.csv(tab, "resultados/modelagem/coeficientes_mqo_mqp.csv", row.names = FALSE)

# Pico do U invertido da renda (MQP): rend_c* = -b1 / (2 b2)
bw <- coef(wls)
res$pico_renda <- exp(mean(d$log_rend) - bw["rend_c"] / (2 * bw["rend_c2"]))

# --------------------------------------------------------------------------
# Validação: PRESS  e previsão de 2024 (fora da amostra)
# --------------------------------------------------------------------------
v <- d[d$pop >= 50000, ]
pv <- pmax(predict(wls, v), 0)^2
res$val_n <- nrow(v)
res$val_rho_modelo  <- cor(pv, v$taxa_24, method = "spearman")
res$val_rho_ingenuo <- cor(v$taxa, v$taxa_24, method = "spearman")
res$val_mae_modelo  <- mean(abs(pv - v$taxa_24))
res$val_mae_ingenuo <- mean(abs(v$taxa - v$taxa_24))

# --------------------------------------------------------------------------
# Figuras (mesma paleta do V0)
# --------------------------------------------------------------------------
INK <- "#0b0b0b"; INK2 <- "#52514e"; MUTED <- "#898781"; GRID <- "#e6e5e0"; SURF <- "#fcfcfb"
BLUE <- "#2a78d6"; RED <- "#e34948"
th <- theme_minimal(base_family = FONTE, base_size = 9) +
  theme(plot.background = element_rect(fill = SURF, colour = NA), panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = GRID, linewidth = .3), axis.text = element_text(colour = MUTED),
        axis.title = element_text(colour = INK2), plot.title = element_text(colour = INK, size = 9.5, face = "bold"))
br <- function(x) format(x, decimal.mark = ",", big.mark = ".")

# F1. Box-Cox
p1 <- ggplot(data.frame(l = bc$x, ll = bc$y), aes(l, ll)) + geom_line(colour = BLUE, linewidth = .9) +
  geom_vline(xintercept = res$lambda, colour = MUTED, linetype = 2) +
  geom_vline(xintercept = 0.5, colour = RED, linewidth = .6) +
  annotate("text", x = res$lambda - .03, y = min(bc$y) + .1 * diff(range(bc$y)), hjust = 1, size = 3, colour = INK2,
           label = paste0("λ ótimo = ", br(round(res$lambda, 2)))) +
  annotate("text", x = .53, y = min(bc$y) + .1 * diff(range(bc$y)), hjust = 0, size = 3, colour = RED, label = "λ = 0,5 (√Y)") +
  labs(x = "λ", y = "Log-verossimilhança") + th
ggsave("resultados/modelagem/f1_boxcox.png", p1, width = 6.2, height = 2.6, dpi = 220)

# F2. Diagnóstico: resíduos × ajustados e QQ (bruto vs √)
dd <- rbind(data.frame(m = "Y (taxa bruta)", fit = fitted(m_bruto), es = rstandard(m_bruto)),
            data.frame(m = "√Y (Box-Cox)", fit = fitted(m_sqrt), es = rstandard(m_sqrt)))
dd$m <- factor(dd$m, levels = c("Y (taxa bruta)", "√Y (Box-Cox)"))
p2a <- ggplot(dd, aes(fit, es)) + geom_point(size = .5, alpha = .25, colour = BLUE) +
  geom_hline(yintercept = 0, colour = MUTED, linetype = 2) + facet_wrap(~m, scales = "free_x") +
  labs(x = "Valor ajustado", y = "Resíduo padronizado") + th
ggsave("resultados/modelagem/f2a_residuos.png", p2a, width = 6.4, height = 2.6, dpi = 220)
p2b <- ggplot(dd, aes(sample = es)) + stat_qq(size = .5, alpha = .3, colour = BLUE) +
  stat_qq_line(colour = RED) + facet_wrap(~m) + labs(x = "Quantil teórico N(0,1)", y = "Resíduo padronizado") + th
ggsave("resultados/modelagem/f2b_qq.png", p2b, width = 6.4, height = 2.6, dpi = 220)

# F3. Heteroscedasticidade: |e| × população, antes e depois do MQP
hh <- rbind(data.frame(m = "MQO", pop = d$pop, r = abs(d$e) / sd(d$e)),
            data.frame(m = "MQP (resíduo ponderado)", pop = d$pop, r = abs(d$ew) / sd(d$ew)))
p3 <- ggplot(hh, aes(pop, r)) + geom_point(size = .5, alpha = .2, colour = BLUE) +
  geom_smooth(method = "loess", se = FALSE, colour = RED, linewidth = .7, formula = y ~ x) +
  scale_x_log10(labels = function(x) br(x)) + facet_wrap(~m) +
  labs(x = "População (escala log)", y = "|resíduo| / desvio-padrão") + th
ggsave("resultados/modelagem/f3_heterosc.png", p3, width = 6.4, height = 2.6, dpi = 220)

# F4. Coeficientes padronizados MQP com IC 95%
nomes <- c(rend_c = "Renda per capita (log, centrada)", rend_c2 = "Renda² (curvatura)", desig = "Desigualdade (média/mediana)",
           desocup = "Desocupação", pct_urbana = "% população urbana", log_dens = "Densidade (log)",
           pct_negra = "% preta ou parda", pct_h1529 = "% homens 15–29", amazonia_legal = "Amazônia Legal",
           faixa_fronteira = "Faixa de fronteira", pct_indet = "% intenção indeterminada",
           regiaoN = "Norte (vs. Sudeste)", regiaoNE = "Nordeste", regiaoCO = "Centro-Oeste", regiaoS = "Sul")
tw <- tab[tab$modelo == "MQP" & tab$termo != "(Intercept)", ]
sY <- sd(d$ys)
sX <- sapply(tw$termo, function(v) if (v %in% cont) sd(d[[v]]) else if (v == "rend_c2") sd(d$rend_c2) else 1)
tw$bs <- tw$b * sX / sY; tw$los <- tw$lo * sX / sY; tw$his <- tw$hi * sX / sY
tw$grupo <- ifelse(tw$termo %in% c(cont, "rend_c2"), "Contínuas: efeito de +1 dp de X, em dp de √Y",
                   "Indicadoras: efeito da categoria, em dp de √Y")
tw$nome <- factor(nomes[tw$termo], levels = rev(nomes))
tw$cor <- ifelse(tw$lo > 0, "pos", ifelse(tw$hi < 0, "neg", "ns"))
p4 <- ggplot(tw, aes(bs, nome, colour = cor)) + geom_vline(xintercept = 0, colour = MUTED, linetype = 2) +
  geom_errorbarh(aes(xmin = los, xmax = his), height = 0, linewidth = .9) + geom_point(size = 2) +
  geom_text(aes(x = his, label = format(round(bs, 2), decimal.mark = ",")), hjust = -0.25, size = 2.6, colour = INK2) +
  scale_colour_manual(values = c(pos = RED, neg = BLUE, ns = MUTED), guide = "none") +
  facet_grid(grupo ~ ., scales = "free", space = "free") +
  scale_x_continuous(expand = expansion(mult = c(.05, .15))) +
  labs(x = "Coeficiente padronizado (MQP) com IC 95%", y = NULL) + th +
  theme(strip.text.y = element_blank(), axis.text.y = element_text(colour = INK, size = 8.5))
ggsave("resultados/modelagem/f4_coef.png", p4, width = 6.4, height = 4.4, dpi = 220)

# F5. Mapa dos resíduos (independência espacial)
gd$e_cl <- pmax(pmin(gd$e / sd(gd$e), 3), -3)
p5 <- ggplot(gd) + geom_sf(aes(fill = e_cl), colour = NA) +
  scale_fill_gradient2(low = BLUE, mid = "#f0efec", high = RED, midpoint = 0, limits = c(-3, 3),
                       name = "Resíduo / dp") + theme_void(base_family = FONTE, base_size = 8) +
  theme(plot.background = element_rect(fill = SURF, colour = NA), legend.position = "bottom",
        legend.key.width = unit(1.2, "cm"), legend.key.height = unit(.25, "cm"))
ggsave("resultados/modelagem/f5_mapa_residuos.png", p5, width = 5, height = 5.3, dpi = 220)

# F6. Seleção de variáveis: Cp e BIC por tamanho
sl <- sel %>% mutate(pp1 = p + 1)
p6a <- ggplot(sl, aes(p, Cp)) + geom_abline(intercept = 1, slope = 1, colour = MUTED, linetype = 2) +
  geom_line(colour = BLUE) + geom_point(colour = BLUE, size = 1.5) + scale_y_log10() +
  labs(x = "Número de termos (p)", y = "Cp de Mallows (log)", title = "Cp  (linha: Cp = p + 1)") + th
p6b <- ggplot(sl, aes(p, BIC)) + geom_line(colour = BLUE) + geom_point(colour = BLUE, size = 1.5) +
  geom_point(data = sl[which.min(sl$BIC), ], colour = RED, size = 2.5) +
  labs(x = "Número de termos (p)", y = "BIC", title = "BIC (mínimo em vermelho)") + th
ggsave("resultados/modelagem/f6a_cp.png", p6a, width = 3.1, height = 2.5, dpi = 220)
ggsave("resultados/modelagem/f6b_bic.png", p6b, width = 3.1, height = 2.5, dpi = 220)

# Efeito das indicadoras na escala da taxa (mesma aproximação: ΔY ≈ 2·√Ŷ·b)
ind <- tab$modelo == "MQP" & tab$termo %in% c("amazonia_legal", "faixa_fronteira", "regiaoN", "regiaoNE", "regiaoCO", "regiaoS")
tab$efeito_taxa_categoria <- NA; tab$efeito_taxa_categoria[ind] <- 2 * mfit * tab$b[ind]
write.csv(tab, "resultados/modelagem/coeficientes_mqo_mqp.csv", row.names = FALSE)
saveRDS(list(res = res, comp = comp, anova = anova_blocos, vif_colin = vif_colin, tab = tab, sel = sel), "resultados/modelagem/resultados.rds")
capture.output({
  cat("== RLS ==\n"); print(summary(rls)$coefficients); cat("R2:", res$rls_r2, "\n")
  cat("\n== Box-Cox: lambda", res$lambda, "IC95", res$lambda_ic, "\n")
  cat("Diag bruto:", res$diag_bruto, " | sqrt:", res$diag_sqrt, "\n")
  cat("\n== VIF com colinearidade ==\n"); print(round(vif_colin, 2))
  cat("cor(rend,pobres)=", res$cor_rend_pobres, " cor(rend,alf)=", res$cor_rend_alf, "\n")
  cat("cor(X,X^2) sem centrar=", res$cor_lin_quad_sem_centrar, " centrado=", res$cor_lin_quad_centrado, "\n")
  cat("\n== ANOVA blocos (SQ extras / F parcial) ==\n"); print(anova_blocos)
  cat("F parcial quadrático:", res$F_quad, "\n")
  cat("\n== Comparação ==\n"); print(comp, digits = 4)
  cat("\nBIC (todos subconjuntos) p =", res$p_bic, ":", res$vars_bic, "\n")
  cat("Stepwise:", res$step_vars, "\n")
  cat("\n== Modelo final MQO ==\n"); print(sf_)
  cat("VIF final:\n"); print(res$vif_final)
  cat("\nSW final", res$sw_final, "\n"); print(res$bp_final); print(res$bp_pop)
  cat("outliers |e*|>=4:", res$outliers, "\n")
  print(res$moran_y); print(res$moran_res)
  cat("\n== MQP == var fun", res$var_fun, " LM OLS", res$bp_lm_ols, " LM WLS", res$bp_lm_wls, "\n")
  print(summary(wls))
  cat("pico renda", res$pico_renda, "\n")
  cat("valid n", res$val_n, "rho", res$val_rho_modelo, res$val_rho_ingenuo, "mae", res$val_mae_modelo, res$val_mae_ingenuo, "\n")
}, file = "resultados/modelagem/saida_completa.txt")

# Resumo legível dos principais valores
sink("resultados/modelagem/valores_principais.txt")
cat("MODELAGEM — valores principais\n==============================\n\n")
cat(sprintf("n = %d municípios | resposta: raiz da taxa de homicídios 2021–23\n", res$n))
cat(sprintf("Regressão simples (taxa ~ ln renda): R² = %.3f\n", res$rls_r2))
cat(sprintf("Box-Cox: lambda ótimo = %.2f (IC 95%%: %.2f a %.2f); adotado 0,5\n", res$lambda, res$lambda_ic[1], res$lambda_ic[2]))
cat(sprintf("Shapiro-Wilk: Y bruto W = %.3f | raiz W = %.3f\n", res$diag_bruto["SW"], res$diag_sqrt["SW"]))
cat(sprintf("Correlações: renda×pobres = %.2f | renda×alfabetização = %.2f\n", res$cor_rend_pobres, res$cor_rend_alf))
cat(sprintf("cor(X, X²): sem centrar = %.4f | centrado = %.4f\n", res$cor_lin_quad_sem_centrar, res$cor_lin_quad_centrado))
cat("\nVIF com renda, pobres e alfabetização juntas:\n"); print(round(vif_colin, 2))
cat(sprintf("\nVIF máximo do modelo final: %.2f\n", res$vif_final_max))
cat("\nTestes F parciais por bloco:\n"); print(anova_blocos)
cat(sprintf("\nF parcial do termo quadrático da renda: %.1f\n", res$F_quad))
cat("\nComparação de modelos:\n"); print(comp, digits = 4, row.names = FALSE)
cat(sprintf("\nMelhor subconjunto pelo BIC (%d termos): %s\n", res$p_bic, paste(res$vars_bic, collapse = ", ")))
cat(sprintf("Stepwise (AIC): %s\n", paste(res$step_vars, collapse = ", ")))
cat(sprintf("\nModelo final MQO: R² = %.3f | R²a = %.3f | F = %.1f (%d; %d gl)\n", res$R2, res$R2a,
            res$F_global[1], res$F_global[2], res$F_global[3]))
cat(sprintf("Shapiro-Wilk = %.3f | Breusch-Pagan = %.1f (p = %.2g) | BP contra ln(pop) = %.1f\n", res$sw_final,
            res$bp_final$statistic, res$bp_final$p.value, res$bp_pop$statistic))
cat(sprintf("Outliers |e*| >= 4: %d\n", res$outliers))
cat(sprintf("I de Moran: raiz da taxa = %.3f | resíduos = %.3f (p < 0,001)\n", res$moran_y$estimate[1], res$moran_res$estimate[1]))
cat(sprintf("\nMQP: Var(e) ≈ %.2f + %.0f/pop | BP contra ln(pop): %.1f → %.2f (p = %.2f)\n", res$var_fun["a"], res$var_fun["b"],
            res$bp_lm_ols, res$bp_wls_pop$statistic, res$bp_wls_pop$p.value))
sw_ <- summary(wls)
cat(sprintf("Modelo final MQP: R² = %.3f | R²a = %.3f | F = %.1f (%d; %d gl)\n", sw_$r.squared, sw_$adj.r.squared,
            sw_$fstatistic[1], sw_$fstatistic[2], sw_$fstatistic[3]))
cat(sprintf("Pico do U invertido da renda: R$ %.0f per capita | raiz média ajustada = %.2f\n", res$pico_renda, mfit))
cat("\nCoeficientes MQP (efeitos em homicídios por 100 mil/ano):\n")
x <- tab[tab$modelo == "MQP", c("termo", "b", "ep", "t", "p", "b_pad", "efeito_taxa_1dp", "efeito_taxa_categoria")]
print(format(x, digits = 3), row.names = FALSE)
cat(sprintf("\nValidação 2024 (municípios >= 50 mil hab., n = %d): Spearman modelo = %.2f | taxa passada = %.2f\n",
            res$val_n, res$val_rho_modelo, res$val_rho_ingenuo))
cat(sprintf("Erro absoluto médio: modelo = %.2f | taxa passada = %.2f\n", res$val_mae_modelo, res$val_mae_ingenuo))
sink()
cat(readLines("resultados/modelagem/valores_principais.txt"), sep = "\n")
