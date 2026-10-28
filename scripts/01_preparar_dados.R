# =============================================================================
# 01 - Preparação dos dados
# Entradas: dados/raw/sidra_raw.json (Censo 2022, API SIDRA)
#           dados/raw/tabnet_raw.json (SIM/DATASUS, TabNet)
#           dados/raw/sidra_10056_freq_escolar.json (Censo 2022, frequência escolar)
#           dados/raw/mapbiomas_mineracao_col11.xlsx (MapBiomas, área de garimpo)
# Saídas:   dados/tabelas/ (tabelas limpas e base_analitica.csv) e cópia em entrega/dados/
# =============================================================================

# Limpa área de trabalho
rm(list = ls())

# Roda a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")

library(jsonlite)
library(readxl)

dir.create("dados/tabelas", showWarnings = FALSE)

UF  <- c("11" = "RO", "12" = "AC", "13" = "AM", "14" = "RR", "15" = "PA", "16" = "AP", "17" = "TO",
         "21" = "MA", "22" = "PI", "23" = "CE", "24" = "RN", "25" = "PB", "26" = "PE", "27" = "AL",
         "28" = "SE", "29" = "BA", "31" = "MG", "32" = "ES", "33" = "RJ", "35" = "SP", "41" = "PR",
         "42" = "SC", "43" = "RS", "50" = "MS", "51" = "MT", "52" = "GO", "53" = "DF")
REG <- c("1" = "N", "2" = "NE", "3" = "SE", "4" = "S", "5" = "CO")

# -----------------------------------------------------------------------------
# 1. Tabelas do Censo 2022 (SIDRA)
#    Símbolos do IBGE: "-" = zero absoluto; "X" = suprimido; ".." e "..." = não disponível
# -----------------------------------------------------------------------------
S <- fromJSON("dados/raw/sidra_raw.json", simplifyVector = FALSE)

nomes_colunas <- list(
  "4709"  = "pop",
  "4714"  = c("pop", "area_km2", "densidade"),
  "10295" = c("moradores_dpp", "rend_pc_media", "rend_pc_mediana"),
  "10300" = c("p14_total", "p14_ate_1_4sm", "p14_1_4_a_1_2sm", "p14_1_2_a_1sm", "p14_1_a_2sm",
              "p14_2_a_3sm", "p14_3_a_5sm", "p14_5_a_10sm", "p14_10_a_15sm", "p14_15_a_20sm",
              "p14_mais_20sm", "p14_sem_rendimento"),
  "9517"  = c("p14_total", "forca_trabalho", "ocupados", "desocupados", "fora_forca_trabalho"),
  "9543"  = "taxa_alfabetizacao_15mais",
  "9923"  = c("pop_total", "pop_urbana", "pop_rural"),
  "9605"  = c("pop_total", "branca", "preta", "amarela", "parda", "indigena"),
  "9606"  = c("homens_15_19", "homens_20_24", "homens_25_29"))

# Converte uma tabela do JSON em data.frame (valores ainda como texto)
le_sidra <- function(t) {
  linhas <- lapply(S[[t]]$rows, function(r) sapply(r, function(x) if (is.null(x)) NA else x))
  df <- as.data.frame(do.call(rbind, linhas), stringsAsFactors = FALSE)
  names(df) <- c("cod_ibge", "municipio", nomes_colunas[[t]])
  df$cod_ibge <- as.integer(df$cod_ibge)
  df[order(df$cod_ibge), ]
}

sidra <- list()
for (t in names(S)) {
  bruto <- le_sidra(t)
  write.csv(bruto, sprintf("dados/tabelas/sidra_%s.csv", t), row.names = FALSE)
  num <- bruto
  for (v in nomes_colunas[[t]]) {
    x <- num[[v]]
    x[x == "-"] <- "0"                                        # "-" = zero absoluto
    num[[v]] <- suppressWarnings(as.numeric(x))               # X, .., ... viram NA
  }
  sidra[[t]] <- num
  cat(sprintf("SIDRA %s: %d municípios | NAs: %d\n", t, nrow(num), sum(is.na(num[, nomes_colunas[[t]]]))))
}

# -----------------------------------------------------------------------------
# 2. Variáveis do Censo por município
# -----------------------------------------------------------------------------
pop <- sidra[["4709"]]
c22 <- data.frame(cod_ibge  = pop$cod_ibge,
                  municipio = sub(" - [A-Z]{2}$", "", pop$municipio),
                  uf        = UF[substr(pop$cod_ibge, 1, 2)],
                  regiao    = REG[substr(pop$cod_ibge, 1, 1)],
                  pop       = pop$pop)

junta <- function(t, cols) merge(c22, sidra[[t]][, c("cod_ibge", cols)], by = "cod_ibge", sort = FALSE)
c22 <- junta("4714", c("area_km2", "densidade"));            names(c22)[names(c22) == "densidade"] <- "dens"
c22 <- junta("10295", c("rend_pc_media", "rend_pc_mediana"))

p <- sidra[["10300"]]                                        # pessoas 14+ por classe de renda per capita
p$pct_pobres <- (p$p14_ate_1_4sm + p$p14_sem_rendimento) / p$p14_total * 100
t9517 <- sidra[["9517"]]
t9517$desocup <- t9517$desocupados / t9517$forca_trabalho * 100
u <- sidra[["9923"]]
u$pct_urbana <- u$pop_urbana / u$pop_total * 100
r <- sidra[["9605"]]
r$pct_negra <- (r$preta + r$parda) / r$pop_total * 100
h <- sidra[["9606"]]
h$homens_15_29 <- h$homens_15_19 + h$homens_20_24 + h$homens_25_29

c22 <- merge(c22, p[, c("cod_ibge", "pct_pobres")], by = "cod_ibge")
c22 <- merge(c22, t9517[, c("cod_ibge", "desocup")], by = "cod_ibge")
c22 <- merge(c22, data.frame(cod_ibge = sidra[["9543"]]$cod_ibge,
                             alfabet = sidra[["9543"]]$taxa_alfabetizacao_15mais), by = "cod_ibge")
c22 <- merge(c22, u[, c("cod_ibge", "pct_urbana")], by = "cod_ibge")
c22 <- merge(c22, r[, c("cod_ibge", "pct_negra")], by = "cod_ibge")
c22 <- merge(c22, h[, c("cod_ibge", "homens_15_29")], by = "cod_ibge")

# Checagens de consistência entre as tabelas (nº de municípios com diferença)
cat("\nInconsistências:\n")
cat("  pop 4709 x 4714:", sum(pop$pop != sidra[["4714"]]$pop), "\n")
cat("  pop 4709 x 9923:", sum(pop$pop != u$pop_total), "\n")
cat("  pop 4709 x 9605:", sum(pop$pop != r$pop_total), "\n")
cat("  10300 soma das classes x total:", sum(rowSums(p[, nomes_colunas[["10300"]][-1]]) != p$p14_total), "\n")
cat("  9517 ocupados + desocupados x força de trabalho:",
    sum(t9517$ocupados + t9517$desocupados != t9517$forca_trabalho), "\n")
cat("  9923 urbana + rural x total:", sum(u$pop_urbana + u$pop_rural != u$pop_total), "\n")
write.csv(c22, "dados/tabelas/censo2022_municipios.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 3. Óbitos por causas externas (SIM/DATASUS, por município de residência)
# -----------------------------------------------------------------------------
R <- fromJSON("dados/raw/tabnet_raw.json")

grupos <- c("V01-V99" = "transporte", "W00-X59" = "outras_acidentais", "X60-X84" = "suicidio",
            "X85-Y09" = "agressao", "Y10-Y34" = "intencao_indeterminada", "Y35-Y36" = "intervencao_legal",
            "Y40-Y84" = "complic_assist_medica", "Y85-Y89" = "sequelas", "Total" = "total_causas_externas")

# Lê a tabela do TabNet ("-" = nenhum óbito)
le_tabnet <- function(s) {
  df <- read.table(text = s, sep = ";", header = TRUE, quote = "\"", check.names = FALSE,
                   na.strings = "-", fill = TRUE, stringsAsFactors = FALSE, encoding = "UTF-8")
  names(df)[1] <- "linha"
  for (k in names(grupos)) names(df)[startsWith(names(df), k)] <- grupos[k]
  df[is.na(df)] <- 0
  df
}

e_municipio <- function(x) grepl("^\\s*[0-9]{6} ", x)

sim <- list()
for (k in c("h2123", "h24")) {
  df <- le_tabnet(R[[k]])
  mun <- df[e_municipio(df$linha), ]
  ign <- df[!e_municipio(df$linha) & !grepl("Total", df$linha) & df$linha != "&", ]
  mun$cod6 <- as.integer(substr(trimws(mun$linha), 1, 6))
  mun$municipio_tabnet <- substring(trimws(mun$linha), 8)
  mun <- mun[, c("cod6", "municipio_tabnet", unname(grupos))]
  nome <- c(h2123 = "sim_causas_externas_2021_2023", h24 = "sim_causas_externas_2024")[k]
  write.csv(mun, sprintf("dados/tabelas/%s.csv", nome), row.names = FALSE)
  cat(sprintf("\n%s: %d municípios | homicídios com município ignorado: %d\n", nome, nrow(mun),
              sum(ign$agressao + ign$intervencao_legal)))
  sim[[k]] <- mun
}

# Listas de municípios da Amazônia Legal e da faixa de fronteira
lista <- function(k) {
  df <- le_tabnet(R[[k]])
  as.integer(substr(trimws(df$linha[e_municipio(df$linha)]), 1, 6))
}
ama <- lista("ama"); fro <- lista("fro")
write.csv(data.frame(cod6 = ama), "dados/tabelas/municipios_amazonia_legal.csv", row.names = FALSE)
write.csv(data.frame(cod6 = fro), "dados/tabelas/municipios_faixa_fronteira.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# 4. Base analítica (1 linha por município)
# -----------------------------------------------------------------------------
b <- c22
b$cod6 <- b$cod_ibge %/% 10                                  # DATASUS usa o código sem o dígito verificador
h21 <- sim$h2123[, c("cod6", "agressao", "intervencao_legal", "intencao_indeterminada", "total_causas_externas")]
h24 <- sim$h24[, c("cod6", "agressao", "intervencao_legal")]
names(h24)[2:3] <- c("agressao_24", "intervencao_legal_24")
b <- merge(b, h21, by = "cod6", all.x = TRUE)
b <- merge(b, h24, by = "cod6", all.x = TRUE)
cols0 <- c("agressao", "intervencao_legal", "intencao_indeterminada", "total_causas_externas",
           "agressao_24", "intervencao_legal_24")
cat("\nMunicípios sem linha no TabNet (zero óbitos externos):", sum(is.na(b$agressao)), "\n")
b[cols0][is.na(b[cols0])] <- 0                               # TabNet omite municípios sem óbitos externos

b$amazonia_legal  <- as.integer(b$cod6 %in% ama)
b$faixa_fronteira <- as.integer(b$cod6 %in% fro)

# Variável resposta: homicídios = agressão (X85-Y09) + intervenção legal (Y35-Y36)
b$hom      <- b$agressao + b$intervencao_legal
b$hom_24   <- b$agressao_24 + b$intervencao_legal_24
b$exposure <- 3 * b$pop                                      # pessoas-ano em 2021-2023
b$taxa     <- b$hom / b$exposure * 1e5                       # homicídios por 100 mil hab. por ano
b$taxa_24  <- b$hom_24 / b$pop * 1e5

# Variáveis explicativas derivadas
b$log_rend  <- log(b$rend_pc_media)
b$desig     <- b$rend_pc_media / b$rend_pc_mediana           # razão média/mediana (Gini não está no SIDRA)
b$log_dens  <- log(b$dens)
b$pct_h1529 <- b$homens_15_29 / b$pop * 100
b$pct_indet <- ifelse(b$total_causas_externas > 0,
                      b$intencao_indeterminada / b$total_causas_externas * 100, 0)

# Frequência escolar bruta de 15 a 17 anos (Censo 2022, SIDRA 10056)
fe <- fromJSON("dados/raw/sidra_10056_freq_escolar.json")[-1, ]          # 1a linha = cabeçalho
fe <- fe[fe$D4C == "2792", ]                                             # 2792 = 15 a 17 anos
b$freq_15a17 <- as.numeric(fe$V)[match(b$cod_ibge, as.integer(fe$D1C))]

# Garimpo de ouro ativo (solo exposto) em 2022, em % da área do município (MapBiomas, Coleção 11)
# Fora: areia e brita (minerais classe 2) e áreas em revegetação, que não têm relação com a hipótese
g <- read_excel("dados/raw/mapbiomas_mineracao_col11.xlsx", sheet = "MINED_SUBSTANCE")
g <- g[g$CLASS_LEVEL_1 == "Garimpo" & g$CLASS_NAME == "Ouro" & g$CLASS_LEVEL_2 == "Solo exposto", ]
ga <- tapply(g$y2022, g$GEOCODE, sum, na.rm = TRUE)                      # hectares
b$garimpo_ha  <- ifelse(is.na(ga[as.character(b$cod_ibge)]), 0, ga[as.character(b$cod_ibge)])
b$pct_garimpo <- b$garimpo_ha / (b$area_km2 * 100) * 100                 # 1 km² = 100 ha

b <- b[order(b$cod_ibge), c("cod_ibge", setdiff(names(b), "cod_ibge"))]
write.csv(b, "dados/tabelas/base_analitica.csv", row.names = FALSE)

cat(sprintf("\nBase analítica: %d municípios | NAs: %d\n", nrow(b), sum(is.na(b))))
cat(sprintf("Homicídios 2021-23: %d | 2024: %d | taxa Brasil: %.2f por 100 mil/ano\n",
            sum(b$hom), sum(b$hom_24), sum(b$hom) / sum(b$exposure) * 1e5))
cat(sprintf("Amazônia Legal: %d | Faixa de fronteira: %d\n", sum(b$amazonia_legal), sum(b$faixa_fronteira)))

# Dicionário das colunas da base analítica
dic <- c(
  cod_ibge = "Código IBGE do município (7 dígitos)",
  cod6 = "Código IBGE sem dígito verificador (usado no DATASUS)",
  municipio = "Nome do município", uf = "Sigla da UF", regiao = "Região (N, NE, CO, SE, S)",
  pop = "População residente, Censo 2022 (SIDRA 4709)",
  area_km2 = "Área territorial em km² (SIDRA 4714)", dens = "Densidade demográfica, hab/km² (SIDRA 4714)",
  rend_pc_media = "Rendimento domiciliar per capita médio, R$ (SIDRA 10295)",
  rend_pc_mediana = "Rendimento domiciliar per capita mediano, R$ (SIDRA 10295)",
  pct_pobres = "% de pessoas de 14+ anos com renda domiciliar per capita até 1/4 SM ou sem rendimento (SIDRA 10300)",
  desocup = "Taxa de desocupação, % da força de trabalho (SIDRA 9517)",
  alfabet = "Taxa de alfabetização, 15+ anos, % (SIDRA 9543)",
  pct_urbana = "% da população em situação urbana (SIDRA 9923)",
  pct_negra = "% da população preta ou parda (SIDRA 9605)",
  homens_15_29 = "Homens de 15 a 29 anos (SIDRA 9606)",
  agressao = "Óbitos por agressão X85-Y09, 2021-2023, por residência (SIM)",
  intervencao_legal = "Óbitos por intervenção legal Y35-Y36, 2021-2023 (SIM)",
  intencao_indeterminada = "Óbitos de intenção indeterminada Y10-Y34, 2021-2023 (SIM)",
  total_causas_externas = "Total de óbitos por causas externas, 2021-2023 (SIM)",
  agressao_24 = "Óbitos por agressão, 2024 (SIM)", intervencao_legal_24 = "Óbitos por intervenção legal, 2024 (SIM)",
  amazonia_legal = "1 se o município pertence à Amazônia Legal",
  faixa_fronteira = "1 se o município está na faixa de fronteira",
  hom = "Homicídios 2021-2023 = agressao + intervencao_legal", hom_24 = "Homicídios 2024",
  exposure = "Pessoas-ano de exposição = 3 x pop",
  taxa = "Taxa de homicídios por 100 mil hab./ano, 2021-2023 (variável resposta)",
  taxa_24 = "Taxa de homicídios por 100 mil hab., 2024",
  log_rend = "ln(rend_pc_media)", desig = "Razão média/mediana do rendimento per capita (desigualdade)",
  log_dens = "ln(dens)", pct_h1529 = "% de homens de 15 a 29 anos na população",
  pct_indet = "% de óbitos de intenção indeterminada no total de causas externas",
  freq_15a17 = "Taxa de frequência escolar bruta de 15 a 17 anos, % (Censo 2022, SIDRA 10056)",
  garimpo_ha = "Área de garimpo de ouro ativo (solo exposto) em 2022, ha (MapBiomas Coleção 11)",
  pct_garimpo = "Área de garimpo de ouro ativo em % da área do município, 2022 (MapBiomas)")
write.csv(data.frame(coluna = names(dic), descricao = dic), "dados/tabelas/dicionario.csv", row.names = FALSE)

# Cópia da base, do dicionário e da malha para a pasta do código de entrega (análise)
dir.create("entrega/dados", recursive = TRUE, showWarnings = FALSE)
file.copy(c("dados/tabelas/base_analitica.csv", "dados/tabelas/dicionario.csv", "dados/malha_mun.geojson"),
          "entrega/dados/", overwrite = TRUE)
