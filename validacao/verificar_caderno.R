origem <- "entrega"
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Uso: Rscript validacao/verificar_caderno.R pasta_da_execucao_isolada")
copia <- args[1]
files <- list.files(file.path(origem, "resultados"), pattern = "[.]csv$", recursive = TRUE)
for (f in files) {
 a <- read.csv(file.path(origem, "resultados", f), check.names = FALSE)
 b <- read.csv(file.path(copia, "resultados", f), check.names = FALSE)
 stopifnot(isTRUE(all.equal(a, b, tolerance = 1e-12)))
}
qmd <- readLines(file.path(origem, "analise_final.qmd"))
for (x in list(c("exploratoria <- local({", "  list(d = d, br = br)", "1_analise_exploratoria.R"),
               c("modelo <- local({", "  stopifnot(nrow(d) == 1133, final$rank == 14, df.residual(final) == 1119,", "2_modelo.R"))) {
 ini <- match(x[1], qmd) + 1
 fim <- match(x[2], qmd) - 1
 stopifnot(identical(sub("^  ", "", qmd[ini:fim]), readLines(file.path(origem, x[3]))))
}
h <- xml2::read_html(file.path(origem, "analise_final.html"))
stopifnot(all(startsWith(xml2::xml_attr(xml2::xml_find_all(h, "//img"), "src"), "data:")))
cat("OK:",length(files),"tabelas reproduzidas com tolerância 1e-12; dois códigos embutidos idênticos; imagens incorporadas.\n")
