# =============================================================================
# USO INTERNO (não faz parte do código de entrega)
# Monta um briefing em PDF por apresentador, a partir de:
#   ../notas.json                      falas e quem apresenta cada slide ("[Nome] ...")
#   ../latex/<deck>.tex e <deck>.pdf  títulos e imagens dos slides (deck padrão: apresentacao_final)
#   ../latex/numeros.tex               números (gerados pelo código)
#   comum.tex e parte_<nome>.tex       texto do briefing
# Saída: briefing_<nome>.pdf nesta pasta.
# Rodar com a pasta apresentacao/briefings/ como diretório de trabalho, depois de
# ../latex/gerar_numeros.R e de compilar a apresentação.
# =============================================================================

library(jsonlite)

# Nome do deck (sem extensão); padrão: apresentacao_final
deck <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(deck)) deck <- "apresentacao_final"
notas <- fromJSON("../notas.json")
tex   <- readLines(sprintf("../latex/%s.tex", deck), encoding = "UTF-8")

# Títulos na ordem das páginas: capa + um título por frame (os slides não têm sobreposições)
fr <- grep("\\\\begin\\{frame\\}", tex, value = TRUE)
titulos <- c("Capa", ifelse(grepl("standout", fr), "Obrigado",
                            sub(".*\\\\begin\\{frame\\}\\{(.*)\\}.*", "\\1", fr)))
stopifnot(length(titulos) == length(notas))

# Quem apresenta cada página: tag "[Nome]" no começo da nota
quem <- ifelse(grepl("^\\[", notas), sub("^\\[([^]]+)\\].*", "\\1", notas), NA)
fala <- sub("^\\[[^]]+\\]\\s*", "", notas)

roteiro <- read.csv("../roteiro.csv", encoding = "UTF-8")
stopifnot(identical(roteiro$slide, which(!is.na(quem))),
          all(roteiro$pessoa == quem[roteiro$slide]),
          all(roteiro$segundos > 0), sum(roteiro$segundos) == 14 * 60 + 30)
roteiro$fim <- cumsum(roteiro$segundos)
roteiro$inicio <- roteiro$fim - roteiro$segundos
tempo <- function(segundos) sprintf("%dmin%02ds", segundos %/% 60, segundos %% 60)

# Texto da nota -> LaTeX: escapa símbolos e troca {Nome} pela macro \nNome do código
para_tex <- function(x) {
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([%$&#_])", "\\\\\\1", x)
  gsub("\\{(\\w+)\\}", "\\\\n\\1{}", x)
}
titulos_tex <- titulos
slug <- function(nome) gsub(" ", "_", tolower(iconv(nome, to = "ASCII//TRANSLIT")))

# Quadro "Quem fala o quê", na ordem da apresentação
blocos <- rle(ifelse(is.na(quem), "", quem))
fim <- cumsum(blocos$lengths); ini <- fim - blocos$lengths + 1
lin <- character(0)
for (i in seq_along(blocos$values)) if (blocos$values[i] != "")
  lin <- c(lin, sprintf("\\textbf{%s} & %s & %s\\\\", blocos$values[i],
                        tempo(sum(roteiro$segundos[roteiro$pessoa == blocos$values[i]])),
                        paste(titulos_tex[ini[i]:fim[i]], collapse = "; ")))
writeLines(c("\\small", "\\begin{tabularx}{\\linewidth}{@{}>{\\raggedright\\arraybackslash}p{2.1cm}p{1.8cm}>{\\raggedright\\arraybackslash}X@{}}",
             "\\toprule", "\\textbf{Quem} & \\textbf{Tempo} & \\textbf{Slides, na ordem}\\\\", "\\midrule", lin,
             "\\bottomrule", "\\end{tabularx}", "\\normalsize"), "divisao.tex")

# Um briefing por apresentador
for (nome in unique(na.omit(quem))) {
  s <- slug(nome)
  if (!file.exists(sprintf("parte_%s.tex", s))) stop("Falta o texto da parte: parte_", s, ".tex")
  pags <- which(quem == nome)
  antes <- quem[max(1, min(pags) - 1)]; depois <- quem[min(length(quem), max(pags) + 1)]
  plano_pessoa <- roteiro[roteiro$pessoa == nome, ]

  topicos <- function(x) paste0("\\item ", strsplit(para_tex(x), "(?<=[.!?])\\s+(?=[[:upper:]%\\\\])", perl = TRUE)[[1]])
  slides <- unlist(lapply(pags, function(k) c(
    "\\noindent\\begin{minipage}{\\linewidth}",
    sprintf("\\textbf{\\large\\color{navy}Slide %d: %s}\\par\\vspace{0.4em}", k, titulos_tex[k]),
    sprintf("\\textbf{Tempo deste slide:} %s. \\textbf{Marco de fim na apresentação:} %s.\\par",
            tempo(roteiro$segundos[roteiro$slide == k]), tempo(roteiro$fim[roteiro$slide == k])),
    sprintf("\\begin{center}\\fbox{\\includegraphics[page=%d,width=0.56\\linewidth]{../latex/%s.pdf}}\\end{center}", k, deck),
    "\\textbf{Fala completa para ensaiar:}", "\\begin{itemize}", topicos(fala[k]), "\\end{itemize}",
    "\\end{minipage}\\par\\vspace{1.6em}")))
  writeLines(c("\\section{Seus slides e o que dizer em cada um}", slides), sprintf("fala_%s.tex", s))

  writeLines(c(
    "\\input{estilo.tex}", "\\begin{document}",
    sprintf("{\\LARGE\\bfseries\\color{navy} Briefing: %s}\\par\\vspace{0.3em}", nome),
    "{\\large Fatores associados aos homicídios nos municípios brasileiros}\\par",
    sprintf("{\\color{gray} GED-16 · ITA · gerado em %s}\\par\\vspace{0.6em}", format(Sys.Date(), "%d/%m/%Y")),
    sprintf("\\caixa{\\textbf{Você apresenta:} %s.\\\\ \\textbf{Antes de você:} %s. \\textbf{Depois de você:} %s.}",
            paste(titulos_tex[pags], collapse = "; "),
            ifelse(min(pags) == 1 || is.na(antes) || antes == nome, "você abre a apresentação", antes),
            ifelse(is.na(depois) || depois == nome, "fim da apresentação", depois)),
    sprintf("\\caixa{\\textbf{Seu tempo total:} %s. \\textbf{Comece no marco:} %s. \\textbf{Termine no marco:} %s.}",
            tempo(sum(plano_pessoa$segundos)), tempo(min(plano_pessoa$inicio)), tempo(max(plano_pessoa$fim))),
    "Os tempos são metas de ensaio. O roteiro reserva trinta segundos para pausas e transições até o limite de quinze minutos.",
    sprintf("\\input{parte_%s.tex}", s), sprintf("\\input{fala_%s.tex}", s),
    "\\newpage", "\\input{comum.tex}", "\\end{document}"), sprintf("briefing_%s.tex", s))

  ok <- system2("tectonic", c("-X", "compile", "--keep-logs", shQuote(sprintf("briefing_%s.tex", s))), stdout = FALSE, stderr = FALSE)
  if (ok != 0) stop("Falhou ao compilar briefing_", s, ".tex")
  file.remove(sprintf("briefing_%s.tex", s), sprintf("fala_%s.tex", s))
  cat("gerado: briefing_", s, ".pdf (", length(pags), " slides)\n", sep = "")
}
