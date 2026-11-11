# Código da análise — apresentação parcial

Fatores associados aos homicídios nos municípios brasileiros (GED-16 · ITA · ODS 16).
Grupo: Douglas Bergamim Fernandes, Fabio Eiiti Kobayashi Urio, Kauan Alves Aragão, Luiz Felipe de Brito Ramos e Willian Nelton Teleken.

## Como rodar

Abra o R com esta pasta (`entrega/`) como diretório de trabalho e rode, nesta ordem:

```r
source("1_analise_exploratoria.R")   # gera resultados/eda/
source("2_modelo_preliminar.R")      # gera resultados/modelagem/
```

Pacotes: `ggplot2`, `dplyr`, `tidyr`, `GGally`, `sf`, `MASS`, `car`, `lmtest`.

## Arquivos

| Arquivo | O que faz |
|---|---|
| `1_analise_exploratoria.R` | Resumos numéricos, distribuição da resposta, mapa, boxplots, correlações e dispersões |
| `2_modelo_preliminar.R` | Box-Cox, multicolinearidade (VIF), construção em blocos com teste F parcial, modelo preliminar, comparação com e sem a renda e diagnóstico dos resíduos |
| `dados/base_analitica.csv` | Base pronta: 1 linha por município (5.570) |
| `dados/dicionario.csv` | Descrição de cada coluna da base |
| `dados/variaveis_extras.csv` | Abandono e distorção idade-série no ensino médio (INEP 2022) e migração recente (Censo 2022); descrição em `dados/dicionario_extras.csv` |
| `dados/validacao_gini.csv` | Gini calculado x Gini oficial do IBGE (Brasil, regiões e UFs) |
| `dados/malha_mun.geojson` | Malha municipal do IBGE (só para o mapa) |

## Escopo e modelo

- A análise exploratória e o modelo usam o mesmo escopo. Só a definição do escopo e o mapa usam os 5.570 municípios.
- O escopo são os 1.134 municípios com 30 mil habitantes ou mais (77% da população). É o percentil 80 da população dos municípios (`resultados/eda/percentis_municipios.csv`). Nesse porte, a taxa nacional dá pelo menos 20 homicídios esperados em 3 anos; abaixo disso a taxa é dominada pelo acaso (ver `resultados/eda/confiabilidade_porte.csv`).
- A densidade não entra no modelo: testada em ln e padronizada, não é significativa neste escopo (ver a seção 5.3 de `resultados/modelagem/valores_modelo.txt`).
- Desigualdade: índice de Gini de cada município, calculado pelas classes de renda do Censo 2022. O IBGE só publica o Gini por região e UF. O cálculo: cada classe de renda recebe o seu ponto médio em salários mínimos (a classe aberta, de mais de 20, recebe 50); ordenam-se as classes, acumulam-se as pessoas e a renda, e o Gini é 1 menos o dobro da área sob essa curva de Lorenz (regra do trapézio). É o método de GASTWIRTH, J. L. The estimation of the Lorenz curve and Gini index. *The Review of Economics and Statistics*, v. 54, n. 3, p. 306–316, 1972. A conferência com o oficial está em `dados/validacao_gini.csv`: nas 27 UFs a correlação é 0,995 e a maior diferença é de 0,008.
- Resposta do modelo: ln(taxa). O Box-Cox estima λ perto de 0; adotamos o logaritmo (λ = 0), mais simples de interpretar, embora 0 fique fora do intervalo de confiança de λ.
- Os números citados no trabalho ficam em `resultados/modelagem/valores_modelo.txt`; as tabelas e figuras, em `resultados/eda/` e `resultados/modelagem/`.
- O modelo é montado em 5 blocos, cada um testado pelo F parcial: A renda e desigualdade; B demografia; C fronteira e registro; D educação e migração; E região.
- A região (5 classes, base Sudeste) entra como variável categórica. O script também ajusta o modelo com o estado (27 UFs, base SP) e grava os dois lado a lado em `resultados/modelagem/regiao_x_estado.csv`. O grupo escolheu a região; o modelo com estado fica como comparação.

## O que vem de fora da apostila

A regra do trabalho é usar só técnicas da apostila de GED-16. Estes itens não estão descritos nela:

| Item | Origem | Para que serve |
|---|---|---|
| Índice de Gini por município, calculado pelas classes de renda | Revisão da professora | Medir a desigualdade; o IBGE só publica o Gini por região e UF |
| Corte no percentil 80 da população | Revisão da professora | Escolher os municípios do estudo (30 mil habitantes ou mais) |
| Padronização de ln(densidade) | Revisão da professora | Usada no teste da densidade, que ficou fora do modelo |
| VIF generalizado (pacote `car`) | Escolha do grupo | VIF de variável com várias categorias (região e estado) |
| Efeito em %: 100·[exp(b·Δ) − 1] | Escolha do grupo | Ler os coeficientes com a resposta em ln |
| Intervalo de confiança de λ no Box-Cox | Escolha do grupo | Dizer se λ = 0 é compatível com os dados |
| Oscilação da taxa por porte: 1/√(casos esperados) | Escolha do grupo | Justificar o corte de população |

## Dados

- Resposta: taxa de homicídios por 100 mil hab./ano, 2021–2023 (SIM/DATASUS, óbitos por residência; CID-10 X85–Y09 e Y35–Y36).
- Explicativas: Censo Demográfico 2022 (IBGE, SIDRA), Indicadores Educacionais 2022 (INEP), região e faixa de fronteira (DATASUS).
- A coleta e a montagem da base estão no repositório completo (`scripts/00_coletar_dados.R`, `scripts/01_preparar_dados.R` e `scripts/02_integrar_candidatas.R`).
