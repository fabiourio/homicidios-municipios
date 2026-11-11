# O que mudou no modelo, e por quê

Resumo das diferenças entre o modelo da apresentação parcial e o modelo final, com as decisões do grupo. Situação em 11/11/2026. O detalhe de cada decisão, com opções, prós e contras, está em `decisoes-do-grupo.pdf`.

## As três versões

| | Apresentação parcial (28/10) | Hoje no código | Final (a aplicar) |
|---|---|---|---|
| Municípios | 1.710 (20 mil hab. ou mais) | 1.134 (30 mil hab. ou mais) | 1.134 |
| Variável de lugar | 27 estados | 5 regiões | 5 regiões |
| Desigualdade | razão renda média / mediana | Gini de 2022, calculado por nós | Gini, com efeito que muda conforme a renda |
| Raça, densidade | no modelo | fora | fora |
| Fronteira, abandono escolar, % de mortes sem causa definida | no modelo | no modelo | fora |
| Parâmetros | 41 | 17 | 15 |
| Quanto explica (R² ajustado) | 0,59 | 0,54 | 0,56 |
| Quanto explica em municípios que o modelo não viu | não medido | 0,53 | 0,55 |
| Maior VIF | 12,7 (acima do limite de 10) | 8,2 | abaixo de 10 (a conferir na aplicação) |

O R² ajustado caiu de 0,59 para 0,54 quando o estado deu lugar à região, a pedido da professora. Em troca, o modelo passou de 41 para 17 parâmetros. O modelo final recupera parte da diferença com 15 parâmetros.

## Melhorias

- **Modelo mais simples.** De 41 para 15 parâmetros, sem grupos pequenos (com estado, 5 grupos têm menos de 10 municípios).
- **Menos ruído nos dados.** Com 30 mil habitantes, a taxa nacional dá pelo menos 20 homicídios esperados em 3 anos por município. O estudo cobre 77% da população e mantém São Paulo e as capitais.
- **Medida de desigualdade conhecida.** O Gini substitui a razão média/mediana. O cálculo segue Gastwirth (1972) e bate com o Gini oficial nos 27 estados (correlação de 0,995).
- **Sem variável com defeito.** A "% de mortes sem causa definida" tinha os homicídios no divisor. Por isso ela caía sozinha quando os homicídios subiam. Com a conta corrigida, ela não tem efeito.
- **Sem sobreajuste.** A diferença entre o que o modelo explica nos dados usados e em dados que ele não viu é de 0,01. Só entrou o que melhora o modelo fora da amostra.
- **Efeito da desigualdade descrito como ele é.** Um único número (+18%) escondia situações diferentes; o modelo final mostra o efeito por faixa de renda.

## Decisões

| # | Decisão | Motivo | Situação |
|---|---|---|---|
| — | Os 9 pedidos da professora (Gini, região, sem raça, sem teste de vizinhos, gráficos de diagnóstico, percentil, comparação com e sem a renda, entre outros) | Revisão da apresentação parcial | Aplicado |
| 16 | Corte de população em 30 mil habitantes | Fica perto do percentil 80 da população; menos ruído nas cidades pequenas | Aplicado |
| 1 e 4 | Densidade fora do modelo, sem corte de densidade | Com 30 mil habitantes ela não tem efeito (p = 0,19) | Aplicado |
| 2 | Sem teste de independência dos erros | Pedido da professora | Aplicado |
| 3 | Região, e não estado | Pedido da professora; modelo menor | Aplicado |
| 5 | A renda fica | Contribui para o modelo (F = 77,4); VIF abaixo de 10 | Aplicado |
| 6 | Gini de 2022 calculado por nós | O IBGE só publica o Gini por região e estado | Aplicado |
| 7 | Amazônia Legal fora | O efeito vem só do Mato Grosso; ganho de 0,002 | Decidido; nada a mudar no código |
| 9 | Fronteira e abandono escolar saem | Sem efeito (p = 0,15 e 0,66); o modelo não perde nada | A aplicar |
| 14 | "% de mortes sem causa definida" sai | Defeito na conta (acima) | A aplicar |
| 10 | Esta é a entrega final | — | A aplicar: trocar "parcial" e "preliminar" |
| 13 | Efeito do Gini conforme a renda (termo Gini × renda) | Único acréscimo que melhora o modelo fora da amostra (0,53 para 0,55) | Sugestão; falta confirmar |
| 8 | Campos do Jordão (SP) | 1 homicídio e 36 mortes sem causa definida: indício de erro no dado | Falta decidir |

## O que muda nas hipóteses

| Hipótese | Apresentação parcial | Modelo final |
|---|---|---|
| H1: mais desigualdade, mais homicídios | Confirmada | Confirmada nos municípios de renda média e alta. Para +0,05 no Gini: +16% na renda mediana, +34% nos 10% mais ricos. Sem efeito claro nos 40% mais pobres |
| H2: mais exclusão escolar, mais homicídios | Confirmada | Confirmada. +5 pontos de frequência escolar: −9%. +10 pontos de distorção idade-série: +15% |
| H3: mais migração recente, mais homicídios | Confirmada | Não confirmada (p = 0,06). O efeito dependia da variável com defeito |

A renda continua com efeito em U invertido, e as quatro regiões continuam acima do Sudeste.

## O que continua como limitação

- A variância dos erros não é constante (teste de Breusch-Pagan). Os valores p são aproximados.
- O Gini municipal é uma aproximação pelas faixas de renda do Censo.
- O estudo é observacional: mostra associação entre municípios, não causa.
