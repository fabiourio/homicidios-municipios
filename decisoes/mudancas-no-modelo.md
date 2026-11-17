# O que mudou no modelo, e por quê

Diferenças entre o modelo da apresentação parcial e o modelo final, com as decisões do grupo. Decisões atualizadas em 17/11/2026. Os indicadores abaixo são os resultados já registrados em 11/11. O histórico de opções está em `decisoes-do-grupo.html` e `.pdf`. As [decisões da apresentação final](discussao-final-17-11-2026.md) prevalecem sobre as propostas históricas.

A coluna "Final" tem todas as decisões e é o que o código faz hoje. A coluna do meio é o modelo de antes das decisões 8, 9, 13 e 14.

## As três versões

| | Apresentação parcial (28/10) | Antes das decisões 8, 9, 13 e 14 | Final |
|---|---|---|---|
| Municípios | 1.710 (20 mil hab. ou mais) | 1.134 (30 mil hab. ou mais) | 1.133 (sai Campos do Jordão) |
| Variável de lugar | 27 estados | 5 regiões | 5 regiões (decisão confirmada em 17/11) |
| Desigualdade | razão renda média / mediana | Gini de 2022, calculado por nós | Gini, com efeito que muda conforme a renda |
| Raça e densidade | no modelo | fora | fora |
| Fronteira, abandono escolar, % homens 15–29, % de mortes sem causa definida | no modelo | no modelo | fora |
| Parâmetros | 41 | 17 | 14 |
| Ajuste de ln(taxa), pelo R² ajustado | 0,59 | 0,54 | 0,56 |
| Quanto explica em municípios que o modelo não viu | não medido | 0,53 | 0,55 |
| Teste de normalidade dos erros (Shapiro-Wilk) | rejeita | rejeita | não rejeita (p = 0,17) |
| Pontos a mais de 4 desvios-padrão | — | 2 | 0 |
| Variância dos erros constante (Breusch-Pagan) | reprova | reprova | reprova |
| Maior VIF | 12,7 | 8,2 | 7,6 |

O R² ajustado caiu de 0,59 para 0,54 quando o estado deu lugar à região, a pedido da professora. Em troca, o modelo passou de 41 para 17 parâmetros. O modelo final recupera parte da diferença com 14 parâmetros.

## Variáveis do modelo final

ln(taxa de homicídios) explicada por: renda e renda² · Gini · Gini × renda · desocupação · % urbana · frequência escolar de 15 a 17 anos · distorção idade-série no ensino médio · migração recente · região.

## Melhorias

- **Modelo mais simples.** De 41 para 14 parâmetros, sem grupos pequenos (com estado, 5 grupos têm menos de 10 municípios).
- **Menos ruído nos dados.** Com 30 mil habitantes, a taxa nacional dá pelo menos 20 homicídios esperados em 3 anos por município. O estudo cobre 77% da população e mantém São Paulo e as capitais.
- **Medida de desigualdade conhecida.** O Gini substitui a razão média/mediana. O cálculo segue Gastwirth (1972) e bate com o Gini oficial nos 27 estados (correlação de 0,995).
- **Sem variável com defeito.** A "% de mortes sem causa definida" tinha os homicídios no divisor. Por isso ela caía sozinha quando os homicídios subiam. Com a conta corrigida, ela não tem efeito.
- **Verificação fora da amostra registrada anteriormente.** A diferença registrada entre os indicadores é de 0,01. Esse resultado não comprova ausência de sobreajuste nem substitui o diagnóstico dos resíduos.
- **Efeito da desigualdade descrito como ele é.** Um único número (+18%) escondia situações diferentes; o modelo final mostra o efeito por faixa de renda.
- **Diagnóstico atualizado.** O teste de Shapiro-Wilk não rejeita a normalidade e nenhum ponto fica a mais de 4 desvios-padrão. Com Campos do Jordão, o teste rejeita; isso não comprova normalidade nem é a justificativa para remover o município.

## Decisões

| # | Decisão | Motivo |
|---|---|---|
| — | Os 9 pedidos da professora: Gini, região, sem raça, sem teste de vizinhos, gráficos de diagnóstico, percentil, comparação com e sem a renda, entre outros | Revisão da apresentação parcial |
| 16 | Corte de população em 30 mil habitantes | Fica perto do percentil 80 da população; menos ruído nas cidades pequenas |
| 1 e 4 | Densidade fora do modelo, sem corte de densidade | Com 30 mil habitantes ela não tem efeito (p = 0,78 no modelo final) |
| 2 | Sem teste de independência dos erros | Pedido da professora |
| 3 | Região mantida; estado fica como comparação complementar | Decisão do grupo em 17/11: preservar uma comparação regional interpretável |
| 5 | A renda fica | Contribui para o modelo; VIF abaixo de 10 |
| 6 | Gini de 2022 calculado por nós | O IBGE só publica o Gini por região e estado |
| 7 | Amazônia Legal fora | O efeito vem só do Mato Grosso; ganho de 0,002 |
| 8 | Campos do Jordão (SP) sai | Indício de sub-registro: 1 homicídio registrado e 36 mortes sem causa definida. A remoção não se justifica apenas pelo diagnóstico |
| 9 | Fronteira, abandono escolar e % homens 15–29 saem | Sem efeito (p = 0,31; 0,67; 0,14). O modelo não perde nada sem elas |
| 13 | Entra o termo Gini × renda | Único acréscimo que melhora o modelo fora da amostra (F = 64,6). Vale com corte de 20, 30, 50 e 100 mil habitantes |
| 14 | "% de mortes sem causa definida" sai | Defeito na conta (acima) |
| 10 | Esta é a entrega final | "Parcial" e "preliminar" saíram dos nomes dos arquivos e da capa |

Decisões concluídas em 17/11: região mantida (pergunta 3), mesma ordem dos cinco apresentadores (pergunta 11) e vizinhança citada como limitação (pergunta 15). Não entra um novo teste espacial. O roteiro prevê 13 minutos e reserva dois minutos para pausas e transições. A capa do deck fica com "novembro de 2026".

## O que muda nas hipóteses

| Hipótese | Apresentação parcial | Modelo final |
|---|---|---|
| H1: mais desigualdade, mais homicídios | Confirmada | Associação positiva nas rendas mediana e alta. Nas rendas baixas, o efeito varia: negativo no percentil 10 e sem distinção de zero no percentil 25 |
| H2: mais exclusão escolar, mais homicídios | Confirmada | Confirmada |
| H3: mais migração recente, mais homicídios | Confirmada | Não confirmada (p = 0,14). O efeito dependia da variável com defeito |

Efeitos no modelo final, com as outras variáveis constantes:

| Variável | Mudança | Efeito na taxa |
|---|---|---|
| Gini, município de renda mediana (R$ 1.383) | +0,05 | +16% |
| Gini, município no percentil 90 de renda (R$ 2.043) | +0,05 | +34% |
| Gini, município no percentil 10 de renda (R$ 699) | +0,05 | −10%; intervalo de 95% não inclui zero |
| Gini, município no percentil 25 de renda (R$ 873) | +0,05 | −2%; intervalo de 95% inclui zero |
| Gini, abaixo de R$ 931 (29% dos municípios) | +0,05 | estimativa pontual não positiva; o limite não define significância |
| Frequência escolar de 15 a 17 anos | +5 pontos | −9% |
| Distorção idade-série no ensino médio | +10 pontos | +16% |
| % urbana | +10 pontos | +12% |
| Desocupação | +5 pontos | −9% |
| Região (contra o Sudeste) | — | Nordeste +108%, Centro-Oeste +83%, Norte +79%, Sul +67% |

A curva ajustada da renda tem forma de U invertido, no Gini médio, com pico perto de R$ 815.
Os efeitos e intervalos dependem das hipóteses do modelo; a variância dos erros não constante limita a inferência.

## Reunião de alinhamento com os professores

Fonte: [transcrição integral do alinhamento](GED-16-alinhamento-com-professores.txt). O texto preserva as falas e os erros da transcrição automática.

| Orientação | O que foi feito |
|---|---|
| Olhar primeiro a especificação e as hipóteses do modelo; a multicolinearidade (VIF) vem depois e só afeta a leitura dos coeficientes | Nos slides, o diagnóstico vem antes dos coeficientes, e o VIF fica por último |
| Contar só a história do modelo final, sem a primeira apresentação nem as decisões do caminho | Região × estado e com × sem a renda foram para os apêndices E e F; a densidade saiu do corpo |
| Criticar o modelo e sugerir trabalhos futuros | Slide "Crítica do modelo" e lista de trabalhos futuros |
| Região ou estado: não há opção certa, depende da pergunta; com estado, cada um é comparado com São Paulo | O grupo manteve região em 17/11. Com estado o R² ajustado de ln(taxa) é maior (0,64 contra 0,56), mas o modelo usa 36 parâmetros e 5 estados têm menos de 10 municípios. A comparação fica no apêndice |

Aprovados na reunião: o Gini calculado pelas faixas de renda, a retirada de Campos do Jordão, o corte em 30 mil habitantes e a Amazônia Legal fora.

## O que continua como limitação

- A resposta inclui agressões e intervenções legais. Ela se relaciona ao ODS 16, mas não equivale estritamente ao indicador 16.1.1 da ONU.
- A variância dos erros não é constante (teste de Breusch-Pagan). Os valores p são aproximados.
- O Gini municipal é uma aproximação pelas faixas de renda do Censo.
- A desocupação tem sinal negativo no modelo e correlação simples positiva com ln(taxa) (+0,30). A correlação com a renda (−0,55) sugere investigar sobreposição entre explicativas, mas não comprova a causa da troca de sinal. O efeito é frágil: perde a significância sem os 31 municípios com muitas mortes sem causa definida.
- A dependência entre municípios próximos não foi avaliada. A ausência de um teste espacial não comprova independência dos erros.
- O estudo é observacional: mostra associação entre municípios, não causa.

## Apresentação final aprovada em 17/11

- Contexto e dados ocupam três minutos, sem leitura da lista completa de variáveis.
- A resposta, o período, o corte de 30 mil habitantes e as limitações continuam explícitos.
- O corpo tem 14 páginas; revisão extensa, coeficientes completos e comparações auxiliares ficam nos apêndices.
- Os diagnósticos mostram gráficos com interpretação antes de apresentar os números dos testes.
- A discussão responde à pergunta de pesquisa e compara os achados com a literatura.
- A apresentação não inclui abandono parental nem variáveis retiradas apenas para melhorar a narrativa.
- Os cinco briefings preservam a ordem Kauan, Fabio, Douglas, Luiz Felipe e Willian.
- O artigo final fica fora desta etapa.
