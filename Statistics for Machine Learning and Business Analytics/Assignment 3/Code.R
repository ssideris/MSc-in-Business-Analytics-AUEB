#set directory and read file
setwd("C:/Users/sgsid/Desktop/BA - Master/Spring/Statistics II/Assignment II")
data <- read.csv("project I  2021-2022.csv", header = TRUE )

#install libraries
library('e1071')
library('MASS')
library('tree')
library('mclust')
library('pgmm')
library('cluster')
#-------------------------Data Cleaning-------------------------------------

#Check for blanks
sum(data == '')
#Check for unknown values
sum(data=='unknown')
#change type of character variables to factor
data_cleaned <- as.data.frame(unclass(data[,c(2:10,15,21)]), stringsAsFactors = TRUE)
#add numeric variables
data_cleaned$age <- as.numeric(data$age)
data_cleaned$duration <- as.numeric(data$duration)
data_cleaned$campaign <- as.numeric(data$campaign)
data_cleaned$previous <- as.numeric(data$previous)
data_cleaned$pdays <- as.numeric(data$pdays)
data_cleaned$emp.var.rate <- data$emp.var.rate
data_cleaned$cons.price.idx <- data$cons.price.idx
data_cleaned$cons.conf.idx <- data$cons.conf.idx
data_cleaned$euribor3m <- data$euribor3m
data_cleaned$nr.employed <- data$nr.employed

#------------------------Part 1---------------------------------------------
#Use K-Folds Cross validation to separate the remaining dataset to training and testing 
n <- nrow(data_cleaned) #number of rows
index <- sample(1:n)
k <- 5 #k=5-fold cross-validation

#Accuracy will be used to evaluate the models used
methods <- c( 'naiveBayes','tree', 'svm')
accuracy <- matrix(data=NA, ncol= 5, nrow = length(methods))
rownames(accuracy) <- methods
#the ml methods using 5-fold cross validation

for (i in 1:k) {
  te <- index[ ((i-1)*(n/k)+1):(i*(n/k))] #get the number of rows that will be used for testing
  train_dataset <- data_cleaned[-te, ] #the training dataset
  test_dataset <- data_cleaned[te,-11] #the testing dataset

  #	naive Bayes method
  z <- naiveBayes(SUBSCRIBED ~ ., data = train_dataset)
  pr <- predict(z, test_dataset)
  accuracy['naiveBayes',i] <- sum(data_cleaned[te,'SUBSCRIBED'] == pr)/dim(test_dataset)[1]

  #	tree
  fit1 <- tree(SUBSCRIBED ~ ., data = train_dataset, split='gini')
  pr <- predict(fit1,newdata=test_dataset,type='class')
  accuracy['tree',i] <- sum(data_cleaned[te,'SUBSCRIBED'] == pr)/dim(test_dataset)[1]	
 
  
  #	svm
  fit2 <- svm(SUBSCRIBED~., data=train_dataset)
  pr <- predict(fit2, newdata=test_dataset)
  accuracy['svm',i] <- sum(data_cleaned[te,'SUBSCRIBED'] == pr)/dim(test_dataset)[1]
  
}

#take the mean value of the 5 tests for each method for evaluation
rowMeans(accuracy)
#plot the accuracy test values
boxplot(t(accuracy),ylab='predictive accuracy', xlab='method', main="Accuracy")

#------------------------Part 2---------------------------------------------
#keep only the variables given in the list
data2 <- data_cleaned[,c(12,1:6,14,16,15,10)]

#extract a sample of 10000 observations as the dataset is very large for a distance matrix to be created
sample_index <- sample(nrow(data2), size = 10000)
data_sample <-  data2[sample_index,]

# Finding distance matrix using daisy function as we have both numeric and factor variables
distance_mat <- daisy(data_sample, metric='gower')

#perform hierarchical clustering
hc1 <- hclust(distance_mat, method="complete")

#cluster dendrogram for 2 and 3 final clusters
par(mfrow=c(1,2))
plot(hc1)
rect.hclust(hc1, k=2, border="red")
cutree(hc1, k = 2)

plot(hc1)
rect.hclust(hc1, k=3, border="red")
cutree(hc1, k = 3)

#silhouette of the clustering
par(mfrow=c(1,2))
plot(silhouette(x=cutree(hc1, k = 2), dist=distance_mat),border=NA, col=2:3)
plot(silhouette(x=cutree(hc1, k = 3), dist=distance_mat),border=NA, col=2:4)
#number of observations with negative width
sum(silhouette(x=cutree(hc1, k = 2), dist=distance_mat)<0)
sum(silhouette(x=cutree(hc1, k = 3), dist=distance_mat)<0)

#compare against SUBSCRIBED variable
adjustedRandIndex(cutree(hc1, k = 3),data_cleaned[sample_index,11])
table(cutree(hc1, k = 2),data_cleaned[sample_index,11])

