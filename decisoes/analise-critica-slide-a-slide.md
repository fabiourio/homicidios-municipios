# Análise crítica da apresentação final

> Registro da revisão anterior. A integração de 18/11 acrescentou um slide de estimativas. A numeração e os tempos atuais estão no [LEIA-ME da apresentação](../apresentacao/LEIA-ME.md). As análises e decisões estatísticas abaixo permanecem válidas.

Referência: enunciado da professora reenviado pelo usuário em 17/11/2026.
Critério: cada slide precisa cumprir uma função e preparar o seguinte, dentro de 10–15 minutos.

## Parecer

A sequência cobre os cinco itens docentes. A versão anterior ainda tinha lacunas de conteúdo.
A abertura perdeu a referência que dimensionava o problema; uma frase óbvia ocupou esse espaço.
A conclusão também precisava responder à parte geográfica e à renda, além das três hipóteses.
A revisão abaixo corrige essas lacunas preservando região, pessoas, ordem e roteiro de 13min30.
Não há motivo para inserir a história das tentativas de modelagem no corpo da apresentação.

## Análise dos 14 slides principais

| Slide | Função necessária | Avaliação crítica e encaminhamento |
|---|---|---|
| 1 — Capa | Identificar tema e grupo | Adequado. Apresentar o tema em dez segundos; não ler os cinco nomes. A capa não substitui a contextualização. |
| 2 — Contexto e pergunta | Definir ODS, identificar ODS 16, meta 16.1, indicador 16.1.1 e pergunta | Precisava ser refeito. “A taxa nacional não descreve diferenças municipais” é genérico e não dimensiona o problema. A abertura define ODS e ODS 16, apresenta meta 16.1 e indicador 16.1.1, compara mundo e Brasil em 2021 e distingue a medida de 2021–2023 do estudo. |
| 3 — Dados e resposta | Explicar de onde vêm os dados e o que a taxa mede | Adequado. Preservar residência, período, denominador e causas incluídas. A medida do modelo difere do homicídio intencional usado na comparação internacional. Essa distinção precisa aparecer na fala. |
| 4 — Recorte e explicativas | Delimitar a aplicação do estudo e apresentar as variáveis principais | Adequado com ajuste. Preservar 30 mil habitantes, 1.133 municípios, cobertura populacional e exclusão de Campos do Jordão. Explicitar frequência de 15–17 anos e atraso no ensino médio. Mostrar categorias, sem ler uma lista extensa. |
| 5 — Modelo e finalidade | Dizer qual modelo foi usado e por que existem quadrado, interação e região | Adequado. A finalidade de cada termo acompanha seu nome. A fala explicita mínimos quadrados. Manter ln(renda), em vez de sugerir que o modelo usa renda bruta ao quadrado. |
| 6 — Como avaliamos | Explicar o propósito dos testes e dos gráficos | Adequado como ponte. O risco é transformar a fala numa lista de siglas. Explicar contribuição conjunta, forma dos erros e informação repetida. Deixar resultados e interpretação para os gráficos seguintes. |
| 7 — Ajuste observado | Apresentar o alcance do ajuste e abrir a crítica dos erros | Precisava de texto mais concreto. Manter R² ajustado na escala logarítmica, leitura da diagonal e erros que permanecem. Retirar a frase vaga “falta verificar a forma desses erros”. Explicitar que ajuste na própria amostra não mede desempenho em dados novos. |
| 8 — Variância dos erros | Mostrar um problema real e explicar sua consequência | Forte e necessário. Os gráficos mostram dispersão desigual; Breusch–Pagan complementa essa leitura. A conclusão é cautela com intervalos e testes clássicos, não uma afirmação de que o modelo está validado. |
| 9 — Normalidade | Interpretar a forma da distribuição dos resíduos | Adequado ao pedido de mostrar gráficos dos testes. Histograma e quantis vêm antes do valor p. Não rejeitar normalidade não comprova normalidade e não resolve o problema da variância. |
| 10 — Escola, urbanização e migração | Interpretar associações, unidades e apoio às hipóteses | Precisava de coerência entre título e texto. A urbanização estava no gráfico, mas quase ausente dos comentários. A revisão inclui sua associação positiva. A fala interpreta exemplos percentuais e explica que migração continua sem apoio claro. O diálogo com a literatura fica ligado ao resultado escolar. |
| 11 — Gini e renda | Mostrar a principal qualificação da hipótese de desigualdade | Forte. A interação impede resumir o Gini a um único sinal. Explicar os eixos e o aumento de 0,05 no Gini, antes dos efeitos na renda mediana e no percentil 90. Não generalizar um resultado nulo a todos os municípios pobres. |
| 12 — Renda e região | Responder à parte econômica e geográfica da pergunta | Adequado. O gráfico ilustra duas das cinco regiões, com demais variáveis em valores comuns. Explicar a curva no Gini médio e o contraste Nordeste–Sudeste. O pico não é uma recomendação de política pública; a diferença regional não identifica sua causa. |
| 13 — Limitações | Dizer quais conclusões o ajuste permite sustentar | Precisava justificar a fragilidade citada. A revisão explica que a associação negativa da desocupação perde evidência numa checagem de exclusão de municípios com alta proporção de óbitos indeterminados. Preservar variância desigual, Gini aproximado, possível sub-registro, recorte e independência espacial não verificada. |
| 14 — Resposta e futuro | Responder à pergunta completa e propor continuidade coerente | Precisava incluir renda e região de forma explícita. A frase genérica sobre literatura cede lugar à relação curva da renda e às diferenças regionais no ajuste. O encerramento retoma desigualdade, escola e migração. Os próximos passos respondem aos limites: variância, dependência espacial e dados de políticas estaduais. |

## Coerência com os cinco itens docentes

| Item pedido | Onde e como é atendido |
|---|---|
| Contextualização e questão | Slides 1–2. Dados dimensionam o problema, a meta 16.1 dá sua relevância e a pergunta define a investigação. |
| Base de dados | Slides 3–4. Fontes, resposta, período, unidade municipal, variáveis, recorte e limites de aplicação. |
| Metodologia | Slides 5–6. Modelo, finalidade dos termos e propósito de cada procedimento de avaliação. |
| Ajuste do modelo | Slides 7–9 mostram qualidade e limites. Os efeitos do modelo ajustado são interpretados nos slides 10–12. |
| Discussão e interpretação | Slides 10–14 relacionam resultados à pergunta, às hipóteses, às limitações e aos próximos passos. |

A leitura do ajuste, dos diagnósticos e dos resultados ocupa 8min15 dos 13min30 planejados.
Esse tempo precisa ser usado para interpretar os gráficos, não para enumerar estatísticas.
A discussão não pode começar e terminar apenas no valor do R².

## Comparação internacional recuperada

A parcial usava uma comparação com a média mundial para mostrar a importância do tema.
Essa função precisava ser preservada. A remoção completa do argumento enfraqueceu a abertura.

A comparação revisada usa homicídio intencional em 2021: Brasil 21,3 e mundo 5,8 por cem mil habitantes.
A razão é aproximadamente 3,7. O dado da base do modelo não é usado nessa divisão.
A base continua com média de 46.105 mortes anuais em 2021–2023, incluindo intervenções legais.
Essas informações têm papéis distintos: comparação internacional e dimensão do conjunto analisado.

As taxas foram conferidas no relatório original do [UNODC, Global Study on Homicide 2023](https://www.unodc.org/documents/data-and-analysis/gsh/2023/Global_study_on_homicide_2023_web.pdf), figuras 5 e 6.
O ano e a taxa brasileira também constam na [tabela de homicídios intencionais do Anuário Estatístico da ONU de 2024](https://data.un.org/_Docs/SYB/PDFs/SYB67_328_202411_Intentional%20homicides%20and%20other%20crimes.pdf).
A taxa mundial de 2021 é confirmada no [relatório estendido da ODS 16 de 2024](https://unstats.un.org/sdgs/report/2024/extended-report/Extended-Report_Goal-16.pdf).
Os valores e as referências estão em `apresentacao/contexto_homicidios_2021.csv`.
As referências permanecem na documentação, sem linhas de fonte na projeção.

## Análise dos apêndices

| Apêndice | Avaliação |
|---|---|
| A — Coeficientes | Útil para perguntas; não deve ser lido durante a fala. A tabela passa a incluir também o intercepto, completando os 14 parâmetros. |
| B — Testes | Apoio para contribuição dos blocos e testes globais. Os gráficos dos diagnósticos continuam no corpo. A ordem dos blocos limita a interpretação dos F parciais. |
| C — Box-Cox | Necessário para transparência: o log não é a potência ótima apontada pelo diagnóstico. A figura usa os termos finais. |
| D — Com e sem renda | Responde a uma orientação docente. A retirada é conjunta: termo linear, quadrado e interação. Não interpretar como efeito isolado da renda linear. |
| E — Região e estado | Mantém a comparação documentada. Região é a escolha final; maior R² com estados não reabre automaticamente essa decisão. |
| F — Variáveis retiradas | Útil para perguntas, sem desviar a fala principal para o histórico de tentativas. Ausência de evidência adicional não prova efeito zero. |
| G — Escolhas adicionais | Registro de transparência entre pedidos docentes e escolhas do grupo. Não precisa ser apresentado no roteiro principal. |
| H e I — Resíduos por explicativa | Complementam a checagem da especificação. Manter como apoio, sem acrescentar todas as figuras à fala de quinze minutos. |

## Tempo e preservação das decisões

A ordem permanece Kauan, Fabio, Douglas, Luiz Felipe e Willian.
Os tempos permanecem 1min45, 1min30, 2min, 3min e 5min15, totalizando 13min30.
A explicação de ODS, meta e indicador amplia a abertura de Kauan em trinta segundos, sem criar outro slide.
O ensaio humano continua necessário. A meta de tempo não é uma medição da apresentação real.
Nenhum dado, coeficiente ou especificação do modelo principal foi alterado nesta revisão de conteúdo.
