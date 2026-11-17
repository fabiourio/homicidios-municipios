# Fechamento da apresentação final — 18/11/2026

## Objetivo aprovado

Finalizar os slides, as falas e os briefings para uma apresentação de até 15 minutos.
O usuário aprovou a avaliação das propostas do grupo em 17/11/2026.
O artigo final fica para uma etapa posterior.

## Requisitos verificáveis

- G1: A apresentação cobre os cinco pontos pedidos pela professora.
- G2: O roteiro tem 13 minutos de fala planejada.
- G3: A divisão preserva Kauan, Fabio, Douglas, Luiz Felipe e Willian, nessa ordem.
- G4: A abertura de Kauan e Fabio ocupa três minutos.
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

## Desenho aprovado

Preservar o modelo estatístico e os dados atuais.
Reutilizar o Beamer e os geradores em R da apresentação parcial.
Manter 14 páginas principais e apêndices para perguntas.
Numerar as páginas.
Substituir tabelas densas no corpo por gráficos interpretados.
Explicar Gini × renda quando o resultado aparecer.
Não introduzir abandono parental.
Não selecionar o modelo para minimizar o VIF.
Não esconder as limitações quando os testes não rejeitam uma hipótese.

| Pessoa | Tempo | Páginas principais | Função |
|---|---:|---|---|
| Kauan | 1min30 | 1–2 | Contexto, pergunta e hipóteses |
| Fabio | 1min30 | 3–4 | Fontes, resposta, variáveis e recorte |
| Douglas | 2min | 5–6 | Padrões nos dados e motivação do modelo |
| Luiz Felipe | 3min | 7–9 | Métodos e diagnóstico por gráficos |
| Willian | 5min | 10–14 | Efeitos, interpretação, crítica e conclusão |

O total de 13 minutos reserva dois minutos para pausas e transições.
A estimativa por palavras é uma referência para ensaio, não uma medição de apresentação real.

## Execução

- [x] T1 — Registrar as decisões. Arquivos: `README.md`, `decisoes/mudancas-no-modelo.md`, guia HTML/PDF e registro da discussão. Conferir ausência de decisões finais contraditórias.
- [x] T2 — Revisar a narrativa e os gráficos. Arquivos: `apresentacao/latex/apresentacao_final.tex`, `gerar_numeros.R`, `apresentacao/notas.json`. Conferir as conclusões com os resultados reais.
- [x] T3 — Atualizar os briefings. Arquivos: `apresentacao/briefings/comum.tex`, `parte_*.tex`, `gerar_briefings.R`, `divisao.tex`. Conferir nomes, transições e conteúdo completo.
- [x] T4 — Gerar as exportações. Executar a análise, compilar o Beamer, exportar PPTX/HTML e compilar os cinco briefings. Conferir páginas e notas.
- [x] T5 — Revisar os resultados. Renderizar páginas do deck e dos briefings. Conferir gráficos, cortes, textos, macros e tempo estimado. Corrigir os achados e repetir os checks afetados.
- [ ] T6 — Atualizar o repositório. Registrar a evidência em `apresentacao/VERIFICACAO.md`. Conferir o diff. Fazer commit e preparar PR sem merge.

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
