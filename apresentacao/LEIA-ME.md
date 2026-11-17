# Apresentação final — 18/11/2026

**Apresentar os slides 1–14.** Os slides 15–23 são apêndices para perguntas.
O roteiro planeja 13 minutos. Os dois minutos restantes acomodam pausas e transições.
O grupo ainda precisa confirmar a duração num ensaio cronometrado.
O prazo informado para enviar os slides é 18/11/2026, às 10h00.

## Materiais

- [Slides em PDF](apresentacao_final.pdf): versão principal para conferir e apresentar.
- [Slides em PowerPoint](apresentacao_final.pptx): mesmo visual, com as falas nas notas do apresentador.
- [Slides em HTML](apresentacao_final.html): setas para navegar, N para notas e F para tela cheia.
- [Falas completas](notas.json): uma nota por página, na ordem do deck.
- [Tempos por slide](roteiro.csv): fonte dos tempos nos briefings.
- [Verificação final](VERIFICACAO.md): evidências e limites das verificações.

O PowerPoint usa imagens dos slides para preservar o visual. A fonte editável fica em `latex/apresentacao_final.tex`.
Notas e briefings são materiais internos do grupo. Os slides fazem parte da entrega à professora.

## Quem apresenta

| Pessoa | Slides | Tempo | Marco de início | Marco de fim | Briefing completo |
|---|---|---|---|---|---|
| Kauan | 1–2 | 1min30 | 0min00 | 1min30 | [Abrir](briefings/briefing_kauan.pdf) |
| Fabio | 3–4 | 1min30 | 1min30 | 3min00 | [Abrir](briefings/briefing_fabio.pdf) |
| Douglas | 5–6 | 2min | 3min00 | 5min00 | [Abrir](briefings/briefing_douglas.pdf) |
| Luiz Felipe | 7–9 | 3min | 5min00 | 8min00 | [Abrir](briefings/briefing_luiz_felipe.pdf) |
| Willian | 10–14 | 5min | 8min00 | 13min00 | [Abrir](briefings/briefing_willian.pdf) |

Cada briefing inclui a parte individual, as falas completas, os slides, as decisões comuns e perguntas respondidas.
Os tempos são metas de ensaio, não o resultado de uma apresentação real.
Não ler as referências nem os apêndices durante o roteiro principal.

## Conteúdo dos slides

| Slides | Conteúdo |
|---|---|
| 1–2 | Tema, contexto, pergunta e hipóteses |
| 3–4 | Fontes, resposta, variáveis e recorte |
| 5–6 | Diferenças regionais e relação bruta com a renda |
| 7 | Modelo final e finalidade dos métodos |
| 8–9 | Resíduos, variância dos erros e normalidade, com gráficos interpretados |
| 10–12 | Escola, urbanização, migração, desigualdade, renda e região |
| 13–14 | Limitações, resposta à pergunta, literatura e trabalhos futuros |
| 15–23 | Coeficientes, testes, Box-Cox, comparações, variáveis retiradas e referências |

## Cuidados para a fala

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

O artigo final não integra esta etapa.
O modelo original do Overleaf está em `../relatorio/modelo/`, incluindo o ZIP recebido.
A entrega final ainda precisa do artigo `.tex`/`.pdf`, do `.qmd` alinhado ao modelo e do ZIP completo.
