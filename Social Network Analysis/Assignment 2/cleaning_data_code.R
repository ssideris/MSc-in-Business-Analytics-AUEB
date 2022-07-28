#-------------------- Task 1 --------------------------------#
# Load the zip file
inputFile <-  "authors.csv.gz"
con <-  file(inputFile, open = "r" )

# Create empty dataframes for each of the 5 years
data2016 <- data.frame()
data2017 <- data.frame()
data2018 <- data.frame()
data2019 <- data.frame()
data2020 <- data.frame()

# Parse the dataset per row as it is too big to be loaded as a whole
# and keep the authors for the records that refer to the wanted events
# Then split the dataset to 5 datasets per year for the last 5 years
while (length(oneLine <-  readLines(con, n=1)) > 0) {
  columns <-  scan(text=oneLine, sep=',', what='character', quiet=TRUE)
  if (!is.na(columns[3]) && (columns[3] %in% c('CIKM','KDD','ICWSM','WWW','IEEE BigData'))
      && (!is.na(columns[1])) && (columns[1] %in% c(2016:2020))) {
    print(columns[4])
    if (columns[1]=='2016') {
      data2016[nrow(data2016)+1,1] <- columns[4]
    } else if (columns[1]=='2017') {
      data2017[nrow(data2017)+1,1] <- columns[4]
    } else if (columns[1]=='2018') {
      data2018[nrow(data2018)+1,1] <- columns[4]
    } else if (columns[1]=='2019') {
      data2019[nrow(data2019)+1,1] <- columns[4]
    } else {
      data2020[nrow(data2020)+1,1] <- columns[4]
    }
  }
}
# Delete also records that include only 1 author from the datasets
# To do so, exclude all the rows that include character ","
data2016_clean <-  data.frame()
data2017_clean <-  data.frame()
data2018_clean <-  data.frame()
data2019_clean <-  data.frame()
data2020_clean <-  data.frame()
for (i in 1:nrow(data2016)){
  if (grepl(",", data2016[i,], fixed = TRUE) == TRUE){
    data2016_clean[nrow(data2016_clean)+1,1] <- data2016[i,]
  }
}
for (i in 1:nrow(data2017)){
  if (grepl(",", data2017[i,], fixed = TRUE) == TRUE){
    data2017_clean[nrow(data2017_clean)+1,1] <- data2017[i,]
  }
}
for (i in 1:nrow(data2018)){
  if (grepl(",", data2018[i,], fixed = TRUE) == TRUE){
    data2018_clean[nrow(data2018_clean)+1,1] <- data2018[i,]
  }
}
for (i in 1:nrow(data2019)){
  if (grepl(",", data2019[i,], fixed = TRUE) == TRUE){
    data2019_clean[nrow(data2019_clean)+1,1] <- data2019[i,]
  }
}
for (i in 1:nrow(data2020)){
  if (grepl(",", data2020[i,], fixed = TRUE) == TRUE){
    data2020_clean[nrow(data2020_clean)+1,1] <- data2020[i,]
  }
}

#create csv files
write.csv(data2016_clean,"C:/Users/sgsid/Desktop/BA - Master/Summer/Social Networks/Assignment 2/Cleaned data/data2016_clean", row.names = FALSE)
write.csv(data2017_clean,"C:/Users/sgsid/Desktop/BA - Master/Summer/Social Networks/Assignment 2/Cleaned data/data2017_clean", row.names = FALSE)
write.csv(data2018_clean,"C:/Users/sgsid/Desktop/BA - Master/Summer/Social Networks/Assignment 2/Cleaned data/data2018_clean", row.names = FALSE)
write.csv(data2019_clean,"C:/Users/sgsid/Desktop/BA - Master/Summer/Social Networks/Assignment 2/Cleaned data/data2019_clean", row.names = FALSE)
write.csv(data2020_clean,"C:/Users/sgsid/Desktop/BA - Master/Summer/Social Networks/Assignment 2/Cleaned data/data2020_clean", row.names = FALSE)
