# =============================================================================
# USO INTERNO (não faz parte do código de entrega)
# Exporta o deck em PDF para .pptx e .html com o mesmo visual: cada slide vira uma imagem,
# e as notas do apresentador (notas.json, números tirados de latex/numeros.tex) vão junto.
# Uso (na pasta apresentacao/): Rscript exportar_pptx_html.R [deck]   (padrão: apresentacao_parcial)
# =============================================================================

library(jsonlite)
library(pdftools)
library(officer)
library(base64enc)

deck <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(deck)) deck <- "apresentacao_parcial"
pdf <- sprintf("latex/%s.pdf", deck)

# Notas: troca {Macro} pelo valor de \nMacro em numeros.tex
num_tex <- readLines("latex/numeros.tex", encoding = "UTF-8")
num <- setNames(sub(".*\\}\\{(.*)\\}$", "\\1", num_tex), sub("^\\\\newcommand\\{\\\\n(\\w+)\\}.*", "\\1", num_tex))
num <- gsub("\\$-\\$", "−", gsub("\\\\%", "%", num))
notas <- fromJSON("notas.json")
for (k in names(num)) notas <- gsub(sprintf("{%s}", k), num[[k]], notas, fixed = TRUE)
if (any(grepl("\\{\\w+\\}", notas))) stop("Nota com número sem macro: ", grep("\\{\\w+\\}", notas, value = TRUE)[1])

# Páginas do PDF em PNG
dir_img <- tempfile(); dir.create(dir_img)
pngs <- pdf_convert(pdf, format = "png", dpi = 200, filenames = file.path(dir_img, sprintf("p%02d.png", seq_len(pdf_info(pdf)$pages))), verbose = FALSE)
if (length(pngs) != length(notas)) stop(sprintf("O deck tem %d páginas e notas.json tem %d notas", length(pngs), length(notas)))

# .pptx 16:9, uma imagem por slide, com as notas.
# O modelo padrão do officer é 4:3: criamos uma cópia 16:9 trocando o tamanho do slide no XML
modelo <- file.path(tempdir(), "modelo_16x9.pptx")
dir_mod <- tempfile(); unzip(system.file("template/template.pptx", package = "officer"), exdir = dir_mod)
pres <- file.path(dir_mod, "ppt/presentation.xml")
xml <- readLines(pres, warn = FALSE, encoding = "UTF-8")
xml <- sub('<p:sldSz cx="[0-9]+" cy="[0-9]+"[^/]*/>', '<p:sldSz cx="12192000" cy="6858000"/>', xml)
writeLines(xml, pres, useBytes = TRUE)
atual <- setwd(dir_mod); zip(modelo, list.files(".", recursive = TRUE, all.files = TRUE), flags = "-qX"); setwd(atual)
ppt <- read_pptx(modelo)
for (i in seq_along(pngs)) {
  ppt <- add_slide(ppt, layout = "Blank", master = "Office Theme")
  ppt <- ph_with(ppt, external_img(pngs[i], width = 13.333, height = 7.5), location = ph_location(left = 0, top = 0, width = 13.333, height = 7.5))
  if (nzchar(notas[i])) ppt <- set_notes(ppt, value = notas[i], location = notes_location_type("body"))
}
print(ppt, target = sprintf("%s.pptx", deck))

# .html: uma página só, com navegação por setas, N para notas e F para tela cheia
esc <- function(x) gsub('"', "&quot;", gsub("<", "&lt;", gsub("&", "&amp;", x)))
secoes <- sprintf('<section class="slide" data-notes="%s"><img src="data:image/png;base64,%s" alt="Slide %d"></section>',
                  esc(notas), sapply(pngs, function(f) base64encode(f)), seq_along(pngs))
html <- c('<!doctype html>', '<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">',
  '<title>Homicídios nos municípios</title><style>',
  '*{box-sizing:border-box;margin:0;padding:0}html,body{height:100%;background:#0d1b30;overflow:hidden}',
  '#deck{position:absolute;inset:0;display:flex;align-items:center;justify-content:center}',
  '.slide{display:none;width:min(100vw,177.78vh);height:min(56.25vw,100vh)}.slide.on{display:block}',
  '.slide img{width:100%;height:100%;display:block}',
  '#notes{position:fixed;left:0;right:0;bottom:0;max-height:30%;overflow:auto;background:#fff;color:#1F2933;font:15px/1.4 Arial,sans-serif;padding:12px 18px;border-top:3px solid #00689D;display:none}',
  '#hint{position:fixed;right:12px;bottom:8px;color:#9fb3c8;font:12px Arial,sans-serif}',
  '@media print{html,body{overflow:visible;background:#fff}#deck{position:static;display:block}.slide{display:block!important;width:100%;height:auto;break-after:page}#hint,#notes{display:none!important}}',
  '</style></head><body><div id="deck">', secoes, '</div><div id="notes"></div><div id="hint">← → navegar · N notas · F tela cheia</div><script>',
  "const S=[...document.querySelectorAll('.slide')];let i=0;",
  "function show(n){i=Math.max(0,Math.min(S.length-1,n));S.forEach((s,k)=>s.classList.toggle('on',k===i));document.getElementById('notes').textContent=S[i].dataset.notes;try{history.replaceState(null,'','#'+(i+1))}catch(e){}}",
  "addEventListener('keydown',e=>{if(['ArrowRight','PageDown',' '].includes(e.key))show(i+1);else if(['ArrowLeft','PageUp'].includes(e.key))show(i-1);else if(e.key==='Home')show(0);else if(e.key==='End')show(S.length-1);else if(e.key.toLowerCase()==='n'){const n=document.getElementById('notes');n.style.display=n.style.display==='block'?'none':'block'}else if(e.key.toLowerCase()==='f'){document.fullscreenElement?document.exitFullscreen():document.documentElement.requestFullscreen()}});",
  "document.getElementById('deck').addEventListener('click',e=>show(e.clientX>innerWidth/3?i+1:i-1));show((parseInt(location.hash.slice(1))||1)-1);",
  '</script></body></html>')
writeLines(html, sprintf("%s.html", deck), useBytes = TRUE)
file.copy(pdf, sprintf("%s.pdf", deck), overwrite = TRUE)
cat(sprintf("exportado: %s.pdf, %s.pptx e %s.html (%d slides)\n", deck, deck, deck, length(pngs)))
