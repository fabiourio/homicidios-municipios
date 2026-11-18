library(lmtest)
library(car)
library(jsonlite)
raiz <- if (basename(getwd()) == 'validacao') normalizePath('..') else normalizePath('.')
saida <- file.path(raiz, 'validacao/saida')
dir.create(saida, recursive = TRUE, showWarnings = FALSE)
registro <- file(file.path(saida, '10_estrutura_familiar.txt'), open = 'wt')
sink(registro, split = TRUE)
d <- read.csv(file.path(raiz,'entrega/dados/base_analitica.csv'))
e <- read.csv(file.path(raiz,'entrega/dados/variaveis_extras.csv'))
candidatas <- read.csv(file.path(raiz,'dados/tabelas/candidatas.csv'))
fonte <- read.csv(file.path(raiz,'validacao/dados/estrutura_familiar_2022.csv'))
stopifnot(!anyDuplicated(d$cod_ibge),!anyDuplicated(e$cod_ibge),!anyDuplicated(candidatas$cod_ibge),
          !anyDuplicated(fonte$cod_ibge), nrow(fonte) == 5570,
          all(complete.cases(fonte)), all(fonte$domicilios_particulares_total > 0),
          max(abs(fonte$pct_maes_solo - 100 * fonte$domicilios_mulher_sem_conjuge_com_filhos /
                    fonte$domicilios_particulares_total)) < 1e-10,
          max(abs(fonte$pct_maes_solo - candidatas$pct_maes_solo[match(fonte$cod_ibge, candidatas$cod_ibge)])) < 1e-10)
cat('FONTE: SIDRA 9882, variável 800, ano 2022. Numerador: categoria 72607, sexo 100681. Denominador: 72603, sexo 100679.\n')
cat('Conferência: 5.570 municípios, sem diferenças relevantes entre contagens da fonte e variável integrada.\n')
d <- merge(d,e[c('cod_ibge','distorcao_em','pct_migr_10anos')],by='cod_ibge',all.x=TRUE)
d <- d[d$pop>=30000 & d$cod_ibge!=3509700,]
d$pct_maes_solo <- candidatas$pct_maes_solo[match(d$cod_ibge,candidatas$cod_ibge)]
stopifnot(nrow(d)==1133,all(complete.cases(d[c('taxa','log_rend','gini','desocup','pct_urbana','freq_15a17','distorcao_em','pct_migr_10anos','regiao','pct_maes_solo')])))
d$regiao <- relevel(factor(d$regiao,levels=c('N','NE','CO','SE','S'),labels=c('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')),ref='Sudeste')
d$ly <- log(d$taxa)
d$rend_c <- d$log_rend-mean(d$log_rend)
d$rend_c2 <- d$rend_c^2
d$gini_c <- d$gini-mean(d$gini)
f <- ly ~ rend_c+rend_c2+gini_c+desocup+pct_urbana+freq_15a17+distorcao_em+pct_migr_10anos+regiao+rend_c:gini_c
m0 <- lm(f,data=d)
m1 <- update(m0,.~.+pct_maes_solo)
publicado <- read.csv(file.path(raiz,'entrega/resultados/modelagem/coeficientes.csv'))
stopifnot(max(abs(coef(m0)[publicado$termo]-publicado$b))<1e-10)
cat('AMOSTRA E VARIÁVEL\n');print(summary(d$pct_maes_solo));print(c(n=nrow(d),faltantes=sum(is.na(d$pct_maes_solo)),parametros_base=length(coef(m0)),parametros_com_maes=length(coef(m1))))
cat('\nTESTE F CONDICIONAL\n'); print(anova(m0,m1))
cat('\nCOEFICIENTE ADICIONAL\n');print(coef(summary(m1))['pct_maes_solo',,drop=FALSE])
cat('\nEFEITO PARA +5 PONTOS PERCENTUAIS\n');print(100*expm1(c(estimativa=coef(m1)['pct_maes_solo'],confint(m1)['pct_maes_solo',])*5))
metrics <- function(m) c(n=nobs(m),r2_ajustado=summary(m)$adj.r.squared,sigma=summary(m)$sigma,shapiro_p=shapiro.test(rstandard(m))$p.value,bp_p=bptest(m)$p.value,PRESS=sum((resid(m)/(1-hatvalues(m)))^2),vif_max=max(vif(m)[,'GVIF^(1/(2*Df))']^2))
diagnosticos <- rbind(final=metrics(m0),com_maes_solo=metrics(m1))
cat('\nDIAGNÓSTICOS\n');print(diagnosticos)
effects <- function(m){
  g<-c(gini_c=0.05,'rend_c:gini_c'=0.05*(log(median(d$rend_pc_media))-mean(d$log_rend)))
  c(gini_mediana_pct=100*expm1(sum(coef(m)[names(g)]*g)),freq_5pp=100*expm1(coef(m)['freq_15a17']*5),distorcao_10pp=100*expm1(coef(m)['distorcao_em']*10),migracao_p=coef(summary(m))['pct_migr_10anos',4])
}
mudancas <- rbind(final=effects(m0),com_maes_solo=effects(m1))
cat('\nMUDANÇAS NOS RESULTADOS PRINCIPAIS\n');print(mudancas)
cat('\nDECISÃO ATUAL\nManter o modelo principal. A inclusão tem contribuição adicional imprecisa, ganho mínimo no ajuste e não resolve a variância desigual.\n')
cat('Isso não prova ausência de associação e não reconstrói a justificativa histórica da exclusão. Testes e intervalos são clássicos e exploratórios.\n')
write.csv(coef(summary(m1)),file.path(saida,'10_estrutura_familiar_coeficientes.csv'))
write.csv(diagnosticos,file.path(saida,'10_estrutura_familiar_diagnosticos.csv'))
write.csv(mudancas,file.path(saida,'10_estrutura_familiar_sensibilidade.csv'))
sink()
close(registro)
