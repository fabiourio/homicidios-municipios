# Fatores associados aos homicídios nos municípios brasileiros

Grupo: Douglas Bergamim Fernandes, Fabio Eiiti Kobayashi Urio, Kauan Alves Aragão, Luiz Felipe de Brito Ramos e Willian Nelton Teleken.

Trabalho da disciplina de Análise de Regressão, ligado ao ODS 16 (indicador 16.1.1, taxa de homicídios por 100 mil habitantes).

**Pergunta:** quais fatores socioeconômicos, demográficos e geográficos estão associados à taxa de homicídios nos municípios brasileiros?

- **Unidade de análise:** o município. O modelo usa os 1.622 municípios com 20 mil habitantes ou mais que ficam entre os percentis 2,5 e 97,5 da densidade da sua região
- **Resposta:** taxa de homicídios (agressão X85–Y09 + intervenção legal Y35–Y36), por residência, média anual 2021–2023
- **Explicativas:** Censo Demográfico 2022 (renda, desigualdade pelo índice de Gini, trabalho, urbanização, densidade, idade, frequência escolar, migração), INEP 2022 (abandono e distorção idade-série no ensino médio), região e faixa de fronteira
- **Modelo (preliminar):** regressão linear múltipla para ln(taxa), por mínimos quadrados ordinários
- **Regras do trabalho:** ver `CLAUDE.md` (código só em R; só técnicas da apostila de GED)

## Estrutura

```
dados/
  raw/                  extrações originais (JSON) — SIDRA e TabNet
  candidatos/           fontes e scripts de download das variáveis candidatas (ver FONTES.md)
  tabelas/              tabelas limpas em CSV + dicionários (geradas pelos scripts 01, 02 e 03)
  malha_mun.geojson     malha municipal 2022 (IBGE)
scripts/
  00_coletar_dados.R       baixa tudo de novo das fontes (opcional; os dados já estão no repo)
  01_preparar_dados.R      limpeza, checagens de consistência, cálculo do Gini e montagem da base analítica
  02_integrar_candidatas.R integra as variáveis candidatas (educação e migração entram no modelo)
  03_preparar_relatorio.R  junta o Gini, as variáveis candidatas e os recortes do IBGE (RM/RIDE) -> dados/tabelas/base_relatorio.csv
  funcoes_desigualdade.R   cálculo do Gini pelas classes de renda (usado pelo 03 e pelo relatório)
  instalar_pacotes.R       instala os pacotes de R
entrega/                   CÓDIGO DA ANÁLISE para entregar (ver entrega/LEIA-ME.md)
  1_analise_exploratoria.R estatísticas, mapa, correlações, gráficos -> entrega/resultados/eda/
  2_modelo_preliminar.R    Box-Cox, VIF, blocos com F parcial, modelo, comparação com e sem a renda e diagnóstico -> entrega/resultados/modelagem/
  dados/                   cópia da base analítica e das variáveis extras (geradas pelos scripts 01 e 02)
validacao/                 validação da qualidade dos dados (validar_dados.R e RELATORIO.md)
relatorio/                 relatório da exploração (relatorio.qmd; lê dados/tabelas/base_relatorio.csv)
decisoes/                  INTERNO: guia das decisões do grupo, com opções, prós e contras e o que já foi decidido (PDF e a fonte em HTML)
apresentacao/              INTERNO: slides (latex/), notas.json, exportação .pptx/.html e briefings/ por apresentador
```

## Como rodar

Na raiz do repositório:

```bash
Rscript scripts/instalar_pacotes.R

Rscript scripts/01_preparar_dados.R       # gera dados/tabelas/ e copia a base para entrega/dados/
# (opcional) Rscript scripts/02_integrar_candidatas.R   # regera entrega/dados/variaveis_extras.csv; ver a nota abaixo
Rscript scripts/03_preparar_relatorio.R   # gera dados/tabelas/base_relatorio.csv, usada pelo relatorio/relatorio.qmd
cd entrega
Rscript 1_analise_exploratoria.R          # gera entrega/resultados/eda/
Rscript 2_modelo_preliminar.R             # gera entrega/resultados/modelagem/
```

Slides (sempre depois de rodar os dois scripts da entrega, para os números baterem com o código):

```bash
cd apresentacao/latex
Rscript gerar_numeros.R                   # roda a análise da entrega e gera numeros.tex e tabelas/
tectonic -X compile apresentacao_parcial.tex
cd ..
Rscript exportar_pptx_html.R              # .pdf, .pptx e .html iguais, com as notas (notas.json)
cd briefings
Rscript gerar_briefings.R                 # um briefing_<nome>.pdf por apresentador
```

Tudo em `apresentacao/` é interno do grupo (não vai na entrega). Para atualizar os briefings, use a skill `briefing-apresentacao` (`.claude/skills/`).

Nenhum número é digitado à mão no `.tex`: tudo vem de `numeros.tex` e `tabelas/`. O `gerar_numeros.R` também confere as frases fixas dos slides (ex.: "renda em U invertido") e para com erro se o resultado deixar de sustentá-las.

Os números do trabalho ficam em `entrega/resultados/modelagem/valores_modelo.txt` e nos CSVs de `entrega/resultados/`. Para baixar os dados de novo das fontes oficiais, rode `Rscript scripts/00_coletar_dados.R` antes do passo 01. Isso leva alguns minutos e precisa de acesso a `servicodados.ibge.gov.br`, `apisidra.ibge.gov.br` e `tabnet.datasus.gov.br`.

O script 02 só roda depois de baixar os arquivos das variáveis candidatas, que não ficam no repositório: `Rscript dados/candidatos/baixar_candidatos.R` (ver `dados/candidatos/FONTES.md`). Não é preciso rodá-lo para refazer a análise: `entrega/dados/variaveis_extras.csv` já está versionado.

Os slides são compilados com o `tectonic`.

## Fontes

| Dado | Fonte | Tabelas / filtros |
|---|---|---|
| Óbitos por causas externas, por município de residência | SIM/DATASUS (TabNet `sim/cnv/ext10br.def`) | 2021–2023 e 2024 (2024 consolidado; 2025 ainda preliminar) |
| População, área, densidade | IBGE, Censo 2022 (SIDRA) | 4709, 4714 |
| Renda per capita média | IBGE, Censo 2022 (SIDRA) | 10295 |
| Pessoas 14+ por classe de renda per capita (base do Gini municipal) | IBGE, Censo 2022 (SIDRA) | 10300 |
| Gini oficial do Brasil, das regiões e das UFs (conferência) | IBGE, Censo 2022 (SIDRA) | 10301 |
| Força de trabalho e desocupação | IBGE, Censo 2022 (SIDRA) | 9517 |
| Alfabetização | IBGE, Censo 2022 (SIDRA) | 9543 |
| Situação urbana/rural | IBGE, Censo 2022 (SIDRA) | 9923 |
| Homens de 15 a 29 anos | IBGE, Censo 2022 (SIDRA) | 9606 |
| Frequência escolar de 15 a 17 anos | IBGE, Censo 2022 (SIDRA) | 10056 |
| Moradores há menos de 10 anos no município | IBGE, Censo 2022 (SIDRA) | 10158 |
| Abandono e distorção idade-série no ensino médio | INEP, Indicadores Educacionais 2022 | taxas de rendimento e TDI por município |
| Malha municipal | IBGE, API de malhas | 2022, qualidade mínima |

Dados do SIM coletados em 25/10/2026 e do Censo em 27/10/2026.

## Decisões de tratamento dos dados

- **Símbolos do IBGE:** "-" é zero absoluto e foi lido como 0. Não há valores suprimidos ("X") nas tabelas usadas.
- **Junção:** o código IBGE de 7 dígitos dividido por 10 dá o código de 6 dígitos do DATASUS. Todos os municípios casam.
- **Municípios ausentes no TabNet:** o TabNet omite municípios sem nenhuma morte externa no período, e eles recebem 0.
- **Município de residência ignorado:** 1.687 homicídios (1,2%) de 2021–2023 não puderam ser atribuídos a um município.
- **Desigualdade:** o IBGE só publica o Gini do Censo 2022 para o Brasil, as regiões e as UFs (SIDRA 10301). Calculamos o Gini de cada município pelas classes de renda (SIDRA 10300), pela área sob a curva de Lorenz. O mesmo cálculo nas 27 UFs tem correlação de 0,995 com o Gini oficial (`dados/tabelas/validacao_gini.csv`).
- **Escopo:** o modelo usa os municípios com 20 mil habitantes ou mais, porque abaixo disso a taxa oscila por acaso. Dentro de cada região, saem os municípios abaixo do percentil 2,5 ou acima do percentil 97,5 da densidade (`entrega/resultados/eda/percentis_municipios.csv`).
- **Região:** entra como variável categórica (5 classes, referência Sudeste).
- **Presídios:** os presos entram na população do Censo, o que distorce a % de homens de 15 a 29 anos e o denominador da taxa em alguns municípios pequenos de SP.
- **% intenção indeterminada:** vem da mesma base que a resposta. É um controle de qualidade do registro, não um fator de risco.
