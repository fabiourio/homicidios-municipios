library(jsonlite)
library(readxl)
b <- read.csv("dados/tabelas/base_analitica.csv")
e <- read.csv("entrega/dados/variaveis_extras.csv")
cand <- read.csv("dados/tabelas/candidatas.csv")
e <- e[match(b$cod_ibge, e$cod_ibge), ]
cand <- cand[match(b$cod_ibge, cand$cod_ibge), ]
check <- function(label, raw, saved) {
  neq <- is.na(raw) != is.na(saved) | (!is.na(raw) & !is.na(saved) & abs(raw-saved)>1e-10)
  cat(label, ": n=", length(raw), "; NA=",sum(is.na(raw)), "; divergencias=",sum(neq), "; maior_diff=", max(abs(raw-saved),na.rm=TRUE), "\n",sep="")
  stopifnot(!any(neq))
}
for (z in c("TDI_2022_MUNICIPIOS.zip","tx_rend_municipios_2022.zip")) {
  path <- file.path("dados/candidatos/inep", z)
  files <- unzip(path,list=TRUE)$Name
  target <- grep("xlsx$", files, value=TRUE)
  xlsx <- unzip(path,files=target,exdir=tempdir())
  cat("\nZIP:",z,"\nNotas/cabecalho:\n")
  top <- suppressMessages(read_excel(xlsx,n_max=8,col_names=FALSE,col_types="text"))
  vals <- unique(as.character(unlist(top)))
  vals <- vals[!is.na(vals) & grepl("Taxa|Taxas|2022|Instituto Nacional", vals)]
  cat(paste(vals, collapse = "\n"), "\n", sep = "")
  x <- suppressMessages(read_excel(xlsx,skip=8,col_types="text"))
  total <- x[!is.na(x$CO_MUNICIPIO) & x$NO_CATEGORIA=="Total" & x$NO_DEPENDENCIA=="Total",]
  cat("Fonte Total/Total:", nrow(total),"linhas; chaves duplicadas:",sum(duplicated(total$CO_MUNICIPIO)),"; codigos ausentes:",sum(!b$cod_ibge %in% total$CO_MUNICIPIO),"\n")
  campo <- if(z=="TDI_2022_MUNICIPIOS.zip") "MED_CAT_0" else "3_CAT_MED"
  variable <- if(z=="TDI_2022_MUNICIPIOS.zip") "distorcao_em" else "abandono_em"
  raw <- round(suppressWarnings(as.numeric(total[[campo]])),1)[match(b$cod_ibge,total$CO_MUNICIPIO)]
  check(paste(variable,"entrega"),raw,e[[variable]])
  check(paste(variable,"candidatas"),raw,cand[[variable]])
  print(data.frame(municipio=b$municipio[is.na(raw)],uf=b$uf[is.na(raw)],pop=b$pop[is.na(raw)],valor_bruto=total[[campo]][match(b$cod_ibge[is.na(raw)],total$CO_MUNICIPIO)]),row.names=FALSE)
}
f <- fromJSON("dados/candidatos/frequencia_escolar_censo2022/sidra_10056_freq_15a17_18a24.json")[-1,]
for (age in c("2792","100052")) {
  s <- f[f$D4C==age,]
  cat("Frequencia grupo",age,": duplicados",sum(duplicated(s$D1C)),"; codigos ausentes",sum(!b$cod_ibge %in% s$D1C),"\n")
  raw <- as.numeric(s$V)[match(b$cod_ibge,s$D1C)]
  check(paste("freq",age),raw,if(age=="2792") b$freq_15a17 else cand$freq_18a24)
}
m <- fromJSON("dados/candidatos/migracao_censo2022/sidra_10158_menos10anos_no_municipio.json")[-1,]
m <- m[m$D2C=="13338",]
cat("Migracao: duplicados",sum(duplicated(m$D1C)),"; codigos ausentes",sum(!b$cod_ibge %in% m$D1C),"; unidades",paste(unique(m$MN),collapse="/"),"\n")
m$V[m$V=="-"] <- "0"
raw <- as.numeric(m$V)[match(b$cod_ibge,m$D1C)] / b$pop*100
check("pct_migr_10anos entrega",raw,e$pct_migr_10anos)
check("pct_migr_10anos candidatas",raw,cand$pct_migr_10anos)
cat("FIM: comparacoes validas = 8 x 5570 = 44560 celulas.\n")
