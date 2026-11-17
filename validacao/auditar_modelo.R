if (basename(getwd()) == "validacao") setwd("../entrega")
if (!file.exists("2_modelo.R")) setwd("entrega")
eda_verificacao <- new.env()
sys.source("1_analise_exploratoria.R", envir = eda_verificacao)
saveRDS(eda_verificacao$br, file.path(tempdir(), "ged16-eda-modelo.rds"))
source("2_modelo.R")
dir.create("../validacao/saida", recursive = TRUE, showWarnings = FALSE)
base <- read.csv('dados/base_analitica.csv')
ex <- read.csv('dados/variaveis_extras.csv')
all_data <- merge(base, ex[,c('cod_ibge','abandono_em','distorcao_em','pct_migr_10anos')],by='cod_ibge')
prepare <- function(z) {
 z$regiao <- relevel(factor(z$regiao,levels=c('N','NE','CO','SE','S'),labels=c('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')),ref='Sudeste')
 z$uf <- relevel(factor(z$uf),ref='SP')
 z$y <- z$taxa; z$ly <- log(z$y)
 z$rend_c <- z$log_rend-mean(z$log_rend); z$rend_c2 <- z$rend_c^2
 z$gini_c <- z$gini-mean(z$gini)
 z
}
rows <- list()
add <- function(scenario,metric,value,detail='') {
 rows[[length(rows)+1L]] <<- data.frame(scenario=scenario,metric=metric,value=as.numeric(value),detail=detail)
}
put_effect <- function(name,m,z,term,delta,renda=NA_real_) {
 b <- coef(m); V <- vcov(m); L <- setNames(rep(0,length(b)),names(b))
 if(term=='gini') {
  rc <- log(renda)-mean(z$log_rend)
  L['gini_c'] <- delta; L['rend_c:gini_c'] <- delta*rc
 } else {L[term] <- delta}
 effect <- sum(L*b); se <- sqrt(drop(t(L)%*%V%*%L)); tc <- qt(.975,df.residual(m))
 label <- if(term=='gini') paste0('gini_0.05_renda_',renda) else paste0(term,'_delta_',delta)
 add(name,paste0(label,'_pct'),100*expm1(effect))
 add(name,paste0(label,'_ci_lower'),100*expm1(effect-tc*se))
 add(name,paste0(label,'_ci_upper'),100*expm1(effect+tc*se))
 add(name,paste0(label,'_p'),2*pt(-abs(effect/se),df.residual(m)))
}
metrics <- function(name,m,z) {
 sm <- summary(m); X <- model.matrix(m); y <- model.response(model.frame(m))
 h <- hatvalues(m); singleton <- which(abs(1-h)<1e-12); press <- if(length(singleton)) NA_real_ else sum((residuals(m)/(1-h))^2); sst <- sum((y-mean(y))^2)
 add(name,'leverage_one_count',length(singleton),if(length(singleton)) paste(z$municipio[singleton],collapse=';') else '')
 add(name,'n',nobs(m)); add(name,'rank',qr(X)$rank); add(name,'df_residual',df.residual(m))
 add(name,'zero_response',sum(z$y==0)); add(name,'NA_model_frame',sum(is.na(model.frame(m))))
 add(name,'all_finite',all(is.finite(c(coef(m),fitted(m),residuals(m),vcov(m)))))
 add(name,'R2',sm$r.squared); add(name,'R2_adjusted',sm$adj.r.squared)
 add(name,'F_global',sm$fstatistic[1]); add(name,'F_global_p',pf(sm$fstatistic[1],sm$fstatistic[2],sm$fstatistic[3],lower.tail=FALSE))
 sw <- shapiro.test(rstandard(m)); bp <- lmtest::bptest(m)
 add(name,'SW_W',sw$statistic); add(name,'SW_p',sw$p.value); add(name,'BP',bp$statistic); add(name,'BP_p',bp$p.value)
 vi <- car::vif(m)[,'GVIF^(1/(2*Df))']^2
 add(name,'max_GVIF_adjusted_squared',max(vi)); add(name,'kappa_X',kappa(X,exact=TRUE)); add(name,'max_hat',max(h))
 add(name,'PRESS',press); add(name,'1_PRESS_over_SST',1-press/sst)
 add(name,'log_income_center',mean(z$log_rend)); add(name,'gini_center',mean(z$gini))
 for(r in c(1383.47,2043.102)) put_effect(name,m,z,'gini',.05,r)
 put_effect(name,m,z,'freq_15a17',5); put_effect(name,m,z,'distorcao_em',10)
 add(name,'income_square_b',coef(m)['rend_c2']); add(name,'income_square_F',anova(update(m,.~.-rend_c2),m)$F[2])
 add(name,'interaction_F',anova(update(m,.~.-rend_c:gini_c),m)$F[2])
 invisible(m)
}
stopifnot(nrow(d)==1133,nobs(final)==1133,final$rank==14,df.residual(final)==1119,!anyNA(model.frame(final)),all(d$y>0),!anyDuplicated(d$cod_ibge))
metrics('final_30mil',final,d)
rebuild <- prepare(all_data[all_data$pop>=30000 & all_data$cod_ibge!=3509700,])
re <- lm(formula(final),data=rebuild)
add('verification','rebuild_max_coef_diff',max(abs(coef(re)-coef(final))))
add('verification','manual_coef_CI_max_diff',max(abs(unname(confint(final))-cbind(coef(final)-qt(.975,1119)*sqrt(diag(vcov(final))),coef(final)+qt(.975,1119)*sqrt(diag(vcov(final)))))))
manual_fx <- 100*expm1(coef(final)[mudancas$termo]*mudancas$delta)
add('verification','export_effect_pct_max_diff',max(abs(manual_fx-mudancas$efeito_pct)))
for(i in seq_len(nrow(gini_renda))) {
 rc <- log(gini_renda$renda[i])-mean(d$log_rend)
 L <- setNames(rep(0,length(coef(final))),names(coef(final))); L['gini_c']<-.05; L['rend_c:gini_c']<-.05*rc
 est<-sum(L*coef(final)); se<-sqrt(drop(t(L)%*%vcov(final)%*%L)); vals<-100*expm1(c(est,est-qt(.975,1119)*se,est+qt(.975,1119)*se))
 add('verification',paste0('gini_export_row_',i,'_max_diff'),max(abs(vals-unlist(gini_renda[i,c('efeito_pct','ic_inf_pct','ic_sup_pct')]))))
}
nl <- base[base$municipio=='Nova Lima',c('cod_ibge','municipio','uf','pop','taxa','rend_pc_media')]
stopifnot(nrow(nl)==1)
add('record','Nova_Lima_IBGE',nl$cod_ibge,paste(nl$municipio,nl$uf))
cl <- base[base$cod_ibge==3509700,c('cod_ibge','municipio','uf','pop','hom','intencao_indeterminada')]
add('record','Campos_homicides',cl$hom,paste(cl$municipio,cl$uf)); add('record','Campos_undetermined',cl$intencao_indeterminada)
scenarios <- list(sem_Nova_Lima=all_data[all_data$pop>=30000 & !all_data$cod_ibge%in%c(3509700,nl$cod_ibge),],com_Campos=all_data[all_data$pop>=30000,])
for(cut in c(20000,30000,50000,100000)) scenarios[[paste0('corte_',cut)]]<-all_data[all_data$pop>=cut & all_data$cod_ibge!=3509700,]
for(nm in names(scenarios)) {
 z <- prepare(scenarios[[nm]])
 stopifnot(!anyNA(z[,all.vars(formula(final))[!all.vars(formula(final))%in%c('rend_c','rend_c2','gini_c','ly')]]),all(z$y>0))
 metrics(nm,lm(formula(final),data=z),z)
}
metrics('estado_30mil',com_estado,d)
add('estado_30mil','F_partial_beyond_region',F_estado$F[2]); add('estado_30mil','F_partial_p',F_estado$`Pr(>F)`[2])
add('estado_30mil','extra_parameters',F_estado$Df[2]); add('estado_30mil','states_under_10',sum(table(d$uf)<10))
add('final_30mil','F_partial_income',F_renda$F[2]); add('final_30mil','F_partial_income_p',F_renda$`Pr(>F)`[2])
for(i in 2:nrow(anova_blocos)) {
 add('block_partial_F',rownames(anova_blocos)[i],anova_blocos$F[i]); add('block_partial_p',rownames(anova_blocos)[i],anova_blocos$`Pr(>F)`[i])
}
loo <- vapply(seq_len(nrow(d)),function(i){m <- lm(formula(final),data=d[-i,]);d$ly[i]-predict(m,newdata=d[i,,drop=FALSE])},numeric(1))
add('verification','PRESS_direct_leave_one_out',sum(loo^2))
add('verification','PRESS_identity_max_error',max(abs(loo-residuals(final)/(1-hatvalues(final)))))
bc_final <- MASS::boxcox(lm(update(formula(final), y~.),data=d),lambda=seq(-.5,1.2,.001),plotit=FALSE)
bc_max <- bc_final$x[which.max(bc_final$y)]; bc_ci <- range(bc_final$x[bc_final$y>max(bc_final$y)-qchisq(.95,1)/2])
for(nm in c('auxiliary','final')) {
 fitbc <- if(nm=='auxiliary') bc else bc_final
 lim <- range(fitbc$x[fitbc$y>max(fitbc$y)-qchisq(.95,1)/2])
 add(paste0('boxcox_',nm),'lambda_max',fitbc$x[which.max(fitbc$y)]);add(paste0('boxcox_',nm),'ci_lower',lim[1]);add(paste0('boxcox_',nm),'ci_upper',lim[2]);add(paste0('boxcox_',nm),'log_zero_in_ci',0>=lim[1] && 0<=lim[2])
}
if(file.exists(file.path(tempdir(), 'ged16-eda-modelo.rds'))) {
 eda <- readRDS(file.path(tempdir(), 'ged16-eda-modelo.rds'))
 add('verification','EDA_model_same_ids',identical(sort(eda$cod_ibge[eda$escopo]),sort(d$cod_ibge)))
 add('verification','EDA_scope_n',sum(eda$escopo))
}
migracao <- lapply(list(final = final, com_medida_antiga = update(final, . ~ . + pct_indet),
                       com_medida_corrigida = update(final, . ~ . + indet_sem_hom)), function(m) {
 c(b_migracao = coef(m)[["pct_migr_10anos"]],
   p_migracao = summary(m)$coefficients["pct_migr_10anos", 4], R2a = summary(m)$adj.r.squared)
})
write.csv(do.call(rbind, migracao), "../validacao/saida/08_sensibilidade_migracao.csv")
result <- do.call(rbind,rows)
checks <- subset(result, scenario == "verification")
erros <- checks$value[grepl("diff|error", checks$metric)]
stopifnot(all(is.finite(erros)), all(erros < 1e-10),
          checks$value[checks$metric == "EDA_model_same_ids"] == 1,
          checks$value[checks$metric == "EDA_scope_n"] == nrow(d))
write.csv(result,'../validacao/saida/09_auditoria_modelo.csv',row.names=FALSE)
options(width = 200)
sink('../validacao/saida/09_auditoria_modelo.txt')
cat('AUDITORIA COMPUTACIONAL; cenários auxiliares sem substituir a especificação principal.\n')
cat('Todos os cenários usam os mesmos termos; centralização e covariância recalculadas em cada amostra.\n')
cat('Efeitos do Gini comparados nas mesmas rendas R$ 1383,47 e R$ 2043,102.\n')
cat('Intervalos clássicos são condicionais às hipóteses; heteroscedasticidade e independência espacial não resolvidas.\n')
cat('PRESS é leave-one-out condicional à especificação, sem validar seleção de variáveis ou independência espacial.\n')
cat('R2 e PRESS na escala logarítmica; exp(fit) indica taxa típica, não média aritmética.\n')
cat('Log escolhido apesar de zero fora do IC de Box-Cox auxiliar e final; sem troca automática.\n')
cat('PRESS do modelo com estado indefinido: Brasília é a única observação do DF; sua retirada elimina o nível.\n')
cat('Sem erro aritmético confirmado. Labels taxa/resposta esperada na curva devem dizer taxa típica, pela exponenciação do ajuste log.\n')
cat('Conclusões: retirar Nova Lima e recolocar Campos preserva os sinais. Campos altera Shapiro p de 0.165 para 0.0011.\n')
cat('Nos cortes 20/50/100mil, sinais de Gini, frequência e distorção persistem; IC da frequência cruza zero em 100mil.\n')
cat('Estado reduz magnitudes de Gini/educação; R2 ajustado sobe, mas não justifica troca automática.\n\n')
print(result,row.names=FALSE,digits=9)
cat('\nRegistros reais examinados:\n'); print(nl,row.names=FALSE); print(cl,row.names=FALSE)
cat('\nCoeficientes finais:\n');print(coefs,row.names=FALSE,digits=9)
cat('\nF parcial por blocos:\n'); print(anova_blocos)
cat('\nCovariância Gini/interação, amostra final:\n'); print(vcov(final)[c('gini_c','rend_c:gini_c'),c('gini_c','rend_c:gini_c')])
sink()
arquivo <- '../validacao/saida/09_auditoria_modelo.txt'
writeLines(sub('[[:blank:]]+$', '', readLines(arquivo, warn = FALSE)), arquivo)
cat('Concluído:',nrow(result),'linhas de evidência.\n')
