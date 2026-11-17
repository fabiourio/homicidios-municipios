# =============================================================================
# USO INTERNO (não faz parte do código de entrega)
# Roda os dois scripts da entrega e tira dos resultados os números e as tabelas dos slides.
# Assim slides, notas e briefings nunca ficam desalinhados do código: nada é digitado à mão.
#
# Saída: numeros.tex e tabelas/*.tex (lidos pela apresentação e pelos briefings)
# Rodar com a pasta apresentacao/latex/ como diretório de trabalho.
# =============================================================================

# Roda cada script da entrega numa sessão de R separada e recupera todos os objetos criados
roda <- function(script) {
  arq <- tempfile(fileext = ".rds")
  cmd <- sprintf("source('%s'); saveRDS(mget(ls()), '%s')", script, arq)
  status <- system2(file.path(R.home("bin"), "Rscript"), c("-e", shQuote(cmd)), stdout = FALSE, stderr = FALSE,
                    env = character(0), wait = TRUE)
  if (status != 0) stop("Falhou ao rodar ", script)
  list2env(readRDS(arq))
}
atual <- setwd("../../entrega")
eda <- roda("1_analise_exploratoria.R")
mod <- roda("2_modelo.R")
setwd(atual)

br <- eda$br; d_eda <- eda$d; porte <- as.data.frame(eda$porte); R <- eda$R
reg_br <- tapply(br$hom, br$regiao, sum) / tapply(br$exposure, br$regiao, sum) * 1e5   # todos os municípios
# Taxa mundial de homicídios em 2021: UNODC, Global Study on Homicide 2023 (único número externo, com fonte no slide)
TAXA_MUNDO_UNODC <- 5.8
cv <- eda$cv
e <- c(
  municipios_br = nrow(br), hom_br = sum(br$hom), taxa_br = eda$taxa_br, pop_min = eda$POP_MIN,
  municipios_escopo = nrow(d_eda), pct_pop_escopo = 100 * sum(d_eda$pop) / sum(br$pop),
  percentil_corte = eda$percentil_corte, casos_esp_corte = eda$casos_esperados_corte,
  zeros_escopo = sum(d_eda$hom == 0), zeros_br = sum(br$hom == 0),
  taxa_media = mean(d_eda$taxa), taxa_mediana = median(d_eda$taxa),
  assim_taxa = eda$assimetria(d_eda$taxa),
  hom_ano = sum(br$hom) / 3, taxa_mundo = TAXA_MUNDO_UNODC, razao_mundo = eda$taxa_br / TAXA_MUNDO_UNODC,
  taxa_n_br = reg_br[["N"]], taxa_ne_br = reg_br[["NE"]], taxa_co_br = reg_br[["CO"]],
  taxa_se_br = reg_br[["SE"]], taxa_s_br = reg_br[["S"]],
  cor_renda_pobres = R["ln Renda", "% pobres"], cor_renda_alfabet = R["ln Renda", "Alfabetização"],
  renda_decil_pico = eda$med_faixa$renda[which.max(eda$med_faixa$med)],
  porte_hom_mediana_menor5mil = porte$hom_mediana_3anos[1], porte_oscilacao_menor5mil = porte$oscilacao[1],
  porte_oscilacao_corte = porte$oscilacao[porte$porte == "30–50 mil"])

m <- with(mod, c(
    n = nrow(d), lambda = lambda, lambda_ic_inf = unname(lambda_ic[1]), lambda_ic_sup = unname(lambda_ic[2]),
    sw_y = unname(sw_y$statistic), sw_ln = unname(sw_log$statistic),
    vif_renda = unname(vif_colin["log_rend"]),
    F_B = anova_blocos$F[2], F_C = anova_blocos$F[3], F_D = anova_blocos$F[4], F_E = anova_blocos$F[5],
    p_B = anova_blocos$`Pr(>F)`[2], p_C = anova_blocos$`Pr(>F)`[3], p_D = anova_blocos$`Pr(>F)`[4], p_E = anova_blocos$`Pr(>F)`[5],
    R2a_A = comp$R2a[1], R2a_B = comp$R2a[2], R2a_C = comp$R2a[3], R2a_D = comp$R2a[4], R2a_E = comp$R2a[5],
    R2a = sf_$adj.r.squared, F_global = unname(sf_$fstatistic[1]),
    gl1 = unname(sf_$fstatistic[2]), gl2 = unname(sf_$fstatistic[3]),
    pico_renda = unname(pico_renda), bp = unname(bp$statistic), bp_p = unname(bp$p.value),
    sw = unname(sw_final$statistic), n_outliers = nrow(outliers),
    sw_p = sw_final$p.value, bp_gl = unname(bp$parameter),
    gl_B = anova_blocos$Df[2], gl_C = anova_blocos$Df[3], gl_D = anova_blocos$Df[4], gl_E = anova_blocos$Df[5],
    R2_E = comp$R2[5], sigma = sf_$sigma,
    F_global_p = unname(pf(sf_$fstatistic[1], sf_$fstatistic[2], sf_$fstatistic[3], lower.tail = FALSE)),
    vif_renda_final = unname(vif_final["rend_c"]), vif_demais_max = max(vif_final[names(vif_final) != "rend_c"]),
    n_reg = nlevels(d$regiao) - 1, n_x = length(coef(final)) - 5 - (nlevels(d$regiao) - 1),
    cor_quad_sem = unname(cor_quad[1]), cor_quad_cen = unname(cor_quad[2])))
out_nomes <- if (nrow(mod$outliers)) with(mod$outliers, paste0(municipio, "-", uf)) else character(0)
efe <- mod$mudancas; coefs <- mod$coefs; gr <- mod$gini_renda; ret <- mod$retiradas
p_ret <- function(t) ret$p[match(t, ret$termo)]
fora <- br[br$cod_ibge == eda$FORA, ]

dir.create("tabelas", showWarnings = FALSE)

# Formatação brasileira: vírgula decimal e ponto de milhar
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",")
fp  <- function(p) ifelse(p < 0.001, "$<$0,001", fmt(p, 3))
sinal <- function(x, d = 0) paste0(ifelse(x > 0, "$+$", "$-$"), fmt(abs(x), d))
coef <- function(t, col) coefs[coefs$termo == t, col]

# Confere as frases fixas dos slides: se o resultado mudar, para aqui em vez de gerar slide errado
confere <- function(ok, frase) if (!isTRUE(ok)) stop("O resultado não sustenta mais a frase do slide: ", frase)
confere(coef("rend_c2", "b") < 0 && coef("rend_c2", "p") < 0.05, "renda em U invertido")
confere(m[["lambda"]] < 0.25, "Box-Cox: lambda mais perto de 0 (log) do que de 0,5 (raiz); o log é o valor de fácil interpretação mais próximo")
confere(m[["lambda_ic_inf"]] > 0, "lambda = 0 fica fora do IC 95% de Box-Cox")
confere(all(c(m[["p_B"]], m[["p_C"]], m[["p_D"]], m[["p_E"]]) < 0.001), "todos os blocos entram (p < 0,001)")
ganho <- diff(c(m[["R2a_A"]], m[["R2a_B"]], m[["R2a_C"]], m[["R2a_D"]], m[["R2a_E"]]))
confere(which.max(ganho) == 3, "maior ganho de R² ajustado com a região (bloco D)")
confere(coef("freq_15a17", "b") < 0 && coef("freq_15a17", "p") < 0.05, "mais frequência escolar, menos homicídios")
confere(coef("distorcao_em", "b") > 0 && coef("distorcao_em", "p") < 0.05, "mais distorção idade-série, mais homicídios")
confere(coef("pct_migr_10anos", "p") > 0.05, "H3: migração recente não significativa")
confere(m[["vif_renda"]] > 10, "renda, % pobres e alfabetização juntas têm VIF alto")
confere(e[["zeros_escopo"]] == 0, "nenhum município sem homicídio no escopo")
confere(min(e[["taxa_n_br"]], e[["taxa_ne_br"]]) > max(e[["taxa_se_br"]], e[["taxa_s_br"]]), "Norte e Nordeste acima de Sudeste e Sul")
med_reg <- tapply(d_eda$taxa, d_eda$regiao, median)
confere(min(med_reg[c("Norte", "Nordeste")]) > max(med_reg[c("Sudeste", "Sul")]), "boxplot: Norte e Nordeste acima de Sudeste e Sul no escopo")
confere(e[["taxa_media"]] > e[["taxa_mediana"]], "taxa: média acima da mediana")
confere(e[["assim_taxa"]] > 0, "taxa: assimetria à direita (coeficiente positivo)")
confere(round(e[["percentil_corte"]]) == 80 && e[["casos_esp_corte"]] >= 20, "o corte de 30 mil hab. fica no percentil 80 (arredondado) da população e dá pelo menos 20 homicídios esperados em 3 anos")
confere(mod$POP_MIN == eda$POP_MIN && mod$FORA == eda$FORA && setequal(mod$d$cod_ibge, d_eda$cod_ibge), "exploratória e modelo no mesmo escopo")
confere(nrow(fora) == 1 && fora$pop >= eda$POP_MIN && fora$intencao_indeterminada > 10 * fora$hom, "o município retirado tem muito mais óbitos de intenção indeterminada do que homicídios")
confere(all(p_ret(c("dens_z", "faixa_fronteira", "abandono_em", "pct_h1529", "indet_sem_hom")) > 0.05), "densidade, fronteira, abandono, % homens 15–29 e % indeterminada (corrigida) não são significativas")
al_sem_mt <- summary(update(mod$final, . ~ . + amazonia_legal, data = mod$d[mod$d$uf != "MT", ]))$coefficients["amazonia_legal", 4]
confere(p_ret("amazonia_legal") < 0.05 && al_sem_mt > 0.05, "a evidência da Amazônia Legal é sensível à exclusão de Mato Grosso")
sig_pos <- function(t) coef(t, "b") > 0 && coef(t, "p") < 0.05
confere(sig_pos("pct_urbana"), "mais homicídios com mais urbanização")
confere(sig_pos("gini_c") && sig_pos("rend_c:gini_c") && sig_pos("distorcao_em") &&
          coef("freq_15a17", "b") < 0 && coef("freq_15a17", "p") < 0.05, "sinais consistentes com H1 e H2; o efeito do Gini cresce com a renda")
confere(gr$efeito_pct[gr$percentil == 50] > 0 && gr$p[gr$percentil == 50] < 0.05 && gr$ic_sup_pct[gr$percentil == 25] > 0 && gr$ic_inf_pct[gr$percentil == 25] < 0,
        "o efeito do Gini é positivo na renda mediana e não se distingue de zero no primeiro quarto de renda")
confere(all(sapply(paste0("regiao", c("Norte", "Nordeste", "Centro-Oeste", "Sul")), sig_pos)), "taxa esperada maior no Norte, Nordeste, Centro-Oeste e Sul do que no Sudeste")
confere(mean(d_eda$regiao[d_eda$amazonia_legal == 1] == "Norte") > 0.5, "a maior parte da Amazônia Legal é a região Norte")
confere(m[["bp_p"]] < 0.05, "Breusch-Pagan rejeita H0: erros-padrão e valores p são aproximados")
confere(m[["sw_p"]] > 0.05 && m[["n_outliers"]] == 0, "Shapiro-Wilk não rejeita a normalidade e não há resíduo além de 4")
d_com <- transform(br[br$pop >= eda$POP_MIN, ], ly = log(taxa), rend_c = log_rend - mean(log_rend), gini_c = gini - mean(gini))
d_com$rend_c2 <- d_com$rend_c^2
confere(shapiro.test(rstandard(lm(formula(mod$final), d_com)))$p.value < 0.05, "com o município retirado no estudo, Shapiro-Wilk rejeitava a normalidade")
confere(mod$sw_estado$p.value < 0.05, "com estado, Shapiro-Wilk rejeita a normalidade")
cor_desocup <- cor(mod$d$desocup, mod$d$ly); cor_desocup_renda <- cor(mod$d$desocup, mod$d$log_rend)
confere(cor_desocup > 0.2 && coef("desocup", "b") < 0 && cor_desocup_renda < -0.5, "desocupação: correlação simples positiva, coeficiente negativo e correlação forte com a renda")
confere(which.max(mod$vif_final) == which(names(mod$vif_final) == "rend_c"), "VIF máximo é o da renda")
# Gini calculado pelas classes de renda x Gini oficial do IBGE nas 27 UFs
vg <- read.csv("../../entrega/dados/validacao_gini.csv"); vg <- vg[vg$nivel == "Unidade da Federação", ]
confere(nrow(vg) == 27 && cor(vg$gini_calculado, vg$gini_oficial) > 0.98 && mean(abs(vg$gini_calculado - vg$gini_oficial)) < 0.01,
        "o Gini calculado pelas classes de renda reproduz o Gini oficial das UFs")
# VIF da renda no modelo final com ln renda padronizado (média 0, DP 1) e com ln renda cru (sem centralizar)
vif2 <- function(mm) car::vif(mm)[, "GVIF^(1/(2*Df))"]^2
z <- function(x) (x - mean(x)) / sd(x)
dz <- transform(mod$d, rend_z = z(log_rend), rend_z2 = z(log_rend)^2, rend_cru2 = log_rend^2)
vif_z   <- vif2(update(mod$final, . ~ . - rend_c - rend_c2 - rend_c:gini_c + rend_z + rend_z2 + rend_z:gini_c, data = dz))
vif_cru <- vif2(update(mod$final, . ~ . - rend_c - rend_c2 - rend_c:gini_c + log_rend + rend_cru2 + log_rend:gini_c, data = dz))
confere(abs(vif_z[["rend_z"]] - mod$vif_final[["rend_c"]]) < 1e-6, "padronizar ln renda não muda o VIF")
confere(vif_cru[["log_rend"]] > 100, "sem centralizar, o VIF da renda fica muito maior")
pico_pct <- 100 * mean(mod$d$rend_pc_media < m[["pico_renda"]]); decil_pico <- which.max(eda$med_faixa$med)
confere(m[["pico_renda"]] < median(mod$d$rend_pc_media) && e[["renda_decil_pico"]] < median(mod$d$rend_pc_media), "o pico da taxa fica abaixo da renda mediana, nos dados e no modelo")
confere(abs(m[["pico_renda"]] - e[["renda_decil_pico"]]) / m[["pico_renda"]] < 0.15, "o pico do modelo fica perto do pico dos dados")
confere(max(eda$med_faixa$med[c(1, 10)]) < max(eda$med_faixa$med), "a taxa cai para os dois lados do décimo do pico")
confere(lmtest::bptest(mod$m_y)$statistic > lmtest::bptest(mod$m_log)$statistic, "com ln Y a dispersão dos resíduos fica mais uniforme do que com Y")
confere(cor(log(mod$d$pop), abs(mod$d$residuo)) < 0, "resíduos maiores nos municípios menores")

# Variável com maior correlação com ln(taxa)
r_resp <- R["ln Taxa", colnames(R) != "ln Taxa"]
var_max <- names(which.max(abs(r_resp)))

bc_final <- MASS::boxcox(lm(update(formula(mod$final), y ~ .), data = mod$d),
                         lambda = seq(-.5, 1.2, .001), plotit = FALSE)
bc_lim <- max(bc_final$y) - qchisq(.95, 1) / 2
bc_ci <- range(bc_final$x[bc_final$y > bc_lim])
bc_max <- bc_final$x[which.max(bc_final$y)]
confere(bc_ci[1] > 0, "Box-Cox final também não seleciona log")
migracao <- read.csv("../../validacao/saida/08_sensibilidade_migracao.csv", row.names = 1)
confere(abs(migracao["final", "p_migracao"] - coef("pct_migr_10anos", "p")) < 1e-10,
        "sensibilidade da migração corresponde ao mesmo modelo final")

mac <- c(
  LambdaFinal = fmt(bc_max, 2), LambdaFinalInf = fmt(bc_ci[1], 2), LambdaFinalSup = fmt(bc_ci[2], 2),
  PMigrFinal = fp(migracao["final", "p_migracao"]),
  PMigrAntiga = fp(migracao["com_medida_antiga", "p_migracao"]),
  PMigrCorrigida = fp(migracao["com_medida_corrigida", "p_migracao"]),
  MunBR = fmt(e[["municipios_br"]], 0), HomBR = fmt(e[["hom_br"]], 0), TaxaBR = fmt(e[["taxa_br"]]),
  PopMin = fmt(e[["pop_min"]] / 1000, 0), MunEsc = fmt(e[["municipios_escopo"]], 0),
  PctPopEsc = fmt(e[["pct_pop_escopo"]], 0), PercCorte = fmt(e[["percentil_corte"]], 0), PctMaiores = fmt(100 - e[["percentil_corte"]], 0),
  CasosEspCorte = fmt(e[["casos_esp_corte"]], 0), FDens = fmt(ret$F[ret$termo == "dens_z"], 2), PDens = fmt(p_ret("dens_z"), 2),
  ForaNome = paste0(fora$municipio, "-", fora$uf), ForaHom = fmt(fora$hom, 0), ForaIndet = fmt(fora$intencao_indeterminada, 0),
  GiniZero = fmt(mod$renda_gini_zero, 0), GiniZeroPct = fmt(100 * mean(mod$d$rend_pc_media < mod$renda_gini_zero), 0),
  GiniEfMediana = sinal(gr$efeito_pct[gr$percentil == 50]), GiniEfNoventa = sinal(gr$efeito_pct[gr$percentil == 90]),
  CorDesocup = sinal(cor_desocup, 2), CorDesocupRenda = sinal(cor_desocup_renda, 2), RdoisPct = fmt(100 * m[["R2a"]], 0), SWpEstado = fp(mod$sw_estado$p.value),
  FInter = fmt(m[["F_E"]]), RdoisAsemInter = fmt(m[["R2a_D"]], 2), PMigr = fmt(coef("pct_migr_10anos", "p"), 2), ZerosBR = fmt(e[["zeros_br"]], 0),
  TaxaMedia = fmt(e[["taxa_media"]]), TaxaMediana = fmt(e[["taxa_mediana"]]),
  TaxaQuartilUm = fmt(unname(quantile(d_eda$taxa, .25))), TaxaQuartilTres = fmt(unname(quantile(d_eda$taxa, .75))),
  AssimTaxa = fmt(e[["assim_taxa"]], 2),
  HomAno = fmt(e[["hom_ano"]], 0), TaxaMundo = fmt(e[["taxa_mundo"]]), RazaoMundo = fmt(e[["razao_mundo"]]),
  TaxaNbr = fmt(e[["taxa_n_br"]]), TaxaNEbr = fmt(e[["taxa_ne_br"]]), TaxaCObr = fmt(e[["taxa_co_br"]]),
  TaxaSEbr = fmt(e[["taxa_se_br"]]), TaxaSbr = fmt(e[["taxa_s_br"]]),
  CorMax = fmt(abs(r_resp[[var_max]]), 2), CorMaxVar = gsub("%", "\\\\%", var_max),
  CorTrio = fmt(max(abs(c(e[["cor_renda_pobres"]], e[["cor_renda_alfabet"]]))), 2),
  RendaDecilPico = fmt(e[["renda_decil_pico"]], 0), DecilPico = fmt(decil_pico, 0), PicoPct = fmt(pico_pct, 0),
  RendaMediana = fmt(median(mod$d$rend_pc_media), 0),
  PorteHomMenor = fmt(e[["porte_hom_mediana_menor5mil"]], 0), PorteOscMenor = fmt(e[["porte_oscilacao_menor5mil"]], 0),
  PorteOscCorte = fmt(e[["porte_oscilacao_corte"]], 0),
  Lambda = fmt(m[["lambda"]], 2), LambdaInf = fmt(m[["lambda_ic_inf"]], 2), LambdaSup = fmt(m[["lambda_ic_sup"]], 2),
  SWy = fmt(m[["sw_y"]], 2), SWln = fmt(m[["sw_ln"]], 2), VIFrenda = fmt(m[["vif_renda"]], 0),
  RdoisA = fmt(m[["R2a"]], 2),
  FblocoEd = fmt(m[["F_C"]]), RdoisAsemEd = fmt(m[["R2a_B"]], 2), RdoisAcomEd = fmt(m[["R2a_C"]], 2), Fglobal = fmt(m[["F_global"]], 0), GlUm = fmt(m[["gl1"]], 0), GlDois = fmt(m[["gl2"]], 0),
  Pico = fmt(m[["pico_renda"]], 0), BP = fmt(m[["bp"]], 0),
  SW = fmt(m[["sw"]], 3), Nout = fmt(m[["n_outliers"]], 0),
  SWp = fp(m[["sw_p"]]), BPgl = fmt(m[["bp_gl"]], 0), BPp = fp(m[["bp_p"]]),
  RdoisE = fmt(m[["R2_E"]], 2), Sigma = fmt(m[["sigma"]], 3),
  FglobalP = fp(m[["F_global_p"]]), VIFrendaFinal = fmt(m[["vif_renda_final"]]), VIFdemaisMax = fmt(m[["vif_demais_max"]]), VIFrendaCru = fmt(vif_cru[["log_rend"]], 0),
  GiniCorUF = fmt(cor(vg$gini_calculado, vg$gini_oficial), 3), GiniErroUF = fmt(mean(abs(vg$gini_calculado - vg$gini_oficial)), 3),
  NumReg = fmt(m[["n_reg"]], 0), NumX = fmt(m[["n_x"]], 0), NumPar = fmt(m[["gl1"]] + 1, 0),
  CorQuadSem = fmt(m[["cor_quad_sem"]], 4), CorQuadCen = fmt(m[["cor_quad_cen"]], 2),
  BetaDois = fmt(coef("rend_c2", "b"), 3), BetaDoisP = fp(coef("rend_c2", "p")),
  OutNomes = if (length(out_nomes)) paste(out_nomes, collapse = ", ") else "nenhum")
mac <- sub("^-", "$-$", mac)
writeLines(sprintf("\\newcommand{\\n%s}{%s}", names(mac), mac), "numeros.tex")

extra <- c(GiniEfDez = sinal(gr$efeito_pct[gr$percentil == 10]),
           GiniEfVinteCinco = sinal(gr$efeito_pct[gr$percentil == 25]),
           RendaDez = fmt(gr$renda[gr$percentil == 10], 0),
           RendaNoventa = fmt(gr$renda[gr$percentil == 90], 0),
           EscolaEfeito = sinal(efe$efeito_pct[efe$termo == "freq_15a17"], 1),
           DistorcaoEfeito = sinal(efe$efeito_pct[efe$termo == "distorcao_em"], 1),
           UrbanaEfeito = sinal(efe$efeito_pct[efe$termo == "pct_urbana"], 1))
cat(paste(sprintf("\\newcommand{\\n%s}{%s}", names(extra), extra), collapse = "\n"),
    "\n", sep = "", file = "numeros.tex", append = TRUE)

# Tabela do corte de população (percentil 80) em cada região
cr <- as.data.frame(eda$corte_regiao)
lin <- sprintf("%s & %s & %s & %s\\%%\\\\", cr$regiao, fmt(cr$municipios, 0), fmt(cr$considerados, 0), fmt(cr$pct_pop, 0))
writeLines(c("\\begin{tabular}{@{}lrrr@{}}", "\\toprule",
             "\\textbf{Região} & \\textbf{Municípios} & \\textbf{Ficam} & \\textbf{População coberta}\\\\", "\\midrule",
             lin, "\\bottomrule", "\\end{tabular}"), "tabelas/corte_regiao.tex")

# Tabela-resumo da exploratória: resposta e explicativas do modelo (casas decimais por variável)
casas <- c(taxa = 1, rend_pc_media = 0, gini = 3, desocup = 1, pct_urbana = 1,
           freq_15a17 = 1, distorcao_em = 1, pct_migr_10anos = 1)
rotulo <- c(taxa = "Taxa de homicídios (/100 mil)", rend_pc_media = "Renda per capita (R\\$)",
            gini = "Desigualdade (índice de Gini)", desocup = "Desocupação (\\%)", pct_urbana = "Urbana (\\%)",
            freq_15a17 = "Frequência escolar 15--17 (\\%)", distorcao_em = "Distorção idade-série EM (\\%)",
            pct_migr_10anos = "Migração recente (\\%)")
ds <- as.data.frame(eda$desc)[match(names(casas), eda$desc$name), ]
stopifnot(!anyNA(ds$name))
num <- function(col) mapply(function(x, k) sub("^-", "$-$", fmt(x, k)), ds[[col]], casas)
lin <- sprintf("%s%s & %s & %s & %s & %s & %s\\\\", ifelse(ds$name == "taxa", "\\rowcolor{fundo}", ""),
               rotulo[ds$name], num("media"), num("dp"), num("min"), num("mediana"), num("max"))
writeLines(c("\\begin{tabular}{@{}lrrrrr@{}}", "\\toprule",
             "\\textbf{Variável} & \\textbf{Média} & \\textbf{DP} & \\textbf{Mín.} & \\textbf{Mediana} & \\textbf{Máx.}\\\\",
             "\\midrule", lin, "\\bottomrule", "\\end{tabular}"), "tabelas/descritiva.tex")

# Tabela do modelo com e sem a renda (sem as indicadoras de região); em negrito, onde a significância a 5% muda
cs <- mod$com_sem[!grepl("^regiao", mod$com_sem$termo), ]
rot_cs <- c(gini_c = "Desigualdade (Gini)", desocup = "Desocupação", pct_urbana = "\\% urbana",
            freq_15a17 = "Freq. escolar 15--17", distorcao_em = "Distorção EM", pct_migr_10anos = "Migração recente")
stopifnot(all(cs$termo %in% names(rot_cs)))
muda <- (cs$p_com < 0.05) != (cs$p_sem < 0.05)
cel <- cbind(rot_cs[cs$termo], gsub("-", "$-$", fmt(cs$b_com, 3)), fp(cs$p_com), gsub("-", "$-$", fmt(cs$b_sem, 3)), fp(cs$p_sem))
cel[muda, ] <- paste0("\\textbf{", cel[muda, ], "}")
writeLines(c("\\begin{tabular}{@{}lrrrr@{}}", "\\toprule",
             " & \\multicolumn{2}{c}{\\textbf{Com renda}} & \\multicolumn{2}{c}{\\textbf{Sem renda}}\\\\",
             "\\textbf{Termo} & \\textbf{$b$} & \\textbf{$p$} & \\textbf{$b$} & \\textbf{$p$}\\\\", "\\midrule",
             paste0(apply(cel, 1, paste, collapse = " & "), "\\\\"), "\\bottomrule", "\\end{tabular}"), "tabelas/com_sem_renda.tex")
p_cs <- function(t, col) cs[cs$termo == t, col]
confere(mod$F_renda$`Pr(>F)`[2] < 0.001 && mod$sf_$adj.r.squared > mod$ss_$adj.r.squared, "a renda contribui para o modelo (F parcial) e o R² ajustado cai sem ela")
confere(max(mod$vif_sem_renda) < max(mod$vif_final) && max(mod$vif_final) < 10, "VIF máximo abaixo de 10 com a renda e menor sem ela")
confere(all(sapply(c("gini_c", "desocup"), function(t) p_cs(t, "p_sem") > 0.05 && p_cs(t, "p_com") < 0.05)),
        "sem a renda, desigualdade e desocupação deixam de ser significativas")
confere(p_cs("freq_15a17", "p_sem") < 0.05 && p_cs("distorcao_em", "p_sem") < 0.05, "sem a renda, frequência escolar e distorção continuam significativas")
cat(sprintf("\\newcommand{\\nFRenda}{%s}\n\\newcommand{\\nGlRenda}{%s}\n\\newcommand{\\nPRenda}{%s}\n\\newcommand{\\nRdoisAsemRenda}{%s}\n\\newcommand{\\nVIFmaxSemRenda}{%s}\n",
            fmt(mod$F_renda$F[2]), fmt(mod$F_renda$Df[2], 0), fp(mod$F_renda$`Pr(>F)`[2]), fmt(mod$ss_$adj.r.squared, 2), fmt(max(mod$vif_sem_renda))),
    file = "numeros.tex", append = TRUE)

# Tabela dos dois modelos lado a lado: região x estado; em negrito, onde a significância a 5% muda
re <- mod$regiao_estado
rot_re <- c(rend_c = "ln renda (centr.)", rend_c2 = "ln renda²", rot_cs, `rend_c:gini_c` = "Gini $\\times$ renda")
stopifnot(all(re$termo %in% names(rot_re)))
muda <- (re$p_regiao < 0.05) != (re$p_estado < 0.05)
cel <- cbind(rot_re[re$termo], gsub("-", "$-$", fmt(re$b_regiao, 3)), fp(re$p_regiao), gsub("-", "$-$", fmt(re$b_estado, 3)), fp(re$p_estado))
cel[muda, ] <- paste0("\\textbf{", cel[muda, ], "}")
writeLines(c("\\begin{tabular}{@{}lrrrr@{}}", "\\toprule",
             " & \\multicolumn{2}{c}{\\textbf{Com região}} & \\multicolumn{2}{c}{\\textbf{Com estado}}\\\\",
             "\\textbf{Termo} & \\textbf{$b$} & \\textbf{$p$} & \\textbf{$b$} & \\textbf{$p$}\\\\", "\\midrule",
             paste0(apply(cel, 1, paste, collapse = " & "), "\\\\"), "\\bottomrule", "\\end{tabular}"), "tabelas/regiao_x_estado.tex")
p_re <- function(t, col) re[re$termo == t, col]
confere(mod$F_estado$`Pr(>F)`[2] < 0.001 && mod$se_$adj.r.squared > mod$sf_$adj.r.squared, "o estado explica mais que a região (F parcial e R² ajustado)")
confere(max(mod$vif_estado) > 10 && max(mod$vif_final) < 10, "VIF máximo acima de 10 com estado e abaixo de 10 com região")
confere(all(sapply(c("rend_c:gini_c", "distorcao_em"), function(t) p_re(t, "p_estado") < 0.05 && p_re(t, "b_estado") > 0)) &&
          p_re("freq_15a17", "p_estado") < 0.05 && p_re("freq_15a17", "b_estado") < 0, "o termo Gini x renda e as medidas de escola são significativos nos dois modelos")
confere(p_re("gini_c", "p_regiao") < 0.05 && p_re("gini_c", "p_estado") > 0.05, "na renda média, o Gini só é significativo com região")
cat(sprintf("\\newcommand{\\nNumParEstado}{%s}\n\\newcommand{\\nRdoisAestado}{%s}\n\\newcommand{\\nVIFmaxEstado}{%s}\n\\newcommand{\\nFEstado}{%s}\n\\newcommand{\\nGlEstado}{%s}\n\\newcommand{\\nPEstado}{%s}\n\\newcommand{\\nNumUFpoucos}{%s}\n",
            fmt(length(stats::coef(mod$com_estado)), 0), fmt(mod$se_$adj.r.squared, 2), fmt(max(mod$vif_estado)), fmt(mod$F_estado$F[2]), fmt(mod$F_estado$Df[2], 0),
            fp(mod$F_estado$`Pr(>F)`[2]), fmt(sum(table(mod$d$uf) < 10), 0)), file = "numeros.tex", append = TRUE)

# Tabela dos blocos (F parcial e R² ajustado)
bloco <- function(nome, k, neg = FALSE) {
  cel <- c(nome, fmt(m[[paste0("gl_", k)]], 0), fmt(m[[paste0("F_", k)]]), fp(m[[paste0("p_", k)]]), fmt(m[[paste0("R2a_", k)]], 2))
  if (neg) cel <- paste0("\\textbf{", cel, "}")
  paste0(if (neg) "\\rowcolor{fundo}" else "", paste(cel, collapse = " & "), "\\\\")
}
writeLines(c("\\begin{tabular}{@{}lrrrr@{}}", "\\toprule",
             "\\textbf{Bloco} & \\textbf{gl} & \\textbf{$F$ parcial} & \\textbf{$p$} & \\textbf{$R^2_a$}\\\\", "\\midrule",
             sprintf("A: socioeconômico & --- & --- & --- & %s\\\\", fmt(m[["R2a_A"]], 2)),
             bloco("B: + urbanização", "B"), bloco("C: + educação e migração", "C"),
             bloco("D: + região", "D", neg = TRUE), bloco("E: + Gini $\\times$ renda", "E"),
             "\\bottomrule", "\\end{tabular}"), "tabelas/blocos.tex")

# Tabela de efeitos na taxa (%): só as significativas; as n.s. viram a macro \nNaoSig
efe <- efe[order(-abs(efe$efeito_pct)), ]
ns <- efe$p >= 0.05
cat(sprintf("\\newcommand{\\nNaoSig}{%s}\n", paste(tolower(gsub("%", "\\\\%", efe$variavel[ns])), collapse = ", ")),
    file = "numeros.tex", append = TRUE)
efe <- efe[!ns, ]
# Hipótese do slide da questão de pesquisa que cada variável testa (H1 desigualdade, H2 escola, H3 migração)
hip <- c(freq_15a17 = "H2", distorcao_em = "H2", pct_migr_10anos = "H3")
efe$hip <- ifelse(efe$termo %in% names(hip), hip[efe$termo], "")
# Gini: o efeito depende da renda; a tabela mostra os percentis 10, 50 e 90 da renda
g3 <- gr[gr$percentil %in% c(10, 50, 90), ]
lin_gini <- sprintf("H1 & Gini (renda de R\\$ %s) & +0,05 & %s\\%% & [%s; %s] & %s\\\\", fmt(g3$renda, 0),
                    sinal(g3$efeito_pct, 1), sinal(g3$ic_inf_pct, 1), sinal(g3$ic_sup_pct, 1), fp(g3$p))
lin <- sprintf("%s & %s & %s & %s\\%% & [%s; %s] & %s\\\\", efe$hip, gsub("%", "\\\\%", efe$variavel), efe$mudanca,
               sinal(efe$efeito_pct, 1), sinal(efe$ic_inf_pct, 1), sinal(efe$ic_sup_pct, 1), fp(efe$p))
writeLines(c("\\begin{tabular}{@{}cllrcr@{}}", "\\toprule",
             "\\textbf{Hip.} & \\textbf{Variável} & \\textbf{Mudança} & \\textbf{Taxa} & \\textbf{IC 95\\%} & \\textbf{$p$}\\\\", "\\midrule",
             sprintf(" & Renda & --- & U invertido & --- & %s\\\\", fp(coef("rend_c2", "p"))),
             lin_gini, lin, "\\bottomrule", "\\end{tabular}"), "tabelas/efeitos.tex")

# Apêndice: coeficientes
nomes <- c(rend_c = "ln renda (centr.)", rend_c2 = "ln renda²", gini_c = "Desigualdade (Gini, centr.)", `rend_c:gini_c` = "Gini $\\times$ renda",
           desocup = "Desocupação", pct_urbana = "\\% urbana",
           freq_15a17 = "Freq. escolar 15--17", distorcao_em = "Distorção EM",
           pct_migr_10anos = "Migração recente", regiaoNorte = "Norte", regiaoNordeste = "Nordeste",
           `regiaoCentro-Oeste` = "Centro-Oeste", regiaoSul = "Sul")
cc <- coefs[match(names(nomes), coefs$termo), ]
cel <- sprintf("%s & %s & %s & %s", nomes, gsub("-", "$-$", fmt(cc$b, 3)), fmt(cc$ep, 3), fp(cc$p))
k <- ceiling(length(cel) / 2)
lin <- paste(cel[1:k], c(cel[(k + 1):length(cel)], rep(" & & & ", 2 * k - length(cel))), sep = " & ")
writeLines(c("\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}lrrrlrrr@{}}", "\\toprule",
             paste0("\\textbf{Termo} & \\textbf{$b$} & \\textbf{EP} & \\textbf{$p$} & ",
                    "\\textbf{Termo} & \\textbf{$b$} & \\textbf{EP} & \\textbf{$p$}\\\\"), "\\midrule",
             paste0(lin, "\\\\"), "\\bottomrule", "\\end{tabular*}"), "tabelas/coeficientes.tex")

# Apêndice: variáveis testadas e retiradas (F parcial de cada uma somada ao modelo final)
motivo <- c(dens_z = "Sem evidência adicional", faixa_fronteira = "Sem evidência adicional", abandono_em = "Sem evidência adicional", pct_h1529 = "Sem evidência adicional",
            amazonia_legal = "Sem evidência clara ao excluir MT",
            indet_sem_hom = "A medida original tinha os homicídios no divisor; corrigida, sem evidência adicional")
stopifnot(all(ret$termo %in% names(motivo)))
lin <- sprintf("%s & %s & %s & %s\\\\", gsub("%", "\\%", gsub("–", "--", ret$variavel), fixed = TRUE), fmt(ret$F, 2), fp(ret$p), motivo[ret$termo])
writeLines(c("\\begin{tabular}{@{}p{0.36\\textwidth}rrp{0.40\\textwidth}@{}}", "\\toprule",
             "\\textbf{Variável} & \\textbf{$F$} & \\textbf{$p$} & \\textbf{Motivo da retirada}\\\\", "\\midrule",
             lin, "\\bottomrule", "\\end{tabular}"), "tabelas/retiradas.tex")

cat("numeros.tex e tabelas/ gerados. Variável de maior correlação com ln(taxa):", var_max, "\n")

library(ggplot2)
dir.create("figuras", showWarnings = FALSE)
azul <- "#00689D"; vermelho <- "#C8343B"; claro <- "#D6E6F2"
tema <- theme_minimal(base_size = 16) +
  theme(panel.grid.minor = element_blank(), plot.background = element_rect(fill = "white", colour = NA))
plot_d <- mod$d
p <- ggplot(plot_d, aes(ajustado, residuo)) +
  geom_hline(yintercept = 0, colour = "grey45", linetype = 2) +
  geom_point(colour = azul, alpha = .3, size = 1.2) +
  labs(x = "Valor ajustado de ln(taxa)", y = "Resíduo de ln(taxa)") + tema
ggsave("figuras/residuos_ajustado.png", p, width = 6.3, height = 4.0, dpi = 220)
p <- ggplot(plot_d, aes(pop, abs(residuo))) +
  geom_point(colour = azul, alpha = .3, size = 1.2) +
  scale_x_log10(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(x = "População (escala log)", y = "Tamanho do erro: |resíduo|") + tema
ggsave("figuras/residuos_populacao.png", p, width = 6.3, height = 4.0, dpi = 220)
p <- ggplot(plot_d, aes(sample = rstandard(mod$final))) +
  stat_qq(colour = azul, alpha = .35, size = 1.1) + stat_qq_line(colour = vermelho, linewidth = .8) +
  labs(x = "Quantis de uma distribuição normal", y = "Quantis dos resíduos padronizados") + tema
ggsave("figuras/qq_final.png", p, width = 6.3, height = 4.0, dpi = 220)
p <- ggplot(plot_d, aes(residuo)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = claro, colour = "white") +
  stat_function(fun = dnorm, args = list(mean = mean(plot_d$residuo), sd = sd(plot_d$residuo)),
                colour = vermelho, linewidth = .8) +
  labs(x = "Resíduo de ln(taxa)", y = "Densidade") + tema
ggsave("figuras/histograma_residuos.png", p, width = 6.3, height = 4.0, dpi = 220)
ef_plot <- mod$mudancas[mod$mudancas$termo != "desocup", ]
ef_plot$rotulo <- c("Urbanização: +10 p.p.", "Frequência escolar: +5 p.p.",
                    "Atraso escolar: +10 p.p.", "Migração recente: +5 p.p.")
ef_plot$rotulo <- factor(ef_plot$rotulo, levels = rev(ef_plot$rotulo))
p <- ggplot(ef_plot, aes(efeito_pct, rotulo)) +
  geom_vline(xintercept = 0, colour = "grey45", linetype = 2) +
  geom_segment(aes(x = ic_inf_pct, xend = ic_sup_pct, yend = rotulo), colour = azul, linewidth = 1.1) +
  geom_point(colour = azul, size = 3.5) +
  labs(x = "Mudança percentual na taxa típica", y = NULL) + tema
ggsave("figuras/efeitos.png", p, width = 8, height = 4.2, dpi = 220)
efeito_grafico <- mod$efeito_gini
environment(efeito_grafico) <- mod
gini_plot <- efeito_grafico(exp(seq(quantile(plot_d$log_rend, .02), quantile(plot_d$log_rend, .98), length.out = 200)))
p <- ggplot(gini_plot, aes(renda, efeito_pct)) +
  geom_ribbon(aes(ymin = ic_inf_pct, ymax = ic_sup_pct), fill = claro, alpha = .8) +
  geom_hline(yintercept = 0, colour = "grey45", linetype = 2) +
  geom_line(colour = azul, linewidth = 1) +
  geom_point(data = gr[gr$percentil %in% c(10, 50, 90), ], colour = vermelho, size = 2.7) +
  scale_x_log10(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(x = "Renda per capita (R$, escala log)", y = "Mudança na taxa típica: +0,05 no Gini (%)") + tema
ggsave("figuras/gini_renda.png", p, width = 7.2, height = 4.3, dpi = 220)
p <- ggplot(mod$grade, aes(rend, taxa, group = regiao)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = claro, alpha = .65) +
  geom_line(aes(colour = regiao), linewidth = 1) +
  scale_colour_manual(values = c(Nordeste = azul, Sudeste = "#13294B"), name = NULL) +
  scale_x_log10(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(x = "Renda per capita (R$, escala log)", y = "Taxa típica ajustada (/100 mil/ano)") +
  tema + theme(legend.position = "bottom")
ggsave("figuras/renda_regiao.png", p, width = 7.2, height = 4.3, dpi = 220)
stopifnot(identical(as.character(ef_plot$termo), as.character(mod$mudancas$termo[mod$mudancas$termo != "desocup"])))

painel_vars <- list(c("log_rend", "gini", "desocup", "pct_urbana"),
                   c("freq_15a17", "distorcao_em", "pct_migr_10anos", "regiao"))
nomes_diag <- c(log_rend = "ln(renda per capita)", gini = "Gini calculado",
                desocup = "Desocupação (%)", pct_urbana = "População urbana (%)",
                freq_15a17 = "Frequência escolar 15–17 (%)", distorcao_em = "Atraso escolar (%)",
                pct_migr_10anos = "Migração recente (%)", regiao = "Região")
for (k in seq_along(painel_vars)) {
  png(sprintf("figuras/residuos_explicativas_%d.png", k), width = 2200, height = 1400, res = 220)
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 2)))
  for (j in seq_along(painel_vars[[k]])) {
    v <- painel_vars[[k]][j]
    p <- ggplot(plot_d, aes(x = .data[[v]], y = residuo)) +
      geom_hline(yintercept = 0, colour = "grey45", linetype = 2)
    if (v == "regiao") {
      p <- p + geom_boxplot(fill = claro, colour = azul, outlier.alpha = .25)
    } else {
      p <- p + geom_point(colour = azul, alpha = .28, size = .8)
    }
    p <- p + labs(x = nomes_diag[[v]], y = "Resíduo de ln(taxa)") + tema +
      theme(text = element_text(size = 12), axis.text.x = element_text(size = 9))
    print(p, vp = grid::viewport(layout.pos.row = (j - 1) %/% 2 + 1,
                                layout.pos.col = (j - 1) %% 2 + 1))
  }
  dev.off()
}

p <- ggplot(plot_d, aes(ajustado, ly)) +
  geom_abline(intercept = 0, slope = 1, colour = vermelho, linetype = 2) +
  geom_point(colour = azul, alpha = .35, size = 1.1) + coord_equal() +
  labs(x = "ln(taxa) ajustado", y = "ln(taxa) observado") + tema
ggsave("figuras/observado_ajustado.png", p, width = 6.3, height = 4.3, dpi = 220)

p <- ggplot(data.frame(lambda = bc_final$x, perfil = bc_final$y), aes(lambda, perfil)) +
  geom_line(colour = azul, linewidth = .8) +
  geom_hline(yintercept = bc_lim, linetype = 2, colour = "grey45") +
  geom_vline(xintercept = 0, colour = vermelho, linetype = 2) +
  geom_vline(xintercept = bc_max, colour = azul, linetype = 3) +
  coord_cartesian(xlim = c(-.05, .4), ylim = c(bc_lim - 20, max(bc_final$y) + 3)) +
  labs(x = "Potência (zero corresponde ao log)", y = "Log-verossimilhança de perfil",
       subtitle = "IC 95%: perfil acima da linha cinza") + tema
ggsave("figuras/boxcox_final.png", p, width = 6.3, height = 4.3, dpi = 220)
