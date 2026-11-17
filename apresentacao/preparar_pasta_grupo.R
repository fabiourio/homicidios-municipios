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
            "../decisoes/revisao-semantica-apresentacao.md", "../validacao/REVISAO_MODELO_FINAL.md")
relativo <- c(file.path("01_slides", basename(origem[1:3])),
              file.path("02_briefings", basename(origem[4:8])), "02_briefings/roteiro.csv",
              "03_revisao/revisao-projeto-apostila.md", "03_revisao/auditoria_extras.txt",
              "03_revisao/decisoes.pdf", "03_revisao/GED-16-alinhamento-com-professores.txt",
              "03_revisao/revisao-semantica-apresentacao.md", "03_revisao/REVISAO_MODELO_FINAL.md")
stopifnot(all(file.exists(origem)), length(origem) == length(relativo))
for (p in unique(dirname(relativo))) dir.create(file.path(destino, p), recursive = TRUE, showWarnings = FALSE)
stopifnot(all(file.copy(origem, file.path(destino, relativo), overwrite = FALSE)))
leia <- c("GED-16 — APRESENTAÇÃO FINAL — 18/11/2026", "",
          "COMECE POR AQUI", "",
          "01_slides: PDF, PowerPoint e HTML com notas. Enviar os slides à professora até 18/11, 10h00.",
          "Apresentar apenas os slides 1 a 14. Slides 15 a 23 são apoio para perguntas.",
          "02_briefings: cada pessoa lê seu PDF e ensaia a fala completa.",
          "03_revisao: auditoria com a apostila, decisões e evidências. Leitura de apoio.", "",
          "DIVISÃO E TEMPO", "Kauan: slides 1–2, contexto, 1min15, termina no marco 1min15.",
          "Fabio: slides 3–4, dados, 1min30, termina no marco 2min45.",
          "Douglas: slides 5–6, métodos, 2min, termina no marco 4min45.",
          "Luiz Felipe: slides 7–9, ajuste e diagnósticos, 3min, termina no marco 7min45.",
          "Willian: slides 10–14, discussão, 5min15, termina no marco 13min00.",
          "Meta: 13 minutos. Abertura: 2min45. Último slide: 60 segundos. Reservar dois minutos para pausas e transições.",
          "Usar os tempos como metas e limites de ensaio. O ensaio humano ainda precisa acontecer.", "",
          "PENDÊNCIAS DO PROJETO COMPLETO", "Artigo .tex/.pdf, .qmd final e ZIP único da entrega ainda faltam.",
          "Definir o responsável pelo envio. Todos precisam postar os nomes do grupo e indicar quem enviou o arquivo.",
          "Esta pasta serve ao grupo e não substitui o ZIP completo exigido pela professora.", "",
          "REPOSITÓRIO", "https://github.com/fabiourio/homicidios-municipios/pull/12", "",
          "Integrantes: Douglas Bergamim Fernandes; Fabio Eiiti Kobayashi Urio; Kauan Alves Aragão; Luiz Felipe de Brito Ramos; Willian Nelton Teleken.")
writeLines(leia, file.path(destino, "LEIA-PRIMEIRO.txt"), useBytes = TRUE)
mensagem <- c("Pessoal, seguem os slides revisados e os briefings individuais.",
              "Mantivemos a ordem: Kauan 1min15; Fabio 1min30; Douglas 2min; Luiz Felipe 3min; Willian 5min15.",
              "A fala principal termina no slide 14. Os slides 15 a 23 são apoio para perguntas.",
              "Cada briefing tem a fala completa, leitura dos gráficos, perguntas prováveis e marcos de tempo.",
              "Precisamos fazer um ensaio cronometrado. A meta é 13 minutos, com limite de 15.",
              "O artigo, o .qmd final e o ZIP completo ficam para a próxima etapa. Falta indicar quem fará o envio.")
writeLines(mensagem, file.path(destino, "MENSAGEM-PARA-O-GRUPO.txt"), useBytes = TRUE)
stopifnot(identical(unname(tools::md5sum(origem)), unname(tools::md5sum(file.path(destino, relativo)))))
files <- sort(list.files(destino, recursive = TRUE))
manifesto <- data.frame(arquivo = files, bytes = unname(file.info(file.path(destino, files))$size),
                       md5 = unname(tools::md5sum(file.path(destino, files))))
write.csv(manifesto, file.path(destino, "MANIFESTO.csv"), row.names = FALSE, fileEncoding = "UTF-8")
cat(sprintf("Pasta pronta: %s (%d arquivos mais manifesto).\n", destino, length(files)))
