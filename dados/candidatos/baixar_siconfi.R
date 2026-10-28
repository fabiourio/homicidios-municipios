# USO INTERNO: despesa municipal por função (SICONFI/Tesouro, DCA Anexo I-E), 2022.
# Guarda só o total, 06 Segurança Pública e 08 Assistência Social. A API responde um município
# por vez: cada resposta é salva em cache/, então o script pode ser interrompido e rodado de novo.
# Uso (na raiz do repositório): Rscript dados/candidatos/baixar_siconfi.R

library(jsonlite)

pasta <- "dados/candidatos/siconfi_dca"
cache <- file.path(pasta, "cache")
dir.create(cache, recursive = TRUE, showWarnings = FALSE)
# Ordem: primeiro os municípios do escopo do modelo (20 mil hab. ou mais), depois os demais
b <- read.csv("dados/tabelas/base_analitica.csv")
cods <- c(b$cod_ibge[b$pop >= 20000], b$cod_ibge[b$pop < 20000])
api  <- "https://apidatalake.tesouro.gov.br/ords/siconfi/tt/dca?an_exercicio=2022&no_anexo=DCA-Anexo%20I-E&id_ente="

for (cod in cods) {
  arq <- file.path(cache, paste0(cod, ".rds"))
  if (file.exists(arq)) next
  itens <- NULL
  for (tentativa in 1:4) {
    itens <- tryCatch(fromJSON(paste0(api, cod))$items, error = function(e) "erro")
    if (!identical(itens, "erro")) break
    Sys.sleep(5 * tentativa)
  }
  if (identical(itens, "erro")) next                            # tenta de novo na próxima rodada
  if (NROW(itens)) itens <- itens[grepl("^(06|08) - |^Despesas Exceto Intra", itens$conta),
                                  intersect(c("cod_ibge", "conta", "coluna", "valor", "populacao"), names(itens))]
  saveRDS(if (NROW(itens)) itens else data.frame(cod_ibge = cod), arq)   # sem DCA entregue: linha vazia
  Sys.sleep(0.3)
}

feitos <- length(list.files(cache))
esc <- sum(file.exists(file.path(cache, paste0(b$cod_ibge[b$pop >= 20000], ".rds"))))
cat(sprintf("%d de %d municípios consultados (escopo: %d de %d)\n", feitos, length(cods), esc, sum(b$pop >= 20000)))
if (feitos == length(cods)) {
  tab <- do.call(rbind, lapply(list.files(cache, full.names = TRUE), function(f) {
    x <- readRDS(f); for (v in c("conta", "coluna", "valor", "populacao")) if (!v %in% names(x)) x[[v]] <- NA; x }))
  write.csv(tab, file.path(pasta, "dca_2022_funcoes_06_08.csv"), row.names = FALSE)
  cat("arquivo final gravado\n")
}
