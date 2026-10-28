# =============================================================================
# 02 - Integração das variáveis candidatas
# Entradas: dados/candidatos/ (arquivos brutos; ver dados/candidatos/FONTES.md)
#           dados/tabelas/base_analitica.csv (pop e area_km2 como denominadores)
#           dados/malha_mun.geojson (malha municipal, para os focos de queimada)
# Saídas:   dados/tabelas/candidatas.csv e dados/tabelas/dicionario_candidatas.csv
# =============================================================================

# Limpa área de trabalho
rm(list = ls())

# Roda a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")

library(jsonlite)
library(readxl)
library(sf)

C <- "dados/candidatos"
base <- read.csv("dados/tabelas/base_analitica.csv")[, c("cod_ibge", "municipio", "uf", "pop", "area_km2")]
out <- data.frame(cod_ibge = base$cod_ibge)
tmp <- tempdir()                                             # zips são abertos aqui, fora do repositório

# Busca o valor de cada município da base num vetor nomeado por código (6 ou 7 dígitos)
por_mun <- function(v, digitos = 7) {
  k <- if (digitos == 7) base$cod_ibge else base$cod_ibge %/% 10
  unname(v[as.character(k)])
}

# Nome padronizado para junção por nome + UF (maiúsculas, sem acento, só letras)
padroniza <- function(x) {
  x <- chartr("ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ", "AAAAAEEEEIIIIOOOOOUUUUCN", toupper(trimws(x)))
  sub("DOOESTE$", "DOESTE", gsub("[^A-Z]", "", x))           # "do Oeste" e "D'Oeste"
}
chave_base <- paste(padroniza(base$municipio), base$uf)

# -----------------------------------------------------------------------------
# 1. Tabelas SIDRA (JSON da API do IBGE)
#    1a linha = cabeçalho; D1C = código de 7 dígitos; "-" = zero; "..." e "X" = NA
# -----------------------------------------------------------------------------
le_sidra <- function(arq) {
  d <- fromJSON(file.path(C, arq))[-1, ]
  d$V[d$V == "-"] <- "0"
  d$V <- suppressWarnings(as.numeric(d$V))
  d
}

# Vetor nomeado por código com as linhas que atendem ao filtro (ex.: D2C = "37")
sidra_v <- function(d, ...) {
  f <- list(...)
  ok <- Reduce(`&`, lapply(names(f), function(k) d[[k]] == f[[k]]))
  setNames(d$V[ok], d$D1C[ok])
}

# PIB per capita 2022 (5938, var. 37, mil R$)
pib22 <- le_sidra("pib_municipal/sidra_5938_2022_a.json")
out$pib_pc    <- por_mun(sidra_v(pib22, D2C = "37")) * 1000 / base$pop
out$ln_pib_pc <- log(out$pib_pc)

# Participação no valor adicionado, 2021 (2022 e 2023 vêm "...")
pa <- le_sidra("pib_municipal/sidra_5938_2021_a.json")
pb <- le_sidra("pib_municipal/sidra_5938_2021_b.json")
out$pct_agro <- por_mun(sidra_v(pa, D2C = "516"))
out$pct_ind  <- por_mun(sidra_v(pb, D2C = "520"))
out$pct_adm  <- por_mun(sidra_v(pb, D2C = "528"))

# População em favelas (9888); município fora da tabela não tem favela = 0
fav <- por_mun(sidra_v(le_sidra("favelas_censo2022/sidra_9888_pop_favelas.json"), D2C = "9612"))
out$pct_favela <- ifelse(is.na(fav), 0, fav) / base$pop * 100

# Frequência escolar bruta de 18 a 24 anos (10056, categoria 100052)
out$freq_18a24 <- por_mun(sidra_v(le_sidra("frequencia_escolar_censo2022/sidra_10056_freq_15a17_18a24.json"),
                                  D4C = "100052"))

# Taxa de crescimento geométrico anual 2010-2022 (4709, var. 10605)
out$cresc_pop <- por_mun(sidra_v(le_sidra("crescimento_pop_censo/sidra_4709_crescimento_2010_2022.json"),
                                 D2C = "10605"))

# Migrantes: há menos de 10 anos no município (10158) e de outra UF 5 anos antes (10159)
out$pct_migr_10anos   <- por_mun(sidra_v(le_sidra("migracao_censo2022/sidra_10158_menos10anos_no_municipio.json"),
                                         D2C = "13338")) / base$pop * 100
out$pct_migr_outra_uf <- por_mun(sidra_v(le_sidra("migracao_censo2022/sidra_10159_outra_uf_5anos_antes.json"),
                                         D2C = "13339")) / base$pop * 100

# Mães solo (9882): responsável mulher sem cônjuge com filhos / total de domicílios particulares
fam <- le_sidra("familia_censo2022/sidra_9882_responsavel_sem_conjuge.json")
out$pct_maes_solo <- por_mun(sidra_v(fam, D4C = "72607", D5C = "100681")) /
                     por_mun(sidra_v(fam, D4C = "72603", D5C = "100679")) * 100

# Pessoal assalariado 2022 (CEMPRE 9509, var. 708) por 100 hab.
out$emprego_formal <- por_mun(sidra_v(le_sidra("cempre/sidra_9509_2022_2023.json"), D2C = "708", D3C = "2022")) /
                      base$pop * 100

# Informalidade (10264): ocupados não contribuintes / total de ocupados
inf <- le_sidra("informalidade_censo2022/sidra_10264_contribuicao_previdencia.json")
out$pct_informal <- por_mun(sidra_v(inf, D6C = "15351")) / por_mun(sidra_v(inf, D6C = "15349")) * 100

# Área de soja 2022 (PAM 5457, ha) em % da área; bois por km² (PPM 3939)
soja <- por_mun(sidra_v(le_sidra("agro_pam_ppm/sidra_5457_area_total_soja.json"), D3C = "2022", D4C = "40124"))
out$pct_soja    <- soja / (base$area_km2 * 100) * 100
out$bovinos_km2 <- por_mun(sidra_v(le_sidra("agro_pam_ppm/sidra_3939_bovinos.json"), D3C = "2022")) / base$area_km2
# Cidade sem lavoura ou gado na tabela (ausente ou "...") = zero, para não sair da regressão
out$pct_soja[is.na(out$pct_soja)] <- 0
out$pct_soja <- pmin(out$pct_soja, 100)                     # 1 caso acima de 100% (erro da fonte)
out$bovinos_km2[is.na(out$bovinos_km2)] <- 0

# -----------------------------------------------------------------------------
# 2. Desmatamento médio 2021-2023 (MapBiomas Coleção 11), soma das transições, ha
# -----------------------------------------------------------------------------
dm <- read_excel(file.path(C, "mapbiomas/MAPBIOMAS-BRAZIL-DEFORESTATION-ANNUAL-MUNICIPALITY-COLLECTION_11.xlsx"),
                 sheet = "ANNUAL_DEFORESTATION")
dha <- tapply(rowSums(dm[, c("y2021", "y2022", "y2023")], na.rm = TRUE), dm$GEOCODE, sum) / 3
dha <- por_mun(dha)
cat("Desmatamento: municípios fora da planilha (= 0):", sum(is.na(dha)), "\n")
out$pct_desmat <- ifelse(is.na(dha), 0, dha) / (base$area_km2 * 100) * 100

# -----------------------------------------------------------------------------
# 3. População presa, 2º sem. de 2022 (SISDEPEN 13º ciclo), sem prisão domiciliar
# -----------------------------------------------------------------------------
sp <- read.csv2(file.path(C, "sisdepen/sisdepen_13o_ciclo_2022_2sem.csv"), check.names = FALSE,
                colClasses = "character", encoding = "UTF-8")
sp <- sp[!grepl("^Domiciliar", sp[["Tipo do Estabelecimento"]]), ]
tot <- grep("^4\\.1 População prisional \\| .* \\| Total$", names(sp), value = TRUE)   # provisórios, regimes, medidas
presos <- rowSums(sapply(sp[tot], function(x) suppressWarnings(as.numeric(x))), na.rm = TRUE)
cod <- as.integer(as.numeric(sp[["Código IBGE"]]))           # vem como "1200104.0"
cat("SISDEPEN: estabelecimentos sem código IBGE:", sum(is.na(cod)), "| presos neles:", sum(presos[is.na(cod)]), "\n")
pr <- por_mun(tapply(presos, cod, sum))
out$pct_presos <- ifelse(is.na(pr), 0, pr) / base$pop * 100

# -----------------------------------------------------------------------------
# 4. Educação: abandono e distorção idade-série no ensino médio (INEP 2022)
#    Linha Localização = Total e Dependência = Total; "--" = sem ensino médio (NA)
# -----------------------------------------------------------------------------
le_inep <- function(zip, coluna) {
  arq <- grep("xlsx$", unzip(file.path(C, "inep", zip), exdir = tmp), value = TRUE)
  x <- read_excel(arq, skip = 8, col_types = "text")
  x <- x[!is.na(x$CO_MUNICIPIO) & x$NO_CATEGORIA == "Total" & x$NO_DEPENDENCIA == "Total", ]
  por_mun(setNames(round(suppressWarnings(as.numeric(x[[coluna]])), 1), x$CO_MUNICIPIO))
}
out$abandono_em  <- le_inep("tx_rend_municipios_2022.zip", "3_CAT_MED")
out$distorcao_em <- le_inep("TDI_2022_MUNICIPIOS.zip", "MED_CAT_0")

# -----------------------------------------------------------------------------
# 5. Guarda municipal (MUNIC 2023, Segurança Pública, MSEG27 "Guarda municipal - existência")
# -----------------------------------------------------------------------------
mu <- read_excel(file.path(C, "munic_2023/Base_MUNIC_2023.xlsx"), sheet = "Segurança Pública")
gm <- c("Sim" = 1, "Não" = 0)[mu$MSEG27]                     # "Não informou" = NA
out$guarda_municipal <- por_mun(setNames(unname(gm), mu$CodMun))

# -----------------------------------------------------------------------------
# 6. Gini 2010 (Censo 2010 via DATASUS, página HTML; código de 6 dígitos)
# -----------------------------------------------------------------------------
h <- readLines(file.path(C, "gini_2010/datasus_ginibr_1991_2000_2010.html"), encoding = "latin1", warn = FALSE)
i <- grep("^\\s*<td>[0-9]{6} ", h)
g10 <- sub(",", ".", gsub("<[^>]+>|\\s", "", h[i + 3]))      # 3a coluna depois do nome = 2010
out$gini_2010 <- por_mun(setNames(suppressWarnings(as.numeric(g10)), sub("^\\s*<td>([0-9]{6}).*", "\\1", h[i])), 6)

# -----------------------------------------------------------------------------
# 7. Assentamentos (INCRA/SIPRA, relatório de 06/03/2026), por nome + UF do município sede
#    Só projetos criados até 2023; projeto em vários municípios fica todo no sede
# -----------------------------------------------------------------------------
l <- readLines(file.path(C, "incra_assentamentos/assentamentosgeral.csv"), encoding = "latin1", warn = FALSE)
l <- unlist(strsplit(iconv(l, "latin1", "UTF-8"), "\r"))
l <- l[grepl("^[A-Z]{2}[0-9]{7};", l)]
a <- as.data.frame(do.call(rbind, lapply(strsplit(l, ";"), `[`, 1:10)))
names(a) <- c("codigo", "nome", "sede", "area_ha", "capacidade", "familias", "fase", "tipo", "numero", "criacao")
a$area_ha  <- as.numeric(gsub(",", ".", gsub("\\.", "", a$area_ha)))
a$familias <- as.numeric(a$familias)
a$ano <- as.integer(substr(a$criacao, 7, 10))
cat("INCRA:", nrow(a), "projetos |", sum(a$ano > 2023, na.rm = TRUE), "criados depois de 2023 (fora) |",
    sum(is.na(a$ano)), "sem data\n")
a <- a[!is.na(a$ano) & a$ano <= 2023, ]
# UF pelas 2 letras do código (sigla da superintendência): AT, MB e SM = PA; MF = PE ou BA;
# DF também atende GO e MG. Se não casar, usa o nome quando ele existe numa única UF do país
sig <- substr(a$codigo, 1, 2)
sig[sig %in% c("AT", "MB", "SM")] <- "PA"
ufs <- list(MF = c("PE", "BA"), DF = c("DF", "GO", "MG"))
nome_base <- sub(" [A-Z]{2}$", "", chave_base)
unico <- setdiff(nome_base, nome_base[duplicated(nome_base)])
# Grafias do INCRA diferentes das do IBGE (nomes antigos ou com erro)
alias <- c(IGUARACI = "IGUARACY", SAOCAETANO = "SAOCAITANO", MUQUEMDESAOFRANCISCO = "MUQUEMDOSAOFRANCISCO",
           TRAJANODEMORAIS = "TRAJANODEMORAES", PARATI = "PARATY", MOJIDASCRUZES = "MOGIDASCRUZES",
           MOJIMIRIM = "MOGIMIRIM", CHIAPETA = "CHIAPETTA", POXOREO = "POXOREU",
           SANTOANTONIODOLEVERGER = "SANTOANTONIODELEVERGER", BATAIPORA = "BATAYPORA",
           PARAISODAAGUAS = "PARAISODASAGUAS", ALTOALEGREDOPARECIS = "ALTOALEGREDOSPARECIS",
           SAODOMINGOSDEPOMBAL = "SAODOMINGOS", SERIDO = "SAOVICENTEDOSERIDO", ACU = "ASSU",
           AUGUSTOSEVERO = "CAMPOGRANDE", GRACHOCARDOSO = "GRACCHOCARDOSO",
           AMPARODESAOFRANCISCO = "AMPARODOSAOFRANCISCO", SAOLUIZ = "SAOLUIZDOANAUA",
           SAOVALERIODANATIVIDADE = "SAOVALERIO", COUTODEMAGALHAES = "COUTOMAGALHAES",
           ELDORADODOSCARAJAS = "ELDORADODOCARAJAS", DISTRITOFEDERAL = "BRASILIA",
           BELEMDESAOFRANCISCO = "BELEMDOSAOFRANCISCO")
nome_a <- padroniza(a$sede)
nome_a <- ifelse(nome_a %in% names(alias), alias[nome_a], nome_a)
k <- mapply(function(n, s) {
  cand <- paste(n, if (s %in% names(ufs)) ufs[[s]] else s)
  if (any(cand %in% chave_base)) return(cand[cand %in% chave_base][1])
  if (n %in% unico) return(chave_base[nome_base == n])
  cand[1]
}, nome_a, sig, USE.NAMES = FALSE)
cat("INCRA: projetos sem município casado por nome + UF:", sum(!k %in% chave_base),
    "| famílias neles:", sum(a$familias[!k %in% chave_base], na.rm = TRUE), "\n")
if (any(!k %in% chave_base)) print(unique(k[!k %in% chave_base]))
fa <- tapply(a$familias, k, sum, na.rm = TRUE)[chave_base]
ar <- tapply(a$area_ha, k, sum, na.rm = TRUE)[chave_base]
out$assent_familias <- ifelse(is.na(fa), 0, fa) / base$pop * 1000
out$pct_area_assent <- pmin(ifelse(is.na(ar), 0, ar) / (base$area_km2 * 100) * 100, 100)   # cortada em 100

# -----------------------------------------------------------------------------
# 8. Focos de queimada (INPE, satélite de referência), média 2021-2023 por km²
#    Cada foco vai para o município cujo polígono contém o ponto (lat/lon)
# -----------------------------------------------------------------------------
sf_use_s2(FALSE)                                             # junção plana, mais rápida
malha <- st_read("dados/malha_mun.geojson", quiet = TRUE)
focos <- do.call(rbind, lapply(2021:2023, function(a) {
  arq <- unzip(file.path(C, sprintf("inpe_focos/focos_br_ref_%d.zip", a)), exdir = tmp)
  read.csv(arq, colClasses = "character")[, c("lat", "lon")]
}))
pts <- st_as_sf(data.frame(lat = as.numeric(focos$lat), lon = as.numeric(focos$lon)),
                coords = c("lon", "lat"), crs = 4326)
dentro <- suppressMessages(st_within(pts, st_transform(malha, 4326)))
mun_foco <- malha$codarea[sapply(dentro, function(z) if (length(z)) z[1] else NA)]
cat("INPE:", nrow(pts), "focos 2021-2023 |", sum(is.na(mun_foco)), "fora de qualquer polígono da malha (descartados)\n")
nf <- por_mun(table(mun_foco))
out$focos_km2 <- ifelse(is.na(nf), 0, nf) / 3 / base$area_km2

# -----------------------------------------------------------------------------
# 9. Cobertura potencial da APS, dez/2022 (Ministério da Saúde; código de 6 dígitos), cortada em 100
# -----------------------------------------------------------------------------
aps <- fromJSON(file.path(C, "cobertura_aps/cobertura_aps_202212.json"))
out$cobertura_aps <- pmin(por_mun(setNames(aps$qtCobertura, aps$coMunicipioIbge), 6), 100)

# -----------------------------------------------------------------------------
# 10. Despesa municipal 2022 nas funções 06 (Segurança) e 08 (Assistência), despesas liquidadas
#     (SICONFI, DCA Anexo I-E). Quem entregou a DCA e não tem a função = 0; quem não entregou = NA
# -----------------------------------------------------------------------------
arq_dca <- file.path(C, "siconfi_dca/dca_2022_funcoes_06_08.csv")
if (file.exists(arq_dca)) {
  dca <- read.csv(arq_dca, stringsAsFactors = FALSE)
  liq <- dca[!is.na(dca$coluna) & dca$coluna == "Despesas Liquidadas", ]
  entregou <- base$cod_ibge %in% liq$cod_ibge[grepl("^Despesas Exceto Intra", liq$conta)]
  funcao <- function(f) {
    v <- por_mun(tapply(liq$valor[startsWith(liq$conta, f)], liq$cod_ibge[startsWith(liq$conta, f)], sum))
    ifelse(entregou, ifelse(is.na(v), 0, v), NA) / base$pop
  }
  out$desp_seg_pc    <- funcao("06 - ")
  out$desp_assist_pc <- funcao("08 - ")
  cat("SICONFI: municípios sem DCA 2022:", sum(!entregou), "\n")
} else {
  warning("SICONFI: ", arq_dca, " ainda não existe; desp_seg_pc e desp_assist_pc ficam NA")
  out$desp_seg_pc <- out$desp_assist_pc <- NA_real_
}

# -----------------------------------------------------------------------------
# 11. Bolsa Família / Auxílio Brasil (Portal da Transparência, coletado na tela de consulta)
#     Arquivo: ano;programa;uf;municipio;valor_total;meses. O portal não traz o nº de
#     beneficiários por município: usamos o valor transferido por habitante por ano
#     (soma dos programas, média dos anos disponíveis). Junta por nome + UF.
# -----------------------------------------------------------------------------
bf_arqs <- list.files(file.path(C, "bolsa_familia"), pattern = "^bolsa_familia_municipios.*\\.csv$", full.names = TRUE)
out$bf_pc <- NA_real_
if (length(bf_arqs)) {
  bf <- do.call(rbind, lapply(bf_arqs, read.csv2, fileEncoding = "UTF-8-BOM", dec = ".", colClasses = c(municipio = "character")))
  bf <- bf[!duplicated(bf[, c("ano", "programa", "uf", "municipio")]), ]
  # O portal ainda usa nomes antigos de 25 municípios: troca pelo nome atual do IBGE
  antigos <- c("AMPARO DE SÃO FRANCISCO|SE" = "Amparo do São Francisco", "ARÊS|RN" = "Arez", "AUGUSTO SEVERO|RN" = "Campo Grande",
               "AÇU|RN" = "Assú", "BARÃO DE MONTE ALTO|MG" = "Barão do Monte Alto", "BRASÓPOLIS|MG" = "Brazópolis",
               "DONA EUSÉBIA|MG" = "Dona Euzébia", "ELDORADO DOS CARAJÁS|PA" = "Eldorado do Carajás", "EMBU|SP" = "Embu das Artes",
               "FLORÍNIA|SP" = "Florínea", "FORTALEZA DO TABOCÃO|TO" = "Tabocão", "GRACHO CARDOSO|SE" = "Graccho Cardoso",
               "IGUARACI|PE" = "Iguaracy", "ITAPAGÉ|CE" = "Itapajé", "MUQUÉM DE SÃO FRANCISCO|BA" = "Muquém do São Francisco",
               "POXORÉO|MT" = "Poxoréu", "PRESIDENTE JUSCELINO|RN" = "Serra Caiada", "SANTA ISABEL DO PARÁ|PA" = "Santa Izabel do Pará",
               "SANTA TERESINHA|BA" = "Santa Terezinha", "SANTO ANTÔNIO DO LEVERGER|MT" = "Santo Antônio de Leverger",
               "SERIDÓ|PB" = "São Vicente do Seridó", "SÃO LUIZ|RR" = "São Luiz do Anauá",
               "SÃO LUÍS DO PARAITINGA|SP" = "São Luiz do Paraitinga", "SÃO THOMÉ DAS LETRAS|MG" = "São Tomé das Letras",
               "TRAJANO DE MORAIS|RJ" = "Trajano de Moraes")
  ka <- paste(bf$municipio, bf$uf, sep = "|")
  bf$municipio[ka %in% names(antigos)] <- antigos[ka[ka %in% names(antigos)]]
  k <- paste(padroniza(bf$municipio), toupper(trimws(bf$uf)))
  cat("Bolsa Família: anos", paste(sort(unique(bf$ano)), collapse = ", "), "| linhas sem município casado por nome + UF:", sum(!k %in% chave_base), "\n")
  por_ano <- tapply(bf$valor_total, list(k, bf$ano), sum)                 # R$ por município e ano
  out$bf_pc <- unname(rowMeans(por_ano, na.rm = TRUE)[chave_base]) / base$pop
} else {
  warning("Bolsa Família: nenhum CSV em ", file.path(C, "bolsa_familia"), "; bf_pc fica NA")
}

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 12. Gravação da tabela e do dicionário
# -----------------------------------------------------------------------------
ordem <- c("cod_ibge", "pct_desmat", "pct_presos", "pib_pc", "ln_pib_pc", "pct_agro", "pct_ind", "pct_adm",
           "pct_favela", "freq_18a24", "abandono_em", "distorcao_em", "guarda_municipal", "gini_2010",
           "cresc_pop", "pct_migr_10anos", "pct_migr_outra_uf", "pct_maes_solo", "emprego_formal",
           "pct_informal", "assent_familias", "pct_area_assent", "pct_soja", "bovinos_km2", "focos_km2",
           "cobertura_aps", "desp_seg_pc", "desp_assist_pc", "bf_pc")
out <- out[order(out$cod_ibge), ordem]
write.csv(out, "dados/tabelas/candidatas.csv", row.names = FALSE)

dic <- c(
  cod_ibge = "Código IBGE do município (7 dígitos)",
  pct_desmat = "Desmatamento médio anual 2021-2023 em % da área: MapBiomas Col. 11, aba ANNUAL_DEFORESTATION, soma das transições (perda de vegetação primária e secundária), ha / (area_km2 x 100) x 100; fora da planilha = 0",
  pct_presos = "Presos em estabelecimentos no 2º sem. 2022 / pop x 100: SISDEPEN 13º ciclo, soma das colunas '4.1 População prisional | ... | Total' (provisórios, regimes fechado/semiaberto/aberto, medidas de segurança), sem 'Domiciliar'; sem estabelecimento = 0",
  pib_pc = "PIB 2022 per capita, R$: SIDRA 5938 var. 37 (mil R$) x 1000 / pop (Censo 2022)",
  ln_pib_pc = "ln(pib_pc)",
  pct_agro = "Participação da agropecuária no valor adicionado bruto, %, 2021 (SIDRA 5938 var. 516)",
  pct_ind = "Participação da indústria no valor adicionado bruto, %, 2021 (SIDRA 5938 var. 520)",
  pct_adm = "Participação da administração, defesa, educação, saúde públicas e seguridade no valor adicionado bruto, %, 2021 (SIDRA 5938 var. 528)",
  pct_favela = "População em favelas e comunidades urbanas / pop x 100, Censo 2022 (SIDRA 9888 var. 9612); fora da tabela = 0",
  freq_18a24 = "Taxa de frequência escolar bruta de 18 a 24 anos, %, Censo 2022 (SIDRA 10056, categoria 100052)",
  abandono_em = "Taxa de abandono no ensino médio, %, 2022 (INEP, tx_rend_municipios_2022, coluna 3_CAT_MED, localização Total e rede Total); NA = sem ensino médio",
  distorcao_em = "Taxa de distorção idade-série no ensino médio, %, 2022 (INEP, TDI_MUNICIPIOS_2022, coluna MED_CAT_0, localização Total e rede Total); NA = sem ensino médio",
  guarda_municipal = "1 se o município tem guarda municipal (MUNIC 2023, aba Segurança Pública, MSEG27 'Guarda municipal - existência'); 'Não informou' = NA",
  gini_2010 = "Índice de Gini da renda domiciliar per capita, Censo 2010 (IBGE via DATASUS ginibr.def); NA = municípios criados depois de 2010",
  cresc_pop = "Taxa de crescimento geométrico anual da população 2010-2022, % (SIDRA 4709 var. 10605)",
  pct_migr_10anos = "Pessoas que residiam há menos de 10 anos no município / pop x 100, Censo 2022 (SIDRA 10158 var. 13338)",
  pct_migr_outra_uf = "Pessoas de 5+ anos que moravam em outra UF 5 anos antes / pop x 100, Censo 2022 (SIDRA 10159 var. 13339)",
  pct_maes_solo = "Domicílios com responsável mulher sem cônjuge com filho(s)/enteado(s) / total de domicílios particulares x 100, Censo 2022 (SIDRA 9882 var. 800; numerador 72607 x 100681, denominador 72603 x 100679)",
  emprego_formal = "Pessoal ocupado assalariado 2022 / pop x 100 (CEMPRE, SIDRA 9509 var. 708; conta pelo local da empresa)",
  pct_informal = "Ocupados de 14+ anos que não contribuem para a previdência / total de ocupados x 100, Censo 2022 (SIDRA 10264, categorias 15351 / 15349)",
  assent_familias = "Famílias assentadas ('FAMILIAS ASSENT.') por 1.000 hab.: INCRA/SIPRA (relatório 06/03/2026), projetos criados até 2023, todo o projeto no município sede, junção por nome + UF; sem projeto = 0",
  pct_area_assent = "Área dos projetos de assentamento / área do município x 100: INCRA/SIPRA, mesmos critérios de assent_familias; cortada em 100 (projeto que cruza municípios fica todo no sede; reservas marinhas; erro de área do INCRA em Tomar do Geru-SE)",
  pct_soja = "Área plantada de soja 2022 / (area_km2 x 100) x 100 (PAM, SIDRA 5457 var. 8331, produto 40124); '-' = 0; fora da tabela ou '...' = 0 (sem lavoura)",
  bovinos_km2 = "Efetivo de bovinos 2022 / area_km2 (PPM, SIDRA 3939 var. 105); '-' = 0; fora da tabela ou '...' = 0 (sem rebanho)",
  focos_km2 = "Média anual de focos de queimada 2021-2023 / area_km2 (INPE BDQueimadas, satélite de referência; foco atribuído pelo ponto lat/lon dentro da malha municipal)",
  cobertura_aps = "Cobertura potencial da Atenção Primária, %, dez/2022 (Ministério da Saúde, qtCobertura), cortada em 100",
  desp_seg_pc = "Despesa liquidada 2022 na função 06 Segurança Pública / pop, R$ (SICONFI DCA Anexo I-E); entregou a DCA sem a função = 0; não entregou = NA",
  desp_assist_pc = "Despesa liquidada 2022 na função 08 Assistência Social / pop, R$ (SICONFI DCA Anexo I-E); entregou a DCA sem a função = 0; não entregou = NA",
  bf_pc = "Valor transferido pelo Bolsa Família / Auxílio Brasil por habitante, R$ por ano (média dos anos baixados; Portal da Transparência)")
write.csv(data.frame(coluna = names(dic), descricao = dic), "dados/tabelas/dicionario_candidatas.csv", row.names = FALSE)

# Cópia para a pasta do código de entrega (o modelo usa algumas destas variáveis)
usadas <- c("abandono_em", "distorcao_em", "pct_migr_10anos")      # as que entraram no modelo
write.csv(out[, c("cod_ibge", usadas)], "entrega/dados/variaveis_extras.csv", row.names = FALSE)
write.csv(data.frame(coluna = usadas, descricao = dic[usadas]), "entrega/dados/dicionario_extras.csv", row.names = FALSE)

cat(sprintf("\nCandidatas: %d municípios x %d variáveis\n", nrow(out), ncol(out) - 1))
