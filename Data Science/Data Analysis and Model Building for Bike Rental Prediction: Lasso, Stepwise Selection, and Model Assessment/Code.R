setwd("C:\\Users\\sgsid\\Desktop\\BA - Master\\Winter\\Statistics 1\\Main Assignment")
dataset <-read.csv2("bike_13.csv")
str(dataset)
#1
#delete variable X,instant,dteday,casual,registered
dataset <- dataset[,c(-1,-2,-3,-16,-17)]

#check for NAs
dataset$season[dataset$season == ""] <- NA; sum(is.na(dataset$season))
dataset$yr[dataset$yr == ""] <- NA; sum(is.na(dataset$yr))
dataset$mnth[dataset$mnth == ""] <- NA; sum(is.na(dataset$mnth))
dataset$hr[dataset$hr == ""] <- NA; sum(is.na(dataset$hr))
dataset$holiday[dataset$holiday == ""] <- NA; sum(is.na(dataset$holiday))
dataset$weekday[dataset$weekday == ""] <- NA; sum(is.na(dataset$weekday))
dataset$weathersit[dataset$weathersit == ""] <- NA; sum(is.na(dataset$weathersit))
dataset$temp[dataset$temp == ""] <- NA; sum(is.na(dataset$temp))
dataset$atemp[dataset$atemp == ""] <- NA; sum(is.na(dataset$atemp))
dataset$hum[dataset$hum == ""] <- NA; sum(is.na(dataset$hum))
dataset$windspeed[dataset$windspeed == ""] <- NA; sum(is.na(dataset$windspeed))
dataset$cnt[dataset$cnt == ""] <- NA; sum(is.na(dataset$cnt))

#change of class
dataset$season <- as.factor(dataset$season)
dataset$yr <- as.factor(dataset$yr)
dataset$mnth <- as.factor(dataset$mnth)
dataset$hr <- as.factor(dataset$hr)
dataset$holiday <- as.factor(dataset$holiday)
dataset$weekday <- as.factor(dataset$weekday)
dataset$workingday <- as.factor(dataset$workingday)
dataset$weathersit  <- as.factor(dataset$weathersit)
dataset$cnt <- as.numeric(dataset$cnt)
dataset$atemp <- as.numeric(dataset$atemp)
dataset$hum <- as.numeric(dataset$hum)
#change of label names for factors
dataset$season<-factor(dataset$season,levels = c(1,2,3,4),labels = c('winter','spring','summer','autumn'))
dataset$yr<-factor(dataset$yr,levels = c(0,1),labels =c(2011,2012))
dataset$workingday <-factor(dataset$workingday,levels = c(0,1),labels =c("not workingday","workingday"))
dataset$holiday<-factor(dataset$holiday,levels = c(0,1),labels =c("not holiday","holiday"))
dataset$weathersit <- factor(dataset$weathersit,levels = c(1, 2,3,4) , 
                           labels = c("Good","Moderate","Bad","Worse"))

#creation of numeric dataset
require(psych)
index <-  sapply(dataset,class) == "numeric"
dataset_numeric <- dataset[,index]
#description of data
round(t(describe(dataset_numeric)),2)
#visualizations
par(mfrow=c(2,3))
str(dataset_numeric)
hist(dataset_numeric[,1], main=names(dataset_numeric[1]), sub="The Histogram of variable temp")
hist(dataset_numeric[,2], main=names(dataset_numeric[2]), sub="The Histogram of variable atemp")   
hist(dataset_numeric[,3], main=names(dataset_numeric[3]), sub="The Histogram of variable hum")
hist(dataset_numeric[,4], main=names(dataset_numeric[4]), sub="The Histogram of variable windspeed")
hist(dataset_numeric[,5], main=names(dataset_numeric[5]), sub="The Histogram of variable cnt")
#Visualizations of factor variables
dataset_factor <- dataset[,!index]; n=nrow(dataset_numeric)
str(dataset_factor)
dataset_factor <- dataset_factor[,-9]
dataset_binary_factor <- dataset_factor[,c(2,5,7)]

par(mfrow=c(2,3))
str(dataset_factor)
plot(table(dataset_factor[,1])/n, type='h', main=names(dataset_factor)[1], ylab='Relative frequency', sub="The Plot of Variable season")
plot(table(dataset_factor[,3])/n, type='h', main=names(dataset_factor)[3], ylab='Relative frequency', sub="The Plot of Variable mnth")
plot(table(dataset_factor[,4])/n, type='h', main=names(dataset_factor)[4], ylab='Relative frequency', sub="The Plot of Variable hr ")
plot(table(dataset_factor[,6])/n, type='h', main=names(dataset_factor)[6], ylab='Relative frequency', sub="The Plot of Variable weekday")
plot(table(dataset_factor[,8])/n, type='h', main=names(dataset_factor)[8], ylab='Relative frequency', sub="The Plot of Variable weathersit")

par(mfrow = c(3,1))
barplot(table(dataset_binary_factor$holiday)/n, horiz=T, las=1,col = 2:3, ylim=c(0,8), cex.names=0.7, sub="The barplot of variable holiday")
legend('top', fil=2:3, legend=c('Not Holiday','Holiday'), ncol=2, bty='n',cex=1.5)
barplot(table(dataset_binary_factor$yr)/n, beside = T, horiz=T, las=1,col = 2:3, ylim=c(0,8), cex.names=0.7, sub="The barplot of variable yr")
legend('top', fil=2:3, legend=c('2011','2012'), ncol=2, bty='n',cex=1.5)
barplot(table(dataset_binary_factor$workingday)/n, beside = T, horiz=T, las=1,col = 2:3, ylim=c(0,8), cex.names=0.55, sub="The barplot of variable workingday")
legend('top', fil=2:3, legend=c('Not Working Day','Working Day'), ncol=2, bty='n',cex=1.5)
#Pairwise correlations of numeric variables
require(corrplot)
corrplot(cor(dataset_numeric), method = "number") 
#Plots of numeric variables
par(mfrow=c(2,3))
for(j in 1:4){
  plot(dataset_numeric[,j], dataset_numeric[,5], xlab=names(dataset_numeric)[j], ylab='Number of Bike Rentals',cex.lab=1.5)
  abline(lm(dataset_numeric[,5]~dataset_numeric[,j]))
}
#Boxplots of factor variables
par(mfrow=c(3,3))
for(j in 1:8){
  boxplot(dataset_numeric[,5]~dataset_factor[,j], xlab=names(dataset_factor)[j], ylab='Number of Bike Rentals',cex.lab=1.0)
}

#Clean off not useful variables
dataset_clean = dataset[,-14]

#The full model
modelfull <- lm(cnt ~., data = dataset_clean)
summary(modelfull)
anova(modelfull)
#The constant model
modelconstant <-  lm(cnt~1, data = dataset_clean)
summary(modelconstant)
# ANOVA for full-model against constant model
anova(modelconstant, modelfull)


#Lasso implementation
require(glmnet)
X <- model.matrix(modelfull)[,-1]
lasso <- glmnet(X, dataset_clean$cnt)
plot(lasso, xvar = "lambda", label = T)
#Find reasonable value for lambda
lasso1 <- cv.glmnet(X, dataset_clean$cnt, alpha = 1)
lasso1$lambda
lasso1$lambda.min
lasso1$lambda.1se
plot(lasso1)
coef(lasso1, s = "lambda.min")
coef(lasso1, s = "lambda.1se")
plot(lasso1$glmnet.fit, xvar = "lambda", label = T)
abline(v=log(c(lasso1$lambda.min, lasso1$lambda.1se)), lty =2)
str(dataset_clean)
#dataset after lasso
dataset_afterlasso <- dataset_clean[,c(-5,-6,-7,-9,-12)]

#full model after lasso
model_afterlasso <- lm(cnt~.,data = dataset_afterlasso)
summary(model_afterlasso)

#stepwise-method
model_afterstep <- step(model_afterlasso, direction='both')
summary(model_afterstep)
dataset_afterstep <- dataset_afterlasso
#Hypothesis Testing
par(mfrow=c(2,2))

#Check for multi collinearity
require(car)
round(vif(model_afterstep),1)

#Check for Normality of Residuals
plot(model_afterstep, which = 2, main = "cnt") 

#Check for Homoscedasticity
#With Plots
Stud.residuals <- rstudent(model_afterstep)
yhat <- fitted(model_afterstep)
par(mfrow=c(1,2))
plot(yhat, Stud.residuals)
abline(h=c(-2,2), col=2, lty=2)
plot(yhat, Stud.residuals^2)
abline(h=4, col=2, lty=2)
#With Test
library(car)
ncvTest(model_afterstep)

#Check for Non-Linearity
residualPlot(model_afterstep, type='rstudent')
residualPlots(model_afterstep, plot=F, type = "rstudent")

#Check for Independence
plot(rstudent(model_afterstep), type='l')
library(car); durbinWatsonTest(model_afterstep)

#Fixing
#Box Cox
initial_model <- lm(cnt~., data = dataset_afterstep)
p1 <- powerTransform(initial_model)
summary(p1)
testTransform(p1, lambda = 0.2) 
#Add Log
logmodel<-lm(log(cnt)~.,data=dataset_afterstep)

#Add polynomial effects
logmodel <- lm(log(cnt)~.+I(atemp^2)+I(hum^2)-yr-mnth, data = dataset_afterstep)

#weighted least squares
wt <- 1 / lm(abs(logmodel$residuals) ~ logmodel$fitted.values)$fitted.values^2
#perform weighted least squares regression
wls_model <- lm(log(cnt)~.+I(atemp^2)+I(hum^2)-yr-mnth, data=dataset_afterstep, weight=wt)

#outliers
library(car)
outs <- influencePlot(logmodel)
n <- 2
Cooksdist <- as.numeric(tail(row.names(outs[order(outs$CookD), ]), n))
dataset_afterstep <- dataset_afterstep %>% slice(-c(1269,1278))

#equation
final_model <- wls_model

#norm
plot(final_model, which = 2, main = "cnt")
require(nortest)
shapiro.test(final_model$residuals)
lillie.test(final_model$residuals)
#heter                                                                    
plot(final_model, which = 3)
ncvTest(final_model)

#non line
residualPlot(final_model, type='rstudent')
residualPlots(final_model, plot=F, type = "rstudent")

#ind
plot(rstudent(final_model), type='l')
durbinWatsonTest(final_model)

#test predictive ability
#Insert dataset test and do transformations
dataset_test <-read.csv2("bike_test.csv")
dataset_test$season[dataset_test$season == ""] <- NA; sum(is.na(dataset_test$season))
dataset_test$yr[dataset_test$yr == ""] <- NA; sum(is.na(dataset_test$yr))
dataset_test$mnth[dataset_test$mnth == ""] <- NA; sum(is.na(dataset_test$mnth))
dataset_test$hr[dataset_test$hr == ""] <- NA; sum(is.na(dataset_test$hr))
dataset_test$holiday[dataset_test$holiday == ""] <- NA; sum(is.na(dataset_test$holiday))
dataset_test$weekday[dataset_test$weekday == ""] <- NA; sum(is.na(dataset_test$weekday))
dataset_test$weathersit[dataset_test$weathersit == ""] <- NA; sum(is.na(dataset_test$weathersit))
dataset_test$temp[dataset_test$temp == ""] <- NA; sum(is.na(dataset_test$temp))
dataset_test$atemp[dataset_test$atemp == ""] <- NA; sum(is.na(dataset_test$atemp))
dataset_test$hum[dataset_test$hum == ""] <- NA; sum(is.na(dataset_test$hum))
dataset_test$windspeed[dataset_test$windspeed == ""] <- NA; sum(is.na(dataset_test$windspeed))
dataset_test$cnt[dataset_test$cnt == ""] <- NA; sum(is.na(dataset_test$cnt))

#change of class
dataset_test$season <- as.factor(dataset_test$season)
dataset_test$yr <- as.factor(dataset_test$yr)
dataset_test$mnth <- as.factor(dataset_test$mnth)
dataset_test$hr <- as.factor(dataset_test$hr)
dataset_test$holiday <- as.factor(dataset_test$holiday)
dataset_test$weekday <- as.factor(dataset_test$weekday)
dataset_test$workingday <- as.factor(dataset_test$workingday)
dataset_test$weathersit  <- as.factor(dataset_test$weathersit)
dataset_test$cnt <- as.numeric(dataset_test$cnt)
dataset_test$atemp <- as.numeric(dataset_test$atemp)
dataset_test$hum <- as.numeric(dataset_test$hum)
#change of label names for factors
dataset_test$season<-factor(dataset_test$season,levels = c(1,2,3,4),labels = c('winter','spring','summer','autumn'))
dataset_test$yr<-factor(dataset_test$yr,levels = c(0,1),labels =c(2011,2012))
dataset_test$workingday <-factor(dataset_test$workingday,levels = c(0,1),labels =c("not workingday","workingday"))
dataset_test$holiday<-factor(dataset_test$holiday,levels = c(0,1),labels =c("not holiday","holiday"))
dataset_test$weathersit <- factor(dataset_test$weathersit,levels = c(1, 2,3,4) , 
                             labels = c("Good","Moderate","Bad","Worse"))

#do predictions
library(caret)
predictions1 <- predict(final_model, dataset_test)
predictions2 <- predict(modelconstant, dataset_test)
predictions3 <- predict(modelfull, dataset_test)
predictions4 <- predict(model_afterlasso, dataset_test)
predictions5 <- predict(model_afterstep, dataset_test)

# computing model performance metrics
R2 = R2(predictions1, dataset_test$cnt)
MAE_2 = mae(dataset_test$cnt,predictions2)
MAE_3 = mae(dataset_test$cnt,predictions3)
MAE_4 = mae(dataset_test$cnt,predictions4)
MAE_5= mae(dataset_test$cnt,predictions5)
metrics <- data.frame(R2, MAE_2, MAE_3, MAE_4, MAE_5)
metrics
#to describe a typical day for each season
#winter
dataset_winter <- dataset[dataset$season=="winter",]
index <-  sapply(dataset_winter,class) == "numeric"
dataset_numeric <- dataset_winter[,index]

par(mfrow=c(3,3))
hist(dataset_numeric[,1], main=names(dataset_numeric[1]), sub="The Histogram of variable temp")
hist(dataset_numeric[,3], main=names(dataset_numeric[3]), sub="The Histogram of variable hum")
hist(dataset_numeric[,4], main=names(dataset_numeric[4]), sub="The Histogram of variable windspeed")

dataset_factor <- dataset_winter[,!index]; n=nrow(dataset_numeric)
dataset_factor <- dataset_factor[,-9]
dataset_binary_factor <- dataset_factor[,c(2,5,7)]

plot(table(dataset_factor[,4])/n, type='h', main=names(dataset_factor)[4], ylab='Relative frequency', sub="The Plot of Variable hr ")
plot(table(dataset_factor[,8])/n, type='h', main=names(dataset_factor)[8], ylab='Relative frequency', sub="The Plot of Variable weathersit")

boxplot(dataset_numeric[,5]~dataset_factor[,4], xlab=names(dataset_factor)[4], ylab='Number of Bike Rentals',cex.lab=1.0)
boxplot(dataset_numeric[,5]~dataset_factor[,1], xlab=names(dataset_factor)[1], ylab='Number of Bike Rentals',cex.lab=1.0)

#spring
dataset_spring <- dataset[dataset$season=="spring",]
index <-  sapply(dataset_spring,class) == "numeric"
dataset_numeric <- dataset_spring[,index]

par(mfrow=c(3,3))
hist(dataset_numeric[,1], main=names(dataset_numeric[1]), sub="The Histogram of variable temp")
hist(dataset_numeric[,3], main=names(dataset_numeric[3]), sub="The Histogram of variable hum")
hist(dataset_numeric[,4], main=names(dataset_numeric[4]), sub="The Histogram of variable windspeed")

dataset_factor <- dataset_spring[,!index]; n=nrow(dataset_numeric)
dataset_factor <- dataset_factor[,-9]
dataset_binary_factor <- dataset_factor[,c(2,5,7)]

plot(table(dataset_factor[,4])/n, type='h', main=names(dataset_factor)[4], ylab='Relative frequency', sub="The Plot of Variable hr ")
plot(table(dataset_factor[,8])/n, type='h', main=names(dataset_factor)[8], ylab='Relative frequency', sub="The Plot of Variable weathersit")

boxplot(dataset_numeric[,5]~dataset_factor[,4], xlab=names(dataset_factor)[4], ylab='Number of Bike Rentals',cex.lab=1.0)
boxplot(dataset_numeric[,5]~dataset_factor[,1], xlab=names(dataset_factor)[1], ylab='Number of Bike Rentals',cex.lab=1.0)

#summer
dataset_summer <- dataset[dataset$season=="summer",]
index <-  sapply(dataset_summer,class) == "numeric"
dataset_numeric <- dataset_summer[,index]

par(mfrow=c(3,3))
hist(dataset_numeric[,1], main=names(dataset_numeric[1]), sub="The Histogram of variable temp")
hist(dataset_numeric[,3], main=names(dataset_numeric[3]), sub="The Histogram of variable hum")
hist(dataset_numeric[,4], main=names(dataset_numeric[4]), sub="The Histogram of variable windspeed")

dataset_factor <- dataset_summer[,!index]; n=nrow(dataset_numeric)
dataset_factor <- dataset_factor[,-9]
dataset_binary_factor <- dataset_factor[,c(2,5,7)]

plot(table(dataset_factor[,4])/n, type='h', main=names(dataset_factor)[4], ylab='Relative frequency', sub="The Plot of Variable hr ")
plot(table(dataset_factor[,8])/n, type='h', main=names(dataset_factor)[8], ylab='Relative frequency', sub="The Plot of Variable weathersit")

boxplot(dataset_numeric[,5]~dataset_factor[,4], xlab=names(dataset_factor)[4], ylab='Number of Bike Rentals',cex.lab=1.0)
boxplot(dataset_numeric[,5]~dataset_factor[,1], xlab=names(dataset_factor)[4], ylab='Number of Bike Rentals',cex.lab=1.0)

#autumn
dataset_autumn <- dataset[dataset$season=="autumn",]
index <-  sapply(dataset_autumn,class) == "numeric"
dataset_numeric <- dataset_autumn[,index]

par(mfrow=c(3,3))
hist(dataset_numeric[,1], main=names(dataset_numeric[1]), sub="The Histogram of variable temp")
hist(dataset_numeric[,3], main=names(dataset_numeric[3]), sub="The Histogram of variable hum")
hist(dataset_numeric[,4], main=names(dataset_numeric[4]), sub="The Histogram of variable windspeed")

dataset_factor <- dataset_autumn[,!index]; n=nrow(dataset_numeric)
dataset_factor <- dataset_factor[,-9]
dataset_binary_factor <- dataset_factor[,c(2,5,7)]

plot(table(dataset_factor[,4])/n, type='h', main=names(dataset_factor)[4], ylab='Relative frequency', sub="The Plot of Variable hr ")
plot(table(dataset_factor[,8])/n, type='h', main=names(dataset_factor)[8], ylab='Relative frequency', sub="The Plot of Variable weathersit")

boxplot(dataset_numeric[,5]~dataset_factor[,4], xlab=names(dataset_factor)[4], ylab='Number of Bike Rentals',cex.lab=1.0)
boxplot(dataset_numeric[,5]~dataset_factor[,1], xlab=names(dataset_factor)[1], ylab='Number of Bike Rentals',cex.lab=1.0)






