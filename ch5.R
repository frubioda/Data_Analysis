##Exercise chapter5
library(pracma)

cd('~/job_interviews/StatisticalLearning/chapter5')
load("5.R.RData")
ls()
names(Xy); head(Xy); tail(Xy)
attach(Xy)

#Q1: Consider the linear regression model of y on X1 and X2. What is the standard error for beta1?
plot(y~X1+X2,Xy,xlab="X1,X2",ylab="y",col="blue")
fit1 = lm(y~X1+X2,data=Xy)
summary(fit1) #std-err beta1=0.02593

par(mfrow=c(2,2)); plot(fit1); par(mfrow=c(1,1))

#Q2: plot the data using matplot(Xy,type="l"). Which of the following do you think is most likely given what you see?
?matplot
matplot(Xy,type="l")
#There is very strong autocorrelation between consecutive rows of the data matrix. Roughly speaking, we have about 10-20 repeats of every data point, so the sample size is in effect much smaller than the number of rows (1000 in this case).

#Q3: use the (standard) bootstrap to estimate SE(beta1). To within 10%, what do you get?
library(boot)

#WAY1: create my own function
alpha=function(x,y){
  vx=var(x)
  vy=var(y)
  cxy=cov(x,y)
  (vy-cxy)/(vx+vy-2*cxy)
}
alpha(Xy$X1,Xy$y) #0.4167192
alpha(Xy$X2,Xy$y) #0.4802987

#WAY2: alpha function
alphax1.fn=function(data, index){
  with(data[index,],alpha(Xy$X1,Xy$y))
}
alphax2.fn=function(data, index){
  with(data[index,],alpha(Xy$X2,Xy$y))
}
alpha.fn<-function(data,index){
  fit1<-lm(y~., data=Xy[index,])
  coefficients(fit1)[['X1']]
}
alphax1.fn(Xy,1:1000) #0.4167192 #n=1000 because the size of Xy$X is 1000
alphax2.fn(Xy,1:1000) #0.4802987

set.seed(1)
alphax1.fn(Xy,sample(1:100,100,replace=TRUE)) #0.4167192
alphax2.fn(Xy,sample(1:100,100,replace=TRUE)) #0.4802987
alpha.fn(Xy,sample(1:100,100,replace=TRUE)) #0.1228036

bootx1.out=boot(Xy,alphax1.fn,R=1000)
boot.out=boot(Xy,alpha.fn,R=1000)
boot.out #0.02873965
plot(boot.out)

#Q3 other way:
rsq <- function(formula, data, indices) { # function to obtain SE from the data 
  d <- Xy[indices,] # allows boot to select sample 
  fit <- lm(formula, data=d)
  return(coef(summary(fit))[, 1])
}

boot(data=Xy, statistic=rsq, R=1000, formula=y ~ .) # bootstrapping with 1000 replications 

#Q4: Use the block bootstrap to estimate SE(beta1). Use blocks of 100 contiguous observations, and resample ten whole blocks with replacement then paste them together to construct each bootstrap time series.
boot.fn.ts = function(data){
  fit <- lm(y ~ ., data)
  return(coef(fit))
}

?tsboot #Use block bootstrapp using the tsboot function
tsboot(Xy, boot.fn.ts, R = 1000, sim = "fixed", l = 100) #0.18770794

q()
