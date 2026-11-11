---
title: "Renda, desigualdade e homicídios nos municípios brasileiros"
subtitle: "Exploração dos dados para a construção do modelo — GED-16 (ITA), ODS 16.1.1"
author: "Douglas Bergamim Fernandes, Fabio Eiiti Kobayashi Urio, Kauan Alves Aragão, Luiz Felipe de Brito Ramos, Willian Nelton Teleken"
lang: pt
format:
  html:
    keep-md: true
    embed-resources: true
    toc: true
    number-sections: true
bibliography: referencias.bib
link-citations: true
---





# Revisão de literatura

| Estudo | O que estuda | Escopo e dados | Método | Principais resultados | O que levamos |
|----|----|----|----|----|----|
| Blau e Blau [-@blau1982] | Desigualdade e violência (privação relativa) | 125 áreas metropolitanas dos EUA | Não informado no texto salvo | A desigualdade aumenta a violência; com ela controlada, a pobreza deixa de importar | A hipótese central: a desigualdade importa mais que a pobreza |
| Pridemore [-@pridemore2011] | Desigualdade contra pobreza | Réplica de dois estudos entre países | Os mesmos modelos, com e sem pobreza | Pobreza positiva; a desigualdade desaparece em dois de três modelos | Incluir % pobres junto da desigualdade |
| Ouimet [-@ouimet2012] | Fatores socioeconômicos do homicídio | 165 países, 2010 | Regressão, com subamostras por nível de desenvolvimento | A desigualdade prediz o homicídio no desenvolvimento médio | Motiva a H2: o efeito da desigualdade depende da renda |
| Duarte et al. [-@duarte2012] | Características municipais e homicídio de homens de 20 a 39 anos | 5.565 municípios, 2007 a 2010 (SIM) | MQO falhou por causa das taxas zero ("n=1.324 municípios"); logit fracional | Risco cresce com a desigualdade (razão 20/40); pico nas categorias intermediárias de renda e de pobreza | Motiva a H1 (U invertido da renda); definição da resposta; média de vários anos |
| Carvalho, Cerqueira e Lobão [-@carvalho2015] | Estrutura socioeconômica e homicídio | 5.507 municípios, 1999 a 2001 | Regressão com dependência espacial (0.382) e indicadoras de estado | Parâmetros significativos; forte influência do Gini | Covariáveis em log, controles e indicadoras de UF |

## Objetivo de análise

"Nos municípios brasileiros, a taxa de homicídios é mais alta onde a renda é intermediária e a desigualdade é alta?"

Seguindo o que já encontramos na literatura, essas serão as duas hipóteses testadas:

- **H1 — forma da renda.** A relação entre renda per capita e taxa de homicídios tem forma de U invertido [@duarte2012].
- **H2 — desigualdade × renda.** O efeito da desigualdade depende do nível de renda [@ouimet2012].

# Dados {#sec-dados}


::: {.cell}

```{.r .cell-code}
# The analysis base is built by scripts/03_preparar_relatorio.R (grouped Gini, joins, derived columns)
d_all <- read.csv(repo("dados/tabelas/base_relatorio.csv"), encoding = "UTF-8")
d_all$porte <- factor(d_all$porte, levels = c("<10 mil", "10–20 mil", "20–50 mil", "50–100 mil", "100 mil+"))
d_all$regiao <- factor(d_all$regiao, levels = c("N", "NE", "CO", "SE", "S"))
counts <- class_counts(income_classes)                       # class counts, used in the UF validation below
n_dash <- sum(as.matrix(income_classes[class_cols]) == "-")
c(rows = nrow(d_all), duplicated_keys = sum(duplicated(d_all$cod_ibge)), dash_cells = n_dash)
```

::: {.cell-output .cell-output-stdout}

```
           rows duplicated_keys      dash_cells 
           5570               0            9788 
```


:::
:::


A unidade de análise é o município. A base tem 5.570 municípios, sem códigos duplicados, e é montada pelos scripts `01_preparar_dados.R`, `02_integrar_candidatas.R` e `03_preparar_relatorio.R`, que param com erro se algum município ficar sem par numa das fontes.

## Variáveis

A resposta é a taxa de homicídios. As explicativas estão em sete grupos:

- **Renda e trabalho:** o nível de renda (H1) e as condições econômicas que a literatura associa ao homicídio: pobreza, desocupação, informalidade e PIB.
- **Desigualdade:** a variável da H2. A forma de medir está na @sec-desigualdade.
- **Educação e família:** frequência escolar dos jovens, alfabetização e domicílios chefiados por mães sem cônjuge.
- **Demografia e urbanização:** porte, densidade, urbanização e a parcela de homens jovens, o grupo com maior risco.
- **Justiça e registro:** presos no município e a parcela de mortes de intenção indeterminada, que indica a qualidade do registro.
- **Território:** Amazônia Legal, faixa de fronteira, região metropolitana e as indicadoras de UF e região.

Quase tudo é de 2022, o ano do Censo. A resposta usa os três anos em torno dele.

| Grupo | Variável | Descrição | Ano | Fonte | Uso |
|----|----|----|----|----|----|
| Resposta | `taxa` | Homicídios (agressão + intervenção legal) por 100 mil hab./ano, por residência | 2021–2023 | SIM/DATASUS; população do Censo | Resposta; em ln, provisório (Box-Cox a refazer no modelo) |
| Renda e trabalho | `rend_pc_media` | Renda domiciliar per capita média (R\$) | 2022 | SIDRA 10295 | Interesse (H1); ln, centralizada e ao quadrado |
| Renda e trabalho | `pct_pobres` | \% de pessoas de 14+ anos sem rendimento ou com até 1/4 SM per capita | 2022 | SIDRA 10300 | Controle |
| Renda e trabalho | `desocup` | Taxa de desocupação (% da força de trabalho) | 2022 | SIDRA 9517 | Controle |
| Renda e trabalho | `pct_informal` | \% dos ocupados que não contribuem para a previdência | 2022 | SIDRA 10264 | Alternativa à desocupação |
| Renda e trabalho | `ln_pib_pc` | ln do PIB per capita (R\$) | 2022 | SIDRA 5938 | Alternativa à renda [@ouimet2012] |
| Desigualdade | `gini` | Gini da renda domiciliar per capita, calculado das classes de renda | 2022 | SIDRA 10300 (cálculo nosso) | Interesse (H2); medida principal |
| Desigualdade | `gini_2010` | Gini oficial da renda domiciliar per capita | 2010 | IBGE via DATASUS (ginibr) | Alternativa e validação |
| Educação e família | `freq_15a17` | Frequência escolar bruta de 15 a 17 anos (%) | 2022 | SIDRA 10056 | Controle |
| Educação e família | `alfabet` | Taxa de alfabetização, 15+ anos (%) | 2022 | SIDRA 9543 | Alternativa; colinear com a renda |
| Educação e família | `pct_maes_solo` | \% de domicílios com mulher responsável, sem cônjuge, com filhos | 2022 | SIDRA 9882 | Controle |
| Demografia e urbanização | `pop` | População residente | 2022 | SIDRA 4709 | Define o porte e o escopo |
| Demografia e urbanização | `dens` | Densidade demográfica (hab./km²) | 2022 | SIDRA 4714 | Controle, em ln |
| Demografia e urbanização | `pct_urbana` | \% da população em situação urbana | 2022 | SIDRA 9923 | Controle |
| Demografia e urbanização | `pct_h1529` | \% de homens de 15 a 29 anos na população | 2022 | SIDRA 9606 | Controle |
| Justiça e registro | `pct_presos` | Presos em estabelecimentos penais / população (%) | 2º sem. 2022 | SISDEPEN | Controle; indicadora + ln(1 + %) |
| Justiça e registro | `pct_indet` | \% de óbitos de intenção indeterminada entre as causas externas | 2021–2023 | SIM/DATASUS | Controle da qualidade do registro |
| Território | `amazonia_legal`, `faixa_fronteira` | Município da Amazônia Legal / da faixa de fronteira (0/1) | — | DATASUS/IBGE | Controles |
| Território | `rm_ride` | Município em região metropolitana ou RIDE (definição legal, 0/1) | 2022 | IBGE, recortes territoriais | Controle |
| Território | `conc_urb` | Município em concentração urbana (definição técnica do IBGE, 0/1) | 2022 | IBGE, recortes territoriais | Alternativa a `rm_ride` |
| Território | `uf`, `regiao` | Unidade da Federação e grande região | — | IBGE | Indicadoras |

: Variáveis da análise. SM = salário mínimo de 2022 (R\$ 1.212).

**Como as variáveis foram obtidas.** A maioria vem pronta das tabelas do Censo no SIDRA. As outras foram construídas a partir de contagens. Uma contagem cresce com o tamanho do município, então a usamos sempre dividida pela população ou pelo grupo de referência: taxas e percentuais permitem comparar municípios de portes diferentes. Os estudos municipais revisados fazem o mesmo, com % de baixa renda e % urbana [@duarte2012] e proporções de jovens, de população urbana e de crianças pobres [@carvalho2015].

- `taxa`: homicídios (agressão X85–Y09 + intervenção legal Y35–Y36) de 2021–2023, por residência, / (3 × população de 2022) × 100 mil. Por 100 mil, como no ODS 16.1.1 e no Atlas da Violência [@cerqueira2025]. Três anos para estabilizar a taxa dos municípios pequenos, como em Duarte et al. [-@duarte2012] e Wanzinack et al. [-@wanzinack2022]; 2022 é o ano do meio.
- `pct_pobres`, `desocup`, `pct_urbana`, `pct_h1529`, `pct_informal`, `pct_maes_solo`, `pct_presos`: contagens divididas pelo grupo de referência (pessoas de 14+, força de trabalho, população, ocupados, domicílios).
- `pct_indet`: mortes de intenção indeterminada (Y10–Y34) / causas externas. Parte delas são homicídios não registrados como tal [@ipea2024], então a parcela controla a qualidade do registro.
- `ln_pib_pc`: ln(PIB 2022 / população), em ln pela forte assimetria, como as covariáveis de Carvalho et al. [-@carvalho2015].
- `rm_ride`, `conc_urb`, `amazonia_legal`, `faixa_fronteira`: indicadoras 0/1 da planilha de recortes do IBGE e dos filtros do TabNet; região metropolitana e fronteira também são indicadoras em Nsoesie et al. [-@nsoesie2020].
- `gini`: calculado das classes de renda (@sec-desigualdade).

## Medida de desigualdade {#sec-desigualdade}

A medida de desigualdade é central para a H2. Nos estudos revisados, ela é medida assim:

| Estudo | Medida de desigualdade | Unidade |
|----|----|----|
| Blau e Blau [-@blau1982] | Gini da renda familiar, segundo fontes secundárias (o método do artigo não foi lido) | Áreas metropolitanas dos EUA |
| Pridemore [-@pridemore2011] | Gini, segundo os artigos que o citam (não verificado); testa várias medidas | Países |
| Ouimet [-@ouimet2012] | Gini | Países |
| Carvalho, Cerqueira e Lobão [-@carvalho2015] | Gini | Municípios brasileiros (Censo 2000) |
| Duarte et al. [-@duarte2012] | Razão 20/40 da renda | Municípios brasileiros |

O Gini é a medida usual, e é a que usamos. Duarte et al. [-@duarte2012] usam a razão 20/40, que compara só os extremos da distribuição; o Gini usa a distribuição inteira e permite comparar os resultados com os demais estudos.

### Índice de Gini

O Gini resume, num número de 0 a 1, o quanto a renda de um lugar está concentrada. Vale 0 quando todos têm a mesma renda e 1 quando uma só pessoa tem toda a renda.

O Gini vem da curva de Lorenz. Com as pessoas ordenadas da mais pobre para a mais rica, a curva $L(P)$ dá a fração da renda total que fica com a fração $P$ mais pobre: por exemplo, $L(0{,}5) = 0{,}2$ quer dizer que a metade mais pobre fica com 20% da renda. Com igualdade perfeita, a curva é a diagonal $L(P) = P$; quanto mais ela se curva para baixo, maior a desigualdade. O Gini é a área entre a diagonal e a curva, dividida pela área sob a diagonal (1/2):

$$G = 1 - 2\int_0^1 L(P)\,dP .$$

Sem a renda de cada pessoa, só com o número de pessoas em cada uma de $K$ classes de renda, a curva fica com um ponto por classe. Ligando os pontos por retas, a integral vira uma soma de trapézios:

$$G = 1 - \sum_{k=1}^{K} (P_k - P_{k-1})(L_k + L_{k-1}), \qquad P_k = \sum_{j \le k} p_j, \qquad L_k = \frac{\sum_{j \le k} p_j\, y_j}{\sum_{j=1}^{K} p_j\, y_j},$$

com $P_0 = L_0 = 0$, $p_j$ a fração das pessoas na classe $j$ e $y_j$ a renda dessas pessoas.

Como não temos a renda de cada pessoa, usamos uma aproximação calculada a partir das classes de renda. É assim que se estima o Gini quando só há dados agrupados [@jorda2018]. A fórmula trata todas as pessoas de uma classe como se tivessem a mesma renda. Por ignorar as diferenças dentro de cada classe, o resultado é um limite inferior.

- Temos 11 classes:

  - sem rendimento;
  - até 1/4 SM, de 1/4 a 1/2 SM e de 1/2 a 1 SM, que separam bem a base da distribuição;
  - de 1 a 2 SM até de 15 a 20 SM, pelo meio e pelo alto;
  - mais de 20 SM, a classe aberta do topo.

  Quanto mais classes, menor a diferença de renda que fica escondida dentro de cada uma. A exceção é a classe aberta, que é a mais larga. Jorda, Sarabia e Jäntti [-@jorda2018] indicam que o viés tende a ser pequeno a partir de cinco classes.


::: {.cell}

```{.r .cell-code}
# Lorenz curves of three municipalities of 20 thousand or more: lowest, median and highest grouped Gini
lorenz_points <- function(n, mids) { p <- n / sum(n); inc <- p * mids
  data.frame(P = c(0, cumsum(p)), L = c(0, cumsum(inc) / sum(inc))) }
cls_cod <- as.numeric(income_classes$cod_ibge)
big <- d_all[d_all$pop >= 2e4, c("cod_ibge", "municipio", "uf", "gini")]
ex <- big[c(which.min(big$gini), which.min(abs(big$gini - median(big$gini))), which.max(big$gini)), ]
lor <- do.call(rbind, lapply(seq_len(nrow(ex)), function(i)
  cbind(lorenz_points(counts[cls_cod == ex$cod_ibge[i], ], mids),
        municipio = sprintf("%s-%s (Gini %s)", ex$municipio[i], ex$uf[i], f(ex$gini[i], 2)))))
ggplot(lor, aes(P, L, colour = municipio)) + geom_abline(linetype = 2, colour = "grey50") +
  geom_line() + geom_point(size = 1) + coord_equal() + theme(legend.position = "right") +
  labs(x = "Fração acumulada das pessoas (das mais pobres às mais ricas)", y = "Fração acumulada da renda", colour = NULL)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/lorenz-example-1.png){width=768}
:::
:::


O gráfico mostra a curva de Lorenz de três municípios de 20 mil habitantes ou mais: o de menor Gini calculado, o mais próximo da mediana e o de maior. Cada ponto é o limite de uma classe; a linha tracejada é a igualdade perfeita.

Cada classe recebe a renda do seu ponto médio, em salários mínimos ("sem rendimento" recebe zero). A classe aberta, acima de 20 SM, não tem ponto médio: ela recebe 50 SM, o valor com que o mesmo cálculo reproduz o Gini oficial do Brasil (0,542; o calculado dá 0,542). O cálculo está em `scripts/01_preparar_dados.R`.

Usar o ponto médio no lugar da renda média de cada classe tem dois custos. Com as médias das classes, ligar os pontos por retas daria um limite inferior do Gini [@gastwirth1972]; com pontos médios, é só aproximadamente um limite inferior. E o valor da classe aberta foi ajustado ao Brasil como um todo, e não a cada UF. Os dois são avaliados na validação abaixo.

### Validação do Gini calculado

Para ter uma ideia da qualidade da nossa estimativa, comparamos o Gini que o nosso cálculo dá com o que o IBGE publica. Como o Gini oficial de 2022 só existe por UF, somamos as classes de renda dos municípios de cada UF e aplicamos o mesmo cálculo.


::: {.cell}

```{.r .cell-code}
val_gini <- read.csv(val_gini_csv)                                   # written by scripts/01_preparar_dados.R
uf_sigla <- unique(data.frame(uf_cod = as.numeric(substr(d_all$cod_ibge, 1, 2)), uf = d_all$uf))
v <- val_gini[val_gini$nivel == "Unidade da Federação", ]
val_uf <- merge(data.frame(uf_cod = v$codigo, oficial = v$gini_oficial, calculado = v$gini_calculado), uf_sigla)
cnt_uf <- rowsum(counts, as.numeric(substr(income_classes$cod_ibge, 1, 2)))
val_uf$dif <- val_uf$calculado - val_uf$oficial
val_r <- cor(val_uf$calculado, val_uf$oficial)
worst <- val_uf[order(-abs(val_uf$dif)), ][1:3, ]
ggplot(val_uf, aes(oficial, calculado, label = uf)) + geom_abline(linetype = 2, colour = "grey50") + geom_text(size = 3) +
  labs(x = "Gini oficial 2022 da UF (SIDRA 10301)", y = "Gini calculado (SIDRA 10300)")
```

::: {.cell-output-display}
![](relatorio_files/figure-html/gini-validation-uf-1.png){width=768}
:::
:::


O resultado é aceitável. Nas 27 UFs, a correlação entre o nosso Gini e o oficial é de 0,995, e a diferença média, em módulo, é de 0,003. As maiores diferenças estão em TO (+0,008), CE (+0,007), AL (+0,006). Com a classe aberta em 50 SM, o cálculo fica ora um pouco acima, ora um pouco abaixo do oficial (abaixo em 7 das 27 UFs). A comparação é feita por UF, então não mede o erro amostral do Censo nos municípios pequenos.

# Análise exploratória

# Taxa de homicídios por tamanho da população

Vejamos como a taxa de homicídios se distribui segundo a população do município, com todos os 5.570 municípios:


::: {.cell}

```{.r .cell-code}
br <- c(0, 5e3, 1e4, 15e3, 2e4, 3e4, 5e4, 1e5, Inf)
d_all$classe <- cut(d_all$pop, br, right = FALSE,
                    labels = c("<5 mil", "5–10 mil", "10–15 mil", "15–20 mil", "20–30 mil", "30–50 mil", "50–100 mil", "100 mil+"))
rot_x <- theme(axis.text.x = element_text(angle = 45, hjust = 1))
plot_size <- function(s) {
  p_fun <- ggplot(s, aes(pop, taxa)) + geom_point(alpha = .2, size = .5) +
    scale_x_log10(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
    labs(x = "População (escala log)", y = "Taxa (/100 mil/ano)", title = "Taxa contra população")
  p_box <- ggplot(s, aes(classe, taxa)) + geom_boxplot(outlier.size = .5) + coord_cartesian(ylim = c(0, 150)) +
    labs(x = NULL, y = "Taxa (/100 mil/ano)", title = "Taxa por porte") + rot_x
  p_hom <- ggplot(s, aes(classe, hom)) + geom_boxplot(outlier.size = .5) +
    scale_y_continuous(trans = "log1p", breaks = c(0, 3, 10, 30, 100, 1000)) +
    labs(x = "População", y = "Homicídios em 3 anos", title = "Contagem por porte") + rot_x
  list(p_fun, p_box, p_hom)
}
for (p in plot_size(d_all)) print(p)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/scope-explore-1.png){width=768}
:::

::: {.cell-output-display}
![](relatorio_files/figure-html/scope-explore-2.png){width=768}
:::

::: {.cell-output-display}
![](relatorio_files/figure-html/scope-explore-3.png){width=768}
:::

```{.r .cell-code}
med_class <- tapply(d_all$taxa, d_all$classe, median)
zeros_class <- tapply(d_all$taxa == 0, d_all$classe, sum)
hom_class <- tapply(d_all$hom, d_all$classe, median)
```
:::


- **Zeros e mediana baixa.** 488 municípios com menos de 5 mil habitantes não tiveram nenhum homicídio em três anos. Taxa zero não diz se o lugar é seguro ou se só teve sorte, e esses zeros puxam a mediana para baixo: 9,6 por 100 mil na menor classe, contra 20,2 a 20,7 a partir de 20 mil habitantes.

A taxa dos municípios pequenos, portanto, mede mal a violência. Para escolher o corte, usamos o sinal mais claro desse problema: as taxas zero. O escopo começa no menor porte a partir do qual nenhum município tem taxa zero. Conferimos também se, a partir dali, o município típico tem homicídios suficientes e se a mediana da taxa já não muda com o porte. A regra é escolha nossa.


::: {.cell}

```{.r .cell-code}
size_tab <- do.call(rbind, lapply(split(d_all, d_all$classe), function(s) data.frame(
  municipios = nrow(s), pct_pop = 100 * sum(s$pop) / sum(d_all$pop), taxas_zero = sum(s$taxa == 0),
  hom_3anos_mediana = median(s$hom), taxa_mediana = median(s$taxa))))
size_tab$sem_zeros <- size_tab$taxas_zero == 0
first_ok <- min(which(rev(cumprod(rev(size_tab$sem_zeros))) == 1))   # first class from which no larger class has a zero rate
chosen <- br[first_ok]
ok_class <- rownames(size_tab)[first_ok]
knitr::kable(cbind(porte = rownames(size_tab), size_tab), digits = 2, row.names = FALSE)
```

::: {.cell-output-display}


|porte      | municipios| pct_pop| taxas_zero| hom_3anos_mediana| taxa_mediana|sem_zeros |
|:----------|----------:|-------:|----------:|-----------------:|------------:|:---------|
|<5 mil     |       1324|    2.19|        488|                 1|         9.57|FALSE     |
|5–10 mil   |       1170|    4.10|        129|                 3|        13.58|FALSE     |
|10–15 mil  |        873|    5.24|         36|                 6|        16.43|FALSE     |
|15–20 mil  |        493|    4.23|          2|                10|        19.27|FALSE     |
|20–30 mil  |        576|    6.91|          0|                15|        20.63|TRUE      |
|30–50 mil  |        477|    8.83|          0|                23|        20.23|TRUE      |
|50–100 mil |        338|   11.56|          0|                43|        20.37|TRUE      |
|100 mil+   |        319|   56.94|          0|               121|        20.75|TRUE      |


:::

```{.r .cell-code}
d <- d_all[d_all$pop >= chosen, ]
d <- d[order(d$cod_ibge), ]
d$classe <- droplevels(d$classe)
```
:::


Pela regra, o escopo começa em **20.000 habitantes**: na classe de 20–30 mil, nenhum município tem taxa zero, contra 2 na classe logo abaixo. Nela, o município típico já tem 15 homicídios em três anos, e a mediana da taxa (20,6) é praticamente a mesma das classes maiores. O escopo fica com 1.710 municípios e 84% da população.

Repetindo os gráficos só com os municípios do escopo, para ver se as distorções saíram:


::: {.cell}

```{.r .cell-code}
for (p in plot_size(d)) print(p)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/scope-check-1.png){width=768}
:::

::: {.cell-output-display}
![](relatorio_files/figure-html/scope-check-2.png){width=768}
:::

::: {.cell-output-display}
![](relatorio_files/figure-html/scope-check-3.png){width=768}
:::

```{.r .cell-code}
med_scope <- tapply(d$taxa, d$classe, median)
```
:::


No escopo, não há taxa zero. As curvas ainda aparecem no canto inferior esquerdo do gráfico de pontos, mas os degraus ficaram pequenos: num município de 20.000 habitantes, um homicídio a mais soma 1,7 à taxa, contra 6,7 num de 5 mil. A mediana da taxa fica estável entre os portes, de 20,2 a 20,7 por 100 mil. A variação que sobra reflete muito mais a diferença de violência entre os municípios do que o acaso de poucas mortes. Daqui em diante, tudo usa apenas os municípios do escopo.

## Distribuição da taxa de homicídios

Olhamos a forma da distribuição da taxa, para escolher a transformação da resposta, e se a sua variação muda com o porte do município.


::: {.cell}

```{.r .cell-code}
skew <- function(v) { v <- v[!is.na(v)]; mean((v - mean(v))^3) / sd(v)^3 }
p1 <- ggplot(d, aes(taxa)) + geom_histogram(bins = 40) + labs(x = "Taxa (/100 mil/ano)", y = NULL)
p2 <- ggplot(d, aes(ln_taxa)) + geom_histogram(bins = 40) + labs(x = "ln(taxa)", y = NULL)
p1 + p2
```

::: {.cell-output-display}
![](relatorio_files/figure-html/outcome-1.png){width=768}
:::

```{.r .cell-code}
bc <- boxcox(lm(taxa ~ 1, data = d), lambda = seq(-1, 1, 0.01), plotit = FALSE)
bc_lambda <- bc$x[which.max(bc$y)]
bc_ci <- range(bc$x[bc$y > max(bc$y) - qchisq(ci_level, 1) / 2])
d$pop_quart <- cut(d$pop, quantile(d$pop, 0:4 / 4), include.lowest = TRUE, labels = c("Q1", "Q2", "Q3", "Q4"))
sd_by_pop <- tapply(d$ln_taxa, d$pop_quart, sd)
round(c(skew_taxa = skew(d$taxa), skew_ln = skew(d$ln_taxa), lambda = bc_lambda, ci_low = bc_ci[1], ci_high = bc_ci[2]), 2)
```

::: {.cell-output .cell-output-stdout}

```
skew_taxa   skew_ln    lambda    ci_low   ci_high 
     1.36     -0.49      0.23      0.18      0.28 
```


:::

```{.r .cell-code}
round(sd_by_pop, 2)
```

::: {.cell-output .cell-output-stdout}

```
  Q1   Q2   Q3   Q4 
0.86 0.81 0.80 0.77 
```


:::
:::


- **Forma:** a taxa tem cauda longa à direita (assimetria 1,36); em ln, fica quase simétrica (-0,49).
- **Transformação:** o Box-Cox indica $\lambda$ = 0,23 (IC 95%: 0,18 a 0,28), mais perto de uma raiz quarta do que do ln ($\lambda$ = 0). É só um indicativo: a escolha final vem do Box-Cox com as explicativas, no modelo (apostila, 4.7).
- **Variância:** o desvio-padrão de ln(taxa) cai de 0,86 nos municípios menores para 0,77 nos maiores; a variância pode não ser constante.

## Distribuição das explicativas

Fazemos o mesmo com cada explicativa: variáveis muito assimétricas podem pedir transformação antes de entrar no modelo.


::: {.cell}

```{.r .cell-code}
x_vars <- c("log_rend", "gini", "pct_pobres", "desocup", "pct_informal", "pct_urbana", "log_dens", "pct_h1529",
            "freq_15a17", "alfabet", "pct_indet", "pct_presos", "pct_maes_solo", "ln_pib_pc")
long_x <- do.call(rbind, lapply(x_vars, function(v) data.frame(var = v, x = d[[v]])))
ggplot(long_x, aes(x)) + geom_histogram(bins = 30) + facet_wrap(~ var, scales = "free", ncol = 5) + labs(x = NULL, y = NULL)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/predictors-1.png){width=768}
:::

```{.r .cell-code}
skews <- sapply(d[x_vars], skew)
skewed <- names(skews)[abs(skews) > 1]
to_log <- skewed[skews[skewed] > 0]   # right-skewed
skew_log <- sapply(skewed, function(v) if (v %in% to_log) skew(log1p(d[[v]])) else NA)
data.frame(assimetria = round(skews[skewed], 2), assimetria_ln1p = round(skew_log, 2))
```

::: {.cell-output .cell-output-stdout}

```
           assimetria assimetria_ln1p
pct_pobres       1.01           -0.03
desocup          1.37           -0.07
freq_15a17      -1.33              NA
pct_indet        2.56           -0.13
pct_presos       8.37            3.81
```


:::

```{.r .cell-code}
c(sem_presidio = sum(d$pct_presos == 0), amazonia_legal = sum(d$amazonia_legal), fronteira = sum(d$faixa_fronteira),
  rm_ride = sum(d$rm_ride), conc_urb = sum(d$conc_urb))
```

::: {.cell-output .cell-output-stdout}

```
  sem_presidio amazonia_legal      fronteira        rm_ride       conc_urb 
          1008            289            131            576            482 
```


:::
:::


Têm assimetria maior que 1 em módulo: pct_pobres, desocup, freq_15a17, pct_indet, pct_presos. A tabela mostra como a assimetria fica depois de ln(1 + x), a transformação candidata para as assimétricas à direita. `freq_15a17` é assimétrica à esquerda e fica como está. `pct_presos` é zero em 1.008 municípios, sem presídio; por isso entra como uma indicadora "tem presídio" mais ln(1 + %). Entre as indicadoras, o escopo tem 289 municípios da Amazônia Legal, 131 da faixa de fronteira, 576 em região metropolitana ou RIDE e 482 em concentração urbana.

## Correlação entre as explicativas

Explicativas muito correlacionadas entre si deixam os coeficientes instáveis e difíceis de interpretar (apostila, 6.2–6.4). Aqui olhamos as correlações duas a duas e a matriz de dispersão das principais.


::: {.cell}

```{.r .cell-code}
r <- cor(d[x_vars])
r_long <- as.data.frame(as.table(r))
ggplot(r_long, aes(Var1, Var2, fill = Freq)) + geom_tile() + geom_text(aes(label = sub("0\\.", ".", sprintf("%.2f", Freq))), size = 2.3) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b", limits = c(-1, 1), name = "r") +
  labs(x = NULL, y = NULL) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

::: {.cell-output-display}
![](relatorio_files/figure-html/correlation-1.png){width=768}
:::

```{.r .cell-code}
high <- which(abs(r) > 0.7 & upper.tri(r), arr.ind = TRUE)
high_pairs <- data.frame(var1 = rownames(r)[high[, 1]], var2 = colnames(r)[high[, 2]], r = round(r[high], 2))
high_pairs[order(-abs(high_pairs$r)), ]
```

::: {.cell-output .cell-output-stdout}

```
           var1         var2     r
1      log_rend   pct_pobres -0.92
2      log_rend pct_informal -0.87
3    pct_pobres pct_informal  0.85
7      log_rend      alfabet  0.85
9  pct_informal      alfabet -0.83
8    pct_pobres      alfabet -0.80
6  pct_informal   pct_urbana -0.77
5    pct_pobres   pct_urbana -0.75
11     log_rend    ln_pib_pc  0.75
4      log_rend   pct_urbana  0.74
10   pct_urbana      alfabet  0.74
12 pct_informal    ln_pib_pc -0.74
```


:::
:::



::: {.cell}

```{.r .cell-code}
pairs(d[c("log_rend", "gini", "pct_pobres", "pct_urbana", "alfabet", "pct_maes_solo")], pch = ".", col = "grey30")
```

::: {.cell-output-display}
![](relatorio_files/figure-html/scatter-matrix-1.png){width=768}
:::
:::


Pares com correlação acima de 0,7 em módulo: log_rend × pct_pobres (-0,92); log_rend × pct_informal (-0,87); pct_pobres × pct_informal (0,85); log_rend × alfabet (0,85); pct_informal × alfabet (-0,83); pct_pobres × alfabet (-0,80); pct_informal × pct_urbana (-0,77); pct_pobres × pct_urbana (-0,75); log_rend × ln_pib_pc (0,75); log_rend × pct_urbana (0,74); pct_urbana × alfabet (0,74); pct_informal × ln_pib_pc (-0,74). Renda e PIB per capita medem quase a mesma coisa e não entram juntas no modelo.

## Variáveis categóricas

O modelo pode usar quatro variáveis categóricas: a UF, a grande região, a faixa de fronteira e a Amazônia Legal. Olhamos quantos municípios há em cada categoria, como a taxa muda entre elas e se elas variam dentro das UFs, o que define se podem entrar junto com as indicadoras de UF.


::: {.cell}

```{.r .cell-code}
cat_prof <- function(g, labels) { s <- split(d, d[[g]])
  data.frame(nivel = labels, municipios = sapply(s, nrow), taxa_mediana = sapply(s, function(z) median(z$taxa)),
             dp_ln_taxa = sapply(s, function(z) sd(z$ln_taxa))) }
cat_tab <- rbind(cbind(variavel = "Região", cat_prof("regiao", levels(d$regiao))),
                 cbind(variavel = "Amazônia Legal", cat_prof("amazonia_legal", c("não", "sim"))),
                 cbind(variavel = "Faixa de fronteira", cat_prof("faixa_fronteira", c("não", "sim"))))
knitr::kable(cat_tab, digits = 2, row.names = FALSE)
```

::: {.cell-output-display}


|variavel           |nivel | municipios| taxa_mediana| dp_ln_taxa|
|:------------------|:-----|----------:|------------:|----------:|
|Região             |N     |        182|        29.70|       0.64|
|Região             |NE    |        592|        33.78|       0.60|
|Região             |CO    |        124|        24.04|       0.44|
|Região             |SE    |        541|        10.73|       0.76|
|Região             |S     |        271|        14.16|       0.67|
|Amazônia Legal     |não   |       1421|        18.03|       0.82|
|Amazônia Legal     |sim   |        289|        30.13|       0.58|
|Faixa de fronteira |não   |       1579|        20.75|       0.82|
|Faixa de fronteira |sim   |        131|        18.39|       0.68|


:::

```{.r .cell-code}
yn_lab <- function(v) factor(ifelse(v == 1, "sim", "não"), levels = c("não", "sim"))
long_cat <- rbind(data.frame(var = "Região", nivel = as.character(d$regiao), ln_taxa = d$ln_taxa),
                  data.frame(var = "Amazônia Legal", nivel = as.character(yn_lab(d$amazonia_legal)), ln_taxa = d$ln_taxa),
                  data.frame(var = "Faixa de fronteira", nivel = as.character(yn_lab(d$faixa_fronteira)), ln_taxa = d$ln_taxa))
long_cat$nivel <- factor(long_cat$nivel, levels = c(levels(d$regiao), "não", "sim"))
long_cat$var <- factor(long_cat$var, levels = c("Região", "Amazônia Legal", "Faixa de fronteira"))
ggplot(long_cat, aes(nivel, ln_taxa)) + geom_boxplot(outlier.size = .4) +
  facet_wrap(~ var, scales = "free_x") + labs(x = NULL, y = "ln(taxa)")
```

::: {.cell-output-display}
![](relatorio_files/figure-html/categorical-1.png){width=768}
:::

```{.r .cell-code}
uf_n_scope <- sort(table(d$uf))
mixed_uf <- function(v) { m <- tapply(d[[v]], d$uf, mean); names(m)[m > 0 & m < 1] }
amaz_mixed <- mixed_uf("amazonia_legal"); front_mixed <- mixed_uf("faixa_fronteira")
amaz_in_n <- 100 * mean(d$regiao[d$amazonia_legal == 1] == "N")
list(municipios_por_uf = uf_n_scope, amazonia_varia_dentro_de = amaz_mixed, fronteira_varia_dentro_de = front_mixed)
```

::: {.cell-output .cell-output-stdout}

```
$municipios_por_uf

 DF  RR  AP  AC  TO  RO  SE  PI  RN  MS  PB  AM  ES  MT  AL  GO  RJ  SC  MA  PR 
  1   4   5   7   9  17  24  26  27  32  32  36  36  36  39  55  66  72  88  92 
 CE  PE  PA  RS  BA  MG  SP 
 97  99 104 107 160 187 252 

$amazonia_varia_dentro_de
[1] "MA"

$fronteira_varia_dentro_de
[1] "AM" "AP" "MS" "MT" "PA" "PR" "RO" "RS" "SC"
```


:::
:::


Entre as regiões, a mediana da taxa vai de 10,7 a 33,8 por 100 mil, uma diferença que o modelo precisa absorver com indicadoras de região (4 parâmetros) ou de UF (26). As de UF captam também o que é próprio de cada estado, como polícia e justiça, mas 5 UFs têm menos de 10 municípios no escopo (DF, RR, AP, AC, TO). A Amazônia Legal (289 municípios, 63% no Norte) só varia dentro de MA quando há indicadoras de UF, então combina melhor com as de região; a faixa de fronteira (131 municípios) varia dentro de 9 UFs e cabe nos dois casos.

**Decisão:** no modelo, as variáveis categóricas serão as indicadoras de região, a Amazônia Legal e a faixa de fronteira, e não as indicadoras de UF. Assim, o modelo gasta 6 parâmetros em vez de 26, não depende das UFs com poucos municípios e consegue estimar o efeito da Amazônia Legal. O custo é que as diferenças entre estados de uma mesma região, como polícia e justiça, ficam fora do modelo.

## Recorte da análise: região, UF e porte

As seções anteriores juntam regiões muito diferentes. Esta seção ajuda a decidir se a análise deve ser nacional ou limitada a uma região, a um porte ou a uma UF.

### Níveis por região

Depois, o nível da taxa, da renda e do Gini em cada região, para ver o quanto as regiões se sobrepõem.


::: {.cell}

```{.r .cell-code}
lv <- rbind(data.frame(var = "ln(taxa)", regiao = d$regiao, x = d$ln_taxa),
            data.frame(var = "ln renda per capita", regiao = d$regiao, x = d$log_rend),
            data.frame(var = "Gini calculado", regiao = d$regiao, x = d$gini))
ggplot(lv, aes(regiao, x, fill = regiao)) + geom_boxplot(outlier.size = .4, show.legend = FALSE) +
  facet_wrap(~ var, scales = "free_y") + labs(x = NULL, y = NULL)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/recorte-niveis-1.png){width=768}
:::

```{.r .cell-code}
reg_q <- t(sapply(split(d, d$regiao), function(s) c(municipios = nrow(s), taxa_mediana = median(s$taxa),
  renda_p10 = unname(quantile(s$rend_pc_media, q_lo)), renda_p90 = unname(quantile(s$rend_pc_media, q_hi)),
  gini_p10 = unname(quantile(s$gini, q_lo)), gini_p90 = unname(quantile(s$gini, q_hi)))))
round(reg_q, 2)
```

::: {.cell-output .cell-output-stdout}

```
   municipios taxa_mediana renda_p10 renda_p90 gini_p10 gini_p90
N         182        29.70    508.38   1370.93     0.45     0.54
NE        592        33.78    621.20   1072.76     0.43     0.51
CO        124        24.04   1168.30   2049.51     0.43     0.51
SE        541        10.73   1122.43   1983.62     0.40     0.49
S         271        14.16   1477.03   2303.59     0.38     0.48
```


:::
:::


A mediana da taxa vai de 10,7 (SE) a 33,8 (NE) por 100 mil. A renda dos municípios entre os percentis 10 e 90 vai de R\$ 621 a 1.073 no Nordeste e de R\$ 1.477 a 2.304 no Sul. Quando as faixas de renda de duas regiões quase não se sobrepõem, um modelo nacional estima o efeito da renda comparando regiões, e esse efeito se mistura com tudo o mais que difere entre elas.

### Relação com a renda por grupo

Para ver se a relação da taxa com a renda é a mesma em todo o país, desenhamos a dispersão de ln(taxa) contra a renda com uma reta de regressão simples para cada grupo: região, Amazônia Legal e faixa de fronteira. Retas com inclinações diferentes indicam que o efeito da renda pode depender do grupo, o que no modelo vira uma interação entre o grupo e a renda (apostila, cap. 7) ou modelos separados.


::: {.cell}

```{.r .cell-code}
plot_grp <- function(g, title, cores) {
  ggplot(data.frame(x = d$log_rend, y = d$ln_taxa, grupo = g), aes(x, y, colour = grupo)) +
    geom_point(alpha = .15, size = .6) + geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 1.2) +
    scale_colour_manual(values = cores) + labs(x = "ln renda per capita média", y = "ln(taxa)", colour = NULL, title = title) +
    theme(legend.position = "bottom")
}
cores_reg <- c(N = "#1b9e77", NE = "#d95f02", CO = "#7570b3", SE = "#e7298a", S = "#66a61e")
cores_yn <- c("não" = "grey60", sim = "#d95f02")
plot_grp(d$regiao, "Por região", cores_reg)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/recorte-relacoes-1.png){width=768}
:::

```{.r .cell-code}
plot_grp(yn_lab(d$amazonia_legal), "Amazônia Legal", cores_yn)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/recorte-relacoes-2.png){width=768}
:::

```{.r .cell-code}
plot_grp(yn_lab(d$faixa_fronteira), "Faixa de fronteira", cores_yn)
```

::: {.cell-output-display}
![](relatorio_files/figure-html/recorte-relacoes-3.png){width=768}
:::

```{.r .cell-code}
slope <- function(g) sapply(split(d, g), function(s) unname(coef(lm(ln_taxa ~ log_rend, data = s))[2]))
slope_reg <- slope(d$regiao); slope_amz <- slope(yn_lab(d$amazonia_legal)); slope_fro <- slope(yn_lab(d$faixa_fronteira))
round(c(slope_reg, `Amazônia: não` = slope_amz[["não"]], `Amazônia: sim` = slope_amz[["sim"]],
        `Fronteira: não` = slope_fro[["não"]], `Fronteira: sim` = slope_fro[["sim"]]), 2)
```

::: {.cell-output .cell-output-stdout}

```
             N             NE             CO             SE              S 
          0.64           0.50          -0.26          -1.07          -0.98 
 Amazônia: não  Amazônia: sim Fronteira: não Fronteira: sim 
         -1.01           0.38          -0.88          -0.30 
```


:::

```{.r .cell-code}
reg_up <- names(slope_reg)[slope_reg > 0]; reg_down <- names(slope_reg)[slope_reg < 0]
up_down <- function(b) if (b > 0) "sobe" else "desce"
```
:::


Os números abaixo dos gráficos são as inclinações das retas. A reta sobe em N, NE e desce em CO, SE, S: no Norte e no Nordeste, os municípios de renda maior são mais violentos; no Sudeste e no Sul, é o contrário. Na Amazônia Legal, a reta sobe, e fora dela desce; na faixa de fronteira, desce, e fora dela desce. São retas sem controles: a diferença entre os grupos pode vir de outras variáveis, e só o modelo pode dizer se ela continua.

### Região metropolitana

Há duas formas de marcar municípios metropolitanos, e comparamos as duas.


::: {.cell}

```{.r .cell-code}
prof <- function(s) c(municipios = nrow(s), pop_mediana = median(s$pop), taxa_mediana = median(s$taxa))
metro_tab <- rbind(`RM/RIDE: sim` = prof(d[d$rm_ride == 1, ]), `RM/RIDE: não` = prof(d[d$rm_ride == 0, ]),
                   `Conc. urbana: sim` = prof(d[d$conc_urb == 1, ]), `Conc. urbana: não` = prof(d[d$conc_urb == 0, ]))
round(metro_tab, 1)
```

::: {.cell-output .cell-output-stdout}

```
                  municipios pop_mediana taxa_mediana
RM/RIDE: sim             576     62178.0         17.4
RM/RIDE: não            1134     33767.0         22.3
Conc. urbana: sim        482    124494.5         18.1
Conc. urbana: não       1228     32165.0         21.4
```


:::

```{.r .cell-code}
table(porte = d$porte, conc_urb = d$conc_urb)
```

::: {.cell-output .cell-output-stdout}

```
            conc_urb
porte          0   1
  <10 mil      0   0
  10–20 mil    0   0
  20–50 mil  946 107
  50–100 mil 260  78
  100 mil+    22 297
```


:::

```{.r .cell-code}
c(ambas = sum(d$rm_ride == 1 & d$conc_urb == 1), so_rm = sum(d$rm_ride == 1 & d$conc_urb == 0), so_conc = sum(d$rm_ride == 0 & d$conc_urb == 1))
```

::: {.cell-output .cell-output-stdout}

```
  ambas   so_rm so_conc 
    346     230     136 
```


:::
:::


A **RM/RIDE** é uma definição legal, criada por lei estadual ou federal, e inclui regiões pequenas e pouco urbanas. A **concentração urbana** é uma definição técnica do IBGE: municípios integrados que, juntos, passam de 100 mil habitantes. No escopo, 346 municípios estão nas duas, 230 só em RM/RIDE e 136 só em concentração urbana. A tabela por porte mostra que a concentração urbana se confunde com o tamanho do município.

## Taxa de homicídios × renda e Gini (H1 e H2)

Aqui olhamos, sem controles e sem teste, a forma das relações que as hipóteses descrevem. As curvas vermelhas são suavizações (loess), que seguem os dados sem impor uma forma.

**H1 — forma da renda.** Se a H1 estiver certa, a taxa sobe com a renda nos municípios mais pobres e cai nos mais ricos, formando um U invertido.


::: {.cell}

```{.r .cell-code}
ggplot(d, aes(log_rend, ln_taxa)) + geom_point(alpha = .25, size = .7) +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE, colour = "red") +
  labs(x = "ln renda per capita média", y = "ln(taxa)")
```

::: {.cell-output-display}
![](relatorio_files/figure-html/h1-shape-1.png){width=768}
:::
:::


A curva mostra só a forma bruta da relação; o efeito da renda com os controles fica para o modelo.

**H2 — desigualdade × renda.** Dividimos os municípios em três grupos de renda (terços) e vemos se a relação entre o Gini e a taxa muda de um grupo para outro. Se muda, o efeito da desigualdade depende da renda.


::: {.cell}

```{.r .cell-code}
d$rend_terc <- cut(d$log_rend, quantile(d$log_rend, 0:3 / 3), include.lowest = TRUE,
                   labels = c("renda baixa", "renda média", "renda alta"))
ggplot(d, aes(gini, ln_taxa)) + geom_point(alpha = .25, size = .7) + geom_smooth(method = "loess", formula = y ~ x, se = FALSE, colour = "red") +
  facet_wrap(~ rend_terc) + labs(x = "Gini calculado", y = "ln(taxa)")
```

::: {.cell-output-display}
![](relatorio_files/figure-html/h2-effect-1.png){width=768}
:::

```{.r .cell-code}
d$gini_w <- uf_centre(d$gini, d$uf); d$ln_taxa_w <- uf_centre(d$ln_taxa, d$uf)
cor_terc <- t(sapply(split(d, d$rend_terc), function(s) c(municipios = nrow(s), r_bruta = cor(s$gini, s$ln_taxa),
                                                         r_dentro_uf = cor(s$gini_w, s$ln_taxa_w), dp_gini = sd(s$gini))))
round(cor_terc, 3)
```

::: {.cell-output .cell-output-stdout}

```
            municipios r_bruta r_dentro_uf dp_gini
renda baixa        570  -0.132      -0.148   0.036
renda média        570   0.367       0.054   0.041
renda alta         570   0.292       0.118   0.050
```


:::

```{.r .cell-code}
terc_reg <- round(100 * prop.table(table(d$rend_terc, d$regiao), 1))
terc_reg
```

::: {.cell-output .cell-output-stdout}

```
             
               N NE CO SE  S
  renda baixa 21 77  0  2  0
  renda média 10 25 11 48  8
  renda alta   1  3 11 45 40
```


:::

```{.r .cell-code}
h2_gap <- diff(range(cor_terc[, "r_dentro_uf"]))
```
:::


A correlação de ln(taxa) com o Gini em cada terço é renda baixa: -0,13; renda média: 0,37; renda alta: 0,29. Há um problema para ler isso: os terços de renda quase coincidem com as regiões. 98% do terço de renda baixa está no Norte ou no Nordeste, e 85% do de renda alta, no Sudeste ou no Sul. Uma diferença entre os terços pode ser, então, uma diferença entre regiões.

Para reduzir isso, centramos o Gini e a taxa na média de cada UF, o que tira a diferença de nível entre os estados. As correlações ficam em -0,15; 0,05; 0,12, e a maior diferença entre elas é de 0,27, acima do limite de 0,2 que usamos para chamar uma diferença de relevante (escolha nossa). Mesmo assim, a exploração não separa uma interação Gini × renda de uma relação do Gini que muda entre regiões; só o modelo pode comparar as duas. O Gini varia o suficiente dentro de cada terço para isso: o desvio-padrão vai de 0,036 a 0,050.

Por fim, a taxa contra cada controle, para ver se alguma relação é curva e pede transformação (apostila, 4.7).


::: {.cell}

```{.r .cell-code}
ctrl <- setdiff(x_vars, c("log_rend", "gini", "ln_pib_pc"))
long <- do.call(rbind, lapply(ctrl, function(v) data.frame(var = v, x = d[[v]], ln_taxa = d$ln_taxa)))
ggplot(long, aes(x, ln_taxa)) + geom_point(alpha = .15, size = .5) +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE, colour = "red") +
  facet_wrap(~ var, scales = "free_x", ncol = 4) + labs(x = NULL, y = "ln(taxa)")
```

::: {.cell-output-display}
![](relatorio_files/figure-html/controls-scatter-1.png){width=768}
:::
:::


## Observações

A tabela reúne o que a exploração sugere para o modelo. São hipóteses e decisões pendentes, não conclusões.

| observação | chunk | implicação para a modelagem | status |
|----|----|----|----|
| Abaixo de 20.000 habitantes há taxas zero e poucos homicídios por município | `scope-explore`, `scope-rule` | Escopo de 20.000 habitantes ou mais; checar a variância dos resíduos por porte | hipótese |
| ln(taxa) é quase simétrica, mas o Box-Cox marginal dá $\lambda$ = 0,23 (IC 0,18–0,28) | `outcome` | Refazer o Box-Cox com as explicativas antes de fixar ln | hipótese |
| O desvio-padrão de ln(taxa) vai de 0,86 a 0,77 do menor para o maior quartil de população | `outcome` | Checar variância constante nos resíduos mesmo assim (Breusch-Pagan, apostila 4.8) | hipótese |
| pct_pobres, desocup, pct_indet, pct_presos são assimétricas à direita | `predictors` | Avaliar ln(1 + x); presos como indicadora + ln(1 + %) | hipótese |
| Renda e pobreza quase colineares (r = -0,92) | `correlation` | Grupo decide como tratar (apostila, 6.5) | decisão pendente |
| Indicadoras de UF custam 26 parâmetros, 5 UFs têm menos de 10 municípios e, com elas, a Amazônia Legal só varia dentro de MA | `categorical` | Usar indicadoras de região, Amazônia Legal e faixa de fronteira no lugar das de UF | decidido |
| O Gini calculado recupera o oficial por UF (r = 0,995) | `gini-validation-uf` | Usar como medida principal; Gini 2010 como alternativa | hipótese |
| Dentro das UFs, a correlação do Gini varia 0,27 entre os terços de renda (limite: 0,2); os terços acompanham as regiões | `h2-effect` | Interação Gini × renda é candidata (H2), mas se confunde com Gini × região; comparar as duas no modelo | hipótese |
| A mediana da taxa vai de 10,7 a 33,8 entre regiões, e as faixas de renda pouco se sobrepõem | `recorte-niveis` | Recorte ou indicadoras de região/UF | decisão pendente |
| A reta de ln(taxa) contra a renda sobe em N, NE e desce em CO, SE, S | `recorte-relacoes` | Interação região × renda ou modelos por região (apostila, cap. 7) | decisão pendente |
| Concentração urbana se confunde com o porte | `metro` | Escolher entre RM/RIDE e concentração urbana; checar VIF com porte | decisão pendente |

# Informações da sessão {.unnumbered}


::: {.cell}

```{.r .cell-code}
sessionInfo()
```

::: {.cell-output .cell-output-stdout}

```
R version 4.6.1 (2026-06-24)
Platform: aarch64-apple-darwin23
Running under: macOS Tahoe 26.6.2

Matrix products: default
BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1

locale:
[1] C.UTF-8/UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8

time zone: America/Sao_Paulo
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] sf_1.1-3        MASS_7.3-65     patchwork_1.3.2 ggplot2_4.0.3  

loaded via a namespace (and not attached):
 [1] Matrix_1.7-5       gtable_0.3.6       jsonlite_2.0.0     dplyr_1.2.1       
 [5] compiler_4.6.1     Rcpp_1.1.2         tidyselect_1.2.1   splines_4.6.1     
 [9] scales_1.4.0       yaml_2.3.12        fastmap_1.2.0      lattice_0.22-9    
[13] R6_2.6.1           labeling_0.4.3     generics_0.1.4     classInt_0.4-11   
[17] knitr_1.51         tibble_3.3.1       units_1.0-1        DBI_1.3.0         
[21] pillar_1.11.1      RColorBrewer_1.1-3 rlang_1.3.0        xfun_0.60         
[25] S7_0.2.2           otel_0.2.0         cli_3.6.6          mgcv_1.9-4        
[29] withr_3.0.3        magrittr_2.0.5     class_7.3-23       digest_0.6.39     
[33] grid_4.6.1         nlme_3.1-169       lifecycle_1.0.5    vctrs_0.7.3       
[37] KernSmooth_2.23-26 proxy_0.4-29       evaluate_1.0.5     glue_1.8.1        
[41] farver_2.1.2       e1071_1.7-17       rmarkdown_2.31     tools_4.6.1       
[45] pkgconfig_2.0.3    htmltools_0.5.9   
```


:::
:::

