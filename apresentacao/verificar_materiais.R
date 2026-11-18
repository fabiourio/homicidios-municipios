library(jsonlite)
library(pdftools)
library(xml2)

notas <- fromJSON("notas.json")
roteiro <- read.csv("roteiro.csv", encoding = "UTF-8")
logs <- c("latex/apresentacao_final.log", list.files("briefings", pattern = "^briefing_.*[.]log$", full.names = TRUE))
logs <- logs[file.exists(logs)]
stopifnot(length(logs) == 6, !any(vapply(logs, function(f) any(grepl("Overfull|Missing character", readLines(f, warn = FALSE))), logical(1))))
pdf <- "apresentacao_final.pdf"
paginas <- pdf_info(pdf)$pages
stopifnot(paginas == 23, paginas == length(notas), nrow(roteiro) == 14,
          identical(roteiro$slide, seq_len(14)), sum(roteiro$segundos) == 810)
pessoas <- c("Kauan", "Fabio", "Douglas", "Luiz Felipe", "Willian")
tempos <- c(105, 90, 120, 180, 315)
stopifnot(identical(unique(roteiro$pessoa), pessoas),
          identical(as.numeric(tapply(roteiro$segundos, factor(roteiro$pessoa, levels = pessoas), sum)), tempos))
num_tex <- readLines("latex/numeros.tex", encoding = "UTF-8")
num <- setNames(sub(".*\\}\\{(.*)\\}$", "\\1", num_tex), sub("^\\\\newcommand\\{\\\\n(\\w+)\\}.*", "\\1", num_tex))
num <- gsub("\\$-\\$", "−", gsub("\\\\%", "%", num))
num <- gsub("$+$", "+", gsub("$<$", "<", num, fixed = TRUE), fixed = TRUE)
for (k in names(num)) notas <- gsub(sprintf("{%s}", k), num[[k]], notas, fixed = TRUE)
stopifnot(!any(grepl("\\{\\w+\\}", notas)))
stopifnot(identical(unname(tools::md5sum(pdf)), unname(tools::md5sum("latex/apresentacao_final.pdf"))))
texto <- pdf_text(pdf)
stopifnot(!grepl("ODS: Objetivos de Desenvolvimento Sustentável", texto[2], fixed = TRUE),
          all(vapply(c("Paz, Justiça e Instituições", "Eficazes", "Meta 16.1:", "Indicador 16.1.1:",
                      "Medida do estudo:", "intervenções legais"),
                    function(t) grepl(t, gsub("[[:space:]]+", " ", texto[2]), fixed = TRUE), logical(1))))
stopifnot(!any(grepl("Fonte:|Fontes:", texto, ignore.case = TRUE)))
stopifnot(all(vapply(seq_along(texto), function(k) {
  linhas <- trimws(strsplit(texto[k], "\n", fixed = TRUE)[[1]])
  tail(linhas[nzchar(linhas)], 1) == as.character(k)
}, logical(1))))

pasta_pptx <- tempfile(); dir.create(pasta_pptx)
unzip("apresentacao_final.pptx", exdir = pasta_pptx)
ns <- c(p = "http://schemas.openxmlformats.org/presentationml/2006/main",
        a = "http://schemas.openxmlformats.org/drawingml/2006/main")
slides <- list.files(file.path(pasta_pptx, "ppt/slides"), pattern = "^slide[0-9]+[.]xml$")
stopifnot(length(slides) == paginas)
for (k in seq_len(paginas)) {
  arq <- file.path(pasta_pptx, sprintf("ppt/notesSlides/notesSlide%d.xml", k))
  nota <- paste(xml_text(xml_find_all(read_xml(arq), "//p:sp[p:nvSpPr/p:nvPr/p:ph[@type='body']]//a:t", ns)), collapse = "")
  stopifnot(identical(nota, notas[k]))
}
html <- read_html("apresentacao_final.html")
secoes <- xml_find_all(html, "//section[@class='slide']")
stopifnot(length(secoes) == paginas, identical(xml_attr(secoes, "data-notes"), notas))

roteiro$palavras <- lengths(strsplit(sub("^\\[[^]]+\\]\\s*", "", notas[roteiro$slide]), "[[:space:]]+"))
roteiro$palavras_por_minuto <- round(60 * roteiro$palavras / roteiro$segundos)
roteiro$fim_segundos <- cumsum(roteiro$segundos)
stopifnot(all(roteiro$palavras_por_minuto <= 140))
tempo <- function(s) sprintf("%dmin%02ds", s %/% 60, s %% 60)
for (pessoa in pessoas) {
  slug <- gsub(" ", "_", tolower(iconv(pessoa, to = "ASCII//TRANSLIT")))
  arq <- sprintf("briefings/briefing_%s.pdf", slug)
  t <- paste(pdf_text(arq), collapse = "\n")
  stopifnot(grepl(paste0("Briefing: ", pessoa), t, fixed = TRUE),
            grepl("Seu tempo total:", t, fixed = TRUE),
            grepl("Antes de você:", t, fixed = TRUE), grepl("Depois de você:", t, fixed = TRUE),
            grepl("Perguntas prováveis", t, fixed = TRUE),
            grepl("O projeto em um minuto", t, fixed = TRUE))
  i <- match(pessoa, pessoas)
  stopifnot(grepl(paste0("Seu tempo total: ", tempo(tempos[i])), t, fixed = TRUE),
            grepl(paste0("Comece no marco: ", tempo(sum(tempos[seq_len(i - 1)]))), t, fixed = TRUE),
            grepl(paste0("Termine no marco: ", tempo(sum(tempos[seq_len(i)]))), t, fixed = TRUE))
  pags <- roteiro$slide[roteiro$pessoa == pessoa]
  stopifnot(all(vapply(pags, function(k) grepl(paste0("Slide ", k, ":"), t, fixed = TRUE), logical(1))))
}
write.csv(roteiro, "tempos_verificados.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("OK: %d páginas, %d slides principais, cinco briefings, notas iguais no PPTX e HTML, roteiro de %d segundos.\n", paginas, nrow(roteiro), sum(roteiro$segundos)))
print(aggregate(cbind(segundos, palavras) ~ pessoa, roteiro, sum))
