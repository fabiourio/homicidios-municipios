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
mod <- roda("2_modelo_preliminar.R")
setwd(atual)

br <- eda$br; d_eda <- eda$d; porte <- as.data.frame(eda$porte); R <- eda$R
reg <- tapply(d_eda$hom, d_eda$regiao, sum) / tapply(d_eda$exposure, d_eda$regiao, sum) * 1e5
reg_br <- tapply(br$hom, br$regiao, sum) / tapply(br$exposure, br$regiao, sum) * 1e5   # todos os municípios
# Taxa mundial de homicídios em 2021: UNODC, Global Study on Homicide 2023 (único número externo, com fonte no slide)
TAXA_MUNDO_UNODC <- 5.8
cv <- eda$cv
e <- c(
  municipios_br = nrow(br), hom_br = sum(br$hom), taxa_br = eda$taxa_br, pop_min = eda$POP_MIN,
  municipios_escopo = nrow(d_eda), pct_pop_escopo = 100 * sum(d_eda$pop) / sum(br$pop),
  dens_extremos = sum(br$dens_extrema),
  zeros_escopo = sum(d_eda$hom == 0), zeros_br = sum(br$hom == 0),
  taxa_media = mean(d_eda$taxa), taxa_mediana = median(d_eda$taxa),
  assim_taxa = eda$assimetria(d_eda$taxa), assim_ln_taxa = eda$assimetria(d_eda$ln_taxa),
  taxa_nordeste = reg[["Nordeste"]], taxa_sudeste = reg[["Sudeste"]],
  hom_ano = sum(br$hom) / 3, taxa_mundo = TAXA_MUNDO_UNODC, razao_mundo = eda$taxa_br / TAXA_MUNDO_UNODC,
  taxa_n_br = reg_br[["N"]], taxa_ne_br = reg_br[["NE"]], taxa_co_br = reg_br[["CO"]],
  taxa_se_br = reg_br[["SE"]], taxa_s_br = reg_br[["S"]],
  cor_renda_pobres = R["ln Renda", "% pobres"], cor_renda_alfabet = R["ln Renda", "Alfabetização"],
  renda_decil_pico = eda$med_faixa$renda[which.max(eda$med_faixa$med)],
  porte_hom_mediana_menor5mil = porte$hom_mediana_3anos[1], porte_oscilacao_menor5mil = porte$oscilacao[1],
  porte_cor2024_menor5mil = porte$cor_2024[1], porte_cor2024_maior100mil = porte$cor_2024[6],
  porte_oscilacao_20a50mil = porte$oscilacao[4], porte_zero_20a50mil = porte$pct_zero[4])

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
    n_reg = nlevels(d$regiao) - 1, n_x = length(coef(final)) - 3 - (nlevels(d$regiao) - 1),
    cor_quad_sem = unname(cor_quad[1]), cor_quad_cen = unname(cor_quad[2])))
out_nomes <- with(mod$outliers, paste0(municipio, "-", uf))
efe <- mod$mudancas; coefs <- mod$coefs

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
confere(which.max(ganho) == 4, "maior ganho de R² ajustado com a região (bloco E)")
confere(coef("freq_15a17", "b") < 0 && coef("freq_15a17", "p") < 0.05, "mais frequência escolar, menos homicídios")
confere(all(sapply(c("distorcao_em", "pct_migr_10anos"), function(t) coef(t, "b") > 0 && coef(t, "p") < 0.05)), "mais distorção e migração recente, mais homicídios")
confere(m[["vif_renda"]] > 10, "renda, % pobres e alfabetização juntas têm VIF alto")
confere(e[["zeros_escopo"]] == 0, "nenhum município sem homicídio no escopo")
confere(min(e[["taxa_n_br"]], e[["taxa_ne_br"]]) > max(e[["taxa_se_br"]], e[["taxa_s_br"]]), "Norte e Nordeste acima de Sudeste e Sul")
med_reg <- tapply(d_eda$taxa, d_eda$regiao, median)
confere(min(med_reg[c("Norte", "Nordeste")]) > max(med_reg[c("Sudeste", "Sul")]), "boxplot: Norte e Nordeste acima de Sudeste e Sul no escopo")
confere(e[["taxa_media"]] > e[["taxa_mediana"]], "taxa: média acima da mediana")
confere(e[["assim_taxa"]] > 0, "taxa: assimetria à direita (coeficiente positivo)")
confere(e[["dens_extremos"]] > 0 && all(d_eda$p_dens > eda$P_CORTE & d_eda$p_dens < 100 - eda$P_CORTE), "densidade: ficam só os municípios entre os percentis de corte da sua região")
confere(m[["n"]] == e[["municipios_escopo"]], "exploratória e modelo no mesmo escopo")
confere(e[["porte_zero_20a50mil"]] == 0, "a partir de 20 mil hab. nenhum município tem taxa zero")
sig_pos <- function(t) coef(t, "b") > 0 && coef(t, "p") < 0.05
confere(sig_pos("pct_urbana"), "mais homicídios com mais urbanização")
confere(sig_pos("gini") && sig_pos("distorcao_em") && sig_pos("pct_migr_10anos") &&
          coef("freq_15a17", "b") < 0 && coef("freq_15a17", "p") < 0.05, "sinais consistentes com H1, H2 e H3")
confere(coef("abandono_em", "p") > 0.05, "H2: abandono no ensino médio não significativo")
confere(all(sapply(paste0("regiao", c("Norte", "Nordeste", "Centro-Oeste", "Sul")), sig_pos)), "taxa esperada maior no Norte, Nordeste, Centro-Oeste e Sul do que no Sudeste")
confere(mean(d_eda$regiao[d_eda$amazonia_legal == 1] == "Norte") > 0.5, "a maior parte da Amazônia Legal é a região Norte")
confere(m[["bp_p"]] < 0.05, "Breusch-Pagan rejeita H0: erros-padrão e valores p são aproximados")
confere(m[["sw_p"]] < 0.05 && m[["sw"]] >= 0.97, "Shapiro-Wilk rejeita com W próximo de 1 (n grande)")
confere(which.max(mod$vif_final) == which(names(mod$vif_final) == "rend_c"), "VIF máximo é o da renda")
# Gini calculado pelas classes de renda x Gini oficial do IBGE nas 27 UFs
vg <- read.csv("../../entrega/dados/validacao_gini.csv"); vg <- vg[vg$nivel == "Unidade da Federação", ]
confere(nrow(vg) == 27 && cor(vg$gini_calculado, vg$gini_oficial) > 0.98 && mean(abs(vg$gini_calculado - vg$gini_oficial)) < 0.01,
        "o Gini calculado pelas classes de renda reproduz o Gini oficial das UFs")
# VIF da renda no modelo final com ln renda padronizado (média 0, DP 1) e com ln renda cru (sem centralizar)
vif2 <- function(mm) car::vif(mm)[, "GVIF^(1/(2*Df))"]^2
z <- function(x) (x - mean(x)) / sd(x)
dz <- transform(mod$d, rend_z = z(log_rend), rend_z2 = z(log_rend)^2, rend_cru2 = log_rend^2)
vif_z   <- vif2(update(mod$final, . ~ . - rend_c - rend_c2 + rend_z + rend_z2, data = dz))
vif_cru <- vif2(update(mod$final, . ~ . - rend_c - rend_c2 + log_rend + rend_cru2, data = dz))
confere(abs(vif_z[["rend_z"]] - mod$vif_final[["rend_c"]]) < 1e-6, "padronizar ln renda não muda o VIF")
confere(vif_cru[["log_rend"]] > 100, "sem centralizar, o VIF da renda fica muito maior")
confere(lmtest::bptest(mod$m_y)$statistic > lmtest::bptest(mod$m_log)$statistic, "com ln Y a dispersão dos resíduos fica mais uniforme do que com Y")
confere(cor(log(mod$d$pop), abs(mod$d$residuo)) < 0, "resíduos maiores nos municípios menores")

# Diagnóstico: ícone e texto decididos pelo teste (5%)
bp_ok <- m[["bp_p"]] > 0.05
sw_ok <- m[["sw"]] >= 0.97

# Variável com maior correlação com ln(taxa)
r_resp <- R["ln Taxa", colnames(R) != "ln Taxa"]
var_max <- names(which.max(abs(r_resp)))

mac <- c(
  MunBR = fmt(e[["municipios_br"]], 0), HomBR = fmt(e[["hom_br"]], 0), TaxaBR = fmt(e[["taxa_br"]]),
  PopMin = fmt(e[["pop_min"]] / 1000, 0), MunEsc = fmt(e[["municipios_escopo"]], 0),
  PctPopEsc = fmt(e[["pct_pop_escopo"]], 0), DensExt = fmt(e[["dens_extremos"]], 0), ZerosBR = fmt(e[["zeros_br"]], 0),
  TaxaMedia = fmt(e[["taxa_media"]]), TaxaMediana = fmt(e[["taxa_mediana"]]),
  TaxaQuartilUm = fmt(unname(quantile(d_eda$taxa, .25))), TaxaQuartilTres = fmt(unname(quantile(d_eda$taxa, .75))),
  AssimTaxa = fmt(e[["assim_taxa"]], 2), AssimLn = fmt(e[["assim_ln_taxa"]], 2),
  TaxaNE = fmt(e[["taxa_nordeste"]]), TaxaSE = fmt(e[["taxa_sudeste"]]),
  HomAno = fmt(e[["hom_ano"]], 0), TaxaMundo = fmt(e[["taxa_mundo"]]), RazaoMundo = fmt(e[["razao_mundo"]]),
  TaxaNbr = fmt(e[["taxa_n_br"]]), TaxaNEbr = fmt(e[["taxa_ne_br"]]), TaxaCObr = fmt(e[["taxa_co_br"]]),
  TaxaSEbr = fmt(e[["taxa_se_br"]]), TaxaSbr = fmt(e[["taxa_s_br"]]),
  CorMax = fmt(abs(r_resp[[var_max]]), 2), CorMaxVar = gsub("%", "\\\\%", var_max),
  CorTrio = fmt(max(abs(c(e[["cor_renda_pobres"]], e[["cor_renda_alfabet"]]))), 2),
  RendaDecilPico = fmt(e[["renda_decil_pico"]], 0),
  PorteHomMenor = fmt(e[["porte_hom_mediana_menor5mil"]], 0), PorteOscMenor = fmt(e[["porte_oscilacao_menor5mil"]], 0),
  PorteCorMenor = fmt(e[["porte_cor2024_menor5mil"]], 2), PorteCorMaior = fmt(e[["porte_cor2024_maior100mil"]], 2),
  PorteOscVinte = fmt(e[["porte_oscilacao_20a50mil"]], 0),
  Lambda = fmt(m[["lambda"]], 2), LambdaInf = fmt(m[["lambda_ic_inf"]], 2), LambdaSup = fmt(m[["lambda_ic_sup"]], 2),
  SWy = fmt(m[["sw_y"]], 2), SWln = fmt(m[["sw_ln"]], 2), VIFrenda = fmt(m[["vif_renda"]], 0),
  RdoisA = fmt(m[["R2a"]], 2),
  FblocoEd = fmt(m[["F_D"]]), RdoisAsemEd = fmt(m[["R2a_C"]], 2), RdoisAcomEd = fmt(m[["R2a_D"]], 2), Fglobal = fmt(m[["F_global"]], 0), GlUm = fmt(m[["gl1"]], 0), GlDois = fmt(m[["gl2"]], 0),
  Pico = fmt(m[["pico_renda"]], 0), BP = fmt(m[["bp"]], 0),
  SW = fmt(m[["sw"]], 2), Nout = fmt(m[["n_outliers"]], 0),
  SWp = fp(m[["sw_p"]]), BPgl = fmt(m[["bp_gl"]], 0), BPp = fp(m[["bp_p"]]),
  RdoisE = fmt(m[["R2_E"]], 2), Sigma = fmt(m[["sigma"]], 3),
  FglobalP = fp(m[["F_global_p"]]), VIFrendaFinal = fmt(m[["vif_renda_final"]]), VIFdemaisMax = fmt(m[["vif_demais_max"]]), VIFrendaCru = fmt(vif_cru[["log_rend"]], 0),
  GiniCorUF = fmt(cor(vg$gini_calculado, vg$gini_oficial), 3), GiniErroUF = fmt(mean(abs(vg$gini_calculado - vg$gini_oficial)), 3),
  NumReg = fmt(m[["n_reg"]], 0), PCorte = fmt(eda$P_CORTE, 1), PCorteSup = fmt(100 - eda$P_CORTE, 1), PctCentral = fmt(100 - 2 * eda$P_CORTE, 0), NumX = fmt(m[["n_x"]], 0), NumPar = fmt(m[["gl1"]] + 1, 0),
  CorQuadSem = fmt(m[["cor_quad_sem"]], 4), CorQuadCen = fmt(m[["cor_quad_cen"]], 2),
  BetaDois = fmt(coef("rend_c2", "b"), 3), BetaDoisP = fp(coef("rend_c2", "p")),
  OutNomes = if (length(out_nomes)) paste(out_nomes, collapse = ", ") else "nenhum",
  IconeSW = if (sw_ok) "\\ok" else "\\nao", TextoSW = if (sw_ok) "Normalidade razoável" else "Normalidade violada",
  IconeOut = "\\ok", TextoOut = paste0(fmt(m[["n_outliers"]], 0), if (m[["n_outliers"]] == 1) " outlier" else " outliers"),
  IconeBP = if (bp_ok) "\\ok" else "\\nao", TextoBP = if (bp_ok) "Variância constante" else "Variância não constante")
mac <- sub("^-", "$-$", mac)
writeLines(sprintf("\\newcommand{\\n%s}{%s}", names(mac), mac), "numeros.tex")

# Tabela do escopo: confiabilidade por porte (linhas do escopo destacadas)
esc <- porte$porte %in% c("20–50 mil", "50–100 mil", ">= 100 mil")
lin <- sprintf("%s%s & %s & %s\\%% & $\\pm$%s\\%%\\\\", ifelse(esc, "\\rowcolor{fundo}", ""),
               sub(">= ", "$\\\\geq$ ", sub("< ", "$<$ ", porte$porte)), fmt(porte$municipios, 0),
               fmt(porte$pct_zero, 0), fmt(porte$oscilacao, 0))
writeLines(c("\\begin{tabular}{@{}lrrr@{}}", "\\toprule",
             "\\textbf{Porte} & \\textbf{Municípios} & \\textbf{Zeros} & \\textbf{Oscilação}\\\\", "\\midrule",
             lin, "\\bottomrule", "\\end{tabular}"), "tabelas/porte.tex")

# Tabela do corte por percentil da densidade em cada região
cr <- as.data.frame(eda$corte_regiao)
lin <- sprintf("%s & %s & %s & %s & %s a %s\\\\", cr$regiao, fmt(cr$municipios, 0), fmt(cr$fora, 0), fmt(cr$considerados, 0),
               fmt(cr$dens_min, 1), fmt(cr$dens_max, 1))
writeLines(c("\\begin{tabular}{@{}lrrrr@{}}", "\\toprule",
             "\\textbf{Região} & \\textbf{Municípios} & \\textbf{Saem} & \\textbf{Ficam} & \\textbf{Densidade que fica}\\\\", "\\midrule",
             lin, "\\bottomrule", "\\end{tabular}"), "tabelas/corte_regiao.tex")

# Tabela-resumo da exploratória: resposta e explicativas do modelo (casas decimais por variável)
casas <- c(taxa = 1, rend_pc_media = 0, gini = 3, desocup = 1, pct_urbana = 1, dens = 1, log_dens = 2,
           pct_h1529 = 1, pct_indet = 1, freq_15a17 = 1, abandono_em = 1, distorcao_em = 1, pct_migr_10anos = 1)
rotulo <- c(taxa = "Taxa de homicídios (/100 mil)", rend_pc_media = "Renda per capita (R\\$)",
            gini = "Desigualdade (índice de Gini)", desocup = "Desocupação (\\%)", pct_urbana = "Urbana (\\%)",
            dens = "Densidade (hab./km²)", log_dens = "ln Densidade", pct_h1529 = "Homens 15--29 (\\%)",
            pct_indet = "Intenção indeterminada (\\%)", freq_15a17 = "Frequência escolar 15--17 (\\%)",
            abandono_em = "Abandono no ensino médio (\\%)", distorcao_em = "Distorção idade-série EM (\\%)",
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
rot_cs <- c(gini = "Desigualdade (Gini)", desocup = "Desocupação", pct_urbana = "\\% urbana", dens_z = "ln densidade (padr.)",
            pct_h1529 = "\\% homens 15--29", faixa_fronteira = "Fronteira", pct_indet = "\\% indeterminada",
            freq_15a17 = "Freq. escolar 15--17", abandono_em = "Abandono EM", distorcao_em = "Distorção EM",
            pct_migr_10anos = "Migração recente")
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
confere(p_cs("gini", "p_sem") < 0.05 && p_cs("gini", "b_sem") > 0 && p_cs("gini", "b_sem") < p_cs("gini", "b_com"), "sem a renda, a desigualdade continua significativa, com efeito menor")
confere(p_cs("pct_migr_10anos", "p_sem") > 0.05 && p_cs("dens_z", "p_sem") > 0.05 && p_cs("pct_migr_10anos", "p_com") < 0.05 && p_cs("dens_z", "p_com") < 0.05,
        "sem a renda, migração e densidade deixam de ser significativas")
cat(sprintf("\\newcommand{\\nFRenda}{%s}\n\\newcommand{\\nGlRenda}{%s}\n\\newcommand{\\nPRenda}{%s}\n\\newcommand{\\nRdoisAsemRenda}{%s}\n\\newcommand{\\nVIFmaxSemRenda}{%s}\n",
            fmt(mod$F_renda$F[2]), fmt(mod$F_renda$Df[2], 0), fp(mod$F_renda$`Pr(>F)`[2]), fmt(mod$ss_$adj.r.squared, 2), fmt(max(mod$vif_sem_renda))),
    file = "numeros.tex", append = TRUE)

# Tabela dos blocos (F parcial e R² ajustado)
bloco <- function(nome, k, neg = FALSE) {
  cel <- c(nome, fmt(m[[paste0("gl_", k)]], 0), fmt(m[[paste0("F_", k)]]), fp(m[[paste0("p_", k)]]), fmt(m[[paste0("R2a_", k)]], 2))
  if (neg) cel <- paste0("\\textbf{", cel, "}")
  paste0(if (neg) "\\rowcolor{fundo}" else "", paste(cel, collapse = " & "), "\\\\")
}
writeLines(c("\\begin{tabular}{@{}lrrrr@{}}", "\\toprule",
             "\\textbf{Bloco} & \\textbf{gl} & \\textbf{$F$ parcial} & \\textbf{$p$} & \\textbf{$R^2_a$}\\\\", "\\midrule",
             sprintf("A: renda e desigualdade & --- & --- & --- & %s\\\\", fmt(m[["R2a_A"]], 2)),
             bloco("B: + demografia", "B"), bloco("C: + fronteira e registro", "C"),
             bloco("D: + educação e migração", "D"), bloco("E: + região", "E", neg = TRUE),
             "\\bottomrule", "\\end{tabular}"), "tabelas/blocos.tex")

# Tabela de efeitos na taxa (%): só as significativas; as n.s. viram a macro \nNaoSig
efe <- efe[order(-abs(efe$efeito_pct)), ]
ns <- efe$p >= 0.05
cat(sprintf("\\newcommand{\\nNaoSig}{%s}\n", paste(tolower(gsub("%", "\\\\%", efe$variavel[ns])), collapse = ", ")),
    file = "numeros.tex", append = TRUE)
efe <- efe[!ns, ]
# Hipótese do slide da questão de pesquisa que cada variável testa (H1 desigualdade, H2 escola, H3 migração)
hip <- c(gini = "H1", freq_15a17 = "H2", abandono_em = "H2", distorcao_em = "H2", pct_migr_10anos = "H3")
efe$hip <- ifelse(efe$termo %in% names(hip), hip[efe$termo], "")
lin <- sprintf("%s & %s & %s & %s\\%% & [%s; %s] & %s\\\\", efe$hip, gsub("%", "\\\\%", efe$variavel), efe$mudanca,
               sinal(efe$efeito_pct, 1), sinal(efe$ic_inf_pct, 1), sinal(efe$ic_sup_pct, 1), fp(efe$p))
writeLines(c("\\begin{tabular}{@{}cllrcr@{}}", "\\toprule",
             "\\textbf{Hip.} & \\textbf{Variável} & \\textbf{Mudança} & \\textbf{Taxa} & \\textbf{IC 95\\%} & \\textbf{$p$}\\\\", "\\midrule",
             sprintf(" & Renda & --- & U invertido & --- & %s\\\\", fp(coef("rend_c2", "p"))),
             lin, "\\bottomrule", "\\end{tabular}"), "tabelas/efeitos.tex")

# Apêndice: coeficientes
nomes <- c(rend_c = "ln renda (centr.)", rend_c2 = "ln renda²", gini = "Desigualdade (Gini)", desocup = "Desocupação",
           pct_urbana = "\\% urbana", dens_z = "ln densidade (padr.)",
           pct_h1529 = "\\% homens 15--29", faixa_fronteira = "Fronteira", pct_indet = "\\% indeterminada",
           freq_15a17 = "Freq. escolar 15--17", abandono_em = "Abandono EM", distorcao_em = "Distorção EM",
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

cat("numeros.tex e tabelas/ gerados. Variável de maior correlação com ln(taxa):", var_max, "\n")
