# =============================================================================
# 00 - Coleta dos dados brutos nas fontes oficiais (opcional: os dados já estão no repositório)
#   1. SIDRA/IBGE (Censo 2022)  -> dados/raw/sidra_raw.json
#   2. TabNet/DATASUS (SIM)      -> dados/raw/tabnet_raw.json
#   3. Malha municipal do IBGE   -> dados/malha_mun.geojson
#   4. Extras: frequência escolar (SIDRA 10056) e garimpo (MapBiomas) -> dados/raw/
# Uso: Rscript scripts/00_coletar_dados.R              (baixa tudo)
#      Rscript scripts/00_coletar_dados.R sidra        (só uma parte: sidra | tabnet | malha | extras)
# =============================================================================

# Roda a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")

library(jsonlite)
library(httr)

dir.create("dados/raw", recursive = TRUE, showWarnings = FALSE)
UA <- user_agent("projeto-academico-regressao/1.0")

# GET com novas tentativas (as APIs do governo às vezes falham)
baixa <- function(url) {
  for (tentativa in 1:5) {
    r <- tryCatch(GET(url, UA, timeout(120)), error = function(e) NULL)
    if (!is.null(r) && status_code(r) == 200) return(r)
    message("   falhou; tentando de novo...")
    Sys.sleep(3 * tentativa)
  }
  stop("não consegui baixar ", url)
}

UFS <- c(11:17, 21:29, 31:33, 35, 41:43, 50:53)

# -----------------------------------------------------------------------------
# 1. SIDRA - tabelas do Censo 2022, por município (consulta feita UF por UF)
# -----------------------------------------------------------------------------
SIDRA <- list(  # tabela, variáveis, classificações
  c("4709",  "93",                "")                                                         ,  # população
  c("4714",  "93|6318|614",       "")                                                         ,  # pop, área, densidade
  c("10295", "13604|13431|13534", "2[6794]|86[95251]|58[95253]")                              ,  # renda pc média e mediana
  c("10300", "13432",             "629[32385]|386[all]")                                      ,  # pessoas 14+ por classe de renda pc
  c("9517",  "1641",              "629[32385,32386,32387,32446,32447]|2[6794]|86[95251]|1568[120704]"),  # força de trabalho
  c("9543",  "2513",              "2[6794]|86[95251]|287[100362]")                            ,  # alfabetização
  c("9923",  "93",                "1[6795,1,2]")                                              ,  # situação urbana/rural
  c("9605",  "93",                "86[95251,2776,2777,2778,2779,2780]")                       ,  # cor ou raça
  c("9606",  "93",                "86[95251]|2[4]|287[93086,93087,93088]"))                      # homens 15-29

coletar_sidra <- function() {
  base <- "https://servicodados.ibge.gov.br/api/v3/agregados/"
  out <- list()
  for (s in SIDRA) {
    t <- s[1]; v <- s[2]; cl <- s[3]
    message("SIDRA ", t, "...")
    cols <- character(0); dados <- list()
    for (uf in UFS) {
      url <- sprintf("%s%s/periodos/2022/variaveis/%s?localidades=N6[N3[%d]]%s", base, t, v, uf,
                     if (cl != "") paste0("&classificacao=", cl) else "")
      js <- fromJSON(content(baixa(URLencode(url)), "text", encoding = "UTF-8"), simplifyVector = FALSE)
      for (V in js) for (R in V$resultados) {
        lab <- sprintf("v%s %s", V$id, V$variavel)
        if (length(R$classificacoes))
          lab <- paste0(lab, " | ", paste(sapply(R$classificacoes, function(k)
            paste0(k$nome, "=", unlist(k$categoria)[1])), collapse = " | "))
        lab <- sprintf("%s [%s]", lab, V$unidade)
        if (!lab %in% cols) cols <- c(cols, lab)
        j <- match(lab, cols)
        for (se in R$series) {
          id <- se$localidade$id
          if (is.null(dados[[id]])) dados[[id]] <- list(nome = se$localidade$nome, v = list())
          dados[[id]]$v[[as.character(j)]] <- se$serie[["2022"]]
        }
      }
    }
    rows <- lapply(names(dados), function(id) {
      r <- dados[[id]]
      c(list(id, r$nome), lapply(seq_along(cols), function(k) r$v[[as.character(k)]]))
    })
    out[[t]] <- list(cols = cols, rows = rows,
                     url = sprintf("%s%s/periodos/2022/variaveis/%s?localidades=N6[all]%s", base, t, v,
                                   if (cl != "") paste0("&classificacao=", cl) else ""))
    message(sprintf("   %d colunas, %d municípios", length(cols), length(rows)))
  }
  write(toJSON(out, auto_unbox = TRUE, null = "null"), "dados/raw/sidra_raw.json")
}

# -----------------------------------------------------------------------------
# 2. TabNet - óbitos por causas externas (SIM), por município de residência
#    O formulário do TabNet espera os campos codificados em Latin-1
# -----------------------------------------------------------------------------
TABNET <- "http://tabnet.datasus.gov.br/cgi/tabcgi.exe?sim/cnv/ext10br.def"
FILTROS <- c("SMunicípio", "SCapital", "SRegião_de_Saúde_(CIR)", "SMacrorregião_de_Saúde", "SMicrorregião_IBGE",
             "SRegião_Metropolitana_-_RIDE", "STerritório_da_Cidadania", "SMesorregião_PNDR", "SAmazônia_Legal",
             "SSemiárido", "SFaixa_de_Fronteira", "SZona_de_Fronteira", "SMunicípio_de_extrema_pobreza",
             "SGrande_Grupo_CID10", "SGrupo_CID10", "SCategoria_CID10", "SFaixa_Etária", "SFaixa_Etária_OPS",
             "SFaixa_Etária_det", "SFx.Etária_Menor_1A", "SSexo", "SCor/raça", "SEscolaridade", "SEstado_civil",
             "SLocal_ocorrência", "SAcid._Trabalho")

# Codifica um texto em Latin-1 para envio no formulário
cod_latin1 <- function(x) {
  b <- iconv(x, from = "UTF-8", to = "latin1", toRaw = TRUE)[[1]]
  ok <- b %in% charToRaw("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
  paste0(ifelse(ok, rawToChar(b, multiple = TRUE), sprintf("%%%02X", as.integer(b))), collapse = "")
}

tabnet <- function(coluna, anos, filtros = list()) {
  campos <- list(c("Linha", "Município"), c("Coluna", coluna), c("Incremento", "Óbitos_p/Residênc"))
  for (a in anos) campos[[length(campos) + 1]] <- c("Arquivos", sprintf("extbr%02d.dbf", a %% 100))
  for (f in FILTROS) for (val in if (is.null(filtros[[f]])) "TODAS_AS_CATEGORIAS__" else filtros[[f]])
    campos[[length(campos) + 1]] <- c(f, val)
  campos <- c(campos, list(c("formato", "prn"), c("mostre", "Mostra")))
  corpo <- paste(sapply(campos, function(k) paste0(cod_latin1(k[1]), "=", cod_latin1(k[2]))), collapse = "&")
  r <- POST(TABNET, UA, timeout(300), body = corpo, content_type("application/x-www-form-urlencoded"))
  stop_for_status(r)
  txt <- iconv(rawToChar(content(r, "raw")), from = "latin1", to = "UTF-8")
  m <- regmatches(txt, regexpr("(?is)<PRE>.*?</PRE>", txt, perl = TRUE))
  if (!length(m)) stop("TabNet não devolveu tabela (o formulário pode ter mudado).")
  gsub("<[^>]+>", "", m)
}

coletar_tabnet <- function() {
  out <- list()
  message("TabNet 2021-2023..."); out$h2123 <- tabnet("Grande_Grupo_CID10", 2021:2023)
  message("TabNet 2024...");      out$h24   <- tabnet("Grande_Grupo_CID10", 2024)
  anos <- 2010:2024   # para listar municípios, qualquer óbito externo no período basta
  message("TabNet Amazônia Legal...");     out$ama <- tabnet("--Não-Ativa--", anos, list(SAmazônia_Legal = "1"))
  message("TabNet faixa de fronteira..."); out$fro <- tabnet("--Não-Ativa--", anos, list(SFaixa_de_Fronteira = "1"))
  write(toJSON(out, auto_unbox = TRUE), "dados/raw/tabnet_raw.json")
}

# -----------------------------------------------------------------------------
# 3. Malha municipal (GeoJSON, qualidade mínima - suficiente para mapas)
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 4. Variáveis extras: frequência escolar (Censo 2022) e garimpo (MapBiomas)
# -----------------------------------------------------------------------------
coletar_extras <- function() {
  message("Frequência escolar (SIDRA 10056)...")
  url <- "https://apisidra.ibge.gov.br/values/t/10056/n6/all/v/3795/p/2022/c58/2792,100052/c2/6794/c86/95251"
  writeBin(content(baixa(url), "raw"), "dados/raw/sidra_10056_freq_escolar.json")
  message("MapBiomas - substância minerada por município (Coleção 11)...")
  url <- paste0("https://brasil.mapbiomas.org/wp-content/uploads/sites/3/2026/10/",
                "MAPBIOMAS-BRAZIL-MINED-SUBSTANCES-MUNICIPALITY-COLLECTION_11.xlsx")
  writeBin(content(baixa(url), "raw"), "dados/raw/mapbiomas_mineracao_col11.xlsx")
}

coletar_malha <- function() {
  message("Malha municipal...")
  url <- paste0("https://servicodados.ibge.gov.br/api/v3/malhas/paises/BR",
                "?intrarregiao=municipio&formato=application/vnd.geo%2Bjson&qualidade=minima")
  writeBin(content(baixa(url), "raw"), "dados/malha_mun.geojson")
}

partes <- commandArgs(trailingOnly = TRUE)
if (!length(partes)) partes <- c("sidra", "tabnet", "malha", "extras")
if ("sidra"  %in% partes) coletar_sidra()
if ("tabnet" %in% partes) coletar_tabnet()
if ("malha"  %in% partes) coletar_malha()
if ("extras" %in% partes) coletar_extras()
message("Pronto. Rode agora: Rscript scripts/01_preparar_dados.R")
