setwd("C:/Users/sgsid/Desktop/BA - Master/Spring/Data Structure and Architecture/Redis-Mongodb/Assignment 1/Recorded Actions")
library("redux")

#-------------------------------------------------------TASK 1--------------------------------------------------------------
#import csv files
emails_sent <- read.csv(file = 'emails_sent.csv')
modified_listings <- read.csv(file = 'modified_listings.csv')
View(modified_listings)

#inspect contents
str(emails_sent)
str(modified_listings)

# Create a connection to the local instance of REDIS
r <- redux::hiredis(
  redux::redis_config(
    host = "127.0.0.1", 
    port = "6379"))
#create subsets of listings per month
January_listings <-  subset(modified_listings, MonthID==1, select = c(UserID, ModifiedListing ))
February_listings <-  subset(modified_listings, MonthID==2, select = c(UserID, ModifiedListing))
March_listings <- subset(modified_listings, MonthID==3, select = c(UserID, ModifiedListing))
#create subsets of emails per month
January_emails <-  subset(emails_sent, MonthID==1, select = c(UserID, MonthID, EmailOpened ))
February_emails <-  subset(emails_sent, MonthID==2, select = c(UserID, MonthID, EmailOpened))
March_emails <- subset(emails_sent, MonthID==3, select = c(UserID, MonthID, EmailOpened))
#-----------------------------------Question 1.1----------------------------------------------------------
#Create BITMAP ModificationsJanuary
for (i in 1:nrow(January_listings)) {
  if (January_listings$ModifiedListing[i]==1){
    r$SETBIT("ModificationsJanuary", i, "1")
  }
}
# Calculate ModificationsJanuary
r$BITCOUNT("ModificationsJanuary")

#----------------------------------Question 1.2-----------------------------------------------------------
#Create BITMAP NoModificationsJanuary
r$BITOP('NOT','NoModificationsJanuary', 'ModificationsJanuary')
r$BITCOUNT('NoModificationsJanuary')
#Check if it is equal to the total number of observations
r$BITCOUNT('NoModificationsJanuary')+r$BITCOUNT("ModificationsJanuary") == nrow(modified_listings)

#----------------------------------Question 1.3-----------------------------------------------------------
#Create BITMAP EmailsJanuary
for (i in 1:nrow(January_emails)) {
  r$SETBIT('EmailsJanuary', January_emails$UserID[i], "1")
}
r$BITCOUNT('EmailsJanuary')
#Create BITMAP EmailsFebruary
for (i in 1:nrow(February_emails)) {
  r$SETBIT('EmailsFebruary', February_emails$UserID[i], "1")
}
r$BITCOUNT('EmailsFebruary')

#Create BITMAP EmailsMarch
for (i in 1:nrow(March_emails)) {
  r$SETBIT('EmailsMarch', March_emails$UserID[i], "1")
}
r$BITCOUNT('EmailsMarch')

#Create BITMAP with the users received emails in all three months
r$BITOP('AND','UsersEmailReceived', c('EmailsJanuary','EmailsFebruary','EmailsMarch'))
#Calculate the total of users received emails in all three months
r$BITCOUNT('UsersEmailReceived')

#----------------------------------Question 1.4-----------------------------------------------------------
#Create BITMAP with the users received emails in both January and March
r$BITOP('AND','UsersEmailReceivedJanuary&March', c('EmailsJanuary','EmailsMarch'))
#Inverse BITMAP of 'EmailsFebruary'
r$BITOP('NOT','EmailsFebruaryInverse', 'EmailsFebruary')
#Create BITMAP of users received emails only in January and March
r$BITOP('AND','UsersEmailReceivedOnlyJanuary&March', c('UsersEmailReceivedJanuary&March','EmailsFebruaryInverse'))
#Calculate number of users who received emails only in January and March
r$BITCOUNT('UsersEmailReceivedOnlyJanuary&March')

#----------------------------------Question 1.5-----------------------------------------------------------
#Create subset of emails in January
EmailsJanuary <-  subset(emails_sent, MonthID==1, select = c(UserID, MonthID, EmailOpened ))
#aggegrate by UserID on EmailOpened, emails sent in January 
EmailsJanuary_agg <- aggregate(EmailsJanuary$EmailOpened, by=list(UserID=EmailsJanuary$UserID), FUN=sum)

#If EmailsJanuary_agg$x == 0 is True turn column x equal to 0 else equal to 1
EmailsJanuary_agg$x <- ifelse(EmailsJanuary_agg$x == 0, 0 ,1)

#Create BITMAP of opened emails in January
for (i in 1:nrow(EmailsJanuary_agg)) {
    r$SETBIT('EmailsOpenedJanuary', EmailsJanuary_agg$UserID[i], EmailsJanuary_agg$x[i])
}
#Inverse BITMAP of 'EmailsOpenedJanuary'
r$BITOP('NOT','EmailsNotOpenedJanuary', 'EmailsOpenedJanuary')
#Users who received but did not open their emails in January but modified their listing
r$BITOP('AND','UsersEmailNotOpenedJanuaryModifiedListing', c('EmailsNotOpenedJanuary','ModificationsJanuary'))
#Total of users who received but did not open their emails in January and modified their listing
r$BITCOUNT('UsersEmailNotOpenedJanuaryModifiedListing')

#----------------------------------Question 1.6-----------------------------------------------------------
#Create subset of emails in March
EmailsMarch <-  subset(emails_sent, MonthID==3, select = c(UserID, MonthID, EmailOpened ))
#aggegrate by UserID on EmailOpened, emails sent in March
EmailsMarch_agg <- aggregate(EmailsMarch$EmailOpened, by=list(UserID=EmailsMarch$UserID), FUN=sum)
#If EmailsMarch_agg$x == 0 is True turn column x equal to 0 else equal to 1
EmailsMarch_agg$x <- ifelse(EmailsMarch_agg$x == 0, 0 ,1)
#Create BITMAP of opened emails in March
for (i in 1:nrow(EmailsMarch_agg)) {
  r$SETBIT('EmailsOpenedMarch', EmailsMarch_agg$UserID[i], EmailsMarch_agg$x[i])
}
#Inverse BITMAP of 'EmailsOpenedMarch'
r$BITOP('NOT','EmailsNotOpenedMarch', 'EmailsOpenedMarch')
#Create BITMAP ModificationsMarch
for (i in 1:nrow(March_listings)) {
  if (March_listings$ModifiedListing[i]==1){
    r$SETBIT("ModificationsMarch", i, "1")
  }
}
#Users who received but did not open their emails in March but modified their listing
r$BITOP('AND','UsersEmailNotOpenedMarchModifiedListing', c('EmailsNotOpenedMarch','ModificationsMarch'))
#Total of users who received but did not open their emails in March but modified their listing
r$BITCOUNT('UsersEmailNotOpenedMarchModifiedListing')


#Create subset of emails in February
EmailsFebruary <-  subset(emails_sent, MonthID==2, select = c(UserID, MonthID, EmailOpened ))
#aggegrate by UserID on EmailOpened, emails sent in February 
EmailsFebruary_agg <- aggregate(EmailsFebruary$EmailOpened, by=list(UserID=EmailsFebruary$UserID), FUN=sum)
#If EmailsFebruary_agg$x == 0 is True turn column x equal to 0 else equal to 1
EmailsFebruary_agg$x <- ifelse(EmailsFebruary_agg$x == 0, 0 ,1)
#Create BITMAP of opened emails in February
for (i in 1:nrow(EmailsFebruary_agg)) {
  r$SETBIT('EmailsOpenedFebruary', EmailsFebruary_agg$UserID[i], EmailsFebruary_agg$x[i])
}
#Inverse BITMAP of 'EmailsOpenedFebruary'
r$BITOP('NOT','EmailsNotOpenedFebruary', 'EmailsOpenedFebruary')
#Create BITMAP ModificationsJanuary
for (i in 1:nrow(February_listings)) {
  if (February_listings$ModifiedListing[i]==1){
    r$SETBIT("ModificationsFebruary", i, "1")
  }
}
# Calculate ModificationsJanuary
r$BITCOUNT("ModificationsFebruary")
#Users who received but did not open their emails in February but modified their listing
r$BITOP('AND','UsersEmailNotOpenedFebruaryModifiedListing', c('EmailsNotOpenedFebruary','ModificationsFebruary'))
#Total of users who received but did not open their emails in February but modified their listing
r$BITCOUNT('UsersEmailNotOpenedFebruaryModifiedListing')


#Create BITMAP of users received an e-mail in January that they did not open but 
#they updated their listing anyway in January OR they received an e-mail in February that 
#they did not open but they updated their listing anyway in February OR they received an e-mail 
#in March that they did not open but they updated their listing anyway in March
r$BITOP('OR','EmailsNotOpenedAndModifiedListing', c('UsersEmailNotOpenedJanuaryModifiedListing','UsersEmailNotOpenedFebruaryModifiedListing','UsersEmailNotOpenedMarchModifiedListing'))
#Total of users
r$BITCOUNT('EmailsOpenedAndModifiedListing')

#----------------------------------Question 1.7-----------------------------------------------------------
#Calculate the users who opened their emails and performed modifications for the 3 months
r$BITOP("AND","EmailOpenJanuary&Modify", c("EmailsOpenedJanuary","ModificationsJanuary"))
r$BITCOUNT("EmailOpenJanuary&Modify")
r$BITOP("AND","EmailOpenFebruary&Modify", c("EmailsOpenedFebruary","ModificationsFebruary"))
r$BITCOUNT("EmailOpenFebruary&Modify")
r$BITOP("AND","EmailOpenMarch&Modify", c("EmailsOpenedMarch", "ModificationsMarch"))
r$BITCOUNT("EmailOpenMarch&Modify")
#Calculate the 
r$BITOP("OR","Opened&Update",c("EmailOpenJanuary&Modify", "EmailOpenFebruary&Modify","EmailOpenMarch&Modify"))
r$BITCOUNT("Opened&Update")

#--------------------------------------------------------TASK 2------------------------------------------------------------------------

#---------------------------------------2.1------------------------------------------------------
#install package
library('rjson')
library('mongolite')
library('lubridate')
library('stringr')
#Set directory BIKES
setwd('C:/Users/sgsid/Desktop/BA - Master/Spring/Data Structure and Architecture/Redis-Mongodb/Assignment 1/BIKES')
#import files_list.txt
jsonfiles <- read.table("files_list.txt", header = TRUE, sep="\n", stringsAsFactors = FALSE)
#create a mongodb connection object and an empty collection
m <- mongo(collection = "mycol",  db = "mydb", url = "mongodb://localhost")
#data cleaning function
cleaned_data <- function(data){
  #Discard columns we will not use in our analysis and require cleaning
  data <- data[-5]
  #Change blanks to NAs
  data$query$url[data$query$url==''] <- NA
  data$query$type[data$query$type==''] <- NA
  data$query$trial_count[data$query$trial_count==''] <- NA
  data$query$last_processed[data$query$last_processed==''] <- NA
  data$title[data$title==''] <- NA
  data$ad_id[data$ad_id==''] <- NA
  data$ad_data$`Make/Model`[data$ad_data$`Make/Model`==''] <- NA
  data$ad_data$`Classified number`[data$ad_data$`Classified number`==''] <- NA
  data$ad_data$Price[data$ad_data$Price==''] <- NA
  data$ad_data$Category[data$ad_data$Category==''] <- NA
  data$ad_data$Registration[data$ad_data$Registration==''] <- NA
  data$ad_data$Mileage[data$ad_data$Mileage==''] <- NA
  data$ad_data$`Fuel type`[data$ad_data$`Fuel type`==''] <- NA
  data$ad_data$`Cubic capacity`[data$ad_data$`Cubic capacity`==''] <- NA
  data$ad_data$Power[data$ad_data$Power==''] <- NA
  data$ad_data$Color[data$ad_data$Color==''] <- NA
  data$ad_data$`Liters/100km`[data$ad_data$`Liters/100km`==''] <- NA
  data$ad_data$`Previous owners`[data$ad_data$`Previous owners`==''] <- NA
  data$ad_data$Modified[data$ad_data$Modified==''] <- NA
  data$ad_data$`Times clicked`[data$ad_data$`Times clicked`==''] <- NA
  data$ad_data$`Short link`[data$ad_data$`Short link`==''] <- NA
  data$ad_data$Telephone[data$ad_data$Telephone==''] <- NA
  data$metadata$type[data$metadata$type==''] <- NA
  data$metadata$brand[data$metadata$brand==''] <- NA
  data$metadata$model[data$metadata$model==''] <- NA
  data$extras <- ifelse(length(data$extras) == 0, NA, data$extras)
  data$description[data$description==''] <- NA
  #turn mileage to numeric and delete characters km and ,
  data$ad_data$Mileage <- gsub(" km","", data$ad_data$Mileage)
  data$ad_data$Mileage <- gsub(",","", data$ad_data$Mileage)
  #Change value 'Askforprice' in price price variable into 0, so that it can change afterwards to numeric
  data$ad_data$Price[data$ad_data$Price=='Askforprice'] <- 0
  #turn price to numeric, delete everything before character ???, delete everything after \, turn Price to numeric, delete all "
  # euro sign might not be recognised by R's encoding and needs to be reinserted into the code manually
  data$ad_data$Price <- gsub(".*???","", data$ad_data$Price)
  data$ad_data$Price <- gsub("\\.","", data$ad_data$Price)
  data$ad_data$Price <- as.numeric(data$ad_data$Price)
  data$extras <- gsub('"',"", data$ad_data$Price)
  #Create new column for Negotiable ads and give them value True if Negotiable and False if not
  if(str_detect(data$metadata$model, "Negotiable")){
    data$ad_data$Negotiable <-  as.logical(TRUE)
  } else{
    data$ad_data$Negotiable <-  as.logical(FALSE)
  }
  return (data)
}

#iterate through jsonfiles
for (i in 1:nrow(jsonfiles)){
  #turn jsons to R objects
  data <- fromJSON(file=jsonfiles[i,])
  #pass data through the cleaning function and convert them to json
  cleaned_json <- toJSON(cleaned_data(data))
  #insert the json into mongodb
  m$insert(cleaned_json)
}

#--------------------------------------2.2--------------------------------------------------
#How many bikes for sale
bikes_for_sale <- m$count()


#--------------------------------------2.3--------------------------------------------------
#Check for adds with price lower than or equal to 200
m$aggregate('[
            {"$match":{"ad_data.Price": {"$lte": 200}}}, 
            {"$group":{"_id": null, "count": {"$sum":1}}}
            ]')
#As 1240 objects with price lower or equal to 200 exist 
#We calculate the average excluding them as they are not realistic prices for bikes 
#and might refer to parts
m$aggregate('[{"$match":{"ad_data.Price": {"$gt": 200}}},
            {"$group":{"_id": null,"average":{"$avg":"$ad_data.Price"}}}
            ]')
#Total of listings used
m$aggregate('[
            {"$match":{"ad_data.Price": {"$gt": 200}}}, 
            {"$group":{"_id": null, "count": {"$sum":1}}}
            ]')

#--------------------------------------2.4--------------------------------------------------
#Maximum logical price
m$aggregate('[{"$match":{"ad_data.Price": {"$gt": 200}}},
            {"$group":{"_id": null,"maximum":{"$max":"$ad_data.Price"}}}
            ]')
#Minimum logical price
m$aggregate('[{"$match":{"ad_data.Price": {"$gt": 200}}},
            {"$group":{"_id": null,"minimum":{"$min":"$ad_data.Price"}}}
            ]')

#--------------------------------------2.5--------------------------------------------------
#Total of ads which are Negotiable
m$aggregate('[{"$match":{"ad_data.Negotiable": true}},
            {"$group":{"_id": null,"count":{"$sum": 1}}}
            ]')

#--------------------------------------2.7--------------------------------------------------
#Brand with highest average price
highestAVGPrice <- m$aggregate(
  '[
  {"$match": {"ad_data.Price": { "$gte": 100 }}},
  {"$group":{"_id": "$metadata.brand", "average":{"$avg":"$ad_data.Price"}}},
  { "$sort": { "average": -1}},
  {"$limit": 1}
  ]'
)

#--------------------------------------2.9--------------------------------------------------
#Ads with ABS as an extra
abs <- m$aggregate('[
  {"$match": {"extras": "ABS"}},
  {"$group": {"_id": null, "ABS": {"$sum": 1}}}
                   ]')


