**INSTRUCTIONS**

You are going to use REDIS and MongoDB to perform an analysis on data related to classified ads from the used motorcycles market.

1. Install REDIS and MongoDB on your workstations. Version 4 of REDIS for windows is available here:
https://github.com/tporadowski/redis/releases If you have an older version, make sure that you upgrade since some of the commands needed for the assignment are not supported by older versions. The installation process is straightforward.
2. Download the BIKES_DATASET.zip dataset from
https://drive.google.com/open?id=1m4W6anTDphWRnHDwsh-hlexOGrAkMrSq
3. Download the RECORDED_ACTIONS.zip dataset from
https://drive.google.com/open?id=1wyL8nQKDEu6rdr9BH6CgBwGnPnvRT8cJ
4. Do the tasks listed in the “TASKS” section:

**SCENARIO**

You are a data analyst at a consulting firm and you have access to a dataset of ~30K classified ads from the used motorcycles market. You also have access to some seller related actions that have been tracked in the previous months. You are asked to create a number of programs/queries for the tasks listed in the “TASKS” section.

**TASK 1**

In this task you are going to use the “recorded actions” dataset in order to generate some analytics with REDIS. At the end of each month, the classifieds provider sends a personalized email to some of the sellers with a number of suggestions on how they could improve their listings. Some e-mails may have been sent two or three times in the same month due to a technical issue. Not all users open these e-mails. However, we keep track of the e-mails that have been read by their recipients. Apart from that you are also given access to a dataset containing all the user ids along with a flag on whether they performed at least one modification on their listing for each month.

In brief, the datasets are the following:
- emails_sent.csv “Sets of EmailID, UserID, MonthID and EmailOpened”
- modified_listings.csv “Sets of UserID, MonthID, ModifiedListing”

The first dataset contains User IDs that have received an e-mail at least once. The second dataset contains all the User IDs of the classifieds provider and a flag that indicates whether the user performed a modification
on his/her listing. Both datasets contain entries for the months January,February and March.
You are asked to answer a number of questions using REDIS Bitmaps:




**Data and Redis Connection Preparation**

R is used. The months included in the datasets are January, February and March. We create 3 subsets, one for each month, of the emails_sent.csv dataset and 3 subsets, one for each month, of the modified_listings.csv dataset.


```python
# Import csv files
emails_sent <- read.csv(file = 'emails_sent.csv')
modified_listings <- read.csv(file = 'modified_listings.csv')
View(modified_listings)

# Inspect contents
str(emails_sent)
str(modified_listings)

# Create a connection to the local instance of REDIS
r <- redux::hiredis(
  redux::redis_config(
    host = "127.0.0.1", 
    port = "6379"))
        
# Create subsets of listings per month
January_listings <-  subset(modified_listings, MonthID==1, select = c(UserID, ModifiedListing ))
February_listings <-  subset(modified_listings, MonthID==2, select = c(UserID, ModifiedListing))
March_listings <- subset(modified_listings, MonthID==3, select = c(UserID, ModifiedListing))

# Create subsets of emails per month
January_emails <-  subset(emails_sent, MonthID==1, select = c(UserID, MonthID, EmailOpened ))
February_emails <-  subset(emails_sent, MonthID==2, select = c(UserID, MonthID, EmailOpened))
March_emails <- subset(emails_sent, MonthID==3, select = c(UserID, MonthID, EmailOpened))
```

**1.1 How many users modified their listing on January?**

Using the January_listings subset, we create a BIT where “1” values show the users that modified their listing in January. The total number is equal to 9969.


```python
# Create BITMAP ModificationsJanuary
for (i in 1:nrow(January_listings)) {
  if (January_listings$ModifiedListing[i]==1){
    r$SETBIT("ModificationsJanuary", i, "1")
  }
}
# Calculate ModificationsJanuary
r$BITCOUNT("ModificationsJanuary")
```

**1.2 How many users did NOT modify their listing on January?**

By reversing the BIT of Question 1.1 we create a new BIT where “1” values show the users that did not modified their listing in January. The total number is equal to 10031. Although the total of January listings is equal to 19999, the sum of totals of Questions 1.1 and 1.2 is equal to 20000. The difference of 1 occurs because BITTOP performs in bits while BITCOUNT performs in bytes. As a byte is equal to 8 bits, 19999 observations do not create a round number of bits and so 1 more bit is added to solve this problem.


```python
#Create BITMAP NoModificationsJanuary
r$BITOP('NOT','NoModificationsJanuary', 'ModificationsJanuary')
r$BITCOUNT('NoModificationsJanuary')
#Check if it is equal to the total number of observations
r$BITCOUNT('NoModificationsJanuary')+r$BITCOUNT("ModificationsJanuary") == nrow(modified_listings)
```

**1.3 How many users received at least one e-mail per month (at least one email in January and at least one e-mail in February and at least one email in March)?**

By iterating, per user ID, through the subsets we created for each month on dataset emails_sent, we create a BIT for each month where value “1” shows the users thar received at least one email on that month. By using BITOP and “AND” we create a BIT where value “1” shows the users that received at least one email on all the 3 months. The total of users is 2668.


```python
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
```

**1.4 How many users received an e-mail on January and March but NOT on February?**

We use the previously created BITs EmailsJanuary and EmailsMarch with BITOP and “AND” in order to create a BIT where value “1” shows the users that received email on both months. Afterwards, we use subset EmailsFebruary and we create an inverse BIT using BITOP and “NOT”. Finally, we create a BIT using BITOP, “AND” and the 2 BITS we created where value “1” shows the users that received an email in January and March but not in February. The total is 2417.


```python
#Create BITMAP with the users received emails in both January and February
r$BITOP('AND','UsersEmailReceivedJanuary&March', c('EmailsJanuary','EmailsMarch'))
#Inverse BITMAP of 'EmailsFebruary'
r$BITOP('NOT','EmailsFebruaryInverse', 'EmailsFebruary')
#Create BITMAP of users received emails only in January and March
r$BITOP('AND','UsersEmailReceivedOnlyJanuary&March', c('UsersEmailReceivedJanuary&March','EmailsFebruaryInverse'))
#Calculate number of users who received emails only in January and March
r$BITCOUNT('UsersEmailReceivedOnlyJanuary&March')
```

**1.5 How many users received an e-mail on January that they did not open but
they updated their listing anyway?**

We create a subset of emails sent in January including the columns UserID, MonthID and EmailOpened.
We aggregate the subset by using sum on column EmailOpened where the UserID is the same as, if sum is greater than “0”, it will mean that the user has opened at least one of the emails he received in January. We change the value of each row on column x to “1” if its value is greater than “0”. We iterate through our created dataset and create a BIT where value “1” shows the users who opened their emails in January. Moreover, we create a BIT to inverse the previous BIT using BITOP and “NOT” where value ”1” will show users that did not open their emails in January. Finally, we create a BIT of the Union of the BIT for users that did not open their emails in January and the BIT created in Question 1.1 for the users that modified their listings in January. The total is 7157.


```python
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
```

**1.6 How many users received an e-mail on January that they did not open but
they updated their listing anyway on January OR they received an e-mail
on February that they did not open but they updated their listing anyway
on February OR they received an e-mail on March that they did not open
but they updated their listing anyway on March?**

We perform the same steps as in question 1.5 for months February and March. Using BITOP and “OR” we create a BIT where value “1” shows the users received an e-mail on January, February or March that they did not open but they updated their listing anyway. The total is 12575.


```python
# Create subset of emails in March
EmailsMarch <-  subset(emails_sent, MonthID==3, select = c(UserID, MonthID, EmailOpened ))
# Aggegrate by UserID on EmailOpened, emails sent in March
EmailsMarch_agg <- aggregate(EmailsMarch$EmailOpened, by=list(UserID=EmailsMarch$UserID), FUN=sum)
# If EmailsMarch_agg$x == 0 is True turn column x equal to 0 else equal to 1
EmailsMarch_agg$x <- ifelse(EmailsMarch_agg$x == 0, 0 ,1)
# Create BITMAP of opened emails in March
for (i in 1:nrow(EmailsMarch_agg)) {
  r$SETBIT('EmailsOpenedMarch', EmailsMarch_agg$UserID[i], EmailsMarch_agg$x[i])
}
# Inverse BITMAP of 'EmailsOpenedMarch'
r$BITOP('NOT','EmailsNotOpenedMarch', 'EmailsOpenedMarch')
# Create BITMAP ModificationsMarch
for (i in 1:nrow(March_listings)) {
  if (March_listings$ModifiedListing[i]==1){
    r$SETBIT("ModificationsMarch", i, "1")
  }
}
# Users who received but did not open their emails in March but modified their listing
r$BITOP('AND','UsersEmailNotOpenedMarchModifiedListing', c('EmailsNotOpenedMarch','ModificationsMarch'))
# Total of users who received but did not open their emails in March but modified their listing
r$BITCOUNT('UsersEmailNotOpenedMarchModifiedListing')


# Create subset of emails in February
EmailsFebruary <-  subset(emails_sent, MonthID==2, select = c(UserID, MonthID, EmailOpened ))
# Aggegrate by UserID on EmailOpened, emails sent in February 
EmailsFebruary_agg <- aggregate(EmailsFebruary$EmailOpened, by=list(UserID=EmailsFebruary$UserID), FUN=sum)
# If EmailsFebruary_agg$x == 0 is True turn column x equal to 0 else equal to 1
EmailsFebruary_agg$x <- ifelse(EmailsFebruary_agg$x == 0, 0 ,1)
# Create BITMAP of opened emails in February
for (i in 1:nrow(EmailsFebruary_agg)) {
  r$SETBIT('EmailsOpenedFebruary', EmailsFebruary_agg$UserID[i], EmailsFebruary_agg$x[i])
}
# Inverse BITMAP of 'EmailsOpenedFebruary'
r$BITOP('NOT','EmailsNotOpenedFebruary', 'EmailsOpenedFebruary')
# Create BITMAP ModificationsJanuary
for (i in 1:nrow(February_listings)) {
  if (February_listings$ModifiedListing[i]==1){
    r$SETBIT("ModificationsFebruary", i, "1")
  }
}
# Calculate ModificationsJanuary
r$BITCOUNT("ModificationsFebruary")
# Users who received but did not open their emails in February but modified their listing
r$BITOP('AND','UsersEmailNotOpenedFebruaryModifiedListing', c('EmailsNotOpenedFebruary','ModificationsFebruary'))
# Total of users who received but did not open their emails in February but modified their listing
r$BITCOUNT('UsersEmailNotOpenedFebruaryModifiedListing')


# Create BITMAP of users received an e-mail in January that they did not open but 
# they updated their listing anyway in January OR they received an e-mail in February that 
# they did not open but they updated their listing anyway in February OR they received an e-mail 
# in March that they did not open but they updated their listing anyway in March
r$BITOP('OR','EmailsNotOpenedAndModifiedListing', c('UsersEmailNotOpenedJanuaryModifiedListing','UsersEmailNotOpenedFebruaryModifiedListing','UsersEmailNotOpenedMarchModifiedListing'))
# Total of users
r$BITCOUNT('EmailsOpenedAndModifiedListing')
```

**1.7 Does it make any sense to keep sending e-mails with recommendations to
sellers? Does this strategy really work? How would you describe this in
terms a business person would understand?**

We calculate a BIT of emails opened followed by a modification on listing for each month and then created a BIT using BITOP and “OR” where value “1” shows all the users that received and opened an email and modified their listing afterwards in January, February or March. The total is 9817. The number of users that did not open their emails but proceed with a modification is 12575 (as answered in question 1.6) and so higher than 9817. So, it seems that the strategy of sending emails is irrational.


```python
# Calculate the users who opened their emails and performed modifications for the 3 months
r$BITOP("AND","EmailOpenJanuary&Modify", c("EmailsOpenedJanuary","ModificationsJanuary"))
r$BITCOUNT("EmailOpenJanuary&Modify")
r$BITOP("AND","EmailOpenFebruary&Modify", c("EmailsOpenedFebruary","ModificationsFebruary"))
r$BITCOUNT("EmailOpenFebruary&Modify")
r$BITOP("AND","EmailOpenMarch&Modify", c("EmailsOpenedMarch", "ModificationsMarch"))
r$BITCOUNT("EmailOpenMarch&Modify")
# Calculate the 
r$BITOP("OR","Opened&Update",c("EmailOpenJanuary&Modify", "EmailOpenFebruary&Modify","EmailOpenMarch&Modify"))
r$BITCOUNT("Opened&Update")
```
