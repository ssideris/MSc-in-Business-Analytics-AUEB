#------------------------------Start----------------------------------------

#import libraries
library(aod)
library(glmnet)

#set directory and read file
setwd("C:/Users/sgsid/Desktop/BA - Master/Spring/Statistics II/Assignment I")
data <- read.csv("project I  2021-2022.csv", header = TRUE )

#-------------------------Data Cleaning-------------------------------------

#Check for blanks
sum(data == '')
#Check for unknown values
sum(data=='unknown')
#Delete column pdays as most of the clients were not contacted before
sum(data[,13]==999)
data <- data[,-13]
View(data)
#change type of character variables to factor
data_cleaned <- as.data.frame(unclass(data[,c(2:10,14,20)]), stringsAsFactors = TRUE)
#add numeric variables
data_cleaned$age <- as.numeric(data$age)
data_cleaned$duration <- as.numeric(data$duration)
data_cleaned$campaign <- as.numeric(data$campaign)
data_cleaned$previous <- as.numeric(data$previous)
data_cleaned$emp.var.rate <- data$emp.var.rate
data_cleaned$cons.price.idx <- data$cons.price.idx
data_cleaned$cons.conf.idx <- data$cons.conf.idx
data_cleaned$euribor3m <- data$euribor3m
data_cleaned$nr.employed <- data$nr.employed

#-------------------------Fit Full Model--------------------------------------
View(data_cleaned)
#Build Unregularized Model
mylogit <- glm(SUBSCRIBED ~ ., data = data_cleaned, family = binomial(link = "logit"))
summary(mylogit)
#------------------------Model selection--------------------------------------

#lasso method
lambdas <- 10 ** seq(8,-4,length=250)
x_matrix <-  model.matrix(mylogit)[,-1]
lasso <- glmnet(x_matrix, data_cleaned$SUBSCRIBED, alpha=1, lambda=lambdas, family="binomial")
#lasso cross validation
lasso.cv <- cv.glmnet(x_matrix, data_cleaned$SUBSCRIBED, alpha=1, lambda=lambdas, family="binomial", type.measure='class')
plot(lasso.cv)
lasso.cv$lambda.1se
coef(lasso.cv, s = lasso.cv$lambda.1se)
#dataset after lasso
data_cleaned <-  data_cleaned[,c(-12,-15,-18,-19)]
#model after lasso
mylogit_1 <- glm(SUBSCRIBED ~ ., data = data_cleaned, family = binomial(link = "logit"))

#stepwise method for both ways according to AIC
m1 <- step(mylogit_1, trace=TRUE, direction = 'both')
#stepwise method for both ways according to BIC
m2 <- step(mylogit_1, trace=TRUE, direction = 'both', log=nrow(data_cleaned))
#goodness of fit  
with(m1, pchisq(deviance, df.residual, lower.tail = F))
with(m2, pchisq(deviance, df.residual, lower.tail = F))

#dataset after step
data_cleaned <- data_cleaned[,c(-3,-5,-6)]

#--------------Testing hypotheses via the Wald statistic----------------------

#wald test to test if job has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 2:12)
#wald test to test if marital status has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 13:15)#out
#wald test to test if default has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 16:17)
#wald test to test if contact has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 18)
#wald test to test if month has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 19:27)
#wald test to test if day_of_week has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 28:31)
#wald test to test if poutcome has no effect on submission
wald.test(b = coef(m2), Sigma = vcov(m2), Terms = 32:33)

#remove variables with zero effect on submission
data_cleaned = data_cleaned[,-2]
mylogit_2 <- glm(SUBSCRIBED ~ ., data = data_cleaned, family = binomial(link = "logit"))

#-------------------------Collinearity Analysis--------------------------------------

#collinearity
index <-  sapply(data_cleaned,class) == "numeric"
dataset_numeric <- data_cleaned[,index]
require(corrplot)
corrplot(cor(dataset_numeric), method = "number") 
#remove numeric variables with high correlation
data_cleaned = data_cleaned[,c(-10,-11)]
str(data_cleaned)

#---------------------------Final Model--------------------------------------------------------

#final model
final_model <- glm(SUBSCRIBED ~ ., data = data_cleaned, family = binomial(link = "logit"))
summary(final_model)

#-------------------Goodness of fit-----------------------------
#final model goodness of fit
with(final_model, pchisq(deviance, df.residual,lower.tail = FALSE))
#compare full model to null model
with(final_model, null.deviance - deviance)
with(final_model, df.null - df.residual)
with(final_model, pchisq(null.deviance - deviance, df.null - df.residual, lower.tail = FALSE))

#-----------------Residuals against all predictors-----------------------------
#outliers test
outlierTest(final_model)

#Pearson residuals against independent variables
par(mfrow=c(3,3))
plot(as.numeric(data_cleaned$job), resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='job',ylim=c(-50,50) )
plot(as.numeric(data_cleaned$default), resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='default',ylim=c(-50,50))
plot(as.numeric(data_cleaned$contact), resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='contact',ylim=c(-50,50))
plot(as.numeric(data_cleaned$month), resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='month',ylim=c(-50,50))
plot(as.numeric(data_cleaned$day_of_week), resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='day_of_week', ylim=c(-50,50))
plot(as.numeric(data_cleaned$poutcome), resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='poutcome', ylim=c(-50,50))
plot(data_cleaned$duration, resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='duration', ylim=c(-50,50))
plot(data_cleaned$campaign, resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='campaign',ylim=c(-50,50))
plot(data_cleaned$nr.employed, resid(final_model, type='pearson'), ylab='Residuals (Pearson)', xlab='nr.employed',ylim=c(-50,50))

#Deviance residuals against independent variables
par(mfrow=c(3,3))
plot(as.numeric(data_cleaned$job), resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='job',ylim=c(-10,10) )
plot(as.numeric(data_cleaned$default), resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='default',ylim=c(-10,10))
plot(as.numeric(data_cleaned$contact), resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='contact',ylim=c(-10,10))
plot(as.numeric(data_cleaned$month), resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='month',ylim=c(-10,10))
plot(as.numeric(data_cleaned$day_of_week), resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='day_of_week',ylim=c(-10,10))
plot(as.numeric(data_cleaned$poutcome), resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='poutcome',ylim=c(-10,10))
plot(data_cleaned$duration, resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='duration',ylim=c(-10,10))
plot(data_cleaned$campaign, resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='campaign',ylim=c(-10,10))
plot(data_cleaned$nr.employed, resid(final_model, type='deviance'), ylab='Residuals (Deviance)', xlab='nr.employed',ylim=c(-10,10))


