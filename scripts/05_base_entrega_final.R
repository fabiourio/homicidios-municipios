# Monta a base da entrega final só com as variáveis usadas no modelo final e no artigo.
# Rodar na raiz do repositório, depois de scripts/01_preparar_dados.R e scripts/02_integrar_candidatas.R.
# Saída: entrega_final/dados/ (base_municipios.csv, gini_oficial.csv, dicionario.csv e malha_mun.geojson)

base <- read.csv("entrega/dados/base_analitica.csv")
extras <- read.csv("entrega/dados/variaveis_extras.csv")
classes <- read.csv("dados/tabelas/sidra_10300.csv", colClasses = "character")
vg <- read.csv("entrega/dados/validacao_gini.csv")

cls <- c("p14_sem_rendimento", "p14_ate_1_4sm", "p14_1_4_a_1_2sm", "p14_1_2_a_1sm", "p14_1_a_2sm", "p14_2_a_3sm",
         "p14_3_a_5sm", "p14_5_a_10sm", "p14_10_a_15sm", "p14_15_a_20sm", "p14_mais_20sm")
for (v in cls) {
  x <- classes[[v]]
  x[x == "-"] <- "0"
  classes[[v]] <- as.numeric(x)
}
classes$cod_ibge <- as.integer(classes$cod_ibge)

colunas <- c("cod_ibge", "municipio", "uf", "regiao", "pop", "agressao", "intervencao_legal",
             "intencao_indeterminada", "total_causas_externas", "rend_pc_media", "desocup", "pct_urbana", "freq_15a17")
d <- merge(base[, colunas], extras[, c("cod_ibge", "distorcao_em", "pct_migr_10anos")], by = "cod_ibge")
d <- merge(d, classes[, c("cod_ibge", cls)], by = "cod_ibge")
d <- d[order(d$cod_ibge), ]
stopifnot(nrow(d) == 5570, identical(d$cod_ibge, sort(base$cod_ibge)))

dir.create("entrega_final/dados", recursive = TRUE, showWarnings = FALSE)
write.csv(d, "entrega_final/dados/base_municipios.csv", row.names = FALSE)
write.csv(vg[vg$nivel %in% c("Brasil", "Unidade da Federação"), c("nivel", "codigo", "local", "gini_oficial")],
          "entrega_final/dados/gini_oficial.csv", row.names = FALSE)
stopifnot(file.copy("entrega/dados/malha_mun.geojson", "entrega_final/dados/malha_mun.geojson", overwrite = TRUE))

dic <- data.frame(arquivo = "base_municipios.csv", coluna = names(d), descricao = c(
  "Código IBGE do município (7 dígitos)",
  "Nome do município (IBGE)",
  "Sigla da UF",
  "Região: N, NE, CO, SE ou S",
  "População residente, em habitantes, Censo 2022 (IBGE, SIDRA 4709)",
  "Número de óbitos por agressão (CID-10 X85-Y09), soma de 2021 a 2023, por residência (SIM/DATASUS)",
  "Número de óbitos por intervenção legal e operações de guerra (CID-10 Y35-Y36), soma de 2021 a 2023, por residência (SIM/DATASUS)",
  "Número de óbitos de intenção indeterminada (CID-10 Y10-Y34), soma de 2021 a 2023, por residência (SIM/DATASUS)",
  "Número total de óbitos por causas externas, soma de 2021 a 2023, por residência (SIM/DATASUS)",
  "Rendimento nominal médio mensal domiciliar per capita, R$ de 2022 (Censo 2022, SIDRA 10295)",
  "Taxa de desocupação, % da força de trabalho (Censo 2022, SIDRA 9517)",
  "% da população em situação urbana (Censo 2022, SIDRA 9923)",
  "Taxa de frequência escolar bruta de 15 a 17 anos, % (Censo 2022, SIDRA 10056)",
  "Taxa de distorção idade-série no ensino médio, %, 2022 (INEP); vazio = município sem ensino médio",
  "Moradores que vieram de outro lugar e residem no município há menos de 10 anos ininterruptos (Censo 2022, SIDRA 10158), em % da população residente (SIDRA 4709)",
  paste("Número de pessoas de 14 anos ou mais na classe de rendimento domiciliar per capita, em salários mínimos (SM) (Censo 2022, SIDRA 10300):",
        c("sem rendimento", "até 1/4 SM", "1/4 a 1/2 SM", "1/2 a 1 SM", "1 a 2 SM", "2 a 3 SM", "3 a 5 SM",
          "5 a 10 SM", "10 a 15 SM", "15 a 20 SM", "mais de 20 SM"))))
dic <- rbind(dic, data.frame(arquivo = "gini_oficial.csv", coluna = c("nivel", "codigo", "local", "gini_oficial"), descricao = c(
  "Brasil ou Unidade da Federação", "Código IBGE (1 = Brasil; 2 dígitos = UF)", "Nome do local", "Índice de Gini oficial do rendimento domiciliar per capita, Censo 2022 (SIDRA 10301)")))
dic <- rbind(dic, data.frame(arquivo = "malha_mun.geojson", coluna = "codarea",
  descricao = "Código IBGE do município na malha municipal 2022 do IBGE; usada só no mapa"))
write.csv(dic, "entrega_final/dados/dicionario.csv", row.names = FALSE)
cat("entrega_final/dados/ gerado:", nrow(d), "municípios,", ncol(d), "colunas\n")
