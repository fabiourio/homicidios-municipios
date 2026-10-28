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
| `dados/variaveis_extras.csv` | Abandono e distorção idade-série no ensino médio (INEP) e migração recente (Censo), 1 linha por município |
| `dados/dicionario_extras.csv` | Descrição das colunas extras |
| `dados/malha_mun.geojson` | Malha municipal do IBGE (só para o mapa) |

## Escopo e modelo

- Análise exploratória e modelo usam os 1.710 municípios com 20 mil habitantes ou mais (84% da população): abaixo disso a taxa é dominada pelo acaso (ver `resultados/eda/confiabilidade_porte.csv`). Só a tabela de porte e o mapa mostram os 5.570.
- O modelo é montado em 5 blocos, cada um testado pelo F parcial: A renda e desigualdade; B demografia; C fronteira e registro; D educação e migração; E estado.
- Resposta do modelo: ln(taxa), escolhida pelo procedimento de Box-Cox.
- Estado (27 UFs, base SP) entra como variável categórica no lugar da região: absorve diferenças entre estados e elimina a correlação entre resíduos de municípios vizinhos (ver Durbin-Watson em `resultados/modelagem/valores_modelo.txt`).

## Dados

- Resposta: taxa de homicídios por 100 mil hab./ano, 2021–2023 (SIM/DATASUS, óbitos por residência; CID-10 X85–Y09 e Y35–Y36).
- Explicativas: Censo Demográfico 2022 (IBGE, SIDRA; inclui frequência escolar 15–17 e migração recente), INEP 2022 (abandono e distorção idade-série no ensino médio), Amazônia Legal e faixa de fronteira (DATASUS).
- A coleta e a montagem da base estão no repositório completo (`scripts/00_coletar_dados.R`, `scripts/01_preparar_dados.R` e `scripts/02_integrar_candidatas.R`).
