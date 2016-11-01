##Exercise chapter7
library(pracma)

cd('~/job_interviews/StatisticalLearning/chapter7')
load("7.R.RData")
ls()

#Q1: Load the data from the file 7.R.RData, and plot it using plot(x,y). What is the slope coefficient in a linear regression of y on x (to within 10%)?
plot(x,y,xlab="x",ylab="y",col="blue")
fit1 = lm(y~x)
summary(fit1) #-0.67483
abline(fit1,lwd=2,col="lightblue")


#Q2: For the model y ~ 1+x+x^2, what is the coefficient of x (to within 10%)?
fit2 = lm(y~x +I(x^2))
summary(fit2) #7.771e+01
abline(fit2,lwd=2,col="darkgreen")

q()
