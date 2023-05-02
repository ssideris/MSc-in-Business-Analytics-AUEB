**INSTRUCTIONS**

You are going to use REDIS and MongoDB to perform an analysis on data related
to classified ads from the used motorcycles market.

1. Install REDIS and MongoDB on your workstations. Version 4 of REDIS for
windows is available here: https://github.com/tporadowski/redis/releases If you have an older version, make sure that you upgrade since some of the commands needed for the assignment are not supported by older versions. The installation process is straightforward.
2. Download the BIKES_DATASET.zip dataset from
https://drive.google.com/open?id=1m4W6anTDphWRnHDwsh-hlexOGrAkMrSq
3. Do the tasks listed in the “TASKS” section:

**SCENARIO**

You are a data analyst at a consulting firm and you have access to a dataset of ~30K classified ads from the used motorcycles market. Dataset “bikes” is consisted of 29701 json files which refer to bike ads scrapped from the web. You are asked to create a number of programs/queries for the tasks listed in the “TASKS” section.

**TASKS**

**2.1 Add your data to MongoDB.**

We use library mongolite in R to import the data in MongoDB. First we create a new collection called “mycol” and a new database called “mydb” as a localhost. Then, we create an indexing txt file which includes the paths of all the json files included in the dataset “bikes”. By iterating through the list, we transform json files to data frames and pass them through a cleaning function in order to clean them. In the cleaning procedure we check for blanks and NAs, we substitute words using regex and change the type of variables and finally create a new column “Negotiable” which shows when an ad is negotiable about its price or not. Finally, we retransform data frames to json files and import them to mongoDB.


```python
#install package
library('rjson')
library('mongolite')
library('lubridate')
library('stringr')
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
  #data$ad_data$Mileage <- as.numeric(data$ad_data$Mileage)
  #turn price to numeric, delete everything before character ???, delete everything after \, turn Price to numeric, delete all "
  # euro sign might not be recognized by R's encoding and needs to be reinserted into the code manually
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
```

**2.2 How many bikes are there for sale?**

By using function count we count 29701 bikes for sale.


```python
#How many bikes for sale
bikes_for_sale <- m$count()
```

**2.3 What is the average price of a motorcycle (give a number)? What is the
number of listings that were used in order to calculate this average
(give a number as well)? Is the number of listings used the same as the
answer in 2.2? Why?**

As 1395 ads with price lower or equal to 200 exist, we calculate the average excluding them as they are not realistic prices for bikes and might refer to parts. The total of the bikes left is 28306 (1395 ads difference from the initial dataset) and the average price for the bikes left is 3049.28.  


```python
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
```

**2.4 What is the maximum and minimum price of a motorcycle currently
available in the market?**

The maximum logical price is 89000 and the minimum logical price is 210 (as we excluded prices equal or lower to 200). 



```python
#Maximum logical price
m$aggregate('[{"$match":{"ad_data.Price": {"$gt": 200}}},
            {"$group":{"_id": null,"maximum":{"$max":"$ad_data.Price"}}}
            ]')
#Minimum logical price
m$aggregate('[{"$match":{"ad_data.Price": {"$gt": 200}}},
            {"$group":{"_id": null,"minimum":{"$min":"$ad_data.Price"}}}
            ]')
```

**2.5 How many listings have a price that is identified as negotiable?**

By counting the TRUE values of column Negotiable, we count 1348 negotiable listings.


```python
#Total of ads which are Negotiable
m$aggregate('[{"$match":{"ad_data.Negotiable": true}},
            {"$group":{"_id": null,"count":{"$sum": 1}}}
            ]')
```

**2.6 What is the motorcycle brand with the highest average price?**

The brand with the highest average price is Semog with an average price of 15600.


```python
#Brand with highest average price
highestAVGPrice <- m$aggregate(
  '[
  {"$match": {"ad_data.Price": { "$gte": 100 }}},
  {"$group":{"_id": "$metadata.brand", "average":{"$avg":"$ad_data.Price"}}},
  { "$sort": { "average": -1}},
  {"$limit": 1}
  ]'
)
```

**2.7 How many bikes have “ABS” as an extra?**

The total number of bikes with ABS as an extra is 4008.


```python
#Ads with ABS as an extra
abs <- m$aggregate('[
  {"$match": {"extras": "ABS"}},
  {"$group": {"_id": null, "ABS": {"$sum": 1}}}
                   ]')
```
