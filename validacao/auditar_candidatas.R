library(car)
library(lmtest)
library(jsonlite)
root <- if (basename(getwd()) == 'validacao') normalizePath('..') else normalizePath('.')
output <- file.path(root,'validacao/saida')
dir.create(output,recursive=TRUE,showWarnings=FALSE)
d <- read.csv(file.path(root,'entrega/dados/base_analitica.csv'))
e <- read.csv(file.path(root,'entrega/dados/variaveis_extras.csv'))
x <- read.csv(file.path(root,'dados/tabelas/candidatas.csv'))
r <- read.csv(file.path(root,'dados/tabelas/base_relatorio.csv'))
stopifnot(!anyDuplicated(d$cod_ibge),!anyDuplicated(x$cod_ibge),!anyDuplicated(e$cod_ibge),!anyDuplicated(r$cod_ibge))
for (col in setdiff(names(x),'cod_ibge')) d[[col]] <- x[[col]][match(d$cod_ibge,x$cod_ibge)]
for (col in c('distorcao_em','pct_migr_10anos')) stopifnot(max(abs(d[[col]]-e[[col]][match(d$cod_ibge,e$cod_ibge)]),na.rm=TRUE)<1e-10)
for(col in c('rm_ride','conc_urb')) d[[col]]<-r[[col]][match(d$cod_ibge,r$cod_ibge)]
d<-d[d$pop>=30000 & d$cod_ibge!=3509700,]
d$regiao<-relevel(factor(d$regiao,levels=c('N','NE','CO','SE','S'),labels=c('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')),ref='Sudeste')
d$ly<-log(d$taxa);d$rend_c<-d$log_rend-mean(d$log_rend);d$rend_c2<-d$rend_c^2;d$gini_c<-d$gini-mean(d$gini)
d$indet_sem_hom<-100*d$intencao_indeterminada/(d$total_causas_externas-d$hom)
d$log_pop<-log(d$pop);d$log_area<-log(d$area_km2);d$tem_presidio<-as.numeric(d$pct_presos>0)
f<-ly~rend_c+rend_c2+gini_c+desocup+pct_urbana+freq_15a17+distorcao_em+pct_migr_10anos+regiao+rend_c:gini_c
m<-lm(f,data=d)
published<-read.csv(file.path(root,'entrega/resultados/modelagem/coeficientes.csv'))
stopifnot(nrow(d)==1133,max(abs(coef(m)[published$termo]-published$b))<1e-10)
in_model<-c('distorcao_em','pct_migr_10anos')
candidates<-unique(c(setdiff(names(x),c('cod_ibge',in_model)), 'pct_pobres','alfabet','log_dens','pct_h1529','amazonia_legal','faixa_fronteira','rm_ride','conc_urb','indet_sem_hom','pct_indet','log_pop','log_area','tem_presidio'))
metrics<-function(mod)c(r2a=summary(mod)$adj.r.squared,sigma=summary(mod)$sigma,press=sum((resid(mod)/(1-hatvalues(mod)))^2),bp_p=unname(bptest(mod)$p.value),sw_p=unname(shapiro.test(rstandard(mod))$p.value))
skew<-function(z){z<-z[is.finite(z)]; if(length(unique(z))<3) return(0);mean((z-mean(z))^3)/mean((z-mean(z))^2)^1.5}
results<-list();cases<-list(); mods<-list()
for(v in candidates){
 z<-d[[v]];stopifnot(length(z)==1133)
 forms<-'original'
 if(all(z[is.finite(z)]>=0) && length(unique(z[is.finite(z)]))>5 && skew(z)>1 && !v %in% c('pib_pc','log_pop','log_area','log_dens','ln_pib_pc')) forms<-c(forms,'log1p')
 for(form in forms){
  w<-if(form=='original') z else log1p(z)
  ok<-is.finite(w); dd<-d[ok,];dd$candidata<-w[ok]
  row<-data.frame(variavel=v,forma=form,n=sum(ok),faltantes=sum(!ok),zeros=sum(w[ok]==0),valores_unicos=length(unique(w[ok])),assimetria_original=skew(z),min_original=min(z[ok]),max_original=max(z[ok]))
  if(nrow(dd)<=30 || length(unique(w[ok]))<2){row$estado<-'sem variacao ou casos insuficientes';results[[length(results)+1]]<-row;next}
  a<-lm(f,data=dd);b<-update(a,.~.+candidata)
  if(b$rank!=a$rank+1){row$estado<-'dependencia linear exata';results[[length(results)+1]]<-row;next}
  tt<-anova(a,b); cb<-coef(summary(b))['candidata',];ci<-confint(b)['candidata',]
  ma<-metrics(a);mb<-metrics(b)
  row$estado<-'testada';row$b<-cb[1];row$ep<-cb[2];row$F<-tt$F[2];row$p<-tt$`Pr(>F)`[2];row$ic_inf<-ci[1];row$ic_sup<-ci[2]
  row$r2a_base_mesmos_casos<-ma['r2a'];row$r2a_com<-mb['r2a'];row$delta_r2a<-mb['r2a']-ma['r2a'];row$press_base<-ma['press'];row$press_com<-mb['press'];row$bp_p<-mb['bp_p'];row$sw_p<-mb['sw_p']
  main<-c('freq_15a17','distorcao_em','rend_c:gini_c','pct_migr_10anos')
  row$sinais_principais_alterados<-sum(sign(coef(a)[main])!=sign(coef(b)[main]))
  row$p_migracao_com<-coef(summary(b))['pct_migr_10anos',4]
  key<-paste(v,form,sep='__');mods[[key]]<-b;cases[[key]]<-dd$cod_ibge;results[[length(results)+1]]<-row
 }
}
cols<-unique(unlist(lapply(results,names)))
results<-do.call(rbind,lapply(results,function(z){for(c in setdiff(cols,names(z)))z[[c]]<-NA;z[cols]}))
write.csv(results,file.path(output,'11_candidatas_testes.csv'),row.names=FALSE)
write.csv(results[order(results$p),],file.path(output,'11_candidatas_ranking.csv'),row.names=FALSE)
saveRDS(list(d=d,base=m,resultados=results,modelos=mods,casos=cases),file.path(tempdir(),'ged16-candidatas-auditoria.rds'))
cat('Variáveis:',length(candidates),'especificações:',nrow(results),'\n')
print(results[order(results$p),c('variavel','forma','n','faltantes','estado','p','delta_r2a','sinais_principais_alterados')],row.names=FALSE)

z<-readRDS(file.path(tempdir(),'ged16-candidatas-auditoria.rds'));d<-z$d
m0<-z$base
models<-z$modelos
calc<-function(m){
 ci_effect<-function(weights){b<-sum(coef(m)[names(weights)]*weights);v<-vcov(m)[names(weights),names(weights),drop=FALSE];s<-sqrt(drop(t(weights)%*%v%*%weights));100*expm1(c(b,b-qt(.975,df.residual(m))*s,b+qt(.975,df.residual(m))*s))}
 w<-c(gini_c=.05,'rend_c:gini_c'=.05*(log(median(d$rend_pc_media))-mean(d$log_rend)))
 g<-ci_effect(w)
 c(R2a=summary(m)$adj.r.squared,GiniP50=g[1],GiniP50_inf=g[2],GiniP50_sup=g[3],Freq5=100*expm1(coef(m)['freq_15a17']*5),Dist10=100*expm1(coef(m)['distorcao_em']*10),MigrP=coef(summary(m))['pct_migr_10anos',4],DesocP=coef(summary(m))['desocup',4])
}
keys<-c('pct_favela__original','pct_favela__log1p','pct_ind__original','ln_pib_pc__original','pct_pobres__original','cobertura_aps__original','cresc_pop__original','pct_informal__original','pct_maes_solo__original','guarda_municipal__original')
all<-rbind(final=calc(m0),do.call(rbind,lapply(models[keys],calc)))
print(round(all,5));write.csv(all,file.path(output,'11_candidatas_sensibilidade.csv'))
d$ln1p_favela<-log1p(d$pct_favela);d$ln1p_emprego<-log1p(d$emprego_formal)
combos<-list(social=~pct_favela+pct_maes_solo+freq_18a24+abandono_em,economico=~ln_pib_pc+pct_ind+pct_pobres+pct_informal+ln1p_emprego,territorio=~log_pop+log_dens+amazonia_legal+faixa_fronteira+rm_ride+conc_urb,comparacao_favela_ind_pib=~pct_favela+pct_ind+ln_pib_pc)
for(key in names(combos)){
 extra<-attr(terms(combos[[key]]),'term.labels');fm<-update(formula(m0),paste('.~.+',paste(extra,collapse='+'))); mm<-lm(fm,data=d);print(key);print(anova(m0,mm));print(round(calc(mm),5))
}
library(ggplot2)
nomes <- c(pct_favela='População em favelas e comunidades urbanas',pct_ind='Participação industrial',ln_pib_pc='PIB por habitante (ln)',pct_pobres='Pessoas com baixa renda',cresc_pop='Crescimento populacional',cobertura_aps='Cobertura potencial da APS',pct_maes_solo='Mulher responsável, sem cônjuge, com filhos',abandono_em='Abandono no ensino médio',log_dens='Densidade populacional (ln)',desp_seg_pc='Despesa municipal em segurança')
plot_dados <- results[results$forma == 'original' & results$variavel %in% names(nomes), ]
plot_dados <- plot_dados[match(names(nomes), plot_dados$variavel), ]
plot_dados$rotulo <- factor(unname(nomes[plot_dados$variavel]), levels=rev(unname(nomes)))
p <- ggplot(plot_dados,aes(delta_r2a,rotulo))+geom_vline(xintercept=0,colour='#7A869A')+geom_col(fill='#00689D',width=.65)+labs(x='Ganho de R² ajustado com uma candidata por vez',y=NULL)+scale_x_continuous(labels=function(z) format(z,decimal.mark=',',trim=TRUE))+theme_minimal(base_size=13)+theme(plot.background=element_rect(fill='white',colour=NA),panel.grid.major.y=element_blank())
ggsave(file.path(output,'11_auditoria_candidatas.png'),p,width=10,height=4.7,dpi=170)
