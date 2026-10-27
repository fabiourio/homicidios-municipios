# =============================================================================
# Análise exploratória — homicídios nos municípios brasileiros
# Entradas: dados/tabelas/base_analitica.csv, dados/malha_mun.geojson | Saídas: resultados/eda/
# =============================================================================
# Rodar a partir da raiz do repositório (ou de scripts/)
if (basename(getwd()) == "scripts") setwd("..")
options(width = 200)
FONTE <- tryCatch(if ("Inter" %in% systemfonts::system_fonts()$family) "Inter" else "sans", error = function(e) "sans")
suppressMessages({ library(ggplot2); library(dplyr); library(tidyr); library(sf); library(GGally) })
set.seed(16)
dir.create("resultados/eda", recursive = TRUE, showWarnings = FALSE)

d <- read.csv("dados/tabelas/base_analitica.csv")
d <- d[complete.cases(d[, c("log_rend", "desig", "desocup", "pct_urbana", "log_dens", "pct_negra",
                            "pct_h1529", "pct_pobres", "alfabet", "pct_indet", "pop", "taxa")]), ]
d$regiao <- factor(d$regiao, levels = c("N", "NE", "CO", "SE", "S"),
                   labels = c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul"))
d$raiz_taxa <- sqrt(d$taxa)

INK <- "#0b0b0b"; INK2 <- "#52514e"; MUTED <- "#898781"; GRID <- "#e6e5e0"; SURF <- "#fcfcfb"
BLUE <- "#2a78d6"; RED <- "#e34948"
th <- theme_minimal(base_family = FONTE, base_size = 9) +
  theme(plot.background = element_rect(fill = SURF, colour = NA), panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = GRID, linewidth = .3), axis.text = element_text(colour = MUTED),
        axis.title = element_text(colour = INK2), strip.text = element_text(colour = INK, size = 8.5),
        plot.title = element_text(colour = INK, size = 9.5, face = "bold"))
br <- function(x) format(x, decimal.mark = ",", big.mark = ".", scientific = FALSE, trim = TRUE)

rot <- c(taxa = "Taxa de homicídios (/100 mil)", rend_pc_media = "Renda per capita (R$)",
         desig = "Desigualdade (média/mediana)", pct_pobres = "% pobres (≤ ¼ SM, 14+)",
         desocup = "Desocupação (%)", alfabet = "Alfabetização (%)", pct_urbana = "% urbana",
         dens = "Densidade (hab/km²)", pct_negra = "% preta ou parda", pct_h1529 = "% homens 15–29",
         pct_indet = "% intenção indeterminada", pop = "População")

# --- Tabela descritiva -------------------------------------------------------
desc <- d %>% select(all_of(names(rot))) %>%
  pivot_longer(everything()) %>% group_by(name) %>%
  summarise(media = mean(value), dp = sd(value), min = min(value), q1 = quantile(value, .25),
            mediana = median(value), q3 = quantile(value, .75), max = max(value),
            assimetria = mean((value - mean(value))^3) / sd(value)^3, .groups = "drop") %>%
  mutate(var = rot[name]) %>% arrange(match(name, names(rot)))
write.csv(desc, "resultados/eda/descritiva.csv", row.names = FALSE)

# --- E1. Distribuição da resposta: bruta vs raiz -----------------------------
e1 <- bind_rows(data.frame(escala = "Taxa (Y)", v = d$taxa),
                data.frame(escala = "√Taxa (√Y)", v = d$raiz_taxa))
e1$escala <- factor(e1$escala, levels = c("Taxa (Y)", "√Taxa (√Y)"))
p <- ggplot(e1, aes(v)) + geom_histogram(bins = 50, fill = BLUE, colour = SURF, linewidth = .2) +
  facet_wrap(~escala, scales = "free") + labs(x = NULL, y = "Nº de municípios") + th
ggsave("resultados/eda/e1_hist_resposta.png", p, width = 6.4, height = 2.5, dpi = 220)

# --- E2. Mapa da taxa --------------------------------------------------------
g <- st_read("dados/malha_mun.geojson", quiet = TRUE); g$cod_ibge <- as.integer(g$codarea)
gd <- inner_join(g, d, by = "cod_ibge")
gd$classe <- cut(gd$taxa, c(-Inf, 0, 10, 20, 30, 45, 60, Inf), right = TRUE,
                 labels = c("0", "0–10", "10–20", "20–30", "30–45", "45–60", "60+"))
SEQ <- c("#e8f0fb", "#b7d3f6", "#86b6ef", "#5598e7", "#2a78d6", "#1c5cab", "#0d366b")
uf <- gd %>% mutate(uf = substr(cod_ibge, 1, 2)) %>% group_by(uf) %>% summarise()
p <- ggplot(gd) + geom_sf(aes(fill = classe), colour = NA) + geom_sf(data = uf, fill = NA, colour = "white", linewidth = .25) +
  scale_fill_manual(values = SEQ, name = "Homicídios\npor 100 mil/ano") +
  theme_void(base_family = FONTE, base_size = 8) +
  theme(plot.background = element_rect(fill = SURF, colour = NA), legend.position = c(.15, .25))
ggsave("resultados/eda/e2_mapa_taxa.png", p, width = 5, height = 5, dpi = 220)

# --- E3. Taxa por região e por contexto (boxplots) ---------------------------
e3 <- bind_rows(
  data.frame(grupo = "Região", nivel = as.character(d$regiao), v = d$taxa),
  data.frame(grupo = "Amazônia Legal", nivel = ifelse(d$amazonia_legal == 1, "Sim", "Não"), v = d$taxa),
  data.frame(grupo = "Faixa de fronteira", nivel = ifelse(d$faixa_fronteira == 1, "Sim", "Não"), v = d$taxa))
e3$nivel <- factor(e3$nivel, levels = c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul", "Não", "Sim"))
e3$grupo <- factor(e3$grupo, levels = c("Região", "Amazônia Legal", "Faixa de fronteira"))
p <- ggplot(e3, aes(nivel, v)) +
  geom_boxplot(fill = "#cde2fb", colour = BLUE, outlier.size = .4, outlier.alpha = .3, width = .6, linewidth = .4) +
  stat_summary(fun = mean, geom = "point", colour = RED, size = 1.6) +
  facet_grid(~grupo, scales = "free_x", space = "free_x") + coord_cartesian(ylim = c(0, 100)) +
  labs(x = NULL, y = "Taxa de homicídios (/100 mil)") + th
ggsave("resultados/eda/e3_box_regiao.png", p, width = 6.4, height = 2.7, dpi = 220)

# --- E4. Distribuição das explicativas ---------------------------------------
xs <- c("rend_pc_media", "desig", "pct_pobres", "desocup", "alfabet", "pct_urbana", "log_dens", "pct_negra", "pct_h1529", "pct_indet")
rot4 <- c(rot, log_dens = "ln Densidade"); rot4["desig"] <- "Desigualdade"; rot4["pct_indet"] <- "% indeterminada"; rot4["pct_pobres"] <- "% pobres"
e4 <- d %>% select(all_of(xs)) %>% pivot_longer(everything()) %>% mutate(var = factor(rot4[name], levels = rot4[xs]))
p <- ggplot(e4, aes(value)) + geom_histogram(bins = 40, fill = BLUE, colour = SURF, linewidth = .15) +
  facet_wrap(~var, scales = "free", ncol = 5) + labs(x = NULL, y = NULL) + th +
  theme(axis.text = element_text(size = 6.5), strip.text = element_text(size = 7.5))
ggsave("resultados/eda/e4_hist_explicativas.png", p, width = 7, height = 3.2, dpi = 220)

# --- E5. Matriz de correlação -----------------------------------------------
cv <- c(raiz_taxa = "√Taxa", log_rend = "ln Renda", desig = "Desigualdade", pct_pobres = "% pobres",
        desocup = "Desocupação", alfabet = "Alfabetização", pct_urbana = "% urbana", log_dens = "ln Densidade",
        pct_negra = "% preta/parda", pct_h1529 = "% homens 15–29", pct_indet = "% indeterminada")
R <- cor(d[, names(cv)]); dimnames(R) <- list(cv, cv)
write.csv(round(R, 3), "resultados/eda/correlacao.csv")
rl <- as.data.frame(as.table(R)); names(rl) <- c("a", "b", "r")
rl$a <- factor(rl$a, levels = cv); rl$b <- factor(rl$b, levels = rev(cv))
rl <- rl[as.integer(rl$a) <= (length(cv) + 1 - as.integer(rl$b)), ]          # triângulo inferior
p <- ggplot(rl, aes(a, b, fill = r)) + geom_tile(colour = SURF, linewidth = .8) +
  geom_text(aes(label = sub(".", ",", sprintf("%.2f", r), fixed = TRUE), colour = abs(r) > .55), size = 2.5) +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = INK), guide = "none") +
  scale_fill_gradient2(low = BLUE, mid = "#f0efec", high = RED, limits = c(-1, 1), name = "r de Pearson") +
  labs(x = NULL, y = NULL) + th + theme(axis.text.x = element_text(angle = 40, hjust = 1, colour = INK),
                                        axis.text.y = element_text(colour = INK), panel.grid = element_blank())
ggsave("resultados/eda/e5_correlacao.png", p, width = 6.4, height = 5, dpi = 220)

# --- E6. Resposta × cada explicativa (dispersão + loess) ----------------------
xs6 <- c(log_rend = "ln Renda per capita", desig = "Desigualdade (média/mediana)", desocup = "Desocupação (%)",
         pct_urbana = "% urbana", log_dens = "ln Densidade", pct_negra = "% preta ou parda",
         pct_h1529 = "% homens 15–29", pct_indet = "% intenção indeterminada")
e6 <- d %>% select(raiz_taxa, all_of(names(xs6))) %>% pivot_longer(-raiz_taxa) %>%
  mutate(var = factor(xs6[name], levels = xs6))
p <- ggplot(e6, aes(value, raiz_taxa)) + geom_point(size = .3, alpha = .15, colour = BLUE) +
  geom_smooth(method = "loess", se = FALSE, colour = RED, linewidth = .7, formula = y ~ x, span = .6) +
  facet_wrap(~var, scales = "free_x", ncol = 4) + labs(x = NULL, y = "√Taxa de homicídios") + th +
  theme(strip.text = element_text(size = 7.5), axis.text = element_text(size = 6.5))
ggsave("resultados/eda/e6_dispersao.png", p, width = 7, height = 3.6, dpi = 220)

# --- E7. Matriz de dispersão (pares) de um subconjunto -----------------------
sub <- d %>% transmute(`√Taxa` = raiz_taxa, `ln Renda` = log_rend, `% pobres` = pct_pobres,
                       `Alfabetização` = alfabet, `% urbana` = pct_urbana, `% preta/parda` = pct_negra)
sub <- sub[sample(nrow(sub), 2000), ]
lower_f <- function(data, mapping, ...) ggplot(data, mapping) + geom_point(size = .25, alpha = .25, colour = BLUE)
diag_f  <- function(data, mapping, ...) ggplot(data, mapping) + geom_density(fill = "#cde2fb", colour = BLUE, linewidth = .4)
upper_f <- function(data, mapping, ...) {
  x <- GGally::eval_data_col(data, mapping$x); y <- GGally::eval_data_col(data, mapping$y); r <- cor(x, y)
  ggplot() + annotate("text", x = .5, y = .5, label = sub(".", ",", sprintf("%.2f", r), fixed = TRUE),
                      size = 3 + 2.5 * abs(r), colour = ifelse(abs(r) > .5, RED, INK2), family = FONTE) +
    theme_void()
}
p <- ggpairs(sub, lower = list(continuous = lower_f), diag = list(continuous = diag_f),
             upper = list(continuous = upper_f)) + th +
  theme(axis.text = element_text(size = 5.5), strip.text = element_text(size = 7.5), panel.grid.major = element_blank())
ggsave("resultados/eda/e7_pares.png", p, width = 7, height = 6.2, dpi = 200)

# --- E8. Taxa × população (funil) -------------------------------------------
taxa_br <- sum(d$hom) / sum(d$exposure) * 1e5
pp <- 10^seq(log10(min(d$pop)), log10(max(d$pop)), length.out = 200)
se <- sqrt(taxa_br / 1e5 * 3 * pp) / (3 * pp) * 1e5   # dp de Poisson da taxa
lim <- data.frame(pop = pp, lo = pmax(taxa_br - 1.96 * se, 0), hi = taxa_br + 1.96 * se)
p <- ggplot(d, aes(pop, taxa)) + geom_point(size = .4, alpha = .25, colour = BLUE) +
  geom_line(data = lim, aes(pop, hi), colour = RED, linewidth = .6) +
  geom_line(data = lim, aes(pop, lo), colour = RED, linewidth = .6) +
  geom_hline(yintercept = taxa_br, colour = MUTED, linetype = 2) +
  scale_x_log10(labels = br) + coord_cartesian(ylim = c(0, 150)) +
  labs(x = "População (escala log)", y = "Taxa de homicídios (/100 mil)") + th
ggsave("resultados/eda/e8_funil.png", p, width = 6.4, height = 2.7, dpi = 220)

# --- Valores da análise exploratória ---------------------------------------
fora_funil <- mean(d$taxa > approx(lim$pop, lim$hi, d$pop)$y | d$taxa < approx(lim$pop, lim$lo, d$pop)$y)
reg <- d %>% group_by(regiao) %>% summarise(taxa_agregada = sum(hom) / sum(exposure) * 1e5, mediana = median(taxa), n = n())
ctx <- function(v) d %>% group_by(grupo = d[[v]]) %>%
  summarise(n = n(), mediana_taxa = median(taxa), mediana_renda = median(rend_pc_media),
            mediana_pct_negra = median(pct_negra), mediana_pct_urbana = median(pct_urbana), mediana_dens = median(dens))
top_h <- d %>% arrange(desc(pct_h1529)) %>% select(municipio, uf, pop, pct_h1529) %>% head(5)
mx <- d[which.max(d$taxa), ]

sink("resultados/eda/valores_eda.txt")
cat("ANÁLISE EXPLORATÓRIA — valores\n==============================\n\n")
cat(sprintf("Municípios: %d | sem homicídios: %d (%.1f%%)\n", nrow(d), sum(d$taxa == 0), 100 * mean(d$taxa == 0)))
cat(sprintf("Homicídios 2021–23: %d | taxa nacional: %.2f /100 mil/ano\n", sum(d$hom), taxa_br))
cat(sprintf("Taxa municipal: média %.2f | mediana %.2f | dp %.2f | máx %.1f (%s-%s, %d hab.)\n",
            mean(d$taxa), median(d$taxa), sd(d$taxa), mx$taxa, mx$municipio, mx$uf, mx$pop))
cat(sprintf("Assimetria: taxa %.2f | raiz da taxa %.3f\n", desc$assimetria[desc$name == "taxa"],
            mean((d$raiz_taxa - mean(d$raiz_taxa))^3) / sd(d$raiz_taxa)^3))
cat(sprintf("Fora dos limites de 95%% do funil (Poisson): %.1f%%\n\n", 100 * fora_funil))
cat("Por região:\n"); print(as.data.frame(reg), row.names = FALSE)
cat("\nAmazônia Legal (0 = não, 1 = sim):\n"); print(as.data.frame(ctx("amazonia_legal")), row.names = FALSE)
cat("\nFaixa de fronteira (0 = não, 1 = sim):\n"); print(as.data.frame(ctx("faixa_fronteira")), row.names = FALSE)
cat("\nCorrelação de cada explicativa com a raiz da taxa:\n"); print(round(sort(R[1, -1]), 3))
cat(sprintf("\nCorrelações entre explicativas: renda × pobres = %.2f | renda × alfabetização = %.2f | pobres × alfabetização = %.2f\n",
            R["ln Renda", "% pobres"], R["ln Renda", "Alfabetização"], R["% pobres", "Alfabetização"]))
cat(sprintf("\nRenda mediana amontoada: %d municípios com mediana = R$ 1.212 (1 SM) e %d com R$ 606 (1/2 SM)\n",
            sum(round(d$rend_pc_mediana) == 1212), sum(round(d$rend_pc_mediana) == 606)))
cat("\nMaiores % de homens 15–29 (municípios com presídios):\n"); print(as.data.frame(top_h), row.names = FALSE)
cat("\nEstatísticas descritivas: ver descritiva.csv\n")
sink()
cat(readLines("resultados/eda/valores_eda.txt"), sep = "\n")
