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
- O escopo são os municípios com 20 mil habitantes ou mais: abaixo disso a taxa é dominada pelo acaso (ver `resultados/eda/confiabilidade_porte.csv`).
- Cada município recebe o percentil da sua densidade dentro da sua região (`resultados/eda/percentis_municipios.csv`). Ficam os que estão entre os percentis 2,5 e 97,5 da região: saem 88 e ficam 1.622 municípios (66% da população).
- ln(densidade) entra no modelo padronizado (média 0, desvio-padrão 1).
- Desigualdade: índice de Gini de cada município, calculado pelas classes de renda do Censo 2022. O IBGE só publica o Gini por região e UF; a conferência com o oficial está em `dados/validacao_gini.csv`.
- Resposta do modelo: ln(taxa). O Box-Cox estima λ perto de 0; adotamos o logaritmo (λ = 0), mais simples de interpretar, embora 0 fique fora do intervalo de confiança de λ.
- Os números citados no trabalho ficam em `resultados/modelagem/valores_modelo.txt`; as tabelas e figuras, em `resultados/eda/` e `resultados/modelagem/`.
- O modelo é montado em 5 blocos, cada um testado pelo F parcial: A renda e desigualdade; B demografia; C fronteira e registro; D educação e migração; E região.
- A região (5 classes, base Sudeste) entra como variável categórica. O script também ajusta o modelo com o estado (27 UFs, base SP) e grava os dois lado a lado em `resultados/modelagem/regiao_x_estado.csv`; a escolha está em aberto.

## Dados

- Resposta: taxa de homicídios por 100 mil hab./ano, 2021–2023 (SIM/DATASUS, óbitos por residência; CID-10 X85–Y09 e Y35–Y36).
- Explicativas: Censo Demográfico 2022 (IBGE, SIDRA), Indicadores Educacionais 2022 (INEP), região e faixa de fronteira (DATASUS).
- A coleta e a montagem da base estão no repositório completo (`scripts/00_coletar_dados.R`, `scripts/01_preparar_dados.R` e `scripts/02_integrar_candidatas.R`).
