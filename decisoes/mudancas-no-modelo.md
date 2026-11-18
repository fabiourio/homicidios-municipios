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
| Fronteira, abandono escolar, % homens 15–29, % de óbitos de intenção indeterminada | no modelo | no modelo | fora |
| Parâmetros | 41 | 17 | 14 |
| Ajuste de ln(taxa), pelo R² ajustado | 0,59 | 0,54 | 0,56 |
| 1 − PRESS/SST em ln(taxa), com especificação fixa | não medido | 0,53 | 0,55 |
| Teste de normalidade dos erros (Shapiro-Wilk) | rejeita | rejeita | não rejeita (p = 0,17) |
| Pontos a mais de 4 desvios-padrão | — | 2 | 0 |
| Variância dos erros constante (Breusch-Pagan) | reprova | reprova | reprova |
| Maior VIF | 12,7 | 8,2 | 7,6 |

Os ajustes históricos usaram recortes e termos diferentes. A mudança de R² não isola a troca de estado por região.
Na comparação atual, com a mesma amostra e os mesmos termos restantes, região tem R² ajustado de 0,558 e estado de 0,638.
Região permanece no modelo principal, conforme a decisão confirmada pelo usuário.

## Variáveis do modelo final

ln(taxa de homicídios) explicada por: ln(renda) e seu quadrado · Gini · Gini × ln(renda) · desocupação · % urbana · frequência escolar de 15 a 17 anos · distorção idade-série no ensino médio · migração recente · região.

## Melhorias

- **Modelo mais simples.** De 41 para 14 parâmetros, sem grupos pequenos (com estado, 5 grupos têm menos de 10 municípios).
- **Menos ruído nos dados.** Com 30 mil habitantes, a taxa nacional dá pelo menos 20 homicídios esperados em 3 anos por município. O estudo cobre 77% da população e mantém São Paulo e as capitais.
- **Medida de desigualdade conhecida.** O Gini substitui a razão média/mediana. O cálculo segue Gastwirth (1972). A correlação com a referência oficial nas UFs é 0,995, com universos etários diferentes. Essa comparação não valida o valor exato municipal.
- **Sem variável com defeito.** A proporção de óbitos de intenção indeterminada tinha os homicídios no divisor. Isso criava acoplamento matemático com a resposta. A medida corrigida não apresentou evidência adicional no ajuste.
- **PRESS conferido para a especificação final.** A auditoria reproduziu 1.133 reajustes, retirando um município por vez. O indicador 1 − PRESS/SST foi 0,5521. Ele não valida a seleção anterior das variáveis, independência espacial ou previsão externa.
- **Efeito da desigualdade descrito como ele é.** Um único número (+18%) escondia situações diferentes; o modelo final mostra o efeito por faixa de renda.
- **Diagnóstico atualizado.** O teste de Shapiro-Wilk não rejeita a normalidade e nenhum ponto fica a mais de 4 desvios-padrão. Com Campos do Jordão, o teste rejeita; isso não comprova normalidade nem é a justificativa para remover o município.

## Decisões

| # | Decisão | Motivo |
|---|---|---|
| — | Os 9 pedidos da professora: Gini, região, sem raça, sem teste de vizinhos, gráficos de diagnóstico, percentil, comparação com e sem a renda, entre outros | Revisão da apresentação parcial |
| 16 | Corte de população em 30 mil habitantes | Fica perto do percentil 80 da população; menos ruído nas cidades pequenas |
| 1 e 4 | Densidade fora do modelo, sem corte de densidade | Sem evidência adicional no ajuste final (p = 0,78) |
| 2 | Sem teste baseado em ordem artificial dos municípios | A independência espacial permanece não verificada |
| 3 | Região mantida; estado fica como comparação complementar | Decisão do grupo em 17/11: preservar uma comparação regional interpretável |
| 5 | A renda fica | Contribui para o modelo; VIF abaixo de 10 |
| 6 | Gini de 2022 calculado por nós | Aproximação municipal pelas classes de renda disponíveis no estudo |
| 7 | Amazônia Legal fora | A evidência é sensível à exclusão de Mato Grosso; isso não demonstra causa ou exclusividade |
| 8 | Campos do Jordão (SP) sai | Indício de sub-registro: 1 homicídio registrado e 36 óbitos de intenção indeterminada. A remoção não se justifica apenas pelo diagnóstico |
| 9 | Fronteira, abandono escolar e % homens 15–29 saem | Sem evidência adicional nos testes condicionais (p = 0,31; 0,67; 0,14); isso não prova efeito zero |
| 13 | Entra o termo Gini × renda | Contribuição no teste F parcial (F = 64,6). O F não mede validação externa. A direção persiste nos cortes verificados |
| 14 | Proporção de óbitos de intenção indeterminada sai | Defeito na conta (acima) |
| 10 | Esta é a entrega final | "Parcial" e "preliminar" saíram dos nomes dos arquivos e da capa |

Decisões concluídas em 17/11: região mantida (pergunta 3), mesma ordem dos cinco apresentadores (pergunta 11) e vizinhança citada como limitação (pergunta 15). Não entra um novo teste espacial. O roteiro prevê 13min30 e reserva 1min30 para pausas e transições. A capa do deck fica com "novembro de 2026".

## O que muda nas hipóteses

| Hipótese | Apresentação parcial | Modelo final |
|---|---|---|
| H1: mais desigualdade, mais homicídios | Apoio relatado na parcial | Associação positiva nas rendas mediana e alta. Nas rendas baixas, o efeito varia: negativo no percentil 10 e sem distinção de zero no percentil 25 |
| H2: mais exclusão escolar, mais homicídios | Apoio relatado na parcial | Direções compatíveis com a hipótese; inferência exploratória |
| H3: mais migração recente, mais homicídios | Apoio relatado na parcial | Sem apoio claro no ajuste final (p = 0,14). A evidência mudou após retirar a medida problemática; isso não invalida a hipótese |

Efeitos no modelo final, com as outras variáveis constantes:

| Variável | Mudança | Mudança na taxa típica ajustada |
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
Os valores históricos de PRESS da coluna intermediária são registros anteriores, não uma nova validação dessa versão.

## Reunião de alinhamento com os professores

Fonte: [transcrição integral do alinhamento](GED-16-alinhamento-com-professores.txt). O texto preserva as falas e os erros da transcrição automática.

| Orientação | O que foi feito |
|---|---|
| Olhar primeiro a especificação e as hipóteses do modelo; a multicolinearidade (VIF) vem depois e só afeta a leitura dos coeficientes | Nos slides, o diagnóstico vem antes dos coeficientes, e o VIF fica por último |
| Contar só a história do modelo final, sem a primeira apresentação nem as decisões do caminho | Região × estado está no apêndice E; com × sem renda está no D; a densidade saiu do corpo |
| Criticar o modelo e sugerir trabalhos futuros | Slide 13, "Discussão: limites das conclusões", e slide 14, com próximos passos |
| Região ou estado: não há opção certa, depende da pergunta; com estado, cada um é comparado com São Paulo | O grupo manteve região em 17/11. Com estado o R² ajustado de ln(taxa) é maior (0,64 contra 0,56), mas o modelo usa 36 parâmetros e 5 estados têm menos de 10 municípios. A comparação fica no apêndice |

Aprovados na reunião: o Gini calculado pelas faixas de renda, a retirada de Campos do Jordão, o corte em 30 mil habitantes e a Amazônia Legal fora.

## O que continua como limitação

- A resposta inclui agressões e intervenções legais. Ela se relaciona ao ODS 16, mas não equivale estritamente ao indicador 16.1.1 da ONU.
- A variância dos erros não é constante (teste de Breusch-Pagan). Os valores p são aproximados.
- O Gini municipal é uma aproximação pelas faixas de renda do Censo.
- A desocupação tem sinal negativo no modelo e correlação simples positiva com ln(taxa) (+0,30). A correlação com a renda (−0,55) sugere investigar sobreposição entre explicativas, mas não comprova a causa da troca de sinal. O efeito é frágil: perde a significância sem os 31 municípios com muitos óbitos de intenção indeterminada.
- A dependência entre municípios próximos não foi avaliada. A ausência de um teste espacial não comprova independência dos erros.
- O estudo é observacional: mostra associação entre municípios, não causa.

## Apresentação final aprovada em 17/11

- Contexto e dados ocupam três minutos, sem leitura da lista completa de variáveis.
- A resposta, o período, o corte de 30 mil habitantes e as limitações continuam explícitos.
- O corpo tem 14 páginas; revisão extensa, coeficientes completos e comparações auxiliares ficam nos apêndices.
- Os diagnósticos mostram gráficos com interpretação antes de apresentar os números dos testes.
- A discussão responde à pergunta de pesquisa e compara os achados com a literatura.
- A apresentação não inclui abandono parental nem variáveis retiradas apenas para melhorar a narrativa.
- Os cinco briefings preservam as pessoas e a ordem Kauan, Fabio, Douglas, Luiz Felipe e Willian. Os conteúdos foram condensados e redistribuídos; não são idênticos aos da parcial.
- O artigo final fica fora desta etapa.

## Estrutura familiar: esclarecimento para perguntas

A variável `pct_maes_solo` aparece no levantamento e na exploratória antiga, mas não no ajuste final.
Ela representa domicílios com mulher responsável, sem cônjuge e com filhos, conforme a definição da base candidata.
Ela não identifica abandono parental. O registro consultado não documenta um motivo estatístico específico para sua não inclusão final.
Não afirmar que ela foi retirada por falta de significância. O abandono escolar no ensino médio é outra variável.
Esse abandono escolar foi testado e retirado por ausência de contribuição adicional no ajuste condicional registrado.

A checagem de estrutura familiar foi executada após identificar a lacuna histórica: p clássico de 0,139 e ganho mínimo no ajuste.
A justificativa atual para manter fora está na [auditoria completa das candidatas](../validacao/AUDITORIA_CANDIDATAS.md).
Essa auditoria não autoriza afirmar que todas as outras candidatas eram não significativas.
O usuário confirmou preservar o modelo principal, registrar comparações e não acrescentar apêndices ao deck.
