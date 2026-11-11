# O que mudou no modelo, e por quê

Diferenças entre o modelo da apresentação parcial e o modelo final, com as decisões do grupo. Situação em 11/11/2026. O detalhe de cada decisão, com opções, prós e contras, está em `decisoes-do-grupo.pdf`.

A coluna "Final" tem todas as decisões e é o que o código faz hoje. A coluna do meio é o modelo de antes das decisões 8, 9, 13 e 14.

## As três versões

| | Apresentação parcial (28/10) | Antes das decisões 8, 9, 13 e 14 | Final |
|---|---|---|---|
| Municípios | 1.710 (20 mil hab. ou mais) | 1.134 (30 mil hab. ou mais) | 1.133 (sai Campos do Jordão) |
| Variável de lugar | 27 estados | 5 regiões | 5 regiões |
| Desigualdade | razão renda média / mediana | Gini de 2022, calculado por nós | Gini, com efeito que muda conforme a renda |
| Raça e densidade | no modelo | fora | fora |
| Fronteira, abandono escolar, % homens 15–29, % de mortes sem causa definida | no modelo | no modelo | fora |
| Parâmetros | 41 | 17 | 14 |
| Quanto explica (R² ajustado) | 0,59 | 0,54 | 0,56 |
| Quanto explica em municípios que o modelo não viu | não medido | 0,53 | 0,55 |
| Maior VIF (limite: 10) | 12,7 | 8,2 | 7,6 |
| Erros com distribuição normal (Shapiro-Wilk) | reprova | reprova | aprova (p = 0,17) |
| Pontos a mais de 4 desvios-padrão | — | 2 | 0 |

O R² ajustado caiu de 0,59 para 0,54 quando o estado deu lugar à região, a pedido da professora. Em troca, o modelo passou de 41 para 17 parâmetros. O modelo final recupera parte da diferença com 14 parâmetros.

## Variáveis do modelo final

ln(taxa de homicídios) explicada por: renda e renda² · Gini · Gini × renda · desocupação · % urbana · frequência escolar de 15 a 17 anos · distorção idade-série no ensino médio · migração recente · região.

## Melhorias

- **Modelo mais simples.** De 41 para 14 parâmetros, sem grupos pequenos (com estado, 5 grupos têm menos de 10 municípios).
- **Menos ruído nos dados.** Com 30 mil habitantes, a taxa nacional dá pelo menos 20 homicídios esperados em 3 anos por município. O estudo cobre 77% da população e mantém São Paulo e as capitais.
- **Medida de desigualdade conhecida.** O Gini substitui a razão média/mediana. O cálculo segue Gastwirth (1972) e bate com o Gini oficial nos 27 estados (correlação de 0,995).
- **Sem variável com defeito.** A "% de mortes sem causa definida" tinha os homicídios no divisor. Por isso ela caía sozinha quando os homicídios subiam. Com a conta corrigida, ela não tem efeito.
- **Sem sobreajuste.** A diferença entre o que o modelo explica nos dados usados e em dados que ele não viu é de 0,01. Só entrou o que melhora o modelo fora da amostra.
- **Efeito da desigualdade descrito como ele é.** Um único número (+18%) escondia situações diferentes; o modelo final mostra o efeito por faixa de renda.
- **Suposições mais bem atendidas.** Nenhuma variável repete as outras em excesso (VIF de 12,7 para 7,6) e os erros passam no teste de normalidade.

## Decisões

| # | Decisão | Motivo |
|---|---|---|
| — | Os 9 pedidos da professora: Gini, região, sem raça, sem teste de vizinhos, gráficos de diagnóstico, percentil, comparação com e sem a renda, entre outros | Revisão da apresentação parcial |
| 16 | Corte de população em 30 mil habitantes | Fica perto do percentil 80 da população; menos ruído nas cidades pequenas |
| 1 e 4 | Densidade fora do modelo, sem corte de densidade | Com 30 mil habitantes ela não tem efeito (p = 0,78 no modelo final) |
| 2 | Sem teste de independência dos erros | Pedido da professora |
| 3 | Região, e não estado | Pedido da professora; modelo menor |
| 5 | A renda fica | Contribui para o modelo; VIF abaixo de 10 |
| 6 | Gini de 2022 calculado por nós | O IBGE só publica o Gini por região e estado |
| 7 | Amazônia Legal fora | O efeito vem só do Mato Grosso; ganho de 0,002 |
| 8 | Campos do Jordão (SP) sai | Indício de erro no dado: 1 homicídio registrado e 36 mortes sem causa definida. O modelo esperava 11 homicídios |
| 9 | Fronteira, abandono escolar e % homens 15–29 saem | Sem efeito (p = 0,31; 0,67; 0,14). O modelo não perde nada sem elas |
| 13 | Entra o termo Gini × renda | Único acréscimo que melhora o modelo fora da amostra (F = 64,6). Vale com corte de 20, 30, 50 e 100 mil habitantes |
| 14 | "% de mortes sem causa definida" sai | Defeito na conta (acima) |
| 10 | Esta é a entrega final | "Parcial" e "preliminar" saíram dos nomes dos arquivos e da capa |

Adiada: tamanho do deck e divisão das falas (pergunta 11). Em aberto: citar a vizinhança como limitação (pergunta 15).

## O que muda nas hipóteses

| Hipótese | Apresentação parcial | Modelo final |
|---|---|---|
| H1: mais desigualdade, mais homicídios | Confirmada | Confirmada nos municípios de renda média e alta. Sem efeito claro nos 40% mais pobres |
| H2: mais exclusão escolar, mais homicídios | Confirmada | Confirmada |
| H3: mais migração recente, mais homicídios | Confirmada | Não confirmada (p = 0,14). O efeito dependia da variável com defeito |

Efeitos no modelo final, com as outras variáveis constantes:

| Variável | Mudança | Efeito na taxa |
|---|---|---|
| Gini, município de renda mediana (R$ 1.383) | +0,05 | +16% |
| Gini, 10% mais ricos (R$ 2.043) | +0,05 | +34% |
| Gini, abaixo de R$ 931 (29% dos municípios) | +0,05 | nulo ou negativo |
| Frequência escolar de 15 a 17 anos | +5 pontos | −9% |
| Distorção idade-série no ensino médio | +10 pontos | +16% |
| % urbana | +10 pontos | +12% |
| Desocupação | +5 pontos | −9% |
| Região (contra o Sudeste) | — | Nordeste +108%, Centro-Oeste +83%, Norte +79%, Sul +67% |

A renda continua com efeito em U invertido: a taxa esperada é máxima perto de R$ 815.

## O que continua como limitação

- A variância dos erros não é constante (teste de Breusch-Pagan). Os valores p são aproximados.
- O Gini municipal é uma aproximação pelas faixas de renda do Censo.
- O efeito negativo da desocupação não tem explicação testada e é frágil: perde a significância sem os 31 municípios com muitas mortes sem causa definida.
- O estudo é observacional: mostra associação entre municípios, não causa.
