# =============================================================================
# Checagem de robustez: regressão binomial negativa para as contagens
# A regressão linear para a raiz da taxa é uma aproximação (há muitos zeros).
# Aqui ajustamos o modelo próprio para contagens, com as mesmas variáveis,
# e comparamos sinais e significância com o modelo final (MQP).
# Entradas: dados/tabelas/base_analitica.csv, resultados/modelagem/coeficientes_mqo_mqp.csv
# Saídas:   resultados/robustez/
# =============================================================================
# Rodar a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")
options(width = 200)
FONTE <- tryCatch(if ("Inter" %in% systemfonts::system_fonts()$family) "Inter" else "sans", error = function(e) "sans")
suppressMessages({ library(MASS); library(dplyr) })
dir.create("resultados/robustez", recursive = TRUE, showWarnings = FALSE)

d <- read.csv("dados/tabelas/base_analitica.csv")
d$regiao <- relevel(factor(d$regiao), ref = "SE")
d$rend_c  <- d$log_rend - mean(d$log_rend)
d$rend_c2 <- d$rend_c^2

f <- hom ~ rend_c + rend_c2 + desig + desocup + pct_urbana + log_dens + pct_negra + pct_h1529 +
  amazonia_legal + faixa_fronteira + pct_indet + regiao + offset(log(exposure))
nb <- glm.nb(f, data = d)
pois <- glm(f, data = d, family = poisson)

s <- summary(nb)$coefficients
ci <- suppressMessages(confint.default(nb))
tab <- data.frame(termo = rownames(s), b_nb = s[, 1], ep = s[, 2], z = s[, 3], p_nb = s[, 4],
                  irr = exp(s[, 1]), irr_lo = exp(ci[, 1]), irr_hi = exp(ci[, 2]), row.names = NULL)

mqp <- read.csv("resultados/modelagem/coeficientes_mqo_mqp.csv")
mqp <- mqp[mqp$modelo == "MQP", c("termo", "b", "p")]; names(mqp) <- c("termo", "b_mqp", "p_mqp")
cmp <- merge(tab, mqp, by = "termo", sort = FALSE)
cmp$mesmo_sinal <- sign(cmp$b_nb) == sign(cmp$b_mqp)
cmp$mesma_signif_5pct <- (cmp$p_nb < .05) == (cmp$p_mqp < .05)
write.csv(cmp, "resultados/robustez/binomial_negativa_vs_mqp.csv", row.names = FALSE)

sink("resultados/robustez/valores_robustez.txt")
cat("ROBUSTEZ — binomial negativa (contagem de homicídios, offset = log pessoas-ano)\n\n")
cat(sprintf("n = %d | theta = %.2f | AIC NB = %.0f | AIC Poisson = %.0f\n", nrow(d), nb$theta, AIC(nb), AIC(pois)))
cat(sprintf("Superdispersão no Poisson (qui² de Pearson / gl): %.2f\n",
            sum(residuals(pois, type = "pearson")^2) / pois$df.residual))
cat(sprintf("Pseudo-R² de McFadden (NB vs. só intercepto): %.3f\n\n",
            1 - as.numeric(logLik(nb)) / as.numeric(logLik(glm.nb(hom ~ 1 + offset(log(exposure)), data = d)))))
print(format(cmp[, c("termo", "irr", "irr_lo", "irr_hi", "p_nb", "b_mqp", "p_mqp", "mesmo_sinal", "mesma_signif_5pct")],
             digits = 3), row.names = FALSE)
cat(sprintf("\nTermos com o mesmo sinal: %d de %d | mesma conclusão a 5%%: %d de %d\n",
            sum(cmp$mesmo_sinal), nrow(cmp), sum(cmp$mesma_signif_5pct), nrow(cmp)))
sink()
cat(readLines("resultados/robustez/valores_robustez.txt"), sep = "\n")
