source('validacao/auditar_candidatas.R')
library(jsonlite)
a<-fromJSON('validacao/dados/favelas_sidra_9888_2022.json')[-1,]
b<-read.csv('entrega/dados/base_analitica.csv')
x<-read.csv('dados/tabelas/candidatas.csv')
stopifnot(nrow(a)==656,!anyDuplicated(a$D1C),all(a$D2C=='9612'),all(a$D3C=='2022'),all(a$MN=='Pessoas'),!any(a$V %in% c('-','...','X')))
fav<-as.numeric(a$V[match(b$cod_ibge,a$D1C)])
fav[is.na(fav)]<-0
pct<-100*fav/b$pop
stopifnot(max(abs(pct-x$pct_favela[match(b$cod_ibge,x$cod_ibge)]))<1e-10)
cat('A captura oficial de 17/11/2026 contém 656 municípios, sem sigilo. Total:',sum(as.numeric(a$V)),'; proporções integradas conferidas.\n')
d<-z$d;m0<-z$base
models<-list(base=m0,favela=lm(update(formula(m0),.~.+pct_favela),data=d),favela_log=lm(update(formula(m0),.~.+log1p(pct_favela)),data=d),industria=lm(update(formula(m0),.~.+pct_ind),data=d),pib=lm(update(formula(m0),.~.+ln_pib_pc),data=d),tres=lm(update(formula(m0),.~.+pct_favela+pct_ind+ln_pib_pc),data=d))
for(k in names(models)){
 m<-models[[k]];cat('\n',k,'\n');extra<-setdiff(names(coef(m)),names(coef(m0)));if(length(extra))print(coef(summary(m))[extra,,drop=FALSE]);print(c(r2a=summary(m)$adj.r.squared,SW=shapiro.test(rstandard(m))$p.value,BP=lmtest::bptest(m)$p.value,PRESS=sum((resid(m)/(1-hatvalues(m)))^2),VIFmax=max(car::vif(m)[,'GVIF^(1/(2*Df))']^2)))
}
base_coefs<-coef(models$favela)
cases<-list(todos=rep(TRUE,nrow(d)),sem_SP=d$uf!='SP',sem_RJ=d$uf!='RJ',sem_PA=d$uf!='PA',sem_AM=d$uf!='AM',sem_Nova_Lima=d$cod_ibge!=3144805,sem_percentil99_favela=d$pct_favela<=quantile(d$pct_favela,.99),pop50k=d$pop>=50000,pop100k=d$pop>=100000)
out<-list()
for(k in names(cases)){
 dd<-d[cases[[k]],]; m<-lm(update(formula(m0),.~.+pct_favela),data=dd);t<-coef(summary(m))['pct_favela',];ci<-confint(m)['pct_favela',]
 out[[k]]<-data.frame(cenario=k,n=nrow(dd),b=t[1],p=t[4],efeito_10pp=100*expm1(t[1]*10),inf_10pp=100*expm1(ci[1]*10),sup_10pp=100*expm1(ci[2]*10),SW=shapiro.test(rstandard(m))$p.value,BP=lmtest::bptest(m)$p.value)
}
out<-do.call(rbind,out);print(out,row.names=FALSE);write.csv(out,'validacao/saida/12_favela_sensibilidade.csv',row.names=FALSE)
png('validacao/saida/12_favela_diagnosticos.png',width=1600,height=1200,res=150);par(mfrow=c(2,2),mar=c(4,4,2.5,1));plot(d$pct_favela,d$ly,pch=16,cex=.5,col='#00689D60',xlab='% da população em favelas e comunidades urbanas',ylab='ln(taxa observada)',main='Associação bruta; sem ajuste');plot(fitted(models$favela),resid(models$favela),pch=16,cex=.5,col='#00689D60',xlab='ln(taxa ajustada)',ylab='Resíduo',main='Modelo com percentual em escala original');abline(h=0,lty=2);plot(d$pct_favela,resid(models$favela),pch=16,cex=.5,col='#00689D60',xlab='% da população em favelas e comunidades urbanas',ylab='Resíduo',main='Resíduos contra a nova explicativa');abline(h=0,lty=2);qqnorm(rstandard(models$favela),pch=16,cex=.5,col='#00689D60',main='Q-Q do modelo com percentual');qqline(rstandard(models$favela),col='#C8343B');dev.off()

d$tem_favela<-as.numeric(d$pct_favela>0)
f1<-update(formula(m0),.~.+pct_favela)
a<-lm(f1,data=d)
for(name in c('log_pop','tem_favela')){
 b<-lm(update(f1,paste('.~.+',name)),data=d);cat('\nADICIONAR',name,'AO MODELO COM FAVELA\n');print(anova(a,b));print(coef(summary(b))[c('pct_favela',name),,drop=FALSE])
}
uf<-unique(d$uf); out<-do.call(rbind,lapply(uf,function(s){dd<-d[d$uf!=s,];m<-lm(f1,data=dd);t<-coef(summary(m))['pct_favela',];data.frame(uf_retirada=s,n=nrow(dd),b=t[1],p=t[4])}));cat('\nRETIRADA DE CADA UF\n');print(out,row.names=FALSE);cat('sinais positivos:',sum(out$b>0),'de',nrow(out),'\n');write.csv(out,'validacao/saida/12_favela_sem_uf.csv',row.names=FALSE)
regions<-levels(d$regiao);out2<-do.call(rbind,lapply(regions,function(s){dd<-droplevels(d[d$regiao!=s,]);mm<-lm(f1,data=dd);t<-coef(summary(mm))['pct_favela',];data.frame(regiao_retirada=s,n=nrow(dd),b=t[1],p=t[4])}));print(out2,row.names=FALSE);write.csv(out2,'validacao/saida/12_favela_sem_regiao.csv',row.names=FALSE)
fc<-update(formula(m0),.~.-regiao+factor(uf)+pct_favela);ms<-lm(fc,data=d);cat('\nESTADO APENAS COMO SENSIBILIDADE\n');print(coef(summary(ms))['pct_favela',,drop=FALSE])
