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
| `2_modelo_preliminar.R` | Box-Cox, multicolinearidade (VIF), construção em blocos com teste F parcial, modelo preliminar e diagnóstico dos resíduos |
| `dados/base_analitica.csv` | Base pronta: 1 linha por município (5.570) |
| `dados/dicionario.csv` | Descrição de cada coluna da base |
| `dados/malha_mun.geojson` | Malha municipal do IBGE (só para o mapa) |

## Escopo e modelo

- A análise exploratória usa os 5.570 municípios.
- O modelo usa os municípios com 20 mil habitantes ou mais: abaixo disso a taxa é dominada pelo acaso (ver `resultados/eda/confiabilidade_porte.csv`).
- Cada município recebe o percentil da sua densidade dentro da sua região (`resultados/eda/percentis_municipios.csv`). Ficam os que estão entre os percentis 2,5 e 97,5 da região: saem 87 e ficam 1.623 municípios (66% da população).
- ln(densidade) entra no modelo padronizado (média 0, desvio-padrão 1).
- Resposta do modelo: ln(taxa), escolhida pelo procedimento de Box-Cox.
- A região (5 classes, base Sudeste) entra como variável categórica.

## Dados

- Resposta: taxa de homicídios por 100 mil hab./ano, 2021–2023 (SIM/DATASUS, óbitos por residência; CID-10 X85–Y09 e Y35–Y36).
- Explicativas: Censo Demográfico 2022 (IBGE, SIDRA), Amazônia Legal e faixa de fronteira (DATASUS).
- A coleta e a montagem da base estão no repositório completo (`scripts/00_coletar_dados.R` e `scripts/01_preparar_dados.R`).
