args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Uso: Rscript preparar_pasta_grupo.R pasta_de_destino")
destino <- args[1]
if (dir.exists(destino) && length(list.files(destino, all.files = TRUE, no.. = TRUE))) {
  stop("A pasta de destino precisa estar vazia para preservar arquivos existentes.")
}
origem <- c("apresentacao_final.pdf", "apresentacao_final.pptx", "apresentacao_final.html",
            file.path("briefings", paste0("briefing_", c("kauan", "fabio", "douglas", "luiz_felipe", "willian"), ".pdf")),
            "roteiro.csv", "../decisoes/revisao-projeto-apostila.md", "../validacao/auditoria_extras.txt",
            "../decisoes/decisoes-do-grupo.pdf", "../decisoes/GED-16-alinhamento-com-professores.txt",
            "../decisoes/revisao-semantica-apresentacao.md", "../validacao/REVISAO_MODELO_FINAL.md", "referencias-dos-slides.md")
relativo <- c(file.path("01_slides", basename(origem[1:3])),
              file.path("02_briefings", basename(origem[4:8])), "02_briefings/roteiro.csv",
              "03_revisao/revisao-projeto-apostila.md", "03_revisao/auditoria_extras.txt",
              "03_revisao/decisoes.pdf", "03_revisao/GED-16-alinhamento-com-professores.txt",
              "03_revisao/revisao-semantica-apresentacao.md", "03_revisao/REVISAO_MODELO_FINAL.md", "03_revisao/referencias-dos-slides.md")
codigo <- file.path("../entrega", c("analise_final.qmd", "analise_final.html", "1_analise_exploratoria.R", "2_modelo.R", "LEIA-ME.md"))
bases <- file.path("../entrega/dados", c("base_analitica.csv", "variaveis_extras.csv", "malha_mun.geojson", "dicionario.csv", "dicionario_extras.csv", "validacao_gini.csv"))
origem <- c(origem, codigo, bases, "../decisoes/conferencia-pedidos-17-11-2026.md",
            "../decisoes/analise-critica-slide-a-slide.md", "contexto_homicidios_2021.csv")
relativo <- c(relativo, file.path("04_codigo", basename(codigo)), file.path("04_codigo/dados", basename(bases)),
              "03_revisao/conferencia-pedidos-17-11-2026.md", "03_revisao/analise-critica-slide-a-slide.md",
              "03_revisao/contexto_homicidios_2021.csv")
origem <- c(origem, "MUDANCAS-PARA-O-TIME.md")
relativo <- c(relativo, "MUDANCAS-PARA-O-TIME.md")
stopifnot(all(file.exists(origem)), length(origem) == length(relativo))
for (p in unique(dirname(relativo))) dir.create(file.path(destino, p), recursive = TRUE, showWarnings = FALSE)
stopifnot(all(file.copy(origem, file.path(destino, relativo), overwrite = FALSE)))
stopifnot(identical(unname(tools::md5sum(origem)), unname(tools::md5sum(file.path(destino, relativo)))))
origem_abs <- normalizePath(origem)
raiz <- normalizePath("..")
for (i in which(endsWith(relativo, ".md"))) {
 arquivo <- file.path(destino, relativo[i])
 texto <- paste(readLines(arquivo, warn = FALSE), collapse = "\n")
 links <- unique(regmatches(texto, gregexpr("\\]\\(([^)]+)\\)", texto))[[1]])
 for (link in links) {
  alvo <- substr(link, 3, nchar(link) - 1)
  if (grepl("^(https?:|#)", alvo)) next
  caminho <- normalizePath(file.path(dirname(origem[i]), alvo), mustWork = FALSE)
  j <- match(caminho, origem_abs)
  novo <- if (!is.na(j) && dirname(relativo[i]) == dirname(relativo[j])) basename(relativo[j]) else
    if (startsWith(caminho, paste0(raiz, "/"))) paste0("https://github.com/fabiourio/homicidios-municipios/blob/main/", substring(caminho, nchar(raiz) + 2)) else alvo
  texto <- gsub(link, paste0("](", novo, ")"), texto, fixed = TRUE)
 }
 writeLines(texto, arquivo)
}
leia <- c("GED-16 — APRESENTAÇÃO FINAL — 18/11/2026", "",
          "COMECE POR AQUI", "",
          "Leia MUDANCAS-PARA-O-TIME.md: ODS no contexto, novos marcos de tempo e respostas para perguntas.",
          "01_slides: PDF, PowerPoint e HTML com notas. Enviar os slides à professora até 18/11, 10h00.",
          "Apresentar apenas os slides 1 a 15. Slides 16 a 24 são apoio para perguntas.",
          "02_briefings: cada pessoa lê seu PDF e ensaia a fala completa.",
          "03_revisao: análise e histórico. A numeração e o tempo atuais estão em LEIA-PRIMEIRO.txt e roteiro.csv.",
          "04_codigo: caderno final em .qmd, HTML executado, scripts e bases utilizadas.", "",
          "DIVISÃO E TEMPO", "Kauan: slides 1–2, contexto, 1min45, termina no marco 1min45.",
          "Fabio: slides 3–4, dados, 1min30, termina no marco 3min15.",
          "Douglas: slides 5–6, métodos, 2min, termina no marco 5min15.",
          "Luiz Felipe: slides 7–9, ajuste e diagnósticos, 3min, termina no marco 8min15.",
          "Willian: slides 10–15, discussão, 6min15, termina no marco 14min30.",
          "Meta: 14min30. Abertura: 3min15. Último slide: 60 segundos. Reservar 30 segundos para pausas e transições.",
          "Usar os tempos como metas e limites de ensaio. O ensaio humano ainda precisa acontecer.", "",
          "PENDÊNCIAS DO PROJETO COMPLETO", "Artigo .tex/.pdf e ZIP único da entrega ainda faltam. O .qmd final está em 04_codigo.",
          "Definir o responsável pelo envio. Todos precisam postar os nomes do grupo e indicar quem enviou o arquivo.",
          "Esta pasta serve ao grupo e não substitui o ZIP completo exigido pela professora.", "",
          "REPOSITÓRIO", "https://github.com/fabiourio/homicidios-municipios/tree/main", "",
          "Integrantes: Douglas Bergamim Fernandes; Fabio Eiiti Kobayashi Urio; Kauan Alves Aragão; Luiz Felipe de Brito Ramos; Willian Nelton Teleken.")
writeLines(leia, file.path(destino, "LEIA-PRIMEIRO.txt"), useBytes = TRUE)
mensagem <- c("Pessoal, seguem os slides revisados e os briefings individuais.",
              "Mantivemos a ordem: Kauan 1min45; Fabio 1min30; Douglas 2min; Luiz Felipe 3min; Willian 6min15.",
              "A fala principal termina no slide 15. Os slides 16 a 24 são apoio para perguntas.",
              "Cada briefing tem a fala completa, leitura dos gráficos, perguntas prováveis e marcos de tempo.",
              "Precisamos fazer um ensaio cronometrado. A meta é 14min30, com limite de 15.",
              "O código final em .qmd e seu HTML executado estão em 04_codigo. O artigo e o ZIP completo ficam para a próxima etapa.",
              "Falta indicar quem fará o envio.")
writeLines(mensagem, file.path(destino, "MENSAGEM-PARA-O-GRUPO.txt"), useBytes = TRUE)

files <- sort(list.files(destino, recursive = TRUE))
manifesto <- data.frame(arquivo = files, bytes = unname(file.info(file.path(destino, files))$size),
                       md5 = unname(tools::md5sum(file.path(destino, files))))
write.csv(manifesto, file.path(destino, "MANIFESTO.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("Pasta pronta: %s (%d arquivos mais manifesto).\n", destino, length(files)))
