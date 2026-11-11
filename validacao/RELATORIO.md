# Validação da qualidade dos dados

Script: `validacao/validar_dados.R` (roda do início ao fim; números em `saida/valores_validacao.txt`).
Usa 3 consultas extras ao TabNet (homicídios por ano, homicídios por local de ocorrência e óbitos por capítulo da CID), guardadas em `saida/tabnet_extra.json`. O script lê esse arquivo e não acessa a rede. Nenhum dado nem script do projeto foi alterado.

As seções 1 a 4 olham a base inteira (5.570 municípios) e dizem quanto de cada problema cai no **escopo do modelo**. As seções 5 e 6 usam o modelo atual (`entrega/2_modelo_preliminar.R`): resposta ln(taxa), 1.134 municípios com 30 mil habitantes ou mais (percentil 80 da população). A densidade foi testada e ficou fora do modelo (F = 1,74; p = 0,19).

## Resumo

A base está **limpa do ponto de vista técnico**: não há chave quebrada, valor faltando, valor impossível nem erro de conta. O Gini calculado bate com o oficial do IBGE nas 27 UFs. Os problemas que existem estão **na medição**: a causa da morte às vezes fica sem registro, e com poucos homicídios a taxa oscila muito. O escopo de 30 mil habitantes ou mais já tira a maior parte dos casos ruins (desocupação de 51%, taxa zero, 32 dos 35 municípios com presídio). **Não achamos nenhum erro de dado que justifique remover município.** Há dois resultados frágeis: o coeficiente de **% homens 15–29** e o de **migração recente**. O coeficiente de **% indeterminada** depende de 32 municípios.

## 1. Completude e chaves (ok)

- 5.570 linhas, 5.570 códigos IBGE e 5.570 códigos de 6 dígitos únicos, 0 NAs. As UFs somam 5.570 e o DF tem 1 município. A cópia em `entrega/dados/` é igual à base.
- Junção de 7 para 6 dígitos: todas as 5.566 linhas do SIM 2021–23 e as 5.446 de 2024 casam; nenhuma ficou sem par e não há duplicata. Os nomes diferem em 10 casos, só de grafia (ex.: Poxoréu/POXOREO).
- 4 municípios não aparecem no SIM e recebem 0: São Bento Abade-MG, Serranos-MG, Nova Castilho-SP e Rubiácea-SP. A base tem 4 municípios com 0 óbitos externos, o que é coerente.
- Os 5 municípios instalados em 2013 (Mojuí dos Campos, Pescaria Brava, Balneário Rincão, Pinto Bandeira e Paraíso das Águas) existem no Censo e no SIM.
- Boa Esperança do Norte-MT não está na base, e isso está certo: foi instalado em 2025, depois do Censo 2022.
- O dígito verificador confere em 5.561 de 5.570. As 9 exceções são códigos oficiais conhecidos do IBGE (ex.: Quixaba-PE), não erro.
- **Variáveis extras** (abandono e distorção idade-série no ensino médio, migração recente): 5.570 linhas, todas casam com a base. Faltam 7 valores de abandono e 7 de distorção na base inteira, mas **nenhum no escopo do modelo**.
- **Escopo do modelo:** 1.134 municípios têm 30 mil habitantes ou mais (Sudeste 386, Nordeste 358, Sul 189, Norte 122, Centro-Oeste 79). O modelo usa as 1.134 linhas.

## 2. Valores impossíveis ou suspeitos

| Verificação | Resultado | Avaliação |
|---|---|---|
| Percentuais fora de 0–100 (inclui as 3 variáveis extras) | 0 | ok |
| Gini fora de 0–1 ou faltando | 0; 0 (vai de 0,275 a 0,684 na base e de 0,325 a 0,652 no escopo) | ok |
| Gini calculado × oficial do IBGE | 27 UFs: correlação 0,995, erro absoluto médio 0,003, máximo 0,008 (Tocantins). 5 regiões: erro máximo 0,003. Brasil: 0,542 × 0,542 | ok. O acerto do Brasil não é teste: o script de preparação escolhe a renda da última classe para reproduzir esse valor. O teste são as UFs e as regiões |
| Gini máximo | Alto Alegre-RR 0,684; Petrolândia-SC 0,671; Nova Lima-MG 0,652 | Só Nova Lima está no escopo (Alto Alegre tem 21 mil hab.) e é o ponto de maior alavancagem (seção 5) |
| Gini mínimo | Presidente Lucena-RS 0,275 (base); Forquilhinha-SC 0,325 (escopo) | sem sinal de erro: o valor bate com o recálculo (seção 3) |
| Densidade × pop/área | diferença máxima de 2,5% (arredondamento) | ok |
| Desocupação > 30% | 8 municípios (Joca Marques-PI 51,0%, Alegrete do Piauí-PI 50,5%…) | **nenhum está no escopo** (todos têm menos de 30 mil habitantes) |
| Desocupação no escopo | máximo de 21,0% (Santa Helena-MA); só 1 município acima de 20% | dado da amostra do Censo, publicado pelo IBGE. Alto, mas não é erro de digitação |
| Desocupação = 0 | 29 municípios pequenos | nenhum no escopo |
| % indeterminada = 100% | 2 (Itambé do Mato Dentro-MG e Araguainha-MT) | cada um tem 1 óbito externo só; os dois têm menos de 30 mil habitantes |
| Frequência escolar 15–17 = 100% | 38 municípios | nenhum no escopo |
| Frequência escolar 15–17 mínima | **Veranópolis-RS: 43,5%** na base. O menor do escopo é Rondon do Pará-PA (64,0%) | Veranópolis (24 mil hab.) está fora do escopo e **é suspeito**: a base repete o arquivo do IBGE nos 5.570 municípios, então não é erro nosso. Rondon do Pará não tem sinal de erro |
| População mínima | Serra da Saudade-MG, 833 hab. (base); Floresta-PE, 30.137 (escopo) | real |

Os extremos de cada variável, na base e no escopo, estão em `saida/02_extremos.csv`.

## 3. Coerência interna

- A taxa recalculada a partir das contagens é idêntica à da base (diferença < 1e-12). A soma dos grupos da CID bate com o total do SIM em todas as linhas. A soma por ano (consulta extra ao TabNet) bate com `hom` nos 5.570 municípios.
- **O Gini recalculado a partir das classes de renda (tabela 10300) é idêntico ao da base** (diferença máxima de 5,6e-16).
- A frequência escolar da base é igual à do arquivo bruto do IBGE (tabela 10056) em todos os municípios.
- A população é igual nas tabelas 4709, 4714 e 9923.
- **Tabela 10300 (classes de renda):** a soma das classes difere do total em no máximo ±3 pessoas (no máximo 0,19% do total). **Tabela 9517 (trabalho):** ocupados + desocupados difere da força de trabalho em ±1 pessoa. O padrão é de arredondamento ou de controle de sigilo do IBGE (a causa não foi verificada). Efeito de trocar o denominador: no máximo 0,028 p.p. em `pct_pobres` e 0,030 p.p. em `desocup`. **Desprezível.**

## 4. Qualidade da resposta

- **Contagens pequenas:** a base tem 655 municípios com taxa zero, mas **nenhum está no escopo**. No escopo o mínimo é 1 homicídio em 3 anos, e 19 municípios têm menos de 5. Com ln(taxa), 1 homicídio a mais ou a menos muda muito a resposta desses municípios (ver seção 5).
- **Intenção indeterminada:** 147 municípios têm % indeterminada ≥ 30% (32 no escopo: 12 em MG, 18 em SP e 2 no CE) e 30 têm ≥ 50% (3 no escopo). O problema se concentra em SP (19,4% dos óbitos externos; há 1,5 óbito indeterminado para cada homicídio), MG (14,4%) e RJ (13,2%). Casos grandes, todos no escopo: São Joaquim de Bicas-MG (70%), Embu-Guaçu-SP (54%) e Itapecerica da Serra-SP (53%). Ou seja, **a taxa de SP e MG está subestimada** (homicídio escondido como "indeterminado").
- **Causas mal definidas (cap. XVIII, todos os óbitos):** mediana de 4,7% na base e de 4,0% no escopo. 118 municípios passam de 20%, e 23 deles estão no escopo (ex.: Boca do Acre-AM 30% e Ipirá-BA 28%). No escopo, a correlação com a taxa é de só 0,13. Tirar esses 23 municípios praticamente não muda o modelo (maior mudança entre os coeficientes significativos: % urbana −4%).
- **Instabilidade 2021–23 × 2024:** a correlação entre a taxa dos dois períodos é 0,79 no escopo. Na base inteira é 0,83 nos municípios ≥ 50 mil hab. e só 0,26 nos < 5 mil. Em 77 municípios o número de 2024 foge muito do esperado (|z| ≥ 4), e 33 deles estão no escopo. Exemplos no escopo: Itapipoca-CE (97 homicídios em 3 anos, 98 só em 2024), Manaus (3.336 em 3 anos, 743 em 2024) e São Gonçalo-RJ (849 em 3 anos, 111 em 2024).
- **Presídios:** 35 municípios têm mais de 10% da população fora de domicílio particular, ou seja, morando em presídio, quartel ou asilo. 28 ficam em SP e 3 em PE. Entre eles estão os 10 municípios com maior % de homens 15–29 da base. **Só 3 dos 35 estão no escopo** (de 13,6% em Itaitinga-CE a 10,9% em Charqueadas-RS; o outro é Tremembé-SP), e 1 deles está entre os 10 maiores % de homens 15–29 do escopo. Esses 3 somam 61 homicídios por residência e 80 por ocorrência. No escopo inteiro, a correlação entre as duas contagens é 0,996. A regra que o SIM usa para a residência de um preso que morre dentro do presídio **não foi verificada**.

## 5. Outliers e pontos influentes (modelo atual)

Modelo: ln(taxa) em função de renda (com termo ao quadrado), Gini, desocupação, % urbana, % homens 15–29, fronteira, % indeterminada, frequência escolar, abandono, distorção idade-série, migração recente e região. n = 1.134; R² = 0,544. Os coeficientes são iguais aos de `entrega/resultados/modelagem/valores_modelo.txt`.

- 2 municípios têm |e*| ≥ 4: Campos do Jordão-SP (e* = −4,4; taxa de 0,7) e Pomerode-SC (e* = −4,2; taxa de 1,0). **Os dois são negativos: a taxa é muito menor que a esperada.** Cada um tem 1 homicídio em 3 anos (em 2022 e em 2021), e 1 ou 3 em 2024. A contagem por ocorrência é 0 nos dois. O número é baixo de forma consistente, então **não parece erro de digitação**.
- **Campos do Jordão é suspeito por outro motivo:** tem 1 homicídio e 36 óbitos de intenção indeterminada (37,5% dos óbitos externos). A taxa dele provavelmente está subestimada. Pomerode tem só 2 óbitos indeterminados (3,7%) e 3,5% de causas mal definidas.
- 8 municípios têm |e*| ≥ 3, e **6 são negativos**. Os 6 têm de 1 a 9 homicídios em 3 anos. Os 2 positivos são Vitória-ES (272 homicídios; e* = 3,1) e São Francisco de Itabapoana-RJ (104; e* = 3,2). Isso é efeito da contagem pequena com ln(taxa), não problema de dado.
- *(Fora da apostila, só descritivo)* 74 municípios têm alavancagem acima de 2p/n e 60 têm distância de Cook acima de 4/n, mas o Cook máximo é só 0,023 (Campos do Jordão-SP), ou seja, **nenhum ponto domina o ajuste**. As maiores alavancagens são Nova Lima-MG (Gini de 0,652 e 48,7% de indeterminada), São Joaquim de Bicas-MG (69,8% de indeterminada), São Paulo de Olivença-AM, São Caetano do Sul-SP (45,8% de indeterminada) e Itaíba-PE (desocupação de 19,1%).
- O gráfico de resíduos (`v1`) não tem mais a faixa diagonal dos zeros, porque o escopo não tem taxa zero.

## 6. Sensibilidade: o modelo reajustado sem cada grupo de casos

| Cenário | n | R² | O que muda |
|---|---|---|---|
| base | 1.134 | 0,544 | — |
| sem os 2 com \|e*\| ≥ 4 | 1.132 | 0,547 | nada relevante (maior mudança: `pct_indet` −13%) |
| sem os 8 com \|e*\| ≥ 3 | 1.126 | 0,559 | `pct_h1529` passa a ser significativo (p = 0,032) |
| sem os 3 com presídio (> 10% fora de domicílio) | 1.131 | 0,543 | nada relevante (maior mudança: `pct_migr_10anos` −2%) |
| sem o 1 com desocupação > 20% | 1.133 | 0,544 | nada relevante (maior mudança: `pct_migr_10anos` +1%) |
| sem os 32 com % indeterminada ≥ 30% | 1.102 | 0,530 | `pct_indet` cai 71% e perde a significância (p = 0,42); `pct_migr_10anos` cai 26% e perde a significância (p = 0,12) |
| sem os 23 com > 20% mal definida | 1.111 | 0,543 | nada relevante (maior mudança: % urbana −4%) |
| *(fora da apostila)* sem os 60 com Cook > 4/n | 1.074 | 0,615 | `pct_h1529` cresce 69% (de −0,040 para −0,067) e passa a ser significativo (p = 0,0005); `pct_migr_10anos` cai 29% e perde a significância (p = 0,10) |

- **Nenhum coeficiente troca de sinal em nenhum cenário.**
- Renda (com o termo ao quadrado), Gini, % urbana, frequência escolar, distorção idade-série e região **continuam significativos em todos os cenários**. O Gini fica entre 2,74 e 3,29.
- Desocupação, fronteira e abandono não são significativos no modelo base (p = 0,24, 0,15 e 0,65) e continuam assim em todos os cenários.
- Mudanças em relação à validação anterior: saíram os cenários "sem população < 5 mil" e "sem desocupação > 30% ou = 0", porque o escopo não tem esses casos. Entraram "sem desocupação > 20%" (o extremo dentro do escopo) e "sem |e*| ≥ 3" (com só 2 municípios em |e*| ≥ 4, o cenário antigo quase não testa nada).

## 7. Recomendações

**DEVE ser feito**
1. **Não remover os 2 outliers.** Não há evidência direta de erro (contagem baixa nos três anos e em 2024; ocorrência ≈ residência) e a apostila só manda remover quando há essa evidência. Se tirar os 2, o R² sobe só 0,003 e nenhum coeficiente muda de sinal ou de significância.
2. **Tratar `pct_h1529` e `pct_migr_10anos` como frágeis.** `pct_migr_10anos` (p = 0,033) perde a significância sem os 32 municípios de % indeterminada alta e sem os 60 de Cook alto. `pct_h1529` (p = 0,059) não é significativo no modelo base e passa a ser em 2 cenários. No mínimo, citar isso no trabalho e não tirar conclusão forte dos dois.
3. **Explicar no trabalho que `pct_indet` não é fator de risco.** Ele depende dos 32 municípios com % indeterminada alta, concentrados em MG e SP, e mede subnotificação da resposta. O valor negativo do coeficiente é coerente com isso.

**PODE ser feito**
4. Citar que os resíduos grandes são quase todos negativos (6 de 8) e vêm de municípios com 1 a 9 homicídios em 3 anos. É uma limitação de usar ln(taxa) com contagem pequena.
5. Usar a correlação com 2024 (0,79 no escopo contra 0,26 nos municípios < 5 mil) como evidência a favor do corte em 30 mil habitantes.
6. Dizer que o Gini municipal é uma aproximação feita pelas classes de renda. Ela bate com o oficial nas 27 UFs (erro médio de 0,003), mas o IBGE não publica o valor por município para conferir.
7. Veranópolis-RS (frequência escolar de 43,5%) é valor estranho da fonte, mas está fora do escopo e não afeta o modelo.
8. Ignorar as inconsistências das tabelas 10300 e 9517. O efeito é ≤ 0,03 p.p.; não precisa de correção.

**NÃO deve ser feito**
9. Remover municípios por resíduo, alavancagem ou Cook sem evidência de erro.
10. "Corrigir" a desocupação de 21,0% de Santa Helena-MA ou a frequência escolar de Veranópolis-RS: são os valores publicados pelo IBGE.
11. Trocar o denominador de `pct_pobres` ou de `desocup` por causa das diferenças de ±1 a ±3 pessoas.

## Não verificado
- A regra do SIM para a residência de quem morre dentro do presídio.
- A causa das diferenças de ±1 a ±3 pessoas nas tabelas 10300 e 9517 (parece arredondamento ou sigilo do IBGE).
- O Gini de cada município: só existe valor oficial para o Brasil, as regiões e as UFs. O erro do cálculo dentro de um município não foi medido.
- Por que a frequência escolar de Veranópolis-RS é 43,5%. Só confirmamos que a base repete o arquivo do IBGE.
- Se os 36 óbitos de intenção indeterminada de Campos do Jordão-SP escondem homicídios.
- As 3 variáveis extras (abandono, distorção e migração) contra a fonte original. Só conferimos a junção, os valores faltantes e a faixa de 0 a 100.
- O efeito de tirar só Nova Lima-MG ou Campos do Jordão-SP do modelo (não há cenário para isso).
