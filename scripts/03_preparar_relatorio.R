# =============================================================================
# 03 - Base do relatório (relatorio/relatorio.qmd)
# Entradas: dados/tabelas/base_analitica.csv (script 01)
#           dados/tabelas/sidra_10300.csv (classes de renda, script 01)
#           dados/tabelas/candidatas.csv (script 02)
#           dados/raw/ibge_recortes_territoriais_2022.xlsx (script 00, parte "relatorio")
# Saída:    dados/tabelas/base_relatorio.csv
# Calcula o Gini agrupado, junta as variáveis candidatas e os recortes
# territoriais (RM/RIDE e concentração urbana) e cria ln_taxa, tem_presidio e porte.
# =============================================================================

rm(list = ls())

# Roda a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")

library(readxl)
source("scripts/funcoes_desigualdade.R")

base <- read.csv("dados/tabelas/base_analitica.csv")
income_classes <- read.csv("dados/tabelas/sidra_10300.csv", colClasses = "character")
extras <- read.csv("dados/tabelas/candidatas.csv")

# Gini agrupado (classe aberta = 30 SM); mais o Gini com a classe aberta em 20 e 40 SM (sensibilidade)
counts <- class_counts(income_classes)
ineq <- data.frame(cod_ibge = as.numeric(income_classes$cod_ibge),
                   gini = apply(counts, 1, function(n) grouped_ineq(n, mids)[["gini"]]))
ineq$gini_top20 <- apply(counts, 1, function(n) grouped_ineq(n, replace(mids, 11, 20))[["gini"]])
ineq$gini_top40 <- apply(counts, 1, function(n) grouped_ineq(n, replace(mids, 11, 40))[["gini"]])

# Região metropolitana ou RIDE (definição em lei estadual) e concentração urbana (definição técnica do IBGE)
rec <- as.data.frame(read_excel("dados/raw/ibge_recortes_territoriais_2022.xlsx", sheet = 1, col_types = "text"))
rec <- data.frame(cod_ibge = as.numeric(rec$CD_MUN), rm_ride = as.integer(!is.na(rec$COD_CATMETROPOL)),
                  conc_urb = as.integer(!is.na(rec$CodConcUrbana)))

# Checagens: todo município da base precisa ter par nas três fontes, sem códigos repetidos
extra_cols <- c("cod_ibge", "pct_presos", "pct_maes_solo", "pct_informal", "ln_pib_pc", "gini_2010")
unmatched <- c(classes_10300 = sum(!base$cod_ibge %in% ineq$cod_ibge),
               candidatas = sum(!base$cod_ibge %in% extras$cod_ibge),
               recortes = sum(!base$cod_ibge %in% rec$cod_ibge))
if (any(unmatched > 0)) stop("Municípios sem par: ", paste(names(unmatched), unmatched, sep = " = ", collapse = ", "))

d <- merge(merge(merge(base, ineq, by = "cod_ibge"), extras[extra_cols], by = "cod_ibge"), rec, by = "cod_ibge")
if (nrow(d) != nrow(base) || anyDuplicated(d$cod_ibge)) stop("A junção mudou o número de municípios ou repetiu códigos")

d$ln_taxa <- ifelse(d$taxa > 0, log(d$taxa), NA)
d$tem_presidio <- as.integer(d$pct_presos > 0)
d$porte <- as.character(cut(d$pop, c(0, 1e4, 2e4, 5e4, 1e5, Inf), right = FALSE,
                            labels = c("<10 mil", "10–20 mil", "20–50 mil", "50–100 mil", "100 mil+")))

write.csv(d, "dados/tabelas/base_relatorio.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("Base do relatório: %d municípios x %d colunas; células '-' lidas como zero nas classes de renda: %d\n",
            nrow(d), ncol(d), sum(as.matrix(income_classes[class_cols]) == "-")))
