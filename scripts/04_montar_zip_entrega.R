args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Uso (na raiz do repositório): Rscript scripts/04_montar_zip_entrega.R pasta_de_destino")
destino <- normalizePath(args[1], mustWork = FALSE)
nome <- "GED16_homicidios_municipios"
raiz <- file.path(destino, nome)
if (dir.exists(raiz)) stop("A pasta ", raiz, " já existe; use um destino vazio.")

# O artigo usa cópias das figuras, tabelas e números gerados pelo caderno: precisam estar iguais
res <- "entrega_final/resultados"
copias <- c(numeros.tex = "numeros.tex", setNames(file.path("tabelas", list.files("artigo/tabelas")), file.path("tabelas", list.files("artigo/tabelas"))),
            setNames(file.path("figuras", list.files("artigo/figuras")), file.path("figuras", list.files("artigo/figuras"))))
stopifnot(identical(unname(tools::md5sum(file.path("artigo", copias))), unname(tools::md5sum(file.path(res, names(copias))))))
figuras <- copias[startsWith(copias, "figuras/")]
embute <- function(tex, pasta) {
  for (i in grep("^\\\\input\\{", tex)) {
    arq <- sub("^\\\\input\\{([^}]+)\\}%?$", "\\1", tex[i])
    tex[i] <- paste(readLines(file.path(pasta, arq), encoding = "UTF-8"), collapse = "\n")
  }
  tex
}

dados <- c("base_municipios.csv", "gini_oficial.csv", "malha_mun.geojson", "dicionario.csv")
arquivos <- c(
  "codigo/analise_final.qmd" = "entrega_final/analise_final.qmd",
  setNames(file.path("entrega_final/dados", dados), file.path("codigo/dados", dados)),
  setNames(file.path("artigo", c("artigo.tex", "artigo.pdf", "referencias.bib", "sbpo-template.sty", "sbpo.bst", figuras)),
           file.path("artigo", c("artigo.tex", "artigo.pdf", "referencias.bib", "sbpo-template.sty", "sbpo.bst", figuras))))
stopifnot(all(file.exists(arquivos)))
for (p in unique(dirname(names(arquivos)))) dir.create(file.path(raiz, p), recursive = TRUE, showWarnings = FALSE)
stopifnot(all(file.copy(arquivos, file.path(raiz, names(arquivos)))))
stopifnot(identical(unname(tools::md5sum(arquivos)), unname(tools::md5sum(file.path(raiz, names(arquivos))))))
writeLines(embute(readLines("artigo/artigo.tex", encoding = "UTF-8"), "artigo"), file.path(raiz, "artigo/artigo.tex"), useBytes = TRUE)
stopifnot(!any(grepl("\\\\input\\{", readLines(file.path(raiz, "artigo/artigo.tex")))))

# Slides: as 15 páginas apresentadas, sem os apêndices de perguntas
invisible(qpdf::pdf_subset("apresentacao/apresentacao_final.pdf", pages = 1:15,
                 output = file.path(raiz, "apresentacao_final.pdf")))

zip_final <- file.path(destino, paste0(nome, ".zip"))
old <- setwd(destino)
utils::zip(zip_final, nome, flags = "-r9Xq")
setwd(old)
cat("Gerado:", zip_final, "\n")
