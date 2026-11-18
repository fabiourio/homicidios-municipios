# Auditoria de todas as candidatas — 17/11/2026

## Decisão final e alcance

O usuário confirmou manter o modelo principal, com região, e acrescentar auditoria e comparações.
A auditoria não demonstra que todas as candidatas sejam irrelevantes. Algumas acrescentam informação e merecem ampliação futura.
A especificação principal é um recorte confirmado pelo grupo. Ela não foi provada única, ótima ou resultado de seleção exaustiva prévia.
As justificativas abaixo registram a decisão atual. Não reconstituem motivos históricos que não estavam documentados.

## Universo efetivamente conferido

Foram examinadas 39 colunas e codificações candidatas, em 57 formas de entrada. As alternativas em log1p são checagens adicionais, não escolhas pelo menor p.
Esse inventário inclui as 26 colunas não usadas da base de 28 candidatas, além de medidas do núcleo e da exploratória antiga.
PIB e ln(PIB), por exemplo, são codificações do mesmo conceito. Não são duas fontes independentes.
O núcleo adotado usa 1.133 municípios; cada comparação com dados faltantes reajusta também a referência nos mesmos municípios.
Raça permaneceu excluída por orientação docente. As bases integradas atuais não contêm uma candidata racial a ser testada nesta auditoria.
A razão renda média/mediana foi substituída pelo Gini. Ela não está disponível nas bases integradas atuais.
Identificadores, contagens que compõem a resposta, exposição e taxas de 2024 não foram tratados como explicativas adicionais. Isso criaria vazamento da resposta, duplicação ou mudança de período.

## Conferência dos dados

O integrador original foi executado novamente sobre as fontes locais. Ele reconstruiu 5.570 municípios e 28 candidatas.
Duas colunas de despesas estavam desatualizadas: faltavam todos os valores, embora a fonte consolidada já existisse.
A reconstrução recuperou as despesas; onze municípios sem DCA permanecem faltantes na base nacional. No recorte, falta um.
As demais 26 candidatas e as três variáveis extras usadas na análise permaneceram numericamente iguais, até tolerância de 1e-10.
As junções exigem código municipal único. O modelo de referência foi reproduzido e seus coeficientes conferidos contra a tabela publicada.
As contagens de estrutura familiar foram recalculadas diretamente: 5.570 numeradores e denominadores coincidem com a variável integrada.
A fonte de favelas foi confrontada com a API atual do IBGE: 656 municípios, todas as contagens idênticas, total de 16.390.790 pessoas, sem sigilo ou ausência entre esses registros.
O percentual de favelas representa áreas identificadas no Censo. Zero não demonstra ausência de qualquer ocupação informal não mapeada.
Limites de cada fonte, cortes em 100 e imputações de zero continuam no dicionário. Reconstruir uma fonte não torna essas escolhas perfeitas.

## Método das comparações

Cada candidata é acrescentada ao modelo adotado, com renda, quadrado, Gini, interação, escola, urbanização, migração, desocupação e região.
O teste F parcial avalia contribuição adicional. O R² ajustado e o PRESS complementam a comparação.
Foram examinadas também estabilidade de escola e Gini e mudanças na evidência de migração.
Os testes e intervalos são clássicos: a variância desigual permanece e a independência espacial não foi verificada.
Foram realizadas muitas comparações. Os valores p são exploratórios e não selecionam automaticamente variáveis.
O PRESS é condicionado à especificação. Ele não valida a escolha posterior entre as candidatas nem constitui validação externa.
Os blocos social, econômico e territorial são checagens conjuntas. Eles impedem concluir que vários testes isolados descrevam necessariamente o mesmo modelo.

## Inventário completo: forma original da coluna

A forma original pode já ser um logaritmo, conforme o nome. As 57 linhas, incluindo as alternativas log1p, estão no CSV de testes.
O ganho é a diferença de R² ajustado, usando os mesmos casos em cada comparação. Um ganho negativo indica piora nesse resumo.
| Variável | n | p clássico | ΔR² ajustado | Decisão atual e motivo |
|---|---:|---:|---:|---|
| Desmatamento (`pct_desmat`) | 1133 | 0,183 | 0,0003 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| População prisional (`pct_presos`) | 1133 | 0,308 | 0,0000 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| PIB por habitante (`pib_pc`) | 1133 | 0,112 | 0,0006 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| PIB por habitante (ln) (`ln_pib_pc`) | 1133 | <0,001 | 0,0050 | Comparação de ampliação: existe contribuição adicional no teste clássico; preservar como sensibilidade, conforme decisão atual. O principal é um recorte confirmado pelo grupo, não uma especificação ótima. Não justificar esta exclusão por ausência de significância. |
| Participação agropecuária (`pct_agro`) | 1133 | 0,405 | -0,0001 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Participação industrial (`pct_ind`) | 1133 | <0,001 | 0,0060 | Comparação de ampliação: existe contribuição adicional no teste clássico; preservar como sensibilidade, conforme decisão atual. O principal é um recorte confirmado pelo grupo, não uma especificação ótima. Não justificar esta exclusão por ausência de significância. |
| Participação da administração pública (`pct_adm`) | 1133 | 0,065 | 0,0010 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| População em favelas e comunidades urbanas (`pct_favela`) | 1133 | <0,001 | 0,0053 | Candidata válida; guardar como sensibilidade na versão final. Fonte e contagens conferidas contra a API atual do IBGE. Há contribuição no modelo regional; magnitudes e evidência dependem do controle geográfico e do recorte. |
| Frequência escolar 18–24 (`freq_18a24`) | 1133 | 0,445 | -0,0002 | Manter o recorte escolar 15–17 e distorção no ensino médio. A frequência de 18–24 não acrescenta evidência clara no teste condicional. Sua interpretação etária também difere da hipótese escolar central. |
| Abandono no ensino médio (`abandono_em`) | 1133 | 0,667 | -0,0003 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Guarda municipal (`guarda_municipal`) | 1132 | 0,012 | 0,0021 | Guardar como alternativa; não interpretar a presença como efeito da política. Uma observação faltante; comparação refeita nos mesmos casos. Presença de guarda não mede efetivo, atuação ou impacto causal. |
| Gini de 2010 (`gini_2010`) | 1133 | 0,011 | 0,0021 | Manter Gini 2022 como medida principal; registrar comparação histórica. Gini de 2010 pertence a outro período. Incluir duas medidas altera a pergunta; o teste não demonstra superioridade da medida antiga. |
| Crescimento populacional 2010–2022 (`cresc_pop`) | 1133 | 0,008 | 0,0024 | Comparação de ampliação: existe contribuição adicional no teste clássico; preservar como sensibilidade, conforme decisão atual. O principal é um recorte confirmado pelo grupo, não uma especificação ótima. Não justificar esta exclusão por ausência de significância. |
| Migração de outra UF (`pct_migr_outra_uf`) | 1133 | 0,277 | 0,0001 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Mulher responsável, sem cônjuge, com filhos (`pct_maes_solo`) | 1133 | 0,139 | 0,0005 | Manter fora após checagem atual documentada. Nos mesmos 1.133 municípios: p clássico 0,139; ganho mínimo de R² ajustado e estimativa imprecisa. Não mede abandono parental; a justificativa histórica não estava documentada. |
| Emprego formal por habitante (`emprego_formal`) | 1133 | 0,060 | 0,0010 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Ocupados sem contribuição previdenciária (`pct_informal`) | 1133 | 0,020 | 0,0018 | Comparação de ampliação: existe contribuição adicional no teste clássico; preservar como sensibilidade, conforme decisão atual. O principal é um recorte confirmado pelo grupo, não uma especificação ótima. Não justificar esta exclusão por ausência de significância. |
| Famílias assentadas (`assent_familias`) | 1133 | 0,283 | 0,0001 | Manter fora do principal: limitações de período e localização. O estoque observado é de 2026, embora restrito a projetos criados até 2023. Todo projeto é atribuído à sede. Algumas formas têm evidência, mas a medida exige revisão adicional. |
| Área de assentamentos (`pct_area_assent`) | 1133 | 0,151 | 0,0004 | Manter fora do principal: limitações de período, localização e corte. Estoque de 2026 e atribuição integral à sede; valores cortados em 100. O teste da forma log1p não elimina esses limites. |
| Área de soja (`pct_soja`) | 1133 | 0,070 | 0,0009 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Densidade de bovinos (`bovinos_km2`) | 1133 | 0,145 | 0,0004 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Focos de queimada (`focos_km2`) | 1133 | 0,889 | -0,0004 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Cobertura potencial da APS (`cobertura_aps`) | 1133 | 0,002 | 0,0036 | Guardar como alternativa, sem interpretar como qualidade efetiva do atendimento. Cobertura é potencial e foi limitada a 100. Existe evidência adicional, mas a hipótese e a escala precisam de investigação específica. |
| Despesa municipal em segurança (`desp_seg_pc`) | 1132 | 0,659 | -0,0003 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Despesa municipal em assistência (`desp_assist_pc`) | 1132 | 0,742 | -0,0004 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Transferências monetárias por habitante (`bf_pc`) | 1133 | 0,076 | 0,0009 | Manter fora do principal; registrar teste e alcance da medida. A variável mede valor transferido por habitante, não percentual de famílias beneficiárias. Média dos anos disponíveis 2021 e 2022. |
| Pessoas com renda até 1/4 SM ou sem renda (`pct_pobres`) | 1133 | 0,003 | 0,0030 | Comparação de ampliação: existe contribuição adicional no teste clássico; preservar como sensibilidade, conforme decisão atual. O principal é um recorte confirmado pelo grupo, não uma especificação ótima. Não justificar esta exclusão por ausência de significância. |
| Alfabetização 15+ (`alfabet`) | 1133 | 0,533 | -0,0002 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Densidade populacional (ln) (`log_dens`) | 1133 | 0,782 | -0,0004 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Homens 15–29 (`pct_h1529`) | 1133 | 0,141 | 0,0005 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Amazônia Legal (`amazonia_legal`) | 1133 | 0,006 | 0,0026 | Manter fora por decisão docente/grupo e sensibilidade documentada. Existe evidência no teste original, mas ela é sensível à exclusão de Mato Grosso. Não afirmar ausência de contribuição nem exclusividade daquele estado. |
| Faixa de fronteira (`faixa_fronteira`) | 1133 | 0,307 | 0,0000 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Região metropolitana/RIDE (`rm_ride`) | 1133 | 0,291 | 0,0000 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Concentração urbana (`conc_urb`) | 1133 | 0,315 | 0,0000 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Intenção indeterminada, denominador corrigido (`indet_sem_hom`) | 1133 | 0,996 | -0,0004 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Intenção indeterminada, medida acoplada (`pct_indet`) | 1133 | <0,001 | 0,0083 | Não incluir: acoplamento matemático com a resposta. O denominador inclui homicídios. Um p pequeno não corrige esse problema. A medida corrigida foi testada separadamente. |
| População (ln) (`log_pop`) | 1133 | 0,042 | 0,0012 | Comparação de ampliação: existe contribuição adicional no teste clássico; preservar como sensibilidade, conforme decisão atual. O principal é um recorte confirmado pelo grupo, não uma especificação ótima. Não justificar esta exclusão por ausência de significância. |
| Área territorial (ln) (`log_area`) | 1133 | 0,094 | 0,0007 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |
| Presença de estabelecimento prisional (`tem_presidio`) | 1133 | 0,115 | 0,0006 | Manter fora: contribuição adicional pouco clara nesta forma de entrada; não afirmar efeito nulo. Ganho de ajuste limitado ou negativo; intervalo e teste não sustentam uma contribuição adicional clara, condicionada ao modelo e aos pressupostos. |

## Estrutura familiar: resposta pronta para o grupo

A variável mede domicílios com mulher responsável, sem cônjuge e com filhos/enteados, divididos pelo total de domicílios particulares.
Não mede abandono parental, ausência do pai, negligência ou composição completa da rede de apoio.
A checagem de hoje acrescentou a variável ao modelo adotado, mantendo os mesmos 1.133 municípios.
O teste F parcial deu p = 0,1387. O R² ajustado mudou de 0,5585 para 0,5590.
Para +5 pontos percentuais, a diferença estimada é +9,6%, com IC clássico de 95% de −2,9% a +23,8%.
Manter fora é uma decisão atual apoiada em contribuição imprecisa e ganho pequeno. Isso não demonstra efeito zero nem recupera a justificativa histórica ausente.

## O que mudou na interpretação

Escola e Gini mantêm suas direções nos cenários destacados, mas suas magnitudes mudam.
A pobreza acrescentada, por exemplo, altera o efeito estimado do Gini na renda mediana. Não são parâmetros universais.
A evidência da migração depende de outras explicativas: acrescentar crescimento populacional produz p clássico próximo de 0,004.
Portanto, a frase correta continua sendo: não encontramos evidência clara para migração no modelo principal adotado.
Não afirmar ausência geral de associação nem que a inclusão de uma variável comprove seu mecanismo causal.

## Evidências e reprodução

- `validacao/auditar_candidatas.R`: 57 comparações e blocos auxiliares.
- `validacao/testar_estrutura_familiar.R`: teste e validação das contagens familiares.
- `validacao/saida/11_candidatas_testes.csv`: todas as formas, amostras, coeficientes, intervalos e métricas.
- `validacao/saida/11_candidatas_decisoes.csv`: motivo individual de cada decisão atual.
- `validacao/saida/11_candidatas_sensibilidade.csv`: mudanças nos principais resultados.
- `validacao/saida/11_candidatas_execucao.txt`: testes conjuntos e saídas reproduzidas.
- `validacao/saida/11_reintegracao_candidatas.txt`: reconstrução das fontes locais.

Na raiz do repositório:

```sh
Rscript validacao/testar_estrutura_familiar.R
Rscript validacao/auditar_candidatas.R
```
