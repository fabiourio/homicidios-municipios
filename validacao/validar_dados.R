# =============================================================================
# Validação da qualidade dos dados da base analítica
# Entradas: dados/tabelas/ (base_analitica.csv e tabelas SIDRA/SIM intermediárias)
#           TabNet/DATASUS (3 consultas extras, guardadas em validacao/saida/tabnet_extra.json)
# Saídas:   validacao/saida/ (tabelas, figuras e valores_validacao.txt)
# Não altera nenhum dado do projeto.
# =============================================================================

rm(list = ls())
if (basename(getwd()) == "validacao") setwd("..")

library(jsonlite)
library(ggplot2)
library(car)

OUT <- "validacao/saida"
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
salva <- function(df, nome) write.csv(df, file.path(OUT, nome), row.names = FALSE)

b <- read.csv("dados/tabelas/base_analitica.csv")
b <- b[order(b$cod_ibge), ]

# Lê uma tabela SIDRA intermediária ("-" = zero)
le_sidra <- function(t) {
  x <- read.csv(sprintf("dados/tabelas/sidra_%s.csv", t), colClasses = "character")
  for (v in names(x)[-(1:2)]) { x[[v]][x[[v]] == "-"] <- "0"; x[[v]] <- as.numeric(x[[v]]) }
  x$cod_ibge <- as.integer(x$cod_ibge)
  x[match(b$cod_ibge, x$cod_ibge), ]
}

sink(file.path(OUT, "valores_validacao.txt"), split = TRUE)
cat("VALIDAÇÃO DOS DADOS\n===================\n")

# -----------------------------------------------------------------------------
# 1. Completude e chaves
# -----------------------------------------------------------------------------
cat("\n== 1. Completude e chaves ==\n")
cat(sprintf("Linhas: %d | códigos IBGE únicos: %d | cod6 únicos: %d | NAs: %d\n",
            nrow(b), length(unique(b$cod_ibge)), length(unique(b$cod6)), sum(is.na(b))))
cat(sprintf("Municípios por UF somam 5.570: %s | DF com 1 município: %s\n",
            sum(table(b$uf)) == 5570, sum(b$uf == "DF") == 1))
cat(sprintf("cod6 == cod_ibge %%/%% 10 em todos: %s\n", all(b$cod6 == b$cod_ibge %/% 10)))

# Dígito verificador do código IBGE (módulo 10, pesos 1-2-1-2-1-2)
dv <- function(cod6) {
  d <- as.integer(strsplit(sprintf("%06d", cod6), "")[[1]]) * c(1, 2, 1, 2, 1, 2)
  s <- sum(d %/% 10 + d %% 10)
  (10 - s %% 10) %% 10
}
dv_ok <- sapply(b$cod6, dv) == b$cod_ibge %% 10
cat(sprintf("Dígito verificador confere: %d de %d (exceções conhecidas do IBGE: %s)\n", sum(dv_ok), nrow(b),
            paste(b$municipio[!dv_ok], b$uf[!dv_ok], collapse = "; ")))

s21 <- read.csv("dados/tabelas/sim_causas_externas_2021_2023.csv")
s24 <- read.csv("dados/tabelas/sim_causas_externas_2024.csv")
cat(sprintf("SIM 2021-23: %d linhas, %d sem par na base | SIM 2024: %d linhas, %d sem par na base\n",
            nrow(s21), sum(!s21$cod6 %in% b$cod6), nrow(s24), sum(!s24$cod6 %in% b$cod6)))
cat(sprintf("cod6 duplicado no SIM: %d\n", sum(duplicated(s21$cod6)) + sum(duplicated(s24$cod6))))
sem_sim <- b[!b$cod6 %in% s21$cod6, c("municipio", "uf", "pop")]
cat("Municípios sem linha no SIM 2021-23 (recebem 0):\n"); print(sem_sim, row.names = FALSE)

# Nomes do IBGE x nomes do TabNet (sem acento, só letras)
so_letras <- function(x) gsub("[^A-Z]", "", toupper(iconv(x, "UTF-8", "ASCII//TRANSLIT")))
nm <- merge(b[, c("cod6", "municipio", "uf")], s21[, c("cod6", "municipio_tabnet")], by = "cod6")
nm <- nm[so_letras(nm$municipio) != so_letras(nm$municipio_tabnet), ]
cat(sprintf("Nomes diferentes entre IBGE e TabNet: %d (só grafia):\n", nrow(nm)))
print(nm[, -1], row.names = FALSE)

# Municípios instalados depois de 2005: existem no Censo 2022 e têm registro no SIM?
novos <- c(1504752, 4212650, 4220000, 4314548, 5006275)
cat("Municípios criados em 2013 (instalados com o Censo 2010 já feito):\n")
print(b[b$cod_ibge %in% novos, c("cod_ibge", "municipio", "uf", "pop", "total_causas_externas", "hom", "hom_24")],
      row.names = FALSE)
cat(sprintf("Boa Esperança do Norte-MT (5101837) na base: %s (instalado em 2025, depois do Censo 2022)\n",
            5101837 %in% b$cod_ibge))

# -----------------------------------------------------------------------------
# 2. Valores impossíveis ou suspeitos
# -----------------------------------------------------------------------------
cat("\n== 2. Valores impossíveis ou suspeitos ==\n")
pcts <- c("pct_pobres", "desocup", "alfabet", "pct_urbana", "pct_negra", "pct_h1529", "pct_indet",
          "freq_15a17", "pct_garimpo")
fora <- sapply(b[pcts], function(x) sum(x < 0 | x > 100))
cat("Percentuais fora de 0-100:\n"); print(fora)
cat(sprintf("Contagens negativas: %d\n", sum(b[c("pop", "hom", "hom_24", "total_causas_externas")] < 0)))
cat(sprintf("Homicídios > total de causas externas: %d\n", sum(b$hom > b$total_causas_externas)))
cat(sprintf("Renda mediana > média: %d | desig < 1: %d | desig mín/máx: %.3f / %.3f\n",
            sum(b$rend_pc_mediana > b$rend_pc_media), sum(b$desig < 1), min(b$desig), max(b$desig)))
dens_rel <- abs(b$dens - b$pop / b$area_km2) / b$dens
cat(sprintf("Densidade x pop/área: maior diferença relativa = %.2f%% (arredondamento da densidade)\n",
            100 * max(dens_rel)))
mult_sm <- b$rend_pc_mediana %in% (1212 * c(0.25, 0.5, 1, 1.5, 2))
cat(sprintf("Mediana igual a fração/múltiplo do SM (303, 606, 1212, 1818, 2424): %d municípios; = 1.212: %d\n",
            sum(mult_sm), sum(b$rend_pc_mediana == 1212)))
cat(sprintf("Frequência escolar 15-17 = 100%%: %d | %% urbana = 100%%: %d | desocupação = 0: %d\n",
            sum(b$freq_15a17 >= 100), sum(b$pct_urbana == 100), sum(b$desocup == 0)))

# Extremos de cada variável usada no modelo
vars_mod <- c("taxa", "rend_pc_media", "desig", "desocup", "pct_urbana", "dens", "pct_negra", "pct_h1529",
              "pct_indet", "pop")
ext <- do.call(rbind, lapply(vars_mod, function(v) {
  o <- order(b[[v]])
  i <- c(head(o, 3), tail(o, 3))
  data.frame(variavel = v, lado = rep(c("menor", "maior"), each = 3), municipio = b$municipio[i],
             uf = b$uf[i], pop = b$pop[i], valor = round(b[[v]][i], 2))
}))
salva(ext, "02_extremos.csv")

t9517 <- le_sidra("9517")
cat("Desocupação acima de 30% (Censo: dado da amostra, erro grande em município pequeno):\n")
alto <- which(b$desocup > 30)
print(data.frame(municipio = b$municipio[alto], uf = b$uf[alto], pop = b$pop[alto],
                 forca_trab = t9517$forca_trabalho[alto], desocupados = t9517$desocupados[alto],
                 desocup = round(b$desocup[alto], 1),
                 particip = round(100 * t9517$forca_trabalho[alto] / t9517$p14_total[alto], 1)), row.names = FALSE)
cat(sprintf("Participação na força de trabalho: mediana Brasil = %.1f%%\n",
            median(100 * t9517$forca_trabalho / t9517$p14_total)))

# -----------------------------------------------------------------------------
# 3. Coerência interna
# -----------------------------------------------------------------------------
cat("\n== 3. Coerência interna ==\n")
taxa_rec <- (b$agressao + b$intervencao_legal) / (3 * b$pop) * 1e5
cat(sprintf("Taxa recalculada x taxa da base: maior diferença = %.2g\n", max(abs(taxa_rec - b$taxa))))
s21m <- s21[match(b$cod6, s21$cod6), ]
cat(sprintf("Contagens da base x tabela SIM: diferenças = %d\n",
            sum(b$agressao != ifelse(is.na(s21m$agressao), 0, s21m$agressao))))
cat(sprintf("Soma dos grupos CID x total no SIM 2021-23: linhas com diferença = %d\n",
            sum(rowSums(s21[, 3:10]) != s21$total_causas_externas)))
cat(sprintf("Homicídios: 2021-23 = %d (%.0f/ano) | 2024 = %d\n", sum(b$hom), sum(b$hom) / 3, sum(b$hom_24)))

pops <- data.frame(t4709 = b$pop, t4714 = le_sidra("4714")$pop, t9923 = le_sidra("9923")$pop_total,
                   t9605 = le_sidra("9605")$pop_total)
cat("Populações entre tabelas (municípios com diferença):\n")
print(sapply(pops[-1], function(x) sum(x != pops$t4709)))
r9605 <- le_sidra("9605")
gap9605 <- r9605$pop_total - rowSums(r9605[, c("branca", "preta", "amarela", "parda", "indigena")])
cat(sprintf("9605 total - soma das cores: municípios com diferença = %d | maior = %d pessoas (%.2f%% da pop) | efeito máx. em pct_negra se a falta fosse redistribuída = %.2f p.p.\n",
            sum(gap9605 != 0), max(gap9605), 100 * max(gap9605 / r9605$pop_total),
            max(abs(100 * (r9605$preta + r9605$parda) / (r9605$pop_total - gap9605) - b$pct_negra))))

p <- le_sidra("10300")
classes <- names(p)[4:14]
d10300 <- rowSums(p[classes]) - p$p14_total
d9517a <- t9517$ocupados + t9517$desocupados - t9517$forca_trabalho
d9517b <- t9517$forca_trabalho + t9517$fora_forca_trabalho - t9517$p14_total
cat("Tabela 10300 (soma das classes - total), em pessoas:\n"); print(table(d10300))
cat(sprintf("  maior diferença relativa: %.3f%% do total\n", 100 * max(abs(d10300) / p$p14_total)))
cat("Tabela 9517 (ocupados + desocupados - força de trabalho), em pessoas:\n"); print(table(d9517a))
cat("Tabela 9517 (força + fora da força - total 14+), em pessoas:\n"); print(table(d9517b))

pp_alt <- (p$p14_ate_1_4sm + p$p14_sem_rendimento) / rowSums(p[classes]) * 100
de_alt <- t9517$desocupados / (t9517$ocupados + t9517$desocupados) * 100
cat(sprintf("Efeito em pct_pobres (denominador = soma das classes): maior mudança = %.4f p.p.\n",
            max(abs(pp_alt - b$pct_pobres))))
cat(sprintf("Efeito em desocup (denominador = ocupados + desocupados): maior mudança = %.4f p.p.\n",
            max(abs(de_alt - b$desocup))))

# Moradores fora de domicílio particular (presídio, quartel, asilo etc.)
b$dpp <- le_sidra("10295")$moradores_dpp
b$pct_fora_dpp <- (1 - b$dpp / b$pop) * 100
d14 <- t9517$p14_total - p$p14_total
cat(sprintf("Pessoas 14+ na 9517 (todos) - 10300 (só domicílio particular): mín %d | mediana %d | máx %d\n",
            min(d14), median(d14), max(d14)))
cat(sprintf("%% da população fora de domicílio particular (pop - moradores 10295): mediana %.2f%% | > 10%%: %d municípios\n",
            median(b$pct_fora_dpp), sum(b$pct_fora_dpp > 10)))

# -----------------------------------------------------------------------------
# 4. Qualidade da resposta
# -----------------------------------------------------------------------------
cat("\n== 4. Qualidade da resposta ==\n")
cat(sprintf("Taxa zero: %d | municípios sem nenhum óbito externo: %d\n", sum(b$hom == 0),
            sum(b$total_causas_externas == 0)))
cat(sprintf("%% intenção indeterminada >= 30%%: %d | >= 50%%: %d | = 100%%: %d (todos com <= 1 óbito externo: %s)\n",
            sum(b$pct_indet >= 30), sum(b$pct_indet >= 50), sum(b$pct_indet == 100),
            all(b$total_causas_externas[b$pct_indet == 100] <= 1)))
uf_ind <- aggregate(cbind(intencao_indeterminada, total_causas_externas, hom) ~ uf, b, sum)
uf_ind$pct_indet <- round(100 * uf_ind$intencao_indeterminada / uf_ind$total_causas_externas, 1)
uf_ind$razao_indet_hom <- round(uf_ind$intencao_indeterminada / uf_ind$hom, 2)
uf_ind <- uf_ind[order(-uf_ind$pct_indet), ]
cat("% indeterminada por UF (as 6 maiores):\n"); print(head(uf_ind, 6), row.names = FALSE)
salva(uf_ind, "04_indeterminada_uf.csv")
gr <- b[b$total_causas_externas >= 50, ]
gr <- gr[order(-gr$pct_indet), c("municipio", "uf", "pop", "hom", "intencao_indeterminada",
                                 "total_causas_externas", "pct_indet")]
cat("Municípios com >= 50 óbitos externos e maior % indeterminada:\n"); print(head(gr, 8), row.names = FALSE)

# Estabilidade: taxa 2021-23 x taxa 2024
cat(sprintf("Correlação taxa 2021-23 x 2024: %.3f (todos) | %.3f (pop >= 50 mil) | %.3f (pop < 5 mil)\n",
            cor(b$taxa, b$taxa_24), cor(b$taxa[b$pop >= 5e4], b$taxa_24[b$pop >= 5e4]),
            cor(b$taxa[b$pop < 5e3], b$taxa_24[b$pop < 5e3])))
# Esperado de Poisson se a taxa fosse estável: hom_24 ~ Poisson(hom/3)
b$z24 <- (b$hom_24 - b$hom / 3) / sqrt(pmax(b$hom / 3, 1))
inst <- b[abs(b$z24) >= 4, c("municipio", "uf", "pop", "hom", "hom_24", "taxa", "taxa_24", "z24")]
inst <- inst[order(-abs(inst$z24)), ]
cat(sprintf("Municípios com 2024 muito diferente da média 2021-23 (|z| >= 4, z = (hom24 - hom/3)/sqrt(hom/3)): %d\n",
            nrow(inst)))
salva(inst, "04_instabilidade_2024.csv")

# Consultas extras ao TabNet (feitas uma vez e guardadas)
arq_extra <- file.path(OUT, "tabnet_extra.json")
if (!file.exists(arq_extra)) {
  ok <- requireNamespace("httr", quietly = TRUE)
  if (ok) {
    cod_latin1 <- function(x) {
      r <- iconv(x, from = "UTF-8", to = "latin1", toRaw = TRUE)[[1]]
      k <- r %in% charToRaw("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
      paste0(ifelse(k, rawToChar(r, multiple = TRUE), sprintf("%%%02X", as.integer(r))), collapse = "")
    }
    tabnet <- function(def, prefixo, coluna, incremento, anos, filtros = list()) {
      campos <- list(c("Linha", "Município"), c("Coluna", coluna), c("Incremento", incremento))
      for (a in anos) campos[[length(campos) + 1]] <- c("Arquivos", sprintf("%s%02d.dbf", prefixo, a %% 100))
      for (f in names(filtros)) for (v in filtros[[f]]) campos[[length(campos) + 1]] <- c(f, v)
      campos <- c(campos, list(c("formato", "prn"), c("mostre", "Mostra")))
      corpo <- paste(sapply(campos, function(k) paste0(cod_latin1(k[1]), "=", cod_latin1(k[2]))), collapse = "&")
      r <- httr::POST(paste0("http://tabnet.datasus.gov.br/cgi/tabcgi.exe?", def), httr::timeout(300),
                      body = corpo, httr::content_type("application/x-www-form-urlencoded"))
      txt <- iconv(rawToChar(httr::content(r, "raw")), from = "latin1", to = "UTF-8")
      m <- regmatches(txt, regexpr("(?is)<PRE>.*?</PRE>", txt, perl = TRUE))
      if (!length(m)) stop("TabNet não devolveu tabela")
      gsub("<[^>]+>", "", m)
    }
    hom_f <- list("SGrande_Grupo_CID10" = c("4", "6"))
    extra <- tryCatch(list(
      ano  = tabnet("sim/cnv/ext10br.def", "extbr", "Ano_do_Óbito", "Óbitos_p/Residênc", 2021:2023, hom_f),
      ocor = tabnet("sim/cnv/ext10br.def", "extbr", "--Não-Ativa--", "Óbitos_p/Ocorrênc", 2021:2023, hom_f),
      cap  = tabnet("sim/cnv/obt10br.def", "obtbr", "Capítulo_CID-10", "Óbitos_p/Residênc", 2021:2023)),
      error = function(e) { message("TabNet indisponível: ", conditionMessage(e)); NULL })
    if (!is.null(extra)) write(toJSON(extra, auto_unbox = TRUE), arq_extra)
  }
}

if (file.exists(arq_extra)) {
  X <- fromJSON(arq_extra)
  le_tab <- function(s) {
    df <- read.table(text = s, sep = ";", header = TRUE, quote = "\"", check.names = FALSE, na.strings = "-",
                     fill = TRUE, stringsAsFactors = FALSE, encoding = "UTF-8")
    names(df)[1] <- "linha"
    df <- df[grepl("^\\s*[0-9]{6} ", df$linha), ]
    df[is.na(df)] <- 0
    df$cod6 <- as.integer(substr(trimws(df$linha), 1, 6))
    df
  }
  ano <- le_tab(X$ano); ocor <- le_tab(X$ocor); cap <- le_tab(X$cap)
  a <- ano[match(b$cod6, ano$cod6), c("2021", "2022", "2023")]; a[is.na(a)] <- 0
  b$h21 <- a[[1]]; b$h22 <- a[[2]]; b$h23 <- a[[3]]
  cat(sprintf("TabNet por ano confere com a base (soma 2021-23 = hom): %d de %d municípios\n",
              sum(b$h21 + b$h22 + b$h23 == b$hom), nrow(b)))
  b$hom_ocor <- ocor[[2]][match(b$cod6, ocor$cod6)]; b$hom_ocor[is.na(b$hom_ocor)] <- 0
  b$obitos <- cap$Total[match(b$cod6, cap$cod6)]
  b$mal_def <- cap[["Cap XVIII"]][match(b$cod6, cap$cod6)]
  b$pct_mal_def <- 100 * b$mal_def / b$obitos
  cat(sprintf("Óbitos por causa mal definida (cap. XVIII), %% do total de óbitos: mediana %.1f%% | > 20%%: %d municípios\n",
              median(b$pct_mal_def, na.rm = TRUE), sum(b$pct_mal_def > 20, na.rm = TRUE)))
  print(head(b[order(-b$pct_mal_def), c("municipio", "uf", "pop", "obitos", "mal_def", "pct_mal_def", "taxa")], 8),
        row.names = FALSE)
  cat(sprintf("Correlação %% mal definida x taxa: %.3f | x %% indeterminada: %.3f\n",
              cor(b$pct_mal_def, b$taxa, use = "complete.obs"), cor(b$pct_mal_def, b$pct_indet, use = "complete.obs")))
  pres <- b[b$pct_fora_dpp > 10, c("municipio", "uf", "pop", "pct_fora_dpp", "pct_h1529", "hom", "hom_ocor", "taxa")]
  pres <- pres[order(-pres$pct_fora_dpp), ]
  cat(sprintf("Municípios com > 10%% da população fora de domicílio particular (presídios etc.): %d\n", nrow(pres)))
  cat(sprintf("  homicídios por residência = %d | por ocorrência = %d\n", sum(pres$hom), sum(pres$hom_ocor)))
  print(pres, row.names = FALSE)
  salva(pres, "04_presidios.csv")
} else {
  cat("Consultas extras ao TabNet: não verificado (sem acesso)\n")
}

# -----------------------------------------------------------------------------
# 5. Outliers e pontos influentes no modelo preliminar (D)
# -----------------------------------------------------------------------------
cat("\n== 5. Outliers e pontos influentes ==\n")
b$regiao <- relevel(factor(b$regiao), ref = "SE")
b$ys <- sqrt(b$taxa)
b$rend_c <- b$log_rend - mean(b$log_rend)
b$rend_c2 <- b$rend_c^2
form <- ys ~ rend_c + rend_c2 + desig + desocup + pct_urbana + log_dens + pct_negra + pct_h1529 +
  amazonia_legal + faixa_fronteira + pct_indet + regiao
m <- lm(form, data = b)
n <- nrow(b); pp <- length(coef(m))
b$e_semi <- residuals(m) / sqrt(sum(residuals(m)^2) / m$df.residual)
b$h <- hatvalues(m)                       # fora da apostila: só descritivo
b$cook <- cooks.distance(m)               # fora da apostila: só descritivo
cat(sprintf("|e*| >= 4: %d | |e*| >= 3: %d\n", sum(abs(b$e_semi) >= 4), sum(abs(b$e_semi) >= 3)))
cat(sprintf("[fora da apostila] alavancagem h > 2p/n (%.4f): %d | Cook > 4/n: %d | Cook máx = %.4f\n",
            2 * pp / n, sum(b$h > 2 * pp / n), sum(b$cook > 4 / n), max(b$cook)))
cols <- c("municipio", "uf", "pop", "hom", "taxa", "taxa_24", "desocup", "desig", "pct_h1529", "pct_indet",
          "pct_fora_dpp", "e_semi", "h", "cook")
if ("h21" %in% names(b)) cols <- c(cols, "h21", "h22", "h23")
out <- b[abs(b$e_semi) >= 3 | b$cook > 8 / n | b$h > 4 * pp / n, cols]
out <- out[order(-b$cook[abs(b$e_semi) >= 3 | b$cook > 8 / n | b$h > 4 * pp / n]), ]
salva(out, "05_outliers_influentes.csv")
cat("|e*| >= 4:\n"); print(b[abs(b$e_semi) >= 4, intersect(cols, names(b))], row.names = FALSE)
cat("[fora da apostila] 10 maiores distâncias de Cook:\n")
print(head(b[order(-b$cook), c("municipio", "uf", "pop", "taxa", "desocup", "desig", "pct_h1529", "e_semi",
                               "h", "cook")], 10), row.names = FALSE)
cat("[fora da apostila] 10 maiores alavancagens:\n")
print(head(b[order(-b$h), c("municipio", "uf", "pop", "taxa", "desocup", "desig", "pct_h1529", "pct_indet",
                            "e_semi", "h")], 10), row.names = FALSE)

# -----------------------------------------------------------------------------
# 6. Sensibilidade: reajusta o modelo sem grupos de casos suspeitos
# -----------------------------------------------------------------------------
cat("\n== 6. Sensibilidade do modelo ==\n")
cenarios <- list(
  "base"                              = rep(TRUE, n),
  "sem |e*| >= 4"                     = abs(b$e_semi) < 4,
  "sem > 10% fora de dom. particular" = b$pct_fora_dpp <= 10,
  "sem desocupação > 30% ou = 0"      = b$desocup <= 30 & b$desocup > 0,
  "sem % indeterminada >= 30%"        = b$pct_indet < 30,
  "sem pop < 5 mil"                   = b$pop >= 5000,
  "[fora] sem Cook > 4/n"             = b$cook <= 4 / n)
if ("pct_mal_def" %in% names(b)) cenarios[["sem % mal definida > 20%"]] <- b$pct_mal_def <= 20
res <- do.call(rbind, lapply(names(cenarios), function(k) {
  f <- summary(lm(form, data = b[cenarios[[k]], ]))$coefficients
  data.frame(cenario = k, n = sum(cenarios[[k]]), termo = rownames(f), b = f[, 1], p = f[, 4], row.names = NULL)
}))
salva(res, "06_sensibilidade.csv")
base <- res[res$cenario == "base", ]
res$muda_sinal <- sign(res$b) != sign(base$b[match(res$termo, base$termo)])
res$muda_signif <- (res$p < 0.05) != (base$p[match(res$termo, base$termo)] < 0.05)
res$var_pct <- round(100 * (res$b / base$b[match(res$termo, base$termo)] - 1), 1)
cat("Termos que mudam de sinal ou de significância (5%) em relação ao modelo base:\n")
print(res[res$muda_sinal | res$muda_signif, c("cenario", "n", "termo", "b", "p", "var_pct")], row.names = FALSE)
cat("Maior variação relativa de coeficiente por cenário (termo e %):\n")
for (k in names(cenarios)[-1]) {
  r <- res[res$cenario == k & res$termo != "(Intercept)", ]
  i <- which.max(abs(r$var_pct))
  cat(sprintf("  %-36s n = %d | R² = %.3f | %s %+.1f%%\n", k, r$n[1],
              summary(lm(form, data = b[cenarios[[k]], ]))$r.squared, r$termo[i], r$var_pct[i]))
}
tab <- reshape(res[, c("cenario", "termo", "b")], idvar = "termo", timevar = "cenario", direction = "wide")
names(tab) <- sub("^b\\.", "", names(tab))
cat("Coeficientes por cenário:\n"); print(format(tab, digits = 3), row.names = FALSE)
sink()

# -----------------------------------------------------------------------------
# Figuras
# -----------------------------------------------------------------------------
AZUL <- "#2a78d6"; VERMELHO <- "#e34948"; CINZA <- "#898781"
th <- theme_minimal(base_size = 11) + theme(panel.grid.minor = element_blank())

# V1. Resíduo semi-studentizado x ajustado, com nomes dos |e*| >= 4
b$aj <- fitted(m)
g <- ggplot(b, aes(aj, e_semi)) + geom_point(size = .5, alpha = .25, colour = AZUL) +
  geom_hline(yintercept = c(-4, 4), colour = VERMELHO, linetype = 2) +
  geom_text(data = b[abs(b$e_semi) >= 4, ], aes(label = paste(municipio, uf, sep = "-")), size = 2.6,
            hjust = -0.05, vjust = 0) +
  labs(x = "Valor ajustado (√taxa)", y = "Resíduo semi-studentizado e*") + th
ggsave(file.path(OUT, "v1_residuos_semi.png"), g, width = 6.4, height = 3, dpi = 200)

# V2. Distância de Cook por município (fora da apostila, descritivo)
b$ordem <- seq_len(n)
g <- ggplot(b, aes(ordem, cook)) + geom_segment(aes(xend = ordem, yend = 0), colour = AZUL, linewidth = .2) +
  geom_hline(yintercept = 4 / n, colour = VERMELHO, linetype = 2) +
  geom_text(data = head(b[order(-b$cook), ], 6), aes(label = paste(municipio, uf, sep = "-")), size = 2.6,
            vjust = -0.4) +
  labs(x = "Municípios em ordem de código IBGE", y = "Distância de Cook (fora da apostila)") + th
ggsave(file.path(OUT, "v2_cook.png"), g, width = 6.4, height = 3, dpi = 200)

# V3. Estabilidade: √taxa 2021-23 x √taxa 2024, por porte
b$porte <- cut(b$pop, c(0, 5e3, 5e4, Inf), labels = c("< 5 mil", "5 a 50 mil", ">= 50 mil"))
g <- ggplot(b, aes(sqrt(taxa), sqrt(taxa_24))) + geom_point(size = .5, alpha = .3, colour = AZUL) +
  geom_abline(colour = VERMELHO, linetype = 2) + facet_wrap(~porte) +
  labs(x = "√taxa 2021-2023", y = "√taxa 2024") + th
ggsave(file.path(OUT, "v3_estabilidade_2024.png"), g, width = 6.4, height = 2.6, dpi = 200)

cat("\nSaídas em", OUT, "\n")
