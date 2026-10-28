# =============================================================================
# Fatores associados aos homicídios nos municípios brasileiros
# Parte 1 - Análise exploratória
#
# Entrada: dados/base_analitica.csv (1 linha por município) e dados/malha_mun.geojson
# Saída:   resultados/eda/ (figuras e tabelas)
# Rodar com a pasta entrega/ como diretório de trabalho.
#
# Escopo: a análise é feita nos municípios com 20 mil habitantes ou mais (o mesmo do modelo).
# Só a definição do escopo e o mapa usam todos os 5.570 municípios.
# =============================================================================

rm(list = ls())

library(ggplot2)
library(dplyr)
library(tidyr)
library(GGally)
library(sf)

set.seed(16)
dir.create("resultados/eda", recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Leitura
# -----------------------------------------------------------------------------
br <- read.csv("dados/base_analitica.csv")
str(br)

POP_MIN <- 20000                                   # escopo: municípios com 20 mil hab. ou mais
br$escopo <- br$pop >= POP_MIN
taxa_br <- sum(br$hom) / sum(br$exposure) * 1e5    # taxa nacional (todos os municípios)

# Paleta igual à dos slides: azul do ODS 16, vermelho de destaque e azul-claro de preenchimento
AZUL <- "#00689D"; VERMELHO <- "#C8343B"; CINZA <- "#7A869A"; FUNDO <- "#FFFFFF"; CLARO <- "#D6E6F2"; MARINHO <- "#13294B"
th <- theme_minimal(base_size = 12) +
  theme(plot.background = element_rect(fill = FUNDO, colour = NA), panel.grid.minor = element_blank())
milhar <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
assimetria <- function(x) mean((x - mean(x))^3) / sd(x)^3

# -----------------------------------------------------------------------------
# 1. Definição do escopo: confiabilidade da taxa por porte do município (todos os municípios)
#    oscilacao = 1 / raiz(nº esperado de homicídios em 3 anos): variação só pelo acaso
#    cor_2024  = correlação entre a taxa de 2021-23 e a de 2024 (estabilidade)
# -----------------------------------------------------------------------------
br$porte <- cut(br$pop, c(0, 5e3, 1e4, 2e4, 5e4, 1e5, Inf), right = FALSE,
                labels = c("< 5 mil", "5–10 mil", "10–20 mil", "20–50 mil", "50–100 mil", ">= 100 mil"))
porte <- br %>% group_by(porte) %>%
  summarise(municipios = n(), pct_pop = 100 * sum(pop) / sum(br$pop), hom_mediana_3anos = median(hom),
            pct_zero = 100 * mean(hom == 0), oscilacao = 100 / sqrt(median(exposure) * taxa_br / 1e5),
            cor_2024 = cor(taxa, taxa_24), .groups = "drop")
write.csv(porte, "resultados/eda/confiabilidade_porte.csv", row.names = FALSE)

# Taxa x população: municípios pequenos têm taxas muito mais dispersas
p <- ggplot(br, aes(pop, taxa)) + geom_point(size = .4, alpha = .25, colour = AZUL) +
  geom_vline(xintercept = POP_MIN, colour = VERMELHO, linetype = 2) +
  scale_x_log10(labels = milhar) + coord_cartesian(ylim = c(0, 150)) +
  labs(x = "População (escala log)", y = "Taxa de homicídios (/100 mil)") + th
ggsave("resultados/eda/e0_taxa_pop.png", p, width = 4.8, height = 3.0, dpi = 250)

# -----------------------------------------------------------------------------
# 2. Mapa: municípios do escopo coloridos pela taxa; os demais em cinza
# -----------------------------------------------------------------------------
g <- st_read("dados/malha_mun.geojson", quiet = TRUE)
g$cod_ibge <- as.integer(g$codarea)
gd <- inner_join(g, br, by = "cod_ibge")
gd$classe <- cut(gd$taxa, c(-Inf, 10, 20, 30, 45, 60, Inf), labels = c("até 10", "10–20", "20–30", "30–45", "45–60", "60+"))
gd$classe <- factor(ifelse(gd$escopo, as.character(gd$classe), "fora do escopo"),
                    levels = c(levels(gd$classe), "fora do escopo"))
uf <- gd %>% mutate(uf = substr(cod_ibge, 1, 2)) %>% group_by(uf) %>% summarise()
p <- ggplot(gd) +
  geom_sf(aes(fill = classe), colour = NA) +
  geom_sf(data = uf, fill = NA, colour = "white", linewidth = .25) +
  scale_fill_manual(values = c("#D6E6F2", "#9EC3DB", "#5E9CC2", AZUL, "#1F4A7A", MARINHO, "#E9EBEE"),
                    name = "Homicídios\npor 100 mil/ano") +
  theme_void(base_size = 10) +
  theme(plot.background = element_rect(fill = FUNDO, colour = NA), legend.position = c(.15, .25))
ggsave("resultados/eda/e2_mapa_taxa.png", p, width = 4.2, height = 4.2, dpi = 250)

# -----------------------------------------------------------------------------
# A partir daqui: só os municípios do escopo
# -----------------------------------------------------------------------------
d <- br[br$escopo, ]
d$regiao <- factor(d$regiao, levels = c("N", "NE", "CO", "SE", "S"),
                   labels = c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul"))
d$ln_taxa <- log(d$taxa)

summary(d[, c("taxa", "rend_pc_media", "desig", "pct_pobres", "desocup", "alfabet", "pct_urbana",
              "dens", "pct_negra", "pct_h1529", "pct_indet", "regiao", "amazonia_legal", "faixa_fronteira")])

rot <- c(taxa = "Taxa de homicídios (/100 mil)", rend_pc_media = "Renda per capita (R$)",
         desig = "Desigualdade (média/mediana)", pct_pobres = "% pobres (14+)",
         desocup = "Desocupação (%)", alfabet = "Alfabetização (%)", pct_urbana = "% urbana",
         dens = "Densidade (hab/km²)", pct_negra = "% preta ou parda", pct_h1529 = "% homens 15–29",
         pct_indet = "% intenção indeterminada", pop = "População")

# -----------------------------------------------------------------------------
# 3. Tabelas-resumo: numéricas (média, quartis, assimetria) e categóricas (frequências)
# -----------------------------------------------------------------------------
desc <- d %>% select(all_of(names(rot))) %>%
  pivot_longer(everything()) %>% group_by(name) %>%
  summarise(media = mean(value), dp = sd(value), min = min(value), q1 = quantile(value, .25),
            mediana = median(value), q3 = quantile(value, .75), max = max(value),
            assimetria = assimetria(value), .groups = "drop") %>%
  mutate(var = rot[name]) %>% arrange(match(name, names(rot)))
write.csv(desc, "resultados/eda/descritiva.csv", row.names = FALSE)

freq <- bind_rows(
  d %>% count(nivel = regiao) %>% mutate(variavel = "Região"),
  d %>% count(nivel = as.character(amazonia_legal)) %>% mutate(variavel = "Amazônia Legal (1 = sim)"),
  d %>% count(nivel = as.character(faixa_fronteira)) %>% mutate(variavel = "Faixa de fronteira (1 = sim)")) %>%
  mutate(pct = 100 * n / nrow(d)) %>% select(variavel, nivel, n, pct)
write.csv(freq, "resultados/eda/frequencias.csv", row.names = FALSE)

# -----------------------------------------------------------------------------
# E1. Distribuição da resposta: taxa x ln(taxa) (avalia a assimetria)
# -----------------------------------------------------------------------------
e1 <- bind_rows(data.frame(escala = "Taxa (Y)", v = d$taxa),
                data.frame(escala = "ln Taxa (ln Y)", v = d$ln_taxa))
e1$escala <- factor(e1$escala, levels = c("Taxa (Y)", "ln Taxa (ln Y)"))
p <- ggplot(e1, aes(v)) +
  geom_histogram(bins = 40, fill = AZUL, colour = FUNDO, linewidth = .2) +
  facet_wrap(~escala, scales = "free") +
  labs(x = NULL, y = "Nº de municípios") + th
ggsave("resultados/eda/e1_hist_resposta.png", p, width = 4.8, height = 3.0, dpi = 250)

# -----------------------------------------------------------------------------
# E3. Boxplots de ln(taxa) por região, Amazônia Legal e fronteira
# -----------------------------------------------------------------------------
e3 <- bind_rows(
  data.frame(grupo = "Região", nivel = as.character(d$regiao), v = d$ln_taxa),
  data.frame(grupo = "Amazônia Legal", nivel = ifelse(d$amazonia_legal == 1, "Sim", "Não"), v = d$ln_taxa),
  data.frame(grupo = "Faixa de fronteira", nivel = ifelse(d$faixa_fronteira == 1, "Sim", "Não"), v = d$ln_taxa))
e3$nivel <- factor(e3$nivel, levels = c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul", "Não", "Sim"))
e3$grupo <- factor(e3$grupo, levels = c("Região", "Amazônia Legal", "Faixa de fronteira"))
p <- ggplot(e3, aes(nivel, v)) +
  geom_boxplot(fill = CLARO, colour = AZUL, outlier.size = .4, outlier.alpha = .3, width = .6) +
  stat_summary(fun = mean, geom = "point", colour = VERMELHO, size = 1.6) +
  facet_grid(~grupo, scales = "free_x", space = "free_x") +
  labs(x = NULL, y = "ln Taxa de homicídios") + th +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("resultados/eda/e3_box_regiao.png", p, width = 6.4, height = 2.7, dpi = 220)

# -----------------------------------------------------------------------------
# E4. Histogramas das explicativas numéricas (assimetria e bimodalidade)
# -----------------------------------------------------------------------------
xs <- c("rend_pc_media", "desig", "pct_pobres", "desocup", "alfabet",
        "pct_urbana", "log_dens", "pct_negra", "pct_h1529", "pct_indet")
rot4 <- c(rot, log_dens = "ln Densidade")
e4 <- d %>% select(all_of(xs)) %>% pivot_longer(everything()) %>%
  mutate(var = factor(rot4[name], levels = rot4[xs]))
p <- ggplot(e4, aes(value)) +
  geom_histogram(bins = 40, fill = AZUL, colour = FUNDO, linewidth = .15) +
  facet_wrap(~var, scales = "free", ncol = 5) + labs(x = NULL, y = NULL) + th +
  theme(axis.text = element_text(size = 6.5), strip.text = element_text(size = 7.5))
ggsave("resultados/eda/e4_hist_explicativas.png", p, width = 7, height = 3.2, dpi = 220)

# -----------------------------------------------------------------------------
# E5. Correlações: de cada explicativa com ln(taxa), e entre as explicativas (matriz completa em CSV)
# -----------------------------------------------------------------------------
cv <- c(log_rend = "ln Renda", desig = "Desigualdade", pct_pobres = "% pobres", desocup = "Desocupação",
        alfabet = "Alfabetização", pct_urbana = "% urbana", log_dens = "ln Densidade",
        pct_negra = "% preta/parda", pct_h1529 = "% homens 15–29", pct_indet = "% indeterminada")
R <- cor(d[, c("ln_taxa", names(cv))])
dimnames(R) <- list(c("ln Taxa", cv), c("ln Taxa", cv))
write.csv(round(R, 3), "resultados/eda/correlacao.csv")

trio <- c("ln Renda", "% pobres", "Alfabetização")         # medem quase o mesmo (multicolinearidade)
e5 <- data.frame(var = cv, r = R["ln Taxa", cv])
e5$grupo <- ifelse(e5$var %in% trio, "renda, pobreza e alfabetização", "demais")
e5$var <- factor(e5$var, levels = e5$var[order(e5$r)])
p <- ggplot(e5, aes(r, var, fill = grupo)) + geom_col(width = .7) +
  geom_vline(xintercept = 0, colour = CINZA) +
  geom_text(aes(label = sub(".", ",", sprintf("%.2f", r), fixed = TRUE), hjust = ifelse(r > 0, -0.15, 1.15)), size = 3.3) +
  scale_fill_manual(values = c(`renda, pobreza e alfabetização` = VERMELHO, demais = AZUL), name = NULL) +
  scale_x_continuous(limits = c(-.6, .6)) +
  labs(x = "Correlação com ln(taxa)", y = NULL) + th + theme(legend.position = "bottom")
ggsave("resultados/eda/e5_correlacao.png", p, width = 4.8, height = 3.4, dpi = 250)

# -----------------------------------------------------------------------------
# E6. Dispersão: ln(taxa) x cada explicativa, com reta de mínimos quadrados
# -----------------------------------------------------------------------------
xs6 <- c(log_rend = "ln Renda per capita", desig = "Desigualdade (média/mediana)", desocup = "Desocupação (%)",
         pct_urbana = "% urbana", log_dens = "ln Densidade", pct_negra = "% preta ou parda",
         pct_h1529 = "% homens 15–29", pct_indet = "% intenção indeterminada")
e6 <- d %>% select(ln_taxa, all_of(names(xs6))) %>% pivot_longer(-ln_taxa) %>%
  mutate(var = factor(xs6[name], levels = xs6))
p <- ggplot(e6, aes(value, ln_taxa)) +
  geom_point(size = .3, alpha = .2, colour = AZUL) +
  geom_smooth(method = "lm", se = FALSE, colour = VERMELHO, linewidth = .7, formula = y ~ x) +
  facet_wrap(~var, scales = "free_x", ncol = 4) + labs(x = NULL, y = "ln Taxa de homicídios") + th +
  theme(strip.text = element_text(size = 7.5), axis.text = element_text(size = 6.5))
ggsave("resultados/eda/e6_dispersao.png", p, width = 7, height = 3.6, dpi = 220)

# -----------------------------------------------------------------------------
# E7. Boxplots de ln(taxa) por décimo de renda: mostra a forma (não linear) da relação
# -----------------------------------------------------------------------------
d$faixa_renda <- cut(d$rend_pc_media, quantile(d$rend_pc_media, seq(0, 1, .1)),
                     include.lowest = TRUE, dig.lab = 5)
med_faixa <- d %>% group_by(faixa_renda) %>% summarise(renda = median(rend_pc_media), med = median(ln_taxa))
p <- ggplot(d, aes(faixa_renda, ln_taxa)) +
  geom_boxplot(fill = CLARO, colour = AZUL, outlier.size = .3, outlier.alpha = .3, width = .6) +
  stat_summary(fun = mean, geom = "point", colour = VERMELHO, size = 1.6) +
  scale_x_discrete(labels = milhar(round(med_faixa$renda))) +
  labs(x = "Renda per capita (R$, mediana de cada décimo)", y = "ln Taxa de homicídios") + th +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("resultados/eda/e7_box_renda.png", p, width = 4.8, height = 3.2, dpi = 250)

# -----------------------------------------------------------------------------
# E8. Matriz de gráficos de dispersão de um subconjunto de variáveis
# -----------------------------------------------------------------------------
sub <- d %>% transmute(`ln Taxa` = ln_taxa, `ln Renda` = log_rend, `% pobres` = pct_pobres,
                       `Alfabetização` = alfabet, `% urbana` = pct_urbana, `% preta/parda` = pct_negra)
p <- ggpairs(sub, lower = list(continuous = wrap("points", size = .25, alpha = .25, colour = AZUL)),
             diag = list(continuous = wrap("densityDiag", fill = CLARO, colour = AZUL))) + th +
  theme(axis.text = element_text(size = 5.5), strip.text = element_text(size = 7.5))
ggsave("resultados/eda/e8_pares.png", p, width = 7, height = 6.2, dpi = 200)

# -----------------------------------------------------------------------------
# Resumo no console
# -----------------------------------------------------------------------------
cat("\nConfiabilidade da taxa por porte (todos os municípios):\n"); print(as.data.frame(porte), digits = 3, row.names = FALSE)
cat(sprintf("\nEscopo: %d municípios (%.1f%% da população) | média da taxa %.1f | mediana %.1f\n",
            nrow(d), 100 * sum(d$pop) / sum(br$pop), mean(d$taxa), median(d$taxa)))
cat("\nCorrelação de cada explicativa com ln(taxa):\n"); print(round(sort(R["ln Taxa", cv]), 2))
