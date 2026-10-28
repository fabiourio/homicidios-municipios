# Validação da qualidade dos dados

Script: `validacao/validar_dados.R` (roda do início ao fim; números em `saida/valores_validacao.txt`).
Fez 3 consultas extras ao TabNet (homicídios por ano, homicídios por local de ocorrência e óbitos por capítulo da CID), que ficaram guardadas em `saida/tabnet_extra.json`. Nenhum dado nem script do projeto foi alterado.

## Resumo

A base está **limpa do ponto de vista técnico**: não há chave quebrada, valor faltando, valor impossível nem erro de conta. Os problemas que existem estão **na medição**: em município pequeno o Censo estima a desocupação a partir de uma amostra, a causa da morte às vezes fica sem registro e os presídios distorcem a população. **Não achamos nenhum erro de dado que justifique remover município.** Há dois resultados frágeis: o coeficiente de **% homens 15–29** e o de **desocupação**.

## 1. Completude e chaves (ok)

- 5.570 linhas, 5.570 códigos IBGE e 5.570 códigos de 6 dígitos únicos, 0 NAs. As UFs somam 5.570 e o DF tem 1 município.
- Junção de 7 para 6 dígitos: todas as 5.566 linhas do SIM 2021–23 e as 5.446 de 2024 casam; nenhuma ficou sem par e não há duplicata. Os nomes diferem em 10 casos, só de grafia (ex.: Poxoréu/POXOREO).
- 4 municípios não aparecem no SIM e recebem 0: São Bento Abade-MG, Serranos-MG, Nova Castilho-SP e Rubiácea-SP. Os quatro também têm 0 óbitos externos, o que é coerente.
- Os 5 municípios instalados em 2013 (Mojuí dos Campos, Pescaria Brava, Balneário Rincão, Pinto Bandeira e Paraíso das Águas) existem no Censo e no SIM.
- Boa Esperança do Norte-MT não está na base, e isso está certo: foi instalado em 2025, depois do Censo 2022. Óbitos ocorridos antes disso no território dele contam para o município de origem.
- O dígito verificador confere em 5.561 de 5.570. As 9 exceções são códigos oficiais conhecidos do IBGE (ex.: Quixaba-PE), não erro.

## 2. Valores impossíveis ou suspeitos

| Verificação | Resultado | Avaliação |
|---|---|---|
| Percentuais fora de 0–100 | 0 | ok |
| Renda mediana > média; desig < 1 | 0; 0 (desig vai de 1,05 a 2,92) | ok |
| Densidade × pop/área | diferença máxima de 2,5% (arredondamento) | ok |
| Mediana em fração ou múltiplo do salário mínimo | 638 municípios (395 = R$ 1.212) | real, mas deixa `desig` ruidosa |
| Desocupação > 30% | 8 municípios (Joca Marques-PI 51,0%, Alegrete do Piauí-PI 50,5%, Coité do Nóia-AL 37,1%…) | dado publicado pelo IBGE, mas vem da amostra do Censo: em município de 3–20 mil habitantes o erro é grande. Joca Marques tem só 27% de participação na força de trabalho (mediana Brasil: 52,5%). **Suspeito, não é erro de digitação.** |
| Desocupação = 0 | 29 municípios pequenos (SC, RS, PB…) | mesmo motivo (amostra) |
| % indeterminada = 100% | 2 (Itambé do Mato Dentro-MG e Araguainha-MT) | cada um tem **1 óbito externo só**: é ruído de contagem pequena |
| População mínima | Serra da Saudade-MG, 833 hab. | real |
| desig máxima | Alto Alegre-RR, 2,92 (mediana de R$ 160) | real: tem terra Yanomami, com renda muito desigual |
| Frequência escolar 15–17 = 100% | 38 municípios | teto da taxa bruta; ainda não está no modelo |

Os extremos de cada variável estão em `saida/02_extremos.csv`.

## 3. Coerência interna

- A taxa recalculada a partir das contagens é idêntica à da base (diferença < 1e-12). A soma dos grupos da CID bate com o total do SIM em todas as linhas. A soma por ano (consulta extra ao TabNet) bate com `hom` nos 5.570 municípios.
- A população é igual nas tabelas 4709, 4714, 9923 e 9605.
- **Tabela 10300 (classes de renda):** a soma das classes difere do total em no máximo ±3 pessoas (no máximo 0,19% do total). **Tabela 9517 (trabalho):** ocupados + desocupados difere da força de trabalho em ±1 pessoa. O padrão é de arredondamento ou de controle de sigilo do IBGE (a causa não foi verificada). Efeito de trocar o denominador: no máximo 0,028 p.p. em `pct_pobres` e 0,030 p.p. em `desocup`. **Desprezível.**
- **Tabela 9605 (cor ou raça):** em 1.277 municípios a soma das cores fica abaixo do total. A maior falta é de 1.503 pessoas (4% da população) em Cumaru do Norte-PA, seguido de Pacaraima-RR (3,7%); provavelmente é "sem declaração" (não verificado). Tirar essas pessoas do denominador muda `pct_negra` em no máximo 2,6 p.p. **Baixo impacto.**

## 4. Qualidade da resposta

- **Intenção indeterminada:** 147 municípios têm % indeterminada ≥ 30% e 30 têm ≥ 50%. O problema se concentra em SP (19,4% dos óbitos externos; há 1,5 óbito indeterminado para cada homicídio), MG (14,4%) e RJ (13,2%). Casos grandes: São Joaquim de Bicas-MG (70%), Embu-Guaçu-SP (54%) e Itapecerica da Serra-SP (53%). Ou seja, **a taxa de SP e MG está subestimada** (homicídio escondido como "indeterminado").
- **Causas mal definidas (cap. XVIII, todos os óbitos):** mediana de 4,7%, e 118 municípios passam de 20% (ex.: Novo Santo Antônio-MT 58% e Luciara-MT 53%, ambos muito pequenos). A correlação com a taxa é de só 0,04. Tirar esses 118 municípios praticamente não muda o modelo (maior mudança: renda +8%).
- **Instabilidade 2021–23 × 2024:** a correlação é 0,83 em municípios ≥ 50 mil hab., mas só 0,26 nos < 5 mil. Em 77 municípios o número de 2024 foge muito do esperado (|z| ≥ 4). Exemplos: Barcelos-AM (6 homicídios em 3 anos, 32 só em 2024), Manaus (1.112/ano para 743) e São Gonçalo-RJ (283/ano para 111). Em município pequeno a resposta é muito ruidosa, porque a variância depende da população (o que já aparece no Breusch-Pagan).
- **Presídios:** 35 municípios têm mais de 10% da população fora de domicílio particular, ou seja, morando em presídio, quartel ou asilo (de 65% em Balbinos-SP a 10,7%). 31 deles ficam em SP (28) e PE (3), e entre eles estão os 10 municípios com maior % de homens 15–29. Esses 35 somam 217 homicídios por residência e 239 por ocorrência: diferença pequena. **O efeito do presídio está no denominador e em `pct_h1529`, não no numerador.** A regra que o SIM usa para a residência de um preso que morre dentro do presídio **não foi verificada**.

## 5. Outliers e pontos influentes (modelo D)

- 3 municípios têm |e*| ≥ 4: São João do Jaguaribe-CE (e* = 7,2; taxa de 285), Rodolfo Fernandes-RN (4,4) e Ibicuitinga-CE (4,1). **Nenhum parece erro.** As mortes se espalham pelos três anos (São João do Jaguaribe: 22, 14 e 14) e a contagem por ocorrência é quase igual à por residência (48 contra 50). É violência real, concentrada em município pequeno. Em 2024 São João do Jaguaribe caiu para 1 homicídio.
- *(Fora da apostila, só descritivo)* 345 municípios têm alavancagem acima de 2p/n e 296 têm distância de Cook acima de 4/n, mas o Cook máximo é só 0,029, ou seja, **nenhum ponto domina o ajuste**. As maiores alavancagens são Pracinha-SP (presídio: 31,6% de homens 15–29 e desocupação 0), Alto Alegre-RR e Uiramutã-RR (renda extrema), Reginópolis-SP (presídio) e Joca Marques e Alegrete do Piauí (desocupação de 51%).
- O gráfico de resíduos (`v1`) mostra a faixa diagonal dos 655 zeros e alguns valores ajustados negativos. Essa é a limitação de usar MQO numa resposta com muitos zeros, não um problema de dado.

## 6. Sensibilidade: o modelo reajustado sem cada grupo de casos

| Cenário | n | R² | O que muda |
|---|---|---|---|
| base | 5.570 | 0,342 | — |
| sem os 3 com \|e*\| ≥ 4 | 5.567 | 0,344 | `desocup` perde a significância (p = 0,052) |
| sem os 35 com presídio (> 10% fora de domicílio) | 5.535 | 0,340 | `pct_h1529` cresce 62% (de 0,057 para 0,093) |
| sem desocupação > 30% ou = 0 (37) | 5.533 | 0,339 | `desocup` cai 28% e perde a significância (p = 0,15) |
| sem % indeterminada ≥ 30% (147) | 5.423 | 0,338 | `pct_indet` some (−93%, p = 0,71) |
| sem população < 5 mil (1.324) | 4.246 | 0,371 | **`pct_h1529` troca de sinal** (+0,057 para −0,060); Amazônia Legal e fronteira perdem a significância |
| sem 118 com > 20% mal definida | 5.452 | 0,343 | nada relevante |
| *(fora da apostila)* sem Cook > 4/n | 5.274 | 0,433 | `desocup` perde a significância |

Renda (com o termo ao quadrado), `desig`, urbana, densidade, `pct_negra` e região **não mudam de sinal nem de significância em nenhum cenário**.

## 7. Recomendações

**DEVE ser feito**
1. **Não remover os outliers.** Não há evidência direta de erro (anos consistentes; ocorrência ≈ residência) e a apostila só manda remover quando há essa evidência. Se tirar os 3, o R² sobe só 0,002.
2. **Tratar `pct_h1529` como frágil.** Ele é inflado por presídio, muda 62% sem os 35 municípios com presídio e troca de sinal sem os municípios pequenos. No mínimo, citar isso no trabalho. Se o grupo quiser corrigir, a opção dentro dos dados que já temos é controlar o presídio com a % fora de domicílio particular (vem da tabela 10295, já baixada). Isso é decisão do grupo.
3. **Explicar no trabalho que `pct_indet` não é fator de risco.** Ele só existe por causa dos 147 municípios com % indeterminada alta, concentrados em SP e MG, e mede subnotificação da resposta. O valor negativo do coeficiente é coerente com isso.

**PODE ser feito**
4. Explicar que o coeficiente de `desocup` (fraco, p = 0,03) depende de 3 a 37 municípios e de dados da amostra do Censo com erro grande em município pequeno.
5. Mostrar a variância maior nos municípios pequenos (correlação com 2024 de 0,26 contra 0,83) como evidência para o diagnóstico de heteroscedasticidade. O uso de pesos (mínimos quadrados ponderados) só vale se estiver na apostila: não verificado aqui.
6. Ignorar as inconsistências das tabelas 10300, 9517 e 9605. O efeito é ≤ 0,03 p.p. nas duas primeiras e ≤ 2,6 p.p. na de cor; não precisa de correção.

**NÃO deve ser feito**
7. Remover municípios por resíduo, alavancagem ou Cook sem evidência de erro.
8. "Corrigir" a desocupação de 51% ou de 0%: é o valor publicado pelo IBGE.
9. Trocar o denominador de `pct_pobres` ou de `desocup` por causa das diferenças de ±1 a ±3 pessoas.

## Não verificado
- A regra do SIM para a residência de quem morre dentro do presídio.
- A causa das diferenças de ±1 a ±3 pessoas nas tabelas 10300 e 9517 (parece arredondamento ou sigilo do IBGE) e o que é o "resto" da tabela 9605.
- Se a apostila cobre mínimos quadrados ponderados.
