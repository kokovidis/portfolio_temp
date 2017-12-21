#sqrt(mean(gam.m4$residuals^2))
library(ISLR)
attach(Wage)

# Polynomial Regression and Step Functions
attach(dataset)
fit=lm(house_prices_mean~poly(dis2012,4),data=dataset)
coef(summary(fit))
dataset <- data.frame(dataset)
dislims=range(dis2012)
dis.grid=seq(from=dislims[1],to=dislims[2], by=1)
preds=predict(fit,newdata=list(dis2012=dis.grid),se=TRUE)
se.bands=cbind(preds$fit+2*preds$se.fit,preds$fit-2*preds$se.fit)
par(mfrow=c(1,2),mar=c(4.5,4.5,1,1),oma=c(0,0,4,0))
plot(dis2012,house_prices_mean,xlim=dislims, cex=.5,col="darkgrey")
title("Degree-4 Polynomial",outer=T)
lines(dis.grid,preds$fit,lwd=2,col="blue")
matlines(dis.grid,se.bands,lwd=1,col="green",lty=1)
fit.1=lm(house_prices_mean~dis2012,data=dataset)
fit.2=lm(house_prices_mean~poly(dis2012,2),data=dataset)
fit.3=lm(house_prices_mean~poly(dis2012,3),data=dataset)
fit.4=lm(house_prices_mean~poly(dis2012,4),data=dataset)
fit.5=lm(house_prices_mean~poly(dis2012,5),data=dataset)
anova(fit.1,fit.2,fit.3,fit.4,fit.5)

fit.1=lm(house_prices_mean~dataset[,1],data=dataset)
fit.2=lm(house_prices_mean~poly(dataset[,1],2),data=dataset)
fit.3=lm(house_prices_mean~dataset[,1]+dataset[,2],data=dataset)
anova(fit.1,fit.2,fit.3)
fit=glm(I(house_prices_mean>150000)~poly(dis2012,4),data=dataset,family=binomial)
preds=predict(fit,newdata=list(dis2012=dis.grid),se=T)
pfit=exp(preds$fit)/(1+exp(preds$fit))
se.bands.logit = cbind(preds$fit+2*preds$se.fit, preds$fit-2*preds$se.fit)
se.bands = exp(se.bands.logit)/(1+exp(se.bands.logit))
plot(dis2012,I(house_prices_mean>150000),xlim=dislims,type="n",ylim=c(0,1))
points(jitter(dis2012), I((house_prices_mean>150000)),cex=.5,pch="|",col="darkgrey")
lines(dis.grid,pfit,lwd=2, col="blue")
matlines(dis.grid,se.bands,lwd=1,col="blue",lty=3)
table(cut(dis2012,4))
fit=lm(house_prices_mean~cut(dis2012,4),data=dataset)
coef(summary(fit))

# Splines
#Cubic
library(splines)
fit=lm(house_prices_mean~bs(dis2012,knots=c(10000,15000,20000)),data=dataset)
pred=predict(fit,newdata=list(dis2012=dis.grid),se=T)
plot(dis2012,house_prices_mean,col="gray")
lines(dis.grid,pred$fit,lwd=2)
lines(dis.grid,pred$fit+2*pred$se,lty="dashed")
lines(dis.grid,pred$fit-2*pred$se,lty="dashed")
attr(bs(dis2012,df=9),"knots")

#Natural
fit2=lm(house_prices_mean~ns(dis2012,df=2000),data=dataset)
pred2=predict(fit2,newdata=list(dis2012=dis.grid),se=T)
plot(dis2012,house_prices_mean,xlim=dislims,cex=.5,col="darkgrey")
lines(dis.grid, pred2$fit,col="red",lwd=2)

#Smoothing
fit=smooth.spline(dis2012,house_prices_mean,df=500)
fit2=smooth.spline(dis2012,house_prices_mean,cv=TRUE)
plot(dis2012,house_prices_mean,xlim=dislims,cex=.5,col="darkgrey")
title("Smoothing Spline")
fit2$df
lines(fit,col="red",lwd=2)
lines(fit2,col="blue",lwd=2)
df <- round(fit2$df, digits=4)
df <- as.character(df)
df <- paste("CV", df, "DF", collapse = "")
legend("topright",legend=c("500 DF", df ),col=c("red","blue"),lty=1,lwd=2,cex=.8)

#Local Regression
fit=loess(house_prices_mean~dis2012,span=0.1,data=dataset)
fit2=loess(house_prices_mean~dis2012,span=1,data=dataset)
plot(dis2012,house_prices_mean,xlim=dislims,cex=.5,col="darkgrey")
title("Local Regression")


# GAMs
attach(dataset)
gam.n=lm(house_prices_mean~ns(dis2012,df=8)+ns(natalsmoke2012,df=16),data=dataset)
library(gam)
gam.sp=gam(house_prices_mean~s(dis2012,df=8)+s(natalsmoke2012,df=16),data=dataset)
par(mfrow=c(2,2))
plot.gam(gam.n, se=TRUE, col="red" , main="Natural Spline")
plot.gam(gam.sp, se=TRUE,col="blue", main="Smoothing Spline")


gam.m1=gam(house_prices_mean~poly(dis2012,df=3)+poly(natalsmoke2012,df=3),data=dataset)
gam.m2=gam(house_prices_mean~ns(dis2012,df=3)+ns(natalsmoke2012,df=3),data=dataset)
gam.m3=gam(house_prices_mean~s(dis2012,df=3)+s(natalsmoke2012,df=3),data=dataset)
gam.m4=gam(house_prices_mean~lo(dis2012,span=1)+lo(natalsmoke2012,span=1),data=dataset)

plot.gam(gam.m4, se=TRUE,col="green", main="Local Regression")
preds=predict(gam.m4,newdata=dataset)

anova(gam.m1,gam.m2,gam.m3,test="F")
summary(gam.m3)
preds=predict(gam.m2,newdata=dataset)
par(mfrow=c(1,2))


#local reg
gam.lo=gam(house_prices_mean~lo(dis2012,span=0.5)+lo(natalsmoke2012,span=0.5),data=dataset)
plot.gam(gam.lo, se=TRUE, col="green")
plot.gam(gam.lo)

#logistic reg
gam.lr=gam(I(house_prices_mean>150000)~+s(dis2012,df=5)+natalsmoke2012,family=binomial,data=dataset)
par(mfrow=c(1,2))
plot(gam.lr,se=T,col="yellow", lwd=2)
