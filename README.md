# Fatores associados aos homicídios nos municípios brasileiros

Grupo: Douglas Bergamim Fernandes, Fabio Eiiti Kobayashi Urio, Kauan Alves Aragão, Luiz Felipe de Brito Ramos e Willian Nelton Teleken.

Trabalho da disciplina de Análise de Regressão, ligado ao ODS 16, sobre violência letal nos municípios brasileiros.
A resposta inclui agressões e intervenções legais; ela não equivale estritamente ao indicador 16.1.1 de homicídio intencional da ONU.
O [metadado da ONU](https://unstats.un.org/sdgs/metadata/files/Metadata-16-01-01.pdf) define o indicador e suas exclusões.

**Pergunta:** quais fatores socioeconômicos, demográficos e geográficos estão associados à taxa de homicídios nos municípios brasileiros?

- **Unidade de análise:** o município. O modelo usa os municípios com 30 mil habitantes ou mais (perto do percentil 80 da população): 1.133, sem Campos do Jordão-SP
- **Resposta:** taxa de homicídios (agressão X85–Y09 + intervenção legal Y35–Y36), por residência, média anual 2021–2023
- **Explicativas:** Censo Demográfico 2022 (renda, desigualdade pelo índice de Gini, trabalho, urbanização, frequência escolar, migração), INEP 2022 (distorção idade-série no ensino médio) e região
- **Modelo:** regressão linear múltipla para ln(taxa), por mínimos quadrados ordinários
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
  2_modelo.R    Box-Cox, VIF, blocos com F parcial, modelo, comparação com e sem a renda e diagnóstico -> entrega/resultados/modelagem/
  dados/                   cópia da base analítica e das variáveis extras (geradas pelos scripts 01 e 02)
validacao/                 validação da qualidade dos dados (validar_dados.R e RELATORIO.md)
relatorio/                 relatório da exploração (relatorio.qmd; lê dados/tabelas/base_relatorio.csv) e modelo/ com os arquivos do Overleaf
decisoes/                  INTERNO: transcrição do alinhamento com os professores e guia das decisões do grupo (PDF e fonte em HTML)
apresentacao/              slides finais (latex/ e exportações) e material interno de fala (notas.json e briefings/)
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
Rscript 2_modelo.R             # gera entrega/resultados/modelagem/
```

Slides (sempre depois de rodar os dois scripts da entrega, para os números baterem com o código):

```bash
cd apresentacao/latex
Rscript gerar_numeros.R                   # roda a análise da entrega e gera numeros.tex e tabelas/
tectonic -X compile apresentacao_final.tex
cd ..
Rscript exportar_pptx_html.R              # .pdf, .pptx e .html iguais, com as notas (notas.json)
cd briefings
Rscript gerar_briefings.R                 # um briefing_<nome>.pdf por apresentador
```

Os slides em `apresentacao/apresentacao_final.pdf` e `.pptx` são os arquivos da apresentação para enviar à professora.
O prazo informado pelo grupo é **18/11/2026, às 10h00**. A apresentação tem limite de 15 minutos.
As notas e os briefings são material interno do grupo.
Para atualizar os briefings, use a skill `briefing-apresentacao` (`.claude/skills/`).

## Fechamento da apresentação final

Os [materiais finais e os briefings](apresentacao/LEIA-ME.md) estão organizados por apresentador.
O [registro de verificação](apresentacao/VERIFICACAO.md) documenta os checks, as correções e os limites desta etapa.
Uma [revisão com a apostila e as orientações docentes](decisoes/revisao-projeto-apostila.md) conferiu a análise e os requisitos da entrega.
A [auditoria do modelo final](validacao/REVISAO_MODELO_FINAL.md) reproduz cálculos e registra limitações e sensibilidades.
Ela acrescentou resíduos por explicativa nos apêndices e registrou a conferência das variáveis extras nas fontes originais.

As [decisões aprovadas em 17/11](decisoes/discussao-final-17-11-2026.md) mantêm a região no modelo.
A [revisão da narrativa](decisoes/revisao-semantica-apresentacao.md) define 23 páginas: 14 principais e nove apêndices, de A a I.
O roteiro prevê 13min30: Kauan 1min45, Fabio 1min30, Douglas 2min, Luiz Felipe 3min e Willian 5min15.
Contexto e dados ocupam 3min15. As cinco partes seguem a ordem pedida pelas professoras.
Kauan define ODS, ODS 16, meta 16.1 e indicador de referência 16.1.1 no contexto; Fabio, dados; Douglas, métodos; Luiz Felipe, ajuste e diagnósticos; Willian, discussão.
O slide 7 mostra taxas observadas e ajustadas. Os dois gráficos exploratórios retirados permanecem no repositório.
Os apêndices H e I mostram resíduos por explicativa nas páginas 22 e 23.
As fontes foram retiradas da projeção e preservadas em `apresentacao/referencias-dos-slides.md`.
As legendas técnicas dos gráficos permanecem. O rodapé contém apenas a numeração.
Os 1min30 restantes acomodam pausas e transições.
O ensaio deve confirmar a duração; a estimativa por palavras não substitui a fala real.
Os diagnósticos usam gráficos interpretados antes dos valores dos testes e do VIF.
As hipóteses são expectativas iniciais. A migração recente permanece no modelo, sem evidência clara de associação.
Exclusão escolar significa frequência e atraso escolar. Migração recente significa residência ininterrupta inferior a dez anos.
As limitações incluem o recorte populacional, o Gini aproximado e a dependência entre municípios não avaliada.
O [plano de execução](decisoes/plano-fechamento-final.md) registra os requisitos desta etapa.
O artigo final fica para a próxima etapa; os arquivos do modelo do Overleaf estão em `relatorio/modelo/`.

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
- **Desigualdade:** o IBGE só publica o Gini do Censo 2022 para o Brasil, as regiões e as UFs (SIDRA 10301). Calculamos o Gini de cada município pelas classes de renda (SIDRA 10300), pela área sob a curva de Lorenz (Gastwirth, 1972). O mesmo cálculo nas 27 UFs tem correlação de 0,995 com o Gini oficial (`dados/tabelas/validacao_gini.csv`).
- **Escopo:** o modelo usa os municípios com 30 mil habitantes ou mais, perto do percentil 80 da população (79,6; `entrega/resultados/eda/percentis_municipios.csv`). Nesse porte a taxa nacional dá pelo menos 20 homicídios esperados em 3 anos; abaixo disso a taxa oscila por acaso. Campos do Jordão-SP fica fora, por indício de sub-registro (1 homicídio registrado e 36 óbitos de intenção indeterminada).
- **Variáveis testadas e retiradas:** densidade, faixa de fronteira, abandono no ensino médio, % de homens de 15 a 29 anos, Amazônia Legal e % de óbitos de intenção indeterminada (`entrega/resultados/modelagem/testadas_retiradas.csv`).
- **Desigualdade e renda:** o modelo tem o termo Gini × renda, porque o efeito da desigualdade muda com a renda do município.
- **Região:** entra como variável categórica (5 classes, referência Sudeste).
- **Presídios:** os presos entram na população do Censo, o que distorce a % de homens de 15 a 29 anos e o denominador da taxa em alguns municípios pequenos de SP.
- **% intenção indeterminada:** mede a qualidade do registro. Não entra no modelo: os homicídios estão no seu divisor, então ela cai quando os homicídios sobem, só pela conta.


## Conferência de todos os pedidos

A [matriz de conferência](decisoes/conferencia-pedidos-17-11-2026.md) confronta as mensagens de 17/11 com os materiais reais.
O [caderno final em Quarto](entrega/analise_final.qmd) contém os códigos comentados da análise final.
O [HTML executado](entrega/analise_final.html) apresenta os resultados e gráficos; não substitui o artigo em LaTeX.
A execução isolada reproduziu as 15 tabelas CSV, com tolerância de 1e-12, usando região e 1.133 municípios.
O relatório antigo em `relatorio/` permanece histórico e não deve ser usado como código ou artigo final.
As pessoas e a ordem das falas foram preservadas; os assuntos foram condensados e redistribuídos.

A [análise crítica de cada slide](decisoes/analise-critica-slide-a-slide.md) relaciona conteúdo e enunciado docente.
A abertura recupera a comparação internacional, com taxas de homicídio intencional do mesmo ano, sem alterar o modelo.
A pasta do grupo inclui a análise crítica por slide e a tabela dos dados de contexto.

## Auditoria adicional das candidatas

A [auditoria completa](validacao/AUDITORIA_CANDIDATAS.md) examinou 39 colunas e codificações, em 57 formas de entrada.
Algumas acrescentam informação. O usuário confirmou manter o modelo principal e guardar as comparações como apoio.
A [verificação de favelas](validacao/FAVELAS_METODO_E_DECISAO.md) distingue qualidade da fonte e estabilidade da associação.
O [resumo para o time](apresentacao/MUDANCAS-PARA-O-TIME.md) explica as mudanças finais e as respostas para perguntas.
Não foram acrescentados apêndices nem justificativas de cada candidata à apresentação principal.
