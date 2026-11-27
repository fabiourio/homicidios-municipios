# Uso e passos: .claude/skills/gerar-entrega-final/SKILL.md

args    <- commandArgs(trailingOnly = TRUE)
destino <- normalizePath(c(args[!startsWith(args, "--")], "entrega_zip")[1], mustWork = FALSE)
rscript <- file.path(R.home("bin"), "Rscript")
passo   <- function(msg) cat("\n==>", msg, "\n")
roda    <- function(cmd, argumentos, pasta = ".") {
  atual <- setwd(pasta); on.exit(setwd(atual))
  saida <- suppressWarnings(system2(cmd, argumentos, stdout = TRUE, stderr = TRUE))
  status <- attr(saida, "status")
  if (!is.null(status) && status != 0) stop(cmd, " falhou em ", pasta, ":\n", paste(tail(saida, 25), collapse = "\n"))
  invisible(saida)
}
for (programa in c("quarto", "tectonic")) if (!nzchar(Sys.which(programa))) stop("Programa não encontrado no PATH: ", programa)
Sys.setenv(PATH = paste(R.home("bin"), Sys.getenv("PATH"), sep = .Platform$path.sep))

if ("--base" %in% args) {
  passo("Base de dados (scripts/05_base_entrega_final.R)")
  roda(rscript, "scripts/05_base_entrega_final.R")
}

passo("Caderno R: quarto render entrega_final/analise_final.qmd")
roda("quarto", c("render", "analise_final.qmd"), "entrega_final")

passo("Copia para artigo/ os números, as tabelas e as figuras que o artigo usa")
tex <- readLines("artigo/artigo.tex", encoding = "UTF-8")
tabelas <- unique(sub(".*\\\\input\\{tabelas/([^}]+)\\}.*", "\\1", grep("\\\\input\\{tabelas/", tex, value = TRUE)))
figuras <- unique(sub(".*\\{", "", sub("\\}$", "", unlist(regmatches(tex, gregexpr("\\\\includegraphics(\\[[^]]*\\])?\\{[^}]+\\}", tex))))))
tabelas <- ifelse(grepl("\\.tex$", tabelas), tabelas, paste0(tabelas, ".tex"))
origem  <- c("numeros.tex", file.path("tabelas", tabelas), file.path("figuras", figuras))
faltam  <- origem[!file.exists(file.path("entrega_final/resultados", origem))]
if (length(faltam)) stop("O caderno não gerou: ", paste(faltam, collapse = ", "))
unlink(c(setdiff(list.files("artigo/tabelas", full.names = TRUE), file.path("artigo/tabelas", tabelas)),
         setdiff(list.files("artigo/figuras", full.names = TRUE), file.path("artigo/figuras", figuras))))
stopifnot(all(file.copy(file.path("entrega_final/resultados", origem), file.path("artigo", origem), overwrite = TRUE)))

passo("Artigo: tectonic")
roda("tectonic", c("-X", "compile", "--keep-logs", "artigo.tex"), "artigo")
log_tex <- readLines("artigo/artigo.log", warn = FALSE)
unlink(list.files("artigo", "\\.(log|aux|out|bbl|blg)$", full.names = TRUE))
if (any(grepl("undefined|multiply defined", log_tex, ignore.case = TRUE))) stop("Há referência ou citação indefinida no artigo")
paginas <- pdftools::pdf_info("artigo/artigo.pdf")$pages
texto   <- pdftools::pdf_text("artigo/artigo.pdf")
palavras <- function(inicio, fim) {
  bloco <- sub(paste0(".*\n\\s*", inicio, "\\s*\n"), "", texto[1])
  bloco <- sub(paste0("\n\\s*", fim, ".*"), "", bloco)
  length(strsplit(trimws(bloco), "\\s+")[[1]])
}
n_resumo <- palavras("RESUMO", "PALAVRAS"); n_abstract <- palavras("ABSTRACT", "KEYWORDS")
if (paginas > 15) stop("O artigo tem ", paginas, " páginas; o limite é 15")
if (!grepl("KEYWORDS", texto[1])) stop("O abstract passou da página 1")
if (max(n_resumo, n_abstract) > 150) stop("Resumo ou abstract com mais de 150 palavras: ", n_resumo, " e ", n_abstract)

if ("--slides" %in% args) {
  passo("Slides: tectonic e exportações")
  roda("tectonic", c("-X", "compile", "apresentacao_final.tex"), "apresentacao/latex")
  roda(rscript, "exportar_pptx_html.R", "apresentacao")
}

passo("Monta o .zip (scripts/04_montar_zip_entrega.R)")
temp <- tempfile("entrega_"); dir.create(temp)
roda(rscript, c("scripts/04_montar_zip_entrega.R", temp))
dir.create(destino, recursive = TRUE, showWarnings = FALSE)
zip_final <- file.path(destino, "GED16_homicidios_municipios.zip")
stopifnot(file.copy(file.path(temp, "GED16_homicidios_municipios.zip"), zip_final, overwrite = TRUE))

passo("Teste do zip numa pasta vazia: compila o artigo, roda o caderno e compara")
teste <- tempfile("teste_"); dir.create(teste)
utils::unzip(zip_final, exdir = teste)
base_zip <- file.path(teste, "GED16_homicidios_municipios")
roda("tectonic", c("-X", "compile", "artigo.tex"), file.path(base_zip, "artigo"))
roda("quarto", c("render", "analise_final.qmd"), file.path(base_zip, "codigo"))
figs <- origem[startsWith(origem, "figuras/")]
iguais <- tools::md5sum(file.path(base_zip, "codigo/resultados", figs)) == tools::md5sum(file.path(base_zip, "artigo", figs))
if (!all(iguais)) stop("O caderno do zip não reproduz: ", paste(figs[!iguais], collapse = ", "))
tex_rep <- readLines("artigo/artigo.tex", encoding = "UTF-8")
for (i in grep("^\\\\input\\{", tex_rep)) {
  arq <- sub("^\\\\input\\{([^}]+)\\}%?$", "\\1", tex_rep[i])
  tex_rep[i] <- paste(readLines(file.path(base_zip, "codigo/resultados", arq), encoding = "UTF-8"), collapse = "\n")
}
tex_zip <- readLines(file.path(base_zip, "artigo/artigo.tex"), encoding = "UTF-8")
if (!identical(strsplit(paste(tex_rep, collapse = "\n"), "\n")[[1]], tex_zip))
  stop("Os números ou as tabelas do artigo.tex do zip não batem com o caderno do zip")
texto_zip <- pdftools::pdf_text(file.path(base_zip, "artigo/artigo.pdf"))
if (!identical(texto_zip, texto)) stop("O artigo compilado do zip difere do artigo.pdf")

cat("\nEntrega pronta:", zip_final,
    sprintf("\n  artigo: %d páginas | resumo: %d palavras | abstract: %d palavras", paginas, n_resumo, n_abstract),
    sprintf("\n  slides: %d páginas | %d arquivos (números, tabelas e figuras) reproduzidos pelo caderno do zip\n",
            pdftools::pdf_info(file.path(base_zip, "apresentacao_final.pdf"))$pages, length(origem)))
