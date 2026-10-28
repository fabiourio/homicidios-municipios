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
med_ama <- tapply(d_eda$taxa, d_eda$amazonia_legal, median)
cv <- eda$cv
e <- c(
  municipios_br = nrow(br), hom_br = sum(br$hom), taxa_br = eda$taxa_br, pop_min = eda$POP_MIN,
  municipios_escopo = nrow(d_eda), pct_pop_escopo = 100 * sum(d_eda$pop) / sum(br$pop),
  zeros_escopo = sum(d_eda$hom == 0), zeros_br = sum(br$hom == 0),
  taxa_media = mean(d_eda$taxa), taxa_mediana = median(d_eda$taxa),
  assim_taxa = eda$assimetria(d_eda$taxa), assim_ln_taxa = eda$assimetria(d_eda$ln_taxa),
  taxa_nordeste = reg[["Nordeste"]], taxa_sudeste = reg[["Sudeste"]],
  hom_ano = sum(br$hom) / 3, taxa_mundo = TAXA_MUNDO_UNODC, razao_mundo = eda$taxa_br / TAXA_MUNDO_UNODC,
  taxa_n_br = reg_br[["N"]], taxa_ne_br = reg_br[["NE"]], taxa_co_br = reg_br[["CO"]],
  taxa_se_br = reg_br[["SE"]], taxa_s_br = reg_br[["S"]],
  mediana_amazonia = med_ama[["1"]], mediana_fora_amazonia = med_ama[["0"]],
  cor_renda_pobres = R["ln Renda", "% pobres"], cor_renda_alfabet = R["ln Renda", "Alfabetização"],
  renda_decil_pico = eda$med_faixa$renda[which.max(eda$med_faixa$med)],
  porte_hom_mediana_menor5mil = porte$hom_mediana_3anos[1], porte_oscilacao_menor5mil = porte$oscilacao[1],
  porte_cor2024_menor5mil = porte$cor_2024[1], porte_cor2024_maior100mil = porte$cor_2024[6],
  porte_oscilacao_20a50mil = porte$oscilacao[4], porte_zero_20a50mil = porte$pct_zero[4],
  mediana_fronteira = median(d_eda$taxa[d_eda$faixa_fronteira == 1]),
  mediana_fora_fronteira = median(d_eda$taxa[d_eda$faixa_fronteira == 0]))

m <- with(mod, c(
    n = nrow(d), lambda = lambda, lambda_ic_inf = unname(lambda_ic[1]), lambda_ic_sup = unname(lambda_ic[2]),
    sw_y = unname(sw_y$statistic), sw_ln = unname(sw_log$statistic),
    vif_renda = unname(vif_colin["log_rend"]),
    F_B = anova_blocos$F[2], F_C = anova_blocos$F[3], F_D = anova_blocos$F[4], F_E = anova_blocos$F[5],
    p_B = anova_blocos$`Pr(>F)`[2], p_C = anova_blocos$`Pr(>F)`[3], p_D = anova_blocos$`Pr(>F)`[4], p_E = anova_blocos$`Pr(>F)`[5],
    R2a_A = comp$R2a[1], R2a_B = comp$R2a[2], R2a_C = comp$R2a[3], R2a_D = comp$R2a[4], R2a_E = comp$R2a[5],
    R2a_E_regiao = comp$R2a[6], DW_E_regiao = comp$DW[6], F_uf = F_uf$F[2],
    R2a = sf_$adj.r.squared, F_global = unname(sf_$fstatistic[1]),
    gl1 = unname(sf_$fstatistic[2]), gl2 = unname(sf_$fstatistic[3]),
    pico_renda = unname(pico_renda), bp = unname(bp$statistic), bp_p = unname(bp$p.value),
    dw = unname(dw$statistic), dw_p = unname(dw$p.value), sw = unname(sw_final$statistic), n_outliers = nrow(outliers),
    sw_p = sw_final$p.value, bp_gl = unname(bp$parameter),
    gl_B = anova_blocos$Df[2], gl_C = anova_blocos$Df[3], gl_D = anova_blocos$Df[4], gl_E = anova_blocos$Df[5],
    gl_uf = F_uf$Df[2], p_uf = F_uf$`Pr(>F)`[2], R2_E = comp$R2[5], sigma = sf_$sigma,
    F_global_p = unname(pf(sf_$fstatistic[1], sf_$fstatistic[2], sf_$fstatistic[3], lower.tail = FALSE)),
    vif_renda_final = unname(vif_final["rend_c"]), vif_demais_max = max(vif_final[names(vif_final) != "rend_c"]),
    n_uf = nlevels(d$uf) - 1, n_x = length(coef(final)) - 3 - (nlevels(d$uf) - 1),
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
confere(m[["lambda_ic_sup"]] < 0.25, "Box-Cox: lambda perto de 0, o log é um valor de fácil interpretação próximo")
confere(m[["lambda_ic_inf"]] > 0, "lambda = 0 fica fora do IC 95% de Box-Cox")
confere(all(c(m[["p_B"]], m[["p_C"]], m[["p_D"]], m[["p_E"]]) < 0.001), "todos os blocos entram (p < 0,001)")
confere(m[["R2a_E"]] > m[["R2a_E_regiao"]], "estado no lugar de região melhora o modelo")
ganho <- diff(c(m[["R2a_A"]], m[["R2a_B"]], m[["R2a_C"]], m[["R2a_D"]], m[["R2a_E"]]))
confere(which.max(ganho) == 4, "maior ganho de R² ajustado com o estado (bloco E)")
confere(coef("freq_15a17", "b") < 0 && coef("freq_15a17", "p") < 0.05, "mais frequência escolar, menos homicídios")
confere(all(sapply(c("abandono_em", "distorcao_em", "pct_migr_10anos"), function(t) coef(t, "b") > 0 && coef(t, "p") < 0.05)), "mais abandono, distorção e migração recente, mais homicídios")
confere(m[["vif_renda"]] > 10, "renda, % pobres e alfabetização juntas têm VIF alto")
confere(e[["zeros_escopo"]] == 0, "nenhum município sem homicídio no escopo")
confere(min(e[["taxa_n_br"]], e[["taxa_ne_br"]]) > max(e[["taxa_se_br"]], e[["taxa_s_br"]]), "Norte e Nordeste acima de Sudeste e Sul")
med_reg <- tapply(d_eda$taxa, d_eda$regiao, median)
confere(min(med_reg[c("Norte", "Nordeste")]) > max(med_reg[c("Sudeste", "Sul")]), "boxplot: Norte e Nordeste acima de Sudeste e Sul no escopo")
confere(e[["taxa_media"]] > e[["taxa_mediana"]], "taxa: média acima da mediana")
confere(mean(d_eda$dens) > 3 * median(d_eda$dens), "densidade: média muito acima da mediana")
confere(m[["n"]] == e[["municipios_escopo"]], "exploratória e modelo no mesmo escopo")
confere(e[["porte_zero_20a50mil"]] == 0, "a partir de 20 mil hab. nenhum município tem taxa zero")
sig_pos <- function(t) coef(t, "b") > 0 && coef(t, "p") < 0.05
confere(sig_pos("pct_negra") && sig_pos("pct_urbana") && sig_pos("desig"), "mais homicídios com mais % preta ou parda, urbanização e desigualdade")
confere(all(sapply(c("faixa_fronteira", "log_dens", "pct_h1529"), function(t) coef(t, "p") > 0.05)), "fronteira, densidade e % homens 15-29 não significativas")
confere(sig_pos("desig") && sig_pos("abandono_em") && sig_pos("distorcao_em") && sig_pos("pct_migr_10anos") &&
          coef("freq_15a17", "b") < 0 && coef("freq_15a17", "p") < 0.05, "sinais consistentes com H1, H2 e H3")
confere(m[["bp_p"]] < 0.05, "Breusch-Pagan rejeita H0: erros-padrão e valores p são aproximados")
confere(m[["sw_p"]] < 0.05 && m[["sw"]] >= 0.97, "Shapiro-Wilk rejeita com W próximo de 1 (n grande)")
confere(which.max(mod$vif_final) == which(names(mod$vif_final) == "rend_c"), "VIF máximo é o da renda")

# Diagnóstico: ícone e texto decididos pelo teste (5%)
dw_ok <- m[["dw_p"]] > 0.05
bp_ok <- m[["bp_p"]] > 0.05
sw_ok <- m[["sw"]] >= 0.97

# Variável com maior correlação com ln(taxa)
r_resp <- R["ln Taxa", colnames(R) != "ln Taxa"]
var_max <- names(which.max(abs(r_resp)))

mac <- c(
  MunBR = fmt(e[["municipios_br"]], 0), HomBR = fmt(e[["hom_br"]], 0), TaxaBR = fmt(e[["taxa_br"]]),
  PopMin = fmt(e[["pop_min"]] / 1000, 0), MunEsc = fmt(e[["municipios_escopo"]], 0),
  PctPopEsc = fmt(e[["pct_pop_escopo"]], 0), ZerosBR = fmt(e[["zeros_br"]], 0),
  TaxaMedia = fmt(e[["taxa_media"]]), TaxaMediana = fmt(e[["taxa_mediana"]]),
  AssimTaxa = fmt(e[["assim_taxa"]], 2), AssimLn = fmt(e[["assim_ln_taxa"]], 2),
  TaxaNE = fmt(e[["taxa_nordeste"]]), TaxaSE = fmt(e[["taxa_sudeste"]]),
  HomAno = fmt(e[["hom_ano"]], 0), TaxaMundo = fmt(e[["taxa_mundo"]]), RazaoMundo = fmt(e[["razao_mundo"]]),
  TaxaNbr = fmt(e[["taxa_n_br"]]), TaxaNEbr = fmt(e[["taxa_ne_br"]]), TaxaCObr = fmt(e[["taxa_co_br"]]),
  TaxaSEbr = fmt(e[["taxa_se_br"]]), TaxaSbr = fmt(e[["taxa_s_br"]]),
  MedAma = fmt(e[["mediana_amazonia"]]), MedForaAma = fmt(e[["mediana_fora_amazonia"]]),
  MedFront = fmt(e[["mediana_fronteira"]]), MedForaFront = fmt(e[["mediana_fora_fronteira"]]),
  CorMax = fmt(abs(r_resp[[var_max]]), 2), CorMaxVar = gsub("%", "\\\\%", var_max),
  CorTrio = fmt(max(abs(c(e[["cor_renda_pobres"]], e[["cor_renda_alfabet"]]))), 2),
  RendaDecilPico = fmt(e[["renda_decil_pico"]], 0),
  PorteHomMenor = fmt(e[["porte_hom_mediana_menor5mil"]], 0), PorteOscMenor = fmt(e[["porte_oscilacao_menor5mil"]], 0),
  PorteCorMenor = fmt(e[["porte_cor2024_menor5mil"]], 2), PorteCorMaior = fmt(e[["porte_cor2024_maior100mil"]], 2),
  PorteOscVinte = fmt(e[["porte_oscilacao_20a50mil"]], 0),
  Lambda = fmt(m[["lambda"]], 2), LambdaInf = fmt(m[["lambda_ic_inf"]], 2), LambdaSup = fmt(m[["lambda_ic_sup"]], 2),
  SWy = fmt(m[["sw_y"]], 2), SWln = fmt(m[["sw_ln"]], 2), VIFrenda = fmt(m[["vif_renda"]], 0),
  RdoisA = fmt(m[["R2a"]], 2), RdoisAregiao = fmt(m[["R2a_E_regiao"]], 2), DWregiao = fmt(m[["DW_E_regiao"]], 2),
  Fuf = fmt(m[["F_uf"]]), FblocoEd = fmt(m[["F_D"]]), RdoisAsemEd = fmt(m[["R2a_C"]], 2), RdoisAcomEd = fmt(m[["R2a_D"]], 2), Fglobal = fmt(m[["F_global"]], 0), GlUm = fmt(m[["gl1"]], 0), GlDois = fmt(m[["gl2"]], 0),
  Pico = fmt(m[["pico_renda"]], 0), BP = fmt(m[["bp"]], 0), DW = fmt(m[["dw"]], 2), DWp = fmt(m[["dw_p"]], 2),
  SW = fmt(m[["sw"]], 2), Nout = fmt(m[["n_outliers"]], 0),
  SWp = fp(m[["sw_p"]]), BPgl = fmt(m[["bp_gl"]], 0), BPp = fp(m[["bp_p"]]),
  GlUF = fmt(m[["gl_uf"]], 0), PUF = fp(m[["p_uf"]]), RdoisE = fmt(m[["R2_E"]], 2), Sigma = fmt(m[["sigma"]], 3),
  FglobalP = fp(m[["F_global_p"]]), VIFrendaFinal = fmt(m[["vif_renda_final"]]), VIFdemaisMax = fmt(m[["vif_demais_max"]]),
  NumUF = fmt(m[["n_uf"]], 0), NumX = fmt(m[["n_x"]], 0), NumPar = fmt(m[["gl1"]] + 1, 0),
  CorQuadSem = fmt(m[["cor_quad_sem"]], 4), CorQuadCen = fmt(m[["cor_quad_cen"]], 2),
  BetaDois = fmt(coef("rend_c2", "b"), 3), BetaDoisP = fp(coef("rend_c2", "p")),
  OutNomes = if (length(out_nomes)) paste(out_nomes, collapse = ", ") else "nenhum",
  IconeSW = if (sw_ok) "\\ok" else "\\nao", TextoSW = if (sw_ok) "Normalidade razoável" else "Normalidade violada",
  IconeOut = "\\ok", TextoOut = paste0(fmt(m[["n_outliers"]], 0), if (m[["n_outliers"]] == 1) " outlier" else " outliers"),
  IconeDW = if (dw_ok) "\\ok" else "\\nao",
  TextoDW = if (dw_ok) "Sem autocorrelação na ordem do código" else "Autocorrelação na ordem do código",
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

# Tabela-resumo da exploratória: resposta e explicativas do modelo (casas decimais por variável)
casas <- c(taxa = 1, rend_pc_media = 0, desig = 2, desocup = 1, pct_urbana = 1, dens = 1, pct_negra = 1,
           pct_h1529 = 1, pct_indet = 1, freq_15a17 = 1, abandono_em = 1, distorcao_em = 1, pct_migr_10anos = 1)
rotulo <- c(taxa = "Taxa de homicídios (/100 mil)", rend_pc_media = "Renda per capita (R\\$)",
            desig = "Desigualdade (média/mediana)", desocup = "Desocupação (\\%)", pct_urbana = "Urbana (\\%)",
            dens = "Densidade (hab./km²)", pct_negra = "Preta ou parda (\\%)", pct_h1529 = "Homens 15--29 (\\%)",
            pct_indet = "Intenção indeterminada (\\%)", freq_15a17 = "Frequência escolar 15--17 (\\%)",
            abandono_em = "Abandono no ensino médio (\\%)", distorcao_em = "Distorção idade-série EM (\\%)",
            pct_migr_10anos = "Migração recente (\\%)")
ds <- as.data.frame(eda$desc)[match(names(casas), eda$desc$name), ]
stopifnot(!anyNA(ds$name))
num <- function(col) mapply(function(x, k) fmt(x, k), ds[[col]], casas)
lin <- sprintf("%s%s & %s & %s & %s & %s & %s\\\\", ifelse(ds$name == "taxa", "\\rowcolor{fundo}", ""),
               rotulo[ds$name], num("media"), num("dp"), num("min"), num("mediana"), num("max"))
writeLines(c("\\begin{tabular}{@{}lrrrrr@{}}", "\\toprule",
             "\\textbf{Variável} & \\textbf{Média} & \\textbf{DP} & \\textbf{Mín.} & \\textbf{Mediana} & \\textbf{Máx.}\\\\",
             "\\midrule", lin, "\\bottomrule", "\\end{tabular}"), "tabelas/descritiva.tex")

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
             bloco("D: + educação e migração", "D"), bloco("E: + estado (UF)", "E", neg = TRUE),
             "\\bottomrule", "\\end{tabular}"), "tabelas/blocos.tex")

# Tabela de efeitos na taxa (%): só as significativas; as n.s. viram a macro \nNaoSig
efe <- efe[order(-abs(efe$efeito_pct)), ]
ns <- efe$p >= 0.05
cat(sprintf("\\newcommand{\\nNaoSig}{%s}\n", paste(tolower(gsub("%", "\\\\%", efe$variavel[ns])), collapse = ", ")),
    file = "numeros.tex", append = TRUE)
efe <- efe[!ns, ]
# Hipótese do slide da questão de pesquisa que cada variável testa (H1 desigualdade, H2 escola, H3 migração)
hip <- c(desig = "H1", freq_15a17 = "H2", abandono_em = "H2", distorcao_em = "H2", pct_migr_10anos = "H3")
efe$hip <- ifelse(efe$termo %in% names(hip), hip[efe$termo], "")
lin <- sprintf("%s & %s & %s & %s\\%% & [%s; %s] & %s\\\\", efe$hip, gsub("%", "\\\\%", efe$variavel), efe$mudanca,
               sinal(efe$efeito_pct, 1), sinal(efe$ic_inf_pct, 1), sinal(efe$ic_sup_pct, 1), fp(efe$p))
writeLines(c("\\begin{tabular}{@{}cllrcr@{}}", "\\toprule",
             "\\textbf{Hip.} & \\textbf{Variável} & \\textbf{Mudança} & \\textbf{Taxa} & \\textbf{IC 95\\%} & \\textbf{$p$}\\\\", "\\midrule",
             sprintf(" & Renda & --- & U invertido & --- & %s\\\\", fp(coef("rend_c2", "p"))),
             lin, "\\bottomrule", "\\end{tabular}"), "tabelas/efeitos.tex")

# Apêndice: coeficientes (sem as 26 indicadoras de estado)
nomes <- c(rend_c = "ln renda (centr.)", rend_c2 = "ln renda²", desig = "Desigualdade", desocup = "Desocupação",
           pct_urbana = "\\% urbana", log_dens = "ln densidade", pct_negra = "\\% preta ou parda",
           pct_h1529 = "\\% homens 15--29", faixa_fronteira = "Fronteira", pct_indet = "\\% indeterminada",
           freq_15a17 = "Freq. escolar 15--17", abandono_em = "Abandono EM", distorcao_em = "Distorção EM",
           pct_migr_10anos = "Migração recente")
cc <- coefs[match(names(nomes), coefs$termo), ]
cel <- sprintf("%s & %s & %s & %s", nomes, gsub("-", "$-$", fmt(cc$b, 3)), fmt(cc$ep, 3), fp(cc$p))
k <- ceiling(length(cel) / 2)
lin <- paste(cel[1:k], c(cel[(k + 1):length(cel)], rep(" & & & ", 2 * k - length(cel))), sep = " & ")
writeLines(c("\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}lrrrlrrr@{}}", "\\toprule",
             paste0("\\textbf{Termo} & \\textbf{$b$} & \\textbf{EP} & \\textbf{$p$} & ",
                    "\\textbf{Termo} & \\textbf{$b$} & \\textbf{EP} & \\textbf{$p$}\\\\"), "\\midrule",
             paste0(lin, "\\\\"), "\\bottomrule", "\\end{tabular*}"), "tabelas/coeficientes.tex")

cat("numeros.tex e tabelas/ gerados. Variável de maior correlação com ln(taxa):", var_max, "\n")
