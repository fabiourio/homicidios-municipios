args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Uso (na raiz do repositório): Rscript scripts/04_montar_zip_entrega.R pasta_de_destino")
destino <- normalizePath(args[1], mustWork = FALSE)
nome <- "GED16_homicidios_municipios"
raiz <- file.path(destino, nome)
if (dir.exists(raiz)) stop("A pasta ", raiz, " já existe; use um destino vazio.")

arquivos <- c(
  "1_slides/apresentacao_final.pdf"  = "apresentacao/apresentacao_final.pdf",
  "1_slides/apresentacao_final.pptx" = "apresentacao/apresentacao_final.pptx",
  "2_codigo/analise_final.qmd"       = "entrega/analise_final.qmd",
  "2_codigo/analise_final.html"      = "entrega/analise_final.html",
  "2_codigo/LEIA-ME.md"              = "entrega/LEIA-ME.md",
  setNames(file.path("entrega/dados", c("base_analitica.csv", "variaveis_extras.csv", "malha_mun.geojson",
                                        "dicionario.csv", "dicionario_extras.csv", "validacao_gini.csv")),
           file.path("2_codigo/dados", c("base_analitica.csv", "variaveis_extras.csv", "malha_mun.geojson",
                                         "dicionario.csv", "dicionario_extras.csv", "validacao_gini.csv"))),
  setNames(file.path("artigo", c("artigo.tex", "artigo.pdf", "referencias.bib", "sbpo-template.sty", "sbpo.bst", "numeros.tex")),
           file.path("3_artigo", c("artigo.tex", "artigo.pdf", "referencias.bib", "sbpo-template.sty", "sbpo.bst", "numeros.tex")))
)
extras <- list.files("artigo", pattern = "\\.(png|tex)$", recursive = TRUE)
extras <- extras[dirname(extras) %in% c("figuras", "tabelas")]
arquivos <- c(arquivos, setNames(file.path("artigo", extras), file.path("3_artigo", extras)))

stopifnot(all(file.exists(arquivos)))
for (p in unique(dirname(names(arquivos)))) dir.create(file.path(raiz, p), recursive = TRUE, showWarnings = FALSE)
stopifnot(all(file.copy(arquivos, file.path(raiz, names(arquivos)))))
stopifnot(identical(unname(tools::md5sum(arquivos)), unname(tools::md5sum(file.path(raiz, names(arquivos))))))

zip_final <- file.path(destino, paste0(nome, ".zip"))
old <- setwd(destino)
utils::zip(zip_final, nome, flags = "-r9Xq")
setwd(old)
cat("Gerado:", zip_final, "|", length(arquivos), "arquivos\n")
