# Validação da qualidade dos dados

Script: `validacao/validar_dados.R` (roda do início ao fim; números em `saida/valores_validacao.txt`).
Usa 3 consultas extras ao TabNet (homicídios por ano, homicídios por local de ocorrência e óbitos por capítulo da CID), guardadas em `saida/tabnet_extra.json`. O script lê esse arquivo e não acessa a rede. Nenhum dado nem script do projeto foi alterado.

As seções 1 a 4 olham a base inteira (5.570 municípios) e dizem quanto de cada problema cai no **escopo do modelo**. As seções 5 e 6 usam o modelo atual (`entrega/2_modelo_preliminar.R`): resposta ln(taxa), 1.622 municípios com 20 mil habitantes ou mais e densidade entre os percentis 2,5 e 97,5 da sua região.

## Resumo

A base está **limpa do ponto de vista técnico**: não há chave quebrada, valor faltando, valor impossível nem erro de conta. O Gini calculado bate com o oficial do IBGE nas 27 UFs. Os problemas que existem estão **na medição**: a causa da morte às vezes fica sem registro, e com poucos homicídios a taxa oscila muito. O escopo de 20 mil habitantes ou mais já tira a maior parte dos casos ruins (desocupação de 51%, taxa zero, 25 dos 35 municípios com presídio). **Não achamos nenhum erro de dado que justifique remover município.** Há dois resultados frágeis: o coeficiente de **densidade** e o de **% homens 15–29**. O coeficiente de **% indeterminada** depende de 32 municípios.

## 1. Completude e chaves (ok)

- 5.570 linhas, 5.570 códigos IBGE e 5.570 códigos de 6 dígitos únicos, 0 NAs. As UFs somam 5.570 e o DF tem 1 município. A cópia em `entrega/dados/` é igual à base.
- Junção de 7 para 6 dígitos: todas as 5.566 linhas do SIM 2021–23 e as 5.446 de 2024 casam; nenhuma ficou sem par e não há duplicata. Os nomes diferem em 10 casos, só de grafia (ex.: Poxoréu/POXOREO).
- 4 municípios não aparecem no SIM e recebem 0: São Bento Abade-MG, Serranos-MG, Nova Castilho-SP e Rubiácea-SP. A base tem 4 municípios com 0 óbitos externos, o que é coerente.
- Os 5 municípios instalados em 2013 (Mojuí dos Campos, Pescaria Brava, Balneário Rincão, Pinto Bandeira e Paraíso das Águas) existem no Censo e no SIM.
- Boa Esperança do Norte-MT não está na base, e isso está certo: foi instalado em 2025, depois do Censo 2022.
- O dígito verificador confere em 5.561 de 5.570. As 9 exceções são códigos oficiais conhecidos do IBGE (ex.: Quixaba-PE), não erro.
- **Variáveis extras** (abandono e distorção idade-série no ensino médio, migração recente): 5.570 linhas, todas casam com a base. Faltam 7 valores de abandono e 7 de distorção na base inteira, mas **nenhum no escopo do modelo**.
- **Escopo do modelo:** 1.710 municípios têm 20 mil habitantes ou mais. Depois do corte da densidade ficam 1.622 (Nordeste 562, Sudeste 513, Sul 257, Norte 172, Centro-Oeste 118). O modelo usa as 1.622 linhas.

## 2. Valores impossíveis ou suspeitos

| Verificação | Resultado | Avaliação |
|---|---|---|
| Percentuais fora de 0–100 (inclui as 3 variáveis extras) | 0 | ok |
| Gini fora de 0–1 ou faltando | 0; 0 (vai de 0,275 a 0,684 na base e de 0,300 a 0,684 no escopo) | ok |
| Gini calculado × oficial do IBGE | 27 UFs: correlação 0,995, erro absoluto médio 0,003, máximo 0,008 (Tocantins). 5 regiões: erro máximo 0,003. Brasil: 0,542 × 0,542 | ok. O acerto do Brasil não é teste: o script de preparação escolhe a renda da última classe para reproduzir esse valor. O teste são as UFs e as regiões |
| Gini máximo | Alto Alegre-RR 0,684; Petrolândia-SC 0,671; Nova Lima-MG 0,652 | Alto Alegre e Nova Lima estão no escopo e são os dois pontos de maior alavancagem (seção 5) |
| Gini mínimo | Presidente Lucena-RS 0,275 (base); Nova Hartz-RS 0,300 (escopo) | sem sinal de erro: o valor bate com o recálculo (seção 3) |
| Densidade × pop/área | diferença máxima de 2,5% (arredondamento) | ok |
| Desocupação > 30% | 8 municípios (Joca Marques-PI 51,0%, Alegrete do Piauí-PI 50,5%…) | **nenhum está no escopo** (todos têm menos de 20 mil habitantes) |
| Desocupação no escopo | máximo de 28,8% (Queimadas-BA); 4 municípios acima de 20% (Queimadas, Inajá-PE, Santa Helena-MA e Macarani-BA) | dado da amostra do Censo, publicado pelo IBGE. Alto, mas não é erro de digitação |
| Desocupação = 0 | 29 municípios pequenos | nenhum no escopo |
| % indeterminada = 100% | 2 (Itambé do Mato Dentro-MG e Araguainha-MT) | cada um tem 1 óbito externo só; os dois têm menos de 20 mil habitantes |
| Frequência escolar 15–17 = 100% | 38 municípios | nenhum no escopo |
| Frequência escolar 15–17 mínima | **Veranópolis-RS: 43,5%**, com 98,4% de alfabetização e renda de R$ 2.257. O segundo menor do escopo é Alto Alegre-RR (51,2%) | **suspeito.** A base repete o arquivo do IBGE nos 5.570 municípios, então não é erro nosso. É o 5º ponto de maior alavancagem do modelo |
| População mínima | Serra da Saudade-MG, 833 hab. (base); Turmalina-MG, 20.000 (escopo) | real |

Os extremos de cada variável, na base e no escopo, estão em `saida/02_extremos.csv`.

## 3. Coerência interna

- A taxa recalculada a partir das contagens é idêntica à da base (diferença < 1e-12). A soma dos grupos da CID bate com o total do SIM em todas as linhas. A soma por ano (consulta extra ao TabNet) bate com `hom` nos 5.570 municípios.
- **O Gini recalculado a partir das classes de renda (tabela 10300) é idêntico ao da base** (diferença máxima de 5,6e-16).
- A frequência escolar da base é igual à do arquivo bruto do IBGE (tabela 10056) em todos os municípios.
- A população é igual nas tabelas 4709, 4714 e 9923.
- **Tabela 10300 (classes de renda):** a soma das classes difere do total em no máximo ±3 pessoas (no máximo 0,19% do total). **Tabela 9517 (trabalho):** ocupados + desocupados difere da força de trabalho em ±1 pessoa. O padrão é de arredondamento ou de controle de sigilo do IBGE (a causa não foi verificada). Efeito de trocar o denominador: no máximo 0,028 p.p. em `pct_pobres` e 0,030 p.p. em `desocup`. **Desprezível.**

## 4. Qualidade da resposta

- **Contagens pequenas:** a base tem 655 municípios com taxa zero, mas **nenhum está no escopo**. No escopo o mínimo é 1 homicídio em 3 anos, e 78 municípios têm menos de 5. Com ln(taxa), 1 homicídio a mais ou a menos muda muito a resposta desses municípios (ver seção 5).
- **Intenção indeterminada:** 147 municípios têm % indeterminada ≥ 30% (32 no escopo: 14 em MG, 14 em SP e 4 no CE) e 30 têm ≥ 50% (3 no escopo). O problema se concentra em SP (19,4% dos óbitos externos; há 1,5 óbito indeterminado para cada homicídio), MG (14,4%) e RJ (13,2%). Casos grandes, todos no escopo: São Joaquim de Bicas-MG (70%), Embu-Guaçu-SP (54%) e Itapecerica da Serra-SP (53%). Ou seja, **a taxa de SP e MG está subestimada** (homicídio escondido como "indeterminado").
- **Causas mal definidas (cap. XVIII, todos os óbitos):** mediana de 4,7% na base e de 4,4% no escopo. 118 municípios passam de 20%, e 36 deles estão no escopo (ex.: Paripiranga-BA 37% e Boca do Acre-AM 30%). No escopo, a correlação com a taxa é de só 0,10. Tirar esses 36 municípios praticamente não muda o modelo (maior mudança entre os coeficientes significativos: Gini +3%).
- **Instabilidade 2021–23 × 2024:** a correlação entre a taxa dos dois períodos é 0,76 no escopo. Na base inteira é 0,83 nos municípios ≥ 50 mil hab. e só 0,26 nos < 5 mil. Em 77 municípios o número de 2024 foge muito do esperado (|z| ≥ 4), e 31 deles estão no escopo. Exemplos no escopo: Itapipoca-CE (97 homicídios em 3 anos, 98 só em 2024), Manaus (3.336 em 3 anos, 743 em 2024) e São Gonçalo-RJ (849 em 3 anos, 111 em 2024).
- **Presídios:** 35 municípios têm mais de 10% da população fora de domicílio particular, ou seja, morando em presídio, quartel ou asilo. 28 ficam em SP e 3 em PE. Entre eles estão os 10 municípios com maior % de homens 15–29 da base. **Só 10 dos 35 estão no escopo** (de 15,6% em Mirandópolis-SP a 10,9% em Charqueadas-RS), e 3 deles estão entre os 10 maiores % de homens 15–29 do escopo (ex.: Itapissuma-PE e Itaitinga-CE). Esses 10 somam 177 homicídios por residência e 211 por ocorrência. No escopo inteiro, a correlação entre as duas contagens é 0,996. A regra que o SIM usa para a residência de um preso que morre dentro do presídio **não foi verificada**.

## 5. Outliers e pontos influentes (modelo atual)

Modelo: ln(taxa) em função de renda (com termo ao quadrado), Gini, desocupação, % urbana, densidade, % homens 15–29, fronteira, % indeterminada, frequência escolar, abandono, distorção idade-série, migração recente e região. n = 1.622; R² = 0,460. Os coeficientes são iguais aos de `entrega/resultados/modelagem/valores_modelo.txt`.

- 2 municípios têm |e*| ≥ 4: Nhamundá-AM (e* = −4,1; taxa de 1,7) e Campos do Jordão-SP (e* = −4,0; taxa de 0,7). **Os dois são negativos: a taxa é muito menor que a esperada.** Cada um tem 1 homicídio em 3 anos (em 2022), e 0 ou 1 em 2024. A contagem por ocorrência é 1 e 0. O número é baixo de forma consistente, então **não parece erro de digitação**.
- **Campos do Jordão é suspeito por outro motivo:** tem 1 homicídio e 36 óbitos de intenção indeterminada (37,5% dos óbitos externos). A taxa dele provavelmente está subestimada. Nhamundá não tem óbito indeterminado, mas tem 13,6% de causas mal definidas.
- 13 municípios têm |e*| ≥ 3, e **12 são negativos**. Os 12 têm de 1 a 4 homicídios em 3 anos. O único positivo é Sooretama-ES (73 homicídios; e* = 3,4). Isso é efeito da contagem pequena com ln(taxa), não problema de dado.
- *(Fora da apostila, só descritivo)* 97 municípios têm alavancagem acima de 2p/n e 88 têm distância de Cook acima de 4/n, mas o Cook máximo é só 0,027 (Chaves-PA), ou seja, **nenhum ponto domina o ajuste**. As maiores alavancagens são Nova Lima-MG (Gini de 0,652 e 48,7% de indeterminada), Alto Alegre-RR (Gini de 0,684), São Joaquim de Bicas-MG (69,8% de indeterminada), Queimadas-BA (desocupação de 28,8%) e Veranópolis-RS (frequência escolar de 43,5%).
- O gráfico de resíduos (`v1`) não tem mais a faixa diagonal dos zeros, porque o escopo não tem taxa zero.

## 6. Sensibilidade: o modelo reajustado sem cada grupo de casos

| Cenário | n | R² | O que muda |
|---|---|---|---|
| base | 1.622 | 0,460 | — |
| sem os 2 com \|e*\| ≥ 4 | 1.620 | 0,463 | nada relevante (maior mudança: `pct_indet` −11%) |
| sem os 13 com \|e*\| ≥ 3 | 1.609 | 0,481 | `dens_z` cai 28% e perde a significância (p = 0,087); `pct_h1529` passa a ser significativo (p = 0,026) |
| sem os 10 com presídio (> 10% fora de domicílio) | 1.612 | 0,460 | nada relevante (maior mudança: `dens_z` −5%) |
| sem os 4 com desocupação > 20% | 1.618 | 0,460 | nada relevante (maior mudança: `dens_z` +5%) |
| sem os 32 com % indeterminada ≥ 30% | 1.590 | 0,454 | `pct_indet` cai 46% e perde a significância (p = 0,12) |
| sem os 36 com > 20% mal definida | 1.586 | 0,462 | nada relevante (maior mudança: Gini +3%) |
| *(fora da apostila)* sem os 88 com Cook > 4/n | 1.534 | 0,549 | `pct_h1529` cresce 64% (de −0,033 para −0,054) e passa a ser significativo (p = 0,0009) |

- **Nenhum coeficiente troca de sinal em nenhum cenário.**
- Renda (com o termo ao quadrado), Gini, % urbana, frequência escolar, distorção idade-série, migração recente e região **continuam significativos em todos os cenários**. O Gini fica entre 2,71 e 3,10.
- Desocupação, fronteira e abandono não são significativos no modelo base (p = 0,49, 0,57 e 0,54) e continuam assim em todos os cenários.
- Mudanças em relação à validação anterior: saíram os cenários "sem população < 5 mil" e "sem desocupação > 30% ou = 0", porque o escopo não tem esses casos. Entraram "sem desocupação > 20%" (o extremo dentro do escopo) e "sem |e*| ≥ 3" (com só 2 municípios em |e*| ≥ 4, o cenário antigo quase não testa nada).

## 7. Recomendações

**DEVE ser feito**
1. **Não remover os 2 outliers.** Não há evidência direta de erro (contagem baixa nos três anos e em 2024; ocorrência ≈ residência) e a apostila só manda remover quando há essa evidência. Se tirar os 2, o R² sobe só 0,003 e nenhum coeficiente muda de sinal ou de significância.
2. **Tratar `dens_z` e `pct_h1529` como frágeis.** `dens_z` (p = 0,023) perde a significância sem os 13 municípios de resíduo grande. `pct_h1529` (p = 0,068) não é significativo no modelo base e passa a ser em 2 cenários. No mínimo, citar isso no trabalho e não tirar conclusão forte dos dois.
3. **Explicar no trabalho que `pct_indet` não é fator de risco.** Ele depende dos 32 municípios com % indeterminada alta, concentrados em MG e SP, e mede subnotificação da resposta. O valor negativo do coeficiente é coerente com isso.

**PODE ser feito**
4. Citar que os resíduos grandes são quase todos negativos (12 de 13) e vêm de municípios com 1 a 4 homicídios em 3 anos. É uma limitação de usar ln(taxa) com contagem pequena.
5. Usar a correlação com 2024 (0,76 no escopo contra 0,26 nos municípios < 5 mil) como evidência a favor do corte em 20 mil habitantes.
6. Dizer que o Gini municipal é uma aproximação feita pelas classes de renda. Ela bate com o oficial nas 27 UFs (erro médio de 0,003), mas o IBGE não publica o valor por município para conferir.
7. Citar a frequência escolar de Veranópolis-RS (43,5%) como valor estranho da fonte. É um ponto de alavancagem alta.
8. Ignorar as inconsistências das tabelas 10300 e 9517. O efeito é ≤ 0,03 p.p.; não precisa de correção.

**NÃO deve ser feito**
9. Remover municípios por resíduo, alavancagem ou Cook sem evidência de erro.
10. "Corrigir" a desocupação de 28,8% de Queimadas-BA ou a frequência escolar de Veranópolis-RS: são os valores publicados pelo IBGE.
11. Trocar o denominador de `pct_pobres` ou de `desocup` por causa das diferenças de ±1 a ±3 pessoas.

## Não verificado
- A regra do SIM para a residência de quem morre dentro do presídio.
- A causa das diferenças de ±1 a ±3 pessoas nas tabelas 10300 e 9517 (parece arredondamento ou sigilo do IBGE).
- O Gini de cada município: só existe valor oficial para o Brasil, as regiões e as UFs. O erro do cálculo dentro de um município não foi medido.
- Por que a frequência escolar de Veranópolis-RS é 43,5%. Só confirmamos que a base repete o arquivo do IBGE.
- Se os 36 óbitos de intenção indeterminada de Campos do Jordão-SP escondem homicídios.
- As 3 variáveis extras (abandono, distorção e migração) contra a fonte original. Só conferimos a junção, os valores faltantes e a faixa de 0 a 100.
- O efeito de tirar só Veranópolis-RS, Nova Lima-MG ou Alto Alegre-RR do modelo (não há cenário para isso).
