# Fechamento da apresentação final — 18/11/2026

## Objetivo aprovado

Finalizar os slides, as falas e os briefings para uma apresentação de até 15 minutos.
O usuário aprovou a avaliação das propostas do grupo em 17/11/2026.
O artigo final fica para uma etapa posterior.
A [revisão da narrativa de 17/11](revisao-semantica-apresentacao.md) atualiza a organização e os tempos definidos abaixo.

## Requisitos verificáveis

- G1: A apresentação cobre os cinco pontos pedidos pela professora.
- G2: O roteiro tem 13 minutos de fala planejada.
- G3: A divisão preserva Kauan, Fabio, Douglas, Luiz Felipe e Willian, nessa ordem.
- G4: A abertura de Kauan e Fabio ocupa 2min45.
- G5: Os diagnósticos mostram gráficos com uma interpretação visível.
- G6: Cada página tem uma nota coerente com seu conteúdo.
- G7: Os cinco briefings contêm as falas completas de cada pessoa.
- G8: Os cinco briefings explicam contexto, decisões, gráficos, perguntas prováveis e transições.
- G9: Os números dos slides vêm da análise em R.
- G10: PDF, PPTX e HTML apresentam o mesmo conteúdo.
- G11: A região é a escolha final do modelo.
- G12: As limitações dos dados permanecem explícitas.
- G13: A vizinhança entra como limitação sem introduzir um novo teste espacial.
- G14: O material diferencia associação de causa.
- G15: O material identifica a escala logarítmica ao explicar o ajuste.
- G16: Os arquivos finais e as evidências de verificação ficam no repositório.
- G17: As 23 páginas incluem 14 principais e nove apêndices, A–I.
- G18: Os apêndices H–I ocupam as páginas 22–23 e mostram resíduos por explicativa.
- G19: O rodapé contém apenas a numeração; os gráficos mantêm suas fontes curtas.
- G20: As hipóteses permanecem expectativas iniciais; migração permanece no modelo, sem evidência clara de associação.

## Desenho aprovado

Preservar o modelo estatístico e os dados atuais.
Reutilizar o Beamer e os geradores em R da apresentação parcial.
Manter 14 páginas principais e nove apêndices para perguntas.
Retirar os dois apêndices de referências. Manter as fontes curtas junto aos gráficos.
Manter apenas a numeração no rodapé.
Organizar contexto, dados, metodologia, ajuste e discussão nessa ordem.
Retirar do corpo os dois gráficos exploratórios e preservá-los no repositório.
Mostrar taxas observadas e ajustadas no slide 7, com escala e alcance explícitos.
Abrir com problema e pergunta. Deixar hipóteses nos briefings e retomá-las na discussão.
Definir exclusão escolar por frequência e atraso escolar. Definir migração recente por residência inferior a dez anos.
Substituir tabelas densas no corpo por gráficos interpretados.
Explicar Gini × renda quando o resultado aparecer.
Não introduzir abandono parental.
Não selecionar o modelo para minimizar o VIF.
Não esconder as limitações quando os testes não rejeitam uma hipótese.

| Pessoa | Tempo | Páginas principais | Função |
|---|---:|---|---|
| Kauan | 1min15 | 1–2 | Contexto, problema, motivação e pergunta |
| Fabio | 1min30 | 3–4 | Fontes, resposta, variáveis e recorte |
| Douglas | 2min | 5–6 | Modelo e finalidade dos procedimentos de avaliação |
| Luiz Felipe | 3min | 7–9 | Ajuste observado e diagnóstico por gráficos |
| Willian | 5min15 | 10–14 | Efeitos, interpretação, crítica e conclusão |

O total de 13 minutos reserva dois minutos para pausas e transições.
Os marcos finais são 1min15, 2min45, 4min45, 7min45 e 13min00.
Kauan dispõe de 10 e 65 segundos nos slides 1 e 2. O slide final recebe 60 segundos.
Os tempos são metas e limites de ensaio. Não exigir leitura para preencher segundos.
A estimativa por palavras é uma referência para ensaio, não uma medição de apresentação real.

## Execução anterior à revisão da narrativa

Os itens concluídos abaixo registram a versão anterior. As verificações da revisão atual permanecem na seção seguinte.

- [x] T1 — Registrar as decisões. Arquivos: `README.md`, `decisoes/mudancas-no-modelo.md`, guia HTML/PDF e registro da discussão. Conferir ausência de decisões finais contraditórias.
- [x] T2 — Revisar a narrativa e os gráficos. Arquivos: `apresentacao/latex/apresentacao_final.tex`, `gerar_numeros.R`, `apresentacao/notas.json`. Conferir as conclusões com os resultados reais.
- [x] T3 — Atualizar os briefings. Arquivos: `apresentacao/briefings/comum.tex`, `parte_*.tex`, `gerar_briefings.R`, `divisao.tex`. Conferir nomes, transições e conteúdo completo.
- [x] T4 — Gerar as exportações. Executar a análise, compilar o Beamer, exportar PPTX/HTML e compilar os cinco briefings. Conferir páginas e notas.
- [x] T5 — Revisar os resultados. Renderizar páginas do deck e dos briefings. Conferir gráficos, cortes, textos, macros e tempo estimado. Corrigir os achados e repetir os checks afetados.
- [x] T6 — Atualizar o repositório. Registrar a evidência em `apresentacao/VERIFICACAO.md`. Conferir o diff. Fazer commit e preparar PR sem merge.

## Revisão da narrativa — verificação final

- [x] R1 — Conferir os cinco itens docentes na ordem aprovada e a função de cada slide.
- [x] R2 — Conferir 23 páginas, nove apêndices, fontes curtas e rodapé apenas com numeração.
- [x] R3 — Conferir 780 segundos, tempos individuais e marcos de transição nos materiais exportados.
- [x] R4 — Conferir hipótese de migração, exclusão escolar e abertura sem resultados antecipados.
- [x] R5 — Regenerar exportações e pacote do grupo; executar o verificador e revisar páginas alteradas.
- [x] R6 — Registrar somente verificações executadas e revisar o diff antes de atualizar o PR.

## Comandos de reprodução

Na pasta `apresentacao/latex`:

```sh
/Library/Frameworks/R.framework/Resources/bin/Rscript gerar_numeros.R
tectonic -X compile apresentacao_final.tex
```

Na pasta `apresentacao`:

```sh
/Library/Frameworks/R.framework/Resources/bin/Rscript exportar_pptx_html.R
```

Na pasta `apresentacao/briefings`:

```sh
/Library/Frameworks/R.framework/Resources/bin/Rscript gerar_briefings.R
```

## Registro de execução e agentes

O trabalho começa no commit `1893e89`, sobre `main`. Não existe branch `dev` neste repositório.
O usuário autorizou a execução contínua e a atualização do repositório.
As alterações anteriores desta sessão são a transcrição, o modelo do Overleaf e seus links.
Os agentes recebem tarefas separadas por arquivos. Nenhum agente pode fazer merge.
O registro final de agentes e verificações fica em `apresentacao/VERIFICACAO.md`.
