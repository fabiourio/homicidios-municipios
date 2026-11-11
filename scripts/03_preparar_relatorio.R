# =============================================================================
# 03 - Base do relatório (relatorio/relatorio.qmd)
# Entradas: dados/tabelas/base_analitica.csv (script 01)
#           dados/tabelas/candidatas.csv (script 02)
#           dados/raw/ibge_recortes_territoriais_2022.xlsx (script 00, parte "relatorio")
# Saída:    dados/tabelas/base_relatorio.csv
# Junta à base analítica (que já traz o Gini, calculado no script 01) as variáveis candidatas e os
# recortes territoriais (RM/RIDE e concentração urbana), e cria ln_taxa, tem_presidio e porte.
# =============================================================================

rm(list = ls())

# Roda a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")

library(readxl)

base <- read.csv("dados/tabelas/base_analitica.csv")
extras <- read.csv("dados/tabelas/candidatas.csv")

# Região metropolitana ou RIDE (definição em lei estadual) e concentração urbana (definição técnica do IBGE)
rec <- as.data.frame(read_excel("dados/raw/ibge_recortes_territoriais_2022.xlsx", sheet = 1, col_types = "text"))
rec <- data.frame(cod_ibge = as.numeric(rec$CD_MUN), rm_ride = as.integer(!is.na(rec$COD_CATMETROPOL)),
                  conc_urb = as.integer(!is.na(rec$CodConcUrbana)))

# Checagens: todo município da base precisa ter par nas três fontes, sem códigos repetidos
extra_cols <- c("cod_ibge", "pct_presos", "pct_maes_solo", "pct_informal", "ln_pib_pc", "gini_2010")
unmatched <- c(candidatas = sum(!base$cod_ibge %in% extras$cod_ibge),
               recortes = sum(!base$cod_ibge %in% rec$cod_ibge))
if (any(unmatched > 0)) stop("Municípios sem par: ", paste(names(unmatched), unmatched, sep = " = ", collapse = ", "))

d <- merge(merge(base, extras[extra_cols], by = "cod_ibge"), rec, by = "cod_ibge")
if (nrow(d) != nrow(base) || anyDuplicated(d$cod_ibge)) stop("A junção mudou o número de municípios ou repetiu códigos")

d$ln_taxa <- ifelse(d$taxa > 0, log(d$taxa), NA)
d$tem_presidio <- as.integer(d$pct_presos > 0)
d$porte <- as.character(cut(d$pop, c(0, 1e4, 2e4, 5e4, 1e5, Inf), right = FALSE,
                            labels = c("<10 mil", "10–20 mil", "20–50 mil", "50–100 mil", "100 mil+")))

write.csv(d, "dados/tabelas/base_relatorio.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("Base do relatório: %d municípios x %d colunas\n", nrow(d), ncol(d)))
