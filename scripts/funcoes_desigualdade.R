# =============================================================================
# Desigualdade a partir das classes de renda do Censo 2022 (SIDRA 10300)
# Usado por relatorio/relatorio.qmd (curvas de Lorenz e soma das classes por UF). O Gini da base
# analítica é calculado do mesmo jeito em scripts/01_preparar_dados.R
# =============================================================================

# Colunas das 11 classes de rendimento domiciliar per capita (pessoas de 14 anos ou mais)
class_cols <- c("p14_sem_rendimento", "p14_ate_1_4sm", "p14_1_4_a_1_2sm", "p14_1_2_a_1sm", "p14_1_a_2sm",
                "p14_2_a_3sm", "p14_3_a_5sm", "p14_5_a_10sm", "p14_10_a_15sm", "p14_15_a_20sm", "p14_mais_20sm")

# Ponto médio de cada classe, em salários mínimos; a classe aberta (> 20 SM) recebe 50 SM,
# valor com que o cálculo reproduz o Gini oficial do Brasil (como em scripts/01_preparar_dados.R)
mids <- c(0, 0.125, 0.375, 0.75, 1.5, 2.5, 4, 7.5, 12.5, 17.5, 50)

# Matriz de contagens (municípios x classes). No SIDRA, "-" é zero absoluto
class_counts <- function(classes) {
  to_num <- function(x) { x[x %in% c("-", "", "...", "X")] <- "0"; as.numeric(x) }
  sapply(class_cols, function(k) to_num(as.character(classes[[k]])))
}

# Gini pela curva de Lorenz ligada por retas (Gastwirth, 1972)
grouped_ineq <- function(n, mids) {
  p <- n / sum(n); inc <- p * mids
  L <- c(0, cumsum(inc) / sum(inc)); P <- c(0, cumsum(p))
  c(gini = 1 - sum(diff(P) * (head(L, -1) + tail(L, -1))))
}
