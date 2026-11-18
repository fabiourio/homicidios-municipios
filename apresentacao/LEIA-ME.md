# Apresentação final — 18/11/2026

**Apresentar os slides 1–15.** Os slides 16–24 são os nove apêndices, de A a I, para perguntas.
O roteiro planeja 14min30. Os 30 segundos restantes acomodam pausas e transições.
O grupo ainda precisa confirmar a duração num ensaio cronometrado.
O prazo informado para enviar os slides é 18/11/2026, às 10h00.

## Materiais

- [Slides em PDF](apresentacao_final.pdf): versão principal para conferir e apresentar.
- [Slides em PowerPoint](apresentacao_final.pptx): mesmo visual, com as falas nas notas do apresentador.
- [Slides em HTML](apresentacao_final.html): setas para navegar, N para notas e F para tela cheia.
- [Falas completas](notas.json): uma nota por página, na ordem do deck.
- [Tempos por slide](roteiro.csv): fonte dos tempos nos briefings.
- [Verificação final](VERIFICACAO.md): evidências e limites das verificações.
- [Análise crítica por slide](../decisoes/analise-critica-slide-a-slide.md): função, lacunas e correções conforme o enunciado docente.

O PowerPoint usa imagens dos slides para preservar o visual. A fonte editável fica em `latex/apresentacao_final.tex`.
Notas e briefings são materiais internos do grupo. Os slides fazem parte da entrega à professora.

## Quem apresenta

| Pessoa | Slides | Tempo | Marco de início | Marco de fim | Briefing completo |
|---|---|---|---|---|---|
| Kauan | 1–2 | 1min45 | 0min00 | 1min45 | [Abrir](briefings/briefing_kauan.pdf) |
| Fabio | 3–4 | 1min30 | 1min45 | 3min15 | [Abrir](briefings/briefing_fabio.pdf) |
| Douglas | 5–6 | 2min | 3min15 | 5min15 | [Abrir](briefings/briefing_douglas.pdf) |
| Luiz Felipe | 7–9 | 3min | 5min15 | 8min15 | [Abrir](briefings/briefing_luiz_felipe.pdf) |
| Willian | 10–15 | 6min15 | 8min15 | 14min30 | [Abrir](briefings/briefing_willian.pdf) |

Cada briefing inclui a parte individual, as falas completas, os slides, as decisões comuns e perguntas respondidas.
Mantivemos as pessoas e sua ordem; os assuntos foram condensados e redistribuídos para o roteiro docente.
Os tempos são metas de ensaio, não o resultado de uma apresentação real.
A abertura de Kauan e Fabio ocupa 3min15. O último slide tem 60 segundos.
Não preencher o tempo com leitura. Tratar os tempos como metas e limites de ensaio.
Não ler os apêndices durante o roteiro principal.

## Conteúdo dos slides

| Slides | Conteúdo |
|---|---|
| 1–2 | Contextualização: significado de ODS, ODS 16, meta 16.1, indicador 16.1.1, dimensão do problema e pergunta |
| 3–4 | Fontes, resposta, variáveis e recorte |
| 5–6 | Metodologia: modelo, termos e finalidade dos procedimentos de avaliação |
| 7 | Ajuste do modelo: taxas observadas e ajustadas, escala e alcance |
| 8–9 | Resíduos, variância dos erros e normalidade, com gráficos interpretados |
| 10 | Visão geral das estimativas do modelo; introdução aos resultados |
| 11–13 | Escola, urbanização, migração, desigualdade, renda e região |
| 14–15 | Limitações, resposta à pergunta, literatura e trabalhos futuros |
| 16–22 | Apêndices A–G: coeficientes, testes, Box-Cox, comparações e variáveis retiradas |
| 23–24 | Apêndices H–I: resíduos contra cada variável explicativa, conforme a apostila |

Os dois gráficos exploratórios retirados do corpo permanecem disponíveis no repositório.
As fontes foram retiradas da projeção e preservadas em [registro de referências](referencias-dos-slides.md).
As legendas técnicas dos gráficos permanecem. O rodapé contém apenas a numeração.
Os apêndices de referências foram retirados; o registro bibliográfico permanece no projeto.

## Cuidados para a fala

- Kauan define ODS brevemente na fala. O slide 2 identifica ODS 16, meta 16.1 e indicador de referência 16.1.1.
- A medida do estudo difere do indicador oficial. A comparação mundo–Brasil usa 2021; não demonstra ano atípico.
- Abrir com problema e pergunta. Apresentar os resultados na discussão.
- Tratar as hipóteses como expectativas iniciais. Elas permanecem nos briefings e retornam na discussão.
- Definir exclusão escolar por frequência e atraso escolar. A medida não representa toda a exclusão social.
- Definir migração recente por residência ininterrupta inferior a dez anos. A medida não representa imigração internacional.
- Manter H3: a migração permanece no modelo, sem evidência clara de associação, com p clássico de 0,143.
- Mostrar o padrão do gráfico antes de citar o teste.
- Explicar os eixos e as linhas quando apresentar cada gráfico.
- Distinguir não rejeitar normalidade de comprovar normalidade.
- Ressaltar a variância não constante: os intervalos e testes apresentados são clássicos.
- Ler o R² ajustado na escala de ln(taxa).
- Interpretar o Gini junto da renda. Não apresentar um único efeito para todos os municípios.
- Tratar a desocupação como uma associação frágil, sem causa demonstrada.
- Identificar a medida como violência letal relacionada ao ODS 16. Ela difere do indicador oficial 16.1.1.
- Citar a vizinhança como limitação sem afirmar independência espacial.
- Distinguir associação municipal de causa e risco individual.

## Como reproduzir

Na pasta `latex/`:

```sh
Rscript gerar_numeros.R
tectonic -X compile --keep-logs apresentacao_final.tex
```

Na pasta `apresentacao/`:

```sh
Rscript exportar_pptx_html.R
```

Na pasta `briefings/`:

```sh
Rscript gerar_briefings.R
```

Por fim, na pasta `apresentacao/`:

```sh
Rscript verificar_materiais.R
```

A primeira compilação pode precisar de rede para baixar pacotes e fontes do LaTeX.
Neste Mac, se `Rscript` não estiver no PATH, usar `/Library/Frameworks/R.framework/Resources/bin/Rscript`.
Não editar os números em `latex/numeros.tex`; eles são gerados pela análise.

## Próxima etapa do projeto

O resultado da [revisão com a apostila](../decisoes/revisao-projeto-apostila.md) registra as correções e as pendências.

O artigo final não integra esta etapa.
O modelo original do Overleaf está em `../relatorio/modelo/`, incluindo o ZIP recebido.
O [caderno final em `.qmd`](../entrega/analise_final.qmd) foi executado e reproduziu o ajuste.
A entrega final ainda precisa do artigo `.tex`/`.pdf` e do ZIP completo.

## Preparar os arquivos para o grupo

Na pasta `apresentacao/`, executar `Rscript preparar_pasta_grupo.R` seguido do caminho de uma pasta vazia.
O script copia slides, briefings, revisão, caderno final e bases. Também gera instruções, mensagem pronta e manifesto de hashes.
A pasta criada no Desktop chama-se `GED-16-apresentacao-final`.
Ela é material para o grupo, não a entrega acadêmica completa.
