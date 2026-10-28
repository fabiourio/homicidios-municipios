# Baixa as bases candidatas listadas em FONTES.md (rodar na raiz do repositório)
options(timeout = 1200)
raiz <- "dados/candidatos"

baixar <- function(url, pasta, arquivo) {
  dir.create(file.path(raiz, pasta), recursive = TRUE, showWarnings = FALSE)
  destino <- file.path(raiz, pasta, arquivo)
  if (!file.exists(destino)) download.file(url, destino, mode = "wb")
}

# PIB dos municípios (SIDRA 5938), 2021-2023; a API limita 50 mil valores, por isso 2 blocos/ano
for (ano in 2021:2023) {
  baixar(sprintf("https://apisidra.ibge.gov.br/values/t/5938/n6/all/v/37,498,513,516,517/p/%d", ano),
         "pib_municipal", sprintf("sidra_5938_%d_a.json", ano))
  baixar(sprintf("https://apisidra.ibge.gov.br/values/t/5938/n6/all/v/520,6575,6574,525,528/p/%d", ano),
         "pib_municipal", sprintf("sidra_5938_%d_b.json", ano))
}

# Censo 2022: população em favelas e número de favelas (só municípios com favela; os demais = 0)
baixar("https://apisidra.ibge.gov.br/values/t/9888/n6/all/v/9612/p/2022",
       "favelas_censo2022", "sidra_9888_pop_favelas.json")
baixar("https://apisidra.ibge.gov.br/values/t/9883/n6/all/v/9910/p/2022",
       "favelas_censo2022", "sidra_9883_n_favelas.json")

# Censo 2022: taxa de frequência escolar bruta, 15-17 e 18-24 anos
baixar("https://apisidra.ibge.gov.br/values/t/10056/n6/all/v/3795/p/2022/c58/2792,100052/c2/6794/c86/95251",
       "frequencia_escolar_censo2022", "sidra_10056_freq_15a17_18a24.json")

# MapBiomas Coleção 11: desmatamento anual e área minerada (garimpo x industrial) por município
mb <- "https://brasil.mapbiomas.org/wp-content/uploads/sites/3/2026/10/"
for (f in c("MAPBIOMAS-BRAZIL-DEFORESTATION-ANNUAL-MUNICIPALITY-COLLECTION_11.xlsx",
            "MAPBIOMAS-BRAZIL-MINED-SUBSTANCES-MUNICIPALITY-COLLECTION_11.xlsx")) {
  baixar(paste0(mb, f), "mapbiomas", f)
}

# SISDEPEN: estabelecimentos prisionais (com código IBGE), fim de 2021, 2022 e 2023
sd <- "https://www.gov.br/senappen/pt-br/servicos/sisdepen/bases-de-dados/"
baixar(paste0(sd, "2021/11o-ciclo-base-de-dados-2021-2-semestre.csv/@@download/file"),
       "sisdepen", "sisdepen_11o_ciclo_2021_2sem.csv")
baixar(paste0(sd, "2022/13o-ciclo-base-de-dados-2022-2-semestre.csv/@@download/file"),
       "sisdepen", "sisdepen_13o_ciclo_2022_2sem.csv")
baixar(paste0(sd, "2023/15o-ciclo-base-de-dados-2023-2-semestre.csv/@@download/file"),
       "sisdepen", "sisdepen_15o_ciclo_2023_2sem.csv")

# INEP 2022: taxas de rendimento (abandono/reprovação) e distorção idade-série por município
inep <- "https://download.inep.gov.br/informacoes_estatisticas/indicadores_educacionais/2022/"
baixar(paste0(inep, "tx_rend_municipios_2022.zip"), "inep", "tx_rend_municipios_2022.zip")
baixar(paste0(inep, "TDI_2022_MUNICIPIOS.zip"), "inep", "TDI_2022_MUNICIPIOS.zip")

# MUNIC 2023 (IBGE): aba "Segurança Pública" (guarda municipal etc.)
baixar("https://ftp.ibge.gov.br/Perfil_Municipios/2023/Base_de_Dados/Base_MUNIC_2023.xlsx",
       "munic_2023", "Base_MUNIC_2023.xlsx")

# Gini municipal 1991/2000/2010 (IBGE via DATASUS); página HTML com a tabela pronta, código de 6 dígitos
baixar("http://tabnet.datasus.gov.br/cgi/ibge/censo/cnv/ginibr.def",
       "gini_2010", "datasus_ginibr_1991_2000_2010.html")

# ---- Rodada 2 ----
sidra <- "https://apisidra.ibge.gov.br/values/t/"

# Censo 2022: populacao 2022, variacao absoluta 2010-2022 e taxa de crescimento geometrico
baixar(paste0(sidra, "4709/n6/all/v/93,5936,10605/p/2022"), "crescimento_pop_censo", "sidra_4709_crescimento_2010_2022.json")

# Censo 2022: migrantes recentes (moram ha menos de 10 anos no municipio; e vieram de outra UF nos ultimos 5 anos)
baixar(paste0(sidra, "10158/n6/all/v/13338/p/2022/c305/77807/c3014/95320"), "migracao_censo2022", "sidra_10158_menos10anos_no_municipio.json")
baixar(paste0(sidra, "10159/n6/all/v/13339/p/2022/c2083/77808"), "migracao_censo2022", "sidra_10159_outra_uf_5anos_antes.json")

# Censo 2022: domicilios com responsavel sem conjuge e com filhos, por sexo do responsavel (maes solo)
baixar(paste0(sidra, "9882/n6/all/v/800/p/2022/c1887/72603,72607/c11561/100679,100681"), "familia_censo2022", "sidra_9882_responsavel_sem_conjuge.json")

# Censo 2022: ocupados por contribuicao a previdencia (informalidade)
baixar(paste0(sidra, "10264/n6/all/v/4090/p/2022/c2/6794/c86/95251/c526/15349,15350,15351/c12064/100971"), "informalidade_censo2022", "sidra_10264_contribuicao_previdencia.json")

# CEMPRE (IBGE): pessoal ocupado total e assalariado (emprego formal) por municipio, 2021 (tabela 1685) e 2022-2023 (tabela 9509)
baixar(paste0(sidra, "1685/n6/all/v/707,708/p/2021"), "cempre", "sidra_1685_2021.json")
baixar(paste0(sidra, "9509/n6/all/v/707,708/p/2022,2023"), "cempre", "sidra_9509_2022_2023.json")

# PAM: area plantada total e de soja; PPM: rebanho bovino; 2021-2023
baixar(paste0(sidra, "5457/n6/all/v/8331/p/2021,2022,2023/c782/0,40124"), "agro_pam_ppm", "sidra_5457_area_total_soja.json")
baixar(paste0(sidra, "3939/n6/all/v/105/p/2021,2022,2023/c79/2670"), "agro_pam_ppm", "sidra_3939_bovinos.json")

# INPE BDQueimadas: focos de calor do satelite de referencia, um arquivo por ano
for (ano in 2021:2023) {
  baixar(sprintf("https://dataserver-coids.inpe.br/queimadas/queimadas/focos/csv/anual/Brasil_sat_ref/focos_br_ref_%d.zip", ano),
         "inpe_focos", sprintf("focos_br_ref_%d.zip", ano))
}

# Ministerio da Saude (Relatorios Publicos da APS): cobertura potencial da atencao primaria, dezembro de cada ano
for (ano in 2021:2023) {
  baixar(sprintf("https://relatorioaps-prd.saude.gov.br/cobertura/aps?unidadeGeografica=MUNICIPIO&nuCompInicio=%d12&nuCompFim=%d12", ano, ano),
         "cobertura_aps", sprintf("cobertura_aps_%d12.json", ano))
}

# INCRA: relacao de projetos de assentamento (um registro por projeto) e dicionario
incra <- "https://www.gov.br/incra/pt-br/assuntos/reforma-agraria/"
baixar(paste0(incra, "assentamentosgeral.csv/@@download/file"), "incra_assentamentos", "assentamentosgeral.csv")
baixar(paste0(incra, "dicionario_dados_relacao_projetos.xls/@@download/file"), "incra_assentamentos", "dicionario_dados_relacao_projetos.xls")

# Tesouro: tabela oficial SIAFI -> IBGE (para agregar o arquivo do Bolsa Familia do Portal da Transparencia)
baixar("https://www.tesourotransparente.gov.br/ckan/dataset/abb968cb-3710-4f85-89cf-875c91b9c7f6/resource/eebb3bc6-9eea-4496-8bcf-304f33155282/download/tabmun.csv",
       "siafi_ibge", "tabmun.csv")

# SICONFI/Tesouro (DCA Anexo I-E): despesa municipal por funcao em 2022 - total, 06 Seguranca Publica e 08 Assistencia Social.
# A API so responde um municipio por vez (~0,5 s cada, ~50 min no total); guarda so as linhas dessas funcoes
destino_dca <- file.path(raiz, "siconfi_dca", "dca_2022_funcoes_06_08.csv")
if (!file.exists(destino_dca)) {
  dir.create(dirname(destino_dca), showWarnings = FALSE)
  cods <- unique(jsonlite::fromJSON(file.path(raiz, "crescimento_pop_censo", "sidra_4709_crescimento_2010_2022.json"))$D1C[-1])
  api <- "https://apidatalake.tesouro.gov.br/ords/siconfi/tt/dca?an_exercicio=2022&no_anexo=DCA-Anexo%20I-E&id_ente="
  linhas <- lapply(cods, function(cod) {
    itens <- tryCatch(jsonlite::fromJSON(paste0(api, cod))$items, error = function(e) NULL)
    if (!NROW(itens)) return(data.frame(cod_ibge = as.integer(cod), conta = NA, coluna = NA, valor = NA, populacao = NA))
    itens <- itens[grepl("^(06|08) - |^Despesas Exceto Intra", itens$conta), ]
    itens[, c("cod_ibge", "conta", "coluna", "valor", "populacao")]
  })
  write.csv(do.call(rbind, linhas), destino_dca, row.names = FALSE)
}
