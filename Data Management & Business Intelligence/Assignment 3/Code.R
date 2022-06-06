setwd("C:/Users/sgsid/Desktop/BA - Master/Summer/Analytics Practicum II/Assignment 1")
# Import and combine data of 2003 and 2004
df1 <- read.csv(file = '2003.csv', header = TRUE)
df2 <- read.csv(file = '2004.csv', header = TRUE)
df <-  rbind(df1,df2)

#---- Clean Data-----#
str(df)
# Convert specific variables to type factor and character
df[,1] <- as.factor(df[,1])
df[,2] <- as.factor(df[,2])
df[,3] <- as.factor(df[,3])
df[,4] <- as.factor(df[,4])
df[,10] <- as.character(df[,10])
df[,22] <- as.factor(df[,22])
df[,23] <- as.factor(df[,23])
df[,24] <- as.factor(df[,24])

# Explore missing values
# Cancelled and Diverted flights are responsible for 254391 rows of NAs and so we delete these rows
sum(df$Cancelled==1) + sum(df$Diverted==1)
colSums(is.na(df))
# We will create a second dataset to use without them
df2 <- df[!(df$Cancelled==1),] 
df2 <- df2[!(df2$Diverted==1),] 
# Change NAs of integer type variables with the mean of each variable
colSums(is.na(df2))
df2[is.na(df2[,12]),12] <- mean(df2[,12], na.rm=TRUE)
df2[is.na(df2[,15]),15] <- mean(df2[,15], na.rm=TRUE)
# The rest of NAs are mostly missing values of the 2003 dataset that we will not use 
colSums(is.na(df2))

#Import library ggplot2
library(ggplot2)

#-------------------------------Visualization 1----------------------------#
#Visualize the airports locations on the map and their total number of flights 
#for both years 2003 and 2004

#group by Origin to count for the number of flights in each origin
count <-  aggregate(df,
                     by = list(df$Origin),
                     FUN = length)
count <- count[,c(1:2)]
colnames(count) <- c("Origin","Count")
#import coordinates dataset from https://data.humdata.org/dataset/ourairports-usa
coordinates <- read.csv(file='coordinates.csv', header = TRUE)
coordinates <- coordinates[,c(5,6,18)]
#join the 2 datasets to their origin code
map_data <- left_join(count,coordinates,by= c("Origin"="local_code"))
map_data <- map_data %>% relocate(longitude_deg, .before = Origin)
map_data <- map_data %>% relocate(latitude_deg, .before = Origin)
colnames(map_data) <- c("lon","lat","Origin","Count")
map_data <- na.omit(map_data)

#library that creates the usa map
library(usmap)
library(rgdal)
#transform the coordinates so that they map on the library's map
eq_transformed <- usmap_transform(map_data)

#The final map graph
plot_usmap(fill="#ffebcc") +
  geom_point(data = eq_transformed, aes(x = x, y = y, size = Count/1000),
             color = "red", alpha = 0.25) +
  theme(legend.position = "right",
        panel.background = element_rect(colour="black", fill="#2c2621"))+
  labs(title="Location of Airports in the USA",
       subtitle = "Figure 1. Location of Airports in the USA and their Total Number of Flights in both Years 2003 and 2004",
       size = "Number of Flights Organized (in Thousands)") 


#-------------------------------Visualization 2----------------------------#
#Show all the carriers and the volume of flights each one performs
all_carriers <- df[,c("UniqueCarrier","Year")]
colnames(all_carriers) <- c("Name","Year")
agg1 <- aggregate(all_carriers$Name,
                  by=list(all_carriers$Year,all_carriers$Name),
                  FUN=length)
colnames(agg1) <- c("Year","Carrier_Name","Count")

library(treemap)
#The treemap diagram
t <- treemap(agg1,
        index=c("Carrier_Name","Year"),
        vSize="Count",
        type="index",
        palette = "Set2",
        bg.labels=c("white"),
        align.labels=list(
          c("center", "center"), 
          c("right", "bottom")
        ),
        fontsize.labels = 8,
        title="Volume of Flights per Carrier each Year
        Figure 2. Volume of Flights performed by each Carrier in Years 2003 and 2004"
)

#-------------------------------Visualization 3----------------------------#
#Total of Commercial flights organized by year 
#group by year and count the number of flights
agg1 <- aggregate(df,
                by = list(df$Year),
                FUN = length)
colnames(agg1) <- c("Year","Total_Flights")

#the final bar plot 
ggplot(data=agg1, aes(x=Year, y=Total_Flights/1000000)) +
  geom_bar(stat="identity",colour="black", fill=c("#f7766d", "#0fb7bb"))+
  theme_dark()+
  ggtitle("Total of Commercial Flights Organized by Year",
          subtitle="Figure 3. Total of Organized Flights in years 2003 and 2004 respectively") +
  theme(plot.title = element_text(hjust = 0.5,face = "bold"),
        plot.subtitle= element_text(hjust = 0.5))+
   xlab("Year") + 
  ylab("Total Flights (in millions)")+
  geom_text(aes(label = Total_Flights/1000000),size = 3, hjust = 0.5, vjust = 3, position ="stack")

#-------------------------------Visualization 4----------------------------#
# Total of commercial flights completed by month each year
#group by year and month and count the number of organized flights
agg2 <- aggregate(df,
                  by = list(df$Year, df$Month),
                  FUN = length)
agg2 <- agg2[,c(1:3)]
colnames(agg2) <- c("Year","Month","Total_Flights") 
#The final line plot
ggplot(agg2, aes(x=Month, y=Total_Flights/1000, group=Year)) +
  geom_line(aes(color=Year)) +
  geom_point() + 
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold",size=14),
        plot.subtitle = element_text(hjust = 0.5))+
  ggtitle("Total of Commercial Flights by Month each Year",
          subtitle = "Figure 4. The total of commercial flights organized by month each year") +
  xlab("Month") + 
  ylab("Total Flights (in thousands)") 

#-------------------------------Visualization 5----------------------------#
# Total of Failures to reach final destination by year
#Group by Year, Cancelled Flights and Diverted Flights and count the number of failed flights
agg3 <- aggregate(df[c("Year","Cancelled","Diverted")],
                  by = list(df$Year, df$Cancelled, df$Diverted),
                  FUN = length)
agg3 <- agg3[-c(1,2),]
agg3 <- agg3[,-c(5,6)]
colnames(agg3) <- c("Year","Cancelled","Diverted", "Total_Failures")
agg3$Cancelled <- factor(agg3$Cancelled, labels=c("Diverted", "Cancelled"))
#The final bar plot
ggplot(data=agg3, aes(x=Year, y=Total_Failures/1000, fill=Cancelled)) +
  geom_bar(stat="identity",colour="black") +
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold",size=10))+
  geom_text(aes(label = Total_Failures/1000),size = 2.5, hjust = 0.5, vjust = 3, position ="stack")+
  ggtitle("Failed Flights by Year") +
  xlab("Year") + 
  ylab("Total Failed Flights (in Thousands)") +
  guides(fill=guide_legend(title="Type of Failure"))+
  scale_fill_manual(values=c("#ff00ff","#9900cc"))+
  labs(subtitle = "Figure 5. Total of organized flights which failed to reach final destination in 2003 and 2004")+
  theme(plot.subtitle = element_text(hjust = 0.5),
        plot.title = element_text(hjust = 0.5, size = 14))

#-------------------------------Visualization 6----------------------------#
#Total Failures each month by year
#Group by year, month and Cancelled Flights and Diverted Flights 
#and count the number of failed flights
agg4 <- aggregate(df$Year,
                  by = list(df$Year,df$Month, df$Cancelled, df$Diverted),
                  FUN = length)
colnames(agg4) <- c("Year","Month","Cancelled", "Diverted", "Total_Failures")
agg4 <- agg4[-c(1:24),]
agg4 <- agg4[,-c(6,7)]

#Group by year, month and count the total failed flights by month each year
agg5 <- aggregate(agg4$Total_Failures,
                  by = list(agg4$Year,agg4$Month),
                  FUN = sum)
colnames(agg5) <- c("Year","Month", "Total_Failures")

#The bar plot with dodge position
ggplot(data=agg5, aes(x=Month, y=Total_Failures, fill=Year)) +
  geom_bar(stat="identity", position=position_dodge(),colour="black") +
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold"))+
  ggtitle("Total Flight Failures each Month by Year") +
  labs(aes(x=Null,y=Null), subtitle="Figure 6. Total of organized flights which failed to reach final destination by month in 2003 and 2004")+
  scale_fill_discrete(name = "Year") +
  scale_color_manual(values=c("#f7766d", "#0fb7bb"))+
  coord_polar()

#-------------------------------Visualization 7----------------------------#
#Distribution of the average arrival delay to the number of flights per Airport 
#in years 2003 and 2004
#group by origin and count the number of flights of each origin
agg6 <- aggregate(df2$Year,
                  by = list(df2$Year,df2$Origin),
                  FUN = length)
colnames(agg6) <- c("Year","Origin","Count")

#Count mean Arrival Delay for each origin per year
agg7 <- aggregate(df2$ArrDelay,
                  by = list(df2$Year,df2$Origin),
                  FUN = mean)
colnames(agg7) <- c("Year","Origin","Avg_ArrDelay")
#Join both agg6 and agg7 datasets
library(dplyr)
agg8 <- left_join(agg6,agg7,by= c("Year"="Year","Origin"="Origin"))

ggplot(agg8, aes(x=Count/1000, y=Avg_ArrDelay)) + 
  geom_point(aes(col=Year)) +   # draw points
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold"),
        plot.subtitle = element_text(hjust = 0.5))+
  labs(subtitle="Figure 7. Distribution of the average delay to the number of flights per Airport in years 2003 and 2004", 
       y="Average Arrival Delay (in Minutes)", 
       x="Number of Flights (in Thousands)", 
       title="Number of Flights and Average Arrival Delay")


#-------------------------------Visualization 8----------------------------#
# Distribution of Total Arrival Delay per year

#The boxplot ignoring part of the outliers outside the interquantile range
ggplot(df2, aes(x=Year, y=ArrDelay, fill=Year)) + 
  geom_boxplot(outlier.shape = NA) +
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold"))+
  xlab("Year") + 
  ylab("Arrival Delay (in minutes)") +
  scale_fill_discrete(name = "Year") +
  scale_color_manual(values=c("#f7766d", "#0fb7bb"))+
  coord_cartesian(ylim = c(-10, 10))+
  labs(title = "Arrival Delay for Years 2003 and 2004",
       subtitle = "Figure 8. Distribution of Arrival Delays per year excluding extreme outliers")+
  theme(plot.title = element_text(hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5),
        legend.position="none")

#-------------------------------Visualization 9----------------------------#
library(tidyverse)
library(ggpubr)
#count the number of flights by year and by origin
agg9 <- aggregate(df2$Year,
                  by = list(df2$Year, df2$Origin),
                  FUN = length)
colnames(agg9) <- c("Year","Origin","Count")
#sort by count in decreasing order
sorted_agg9 <- agg9[order(agg9$Count,decreasing = TRUE),]
#keep the top 10 origins with the most counts by year
top10_origins <- Reduce(rbind,                                
                        by(sorted_agg9,
                           sorted_agg9["Year"],
                           head,
                           n = 10))
#scale to thousands
top10_origins$Count <- top10_origins$Count/1000
#diagram of top 10 origins with most completed flights by year
ggdotchart(
  top10_origins, x = "Origin", y = "Count", group="Year", color="Year", 
  add = "segment", position = position_dodge(0.3),
  ylab = "Number of Flights (in Thousands)",
  sorting = "descending",rotate = TRUE, title="Top 10 Origins")+
  labs(subtitle="Figure 9. Top 10 origins with most completed flights by year")+
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold",size=14),
        plot.subtitle = element_text(hjust = 0.5))+
  scale_color_manual(values=c("#f7766d", "#0fb7bb"))
  

#keep the last 10 origins with the least flights by year
last10_origins <- Reduce(rbind,                                
                         by(sorted_agg9,
                            sorted_agg9["Year"],
                            tail,
                            n = 10))
last10_origins_2004 <- last10_origins[last10_origins$Year==2004,]
#diagram of 10 origins with least completed flights by year
ggdotchart(
  last10_origins, x = "Origin", y = "Count", group="Year", color="Year", 
  add = "segment", 
  ylab = "Number of Flights", 
  position = position_dodge(0.3),
  sorting = "descending",rotate = TRUE, 
  title="Last 10 Origins")+
  labs(subtitle="Figure 10. Last 10 origins with least completed flights by year")+
  theme_dark()+ 
  theme(plot.title = element_text(hjust = 0.5,face = "bold",size=14),
        plot.subtitle = element_text(hjust = 0.5))+
  scale_color_manual(values=c("#f7766d", "#0fb7bb"))


#-------------------------------Visualization 10----------------------------#
#Check intervention between top-10 delays airports and top-10 on flights airports
library(VennDiagram)
library("gridExtra")    
#count the number of observations by year and by origin
agg10 <- aggregate(df2$ArrDelay,
                  by = list(df2$Year, df2$Origin),
                  FUN = mean)
colnames(agg10) <- c("Year","Origin","Average_Delay")
#sort by count in decreasing order
sorted_agg10 <- agg10[order(agg10$Average_Delay,decreasing = TRUE),]
#keep the top 10 origins with the most counts by year
top10_Arrdelays <- Reduce(rbind,                                
                        by(sorted_agg10,
                           sorted_agg10["Year"],
                           head,
                           n = 10))
#split top10 arrival delays for 2004
top10_Arrdelays_2004 <- top10_Arrdelays[top10_Arrdelays$Year==2004,]
#split top10 origins by number of flights for 2004
top10_origins_2004 <- top10_origins[top10_origins$Year==2004,]

#The final VennDiagram 
top10_Arrdelays_top10Origins_diag <- venn.diagram(
  x = list(top10_Arrdelays_2004$Origin,top10_origins_2004$Origin),
  category.names = c("top-10 airports on delays", "top-10 airports on flights" ),
  lwd = 1,
  fill = c("#009E73", "#56B4E9"),
  alpha = c(0.3, 0.3), 
  cat.cex = 1.2, 
  cex=0.8, 
  cat.pos = c(0, 0),
  cat.dist = c(0.05,0.05),
  cat.fontface = "bold",
  cat.col = c("#009E73", "#56B4E9"),
  scaled=TRUE,
  filename=NULL
)
plot.new()
title("Venn Diagram of top-10 delays and top-10 airports on flights",
      sub = "Figure 11. Intersection of Top-10 airports with most delays and Top-10 airports on total flights")
#change the labels so that origin names appear in the venn diagram
top10_Arrdelays_top10Origins_diag[[5]]$label  <- paste(setdiff(top10_Arrdelays_2004$Origin,top10_origins_2004$Origin), collapse="\n")  
top10_Arrdelays_top10Origins_diag[[6]]$label <- paste(setdiff(top10_origins_2004$Origin,top10_Arrdelays_2004$Origin)  , collapse="\n")  
top10_Arrdelays_top10Origins_diag[[7]]$label <- paste(intersect(top10_Arrdelays_2004$Origin,top10_origins_2004$Origin), collapse="\n")  

grid.draw(top10_Arrdelays_top10Origins_diag)



#Check intervention between top-10 delays airports and last-10 on flights airports
#last 10 origins for 2004
last10_origins_2004 <- last10_origins[last10_origins$Year==2004,]
#venn diagram for the last 10 origins in 2003 and 2004
top10_Arrdelays_last10Origins_diag <- venn.diagram(
  x = list(x1=top10_Arrdelays_2004$Origin,x2=last10_origins_2004$Origin),
  category.names = c("top-10 airports on delays" , "last-10 airports on flights"),
  height = 480 , 
  width = 480 , 
  lwd = 1,
  fill = c("#009E73", "#56B4E9"),
  alpha = c(0.3, 0.3), 
  cat.cex = 1.2, 
  cex=1, 
  filename=NULL,
  cat.pos = c(0, 0),
  cat.dist = c(0.05,0.05),
  cat.fontface = "bold",
  cat.col = c("#009E73", "#56B4E9"),
  scaled = FALSE,
  ext.text = FALSE,
)
#change the labels so that origin names appear in the venn diagram
top10_Arrdelays_last10Origins_diag[[5]]$label  <- paste(setdiff(top10_Arrdelays_2004$Origin,last10_origins_2004$Origin), collapse="\n")  
top10_Arrdelays_last10Origins_diag[[6]]$label <- paste(setdiff(last10_origins_2004$Origin,top10_Arrdelays_2004$Origin)  , collapse="\n")  
top10_Arrdelays_last10Origins_diag[[7]]$label <- paste(intersect(top10_Arrdelays_2004$Origin,last10_origins_2004$Origin), collapse="\n")  
plot.new()
title("Venn Diagram of top-10 delays and top-10 airports on flights",
      sub = "Figure 12. Intersection of Top-10 airports with most delays and Last-10 airports on total flights")

grid.draw(top10_Arrdelays_last10Origins_diag)


#-------------------------------Visualization 11----------------------------#

#Create a social Network of all the flight destinations for the top performing airport in 2004
library(igraph)
#dataset of best performing airport in 2004
atl_2004 <- df2[df2$Origin=='ATL' & (df2$Year==2004),]
atl_2004 <-  atl_2004[,c(17,18)]
#create intervals of delay
atl_2004_delay <- df2[df2$Origin=='ATL' & df2$Year==2004,]
agg12 <- aggregate(atl_2004_delay$ArrDelay,
                   by = list(atl_2004_delay$Dest),
                   FUN = mean)
colnames(agg12) <- c("Destination","Avg_ArrDelay")
destNames_larger10_lower60 <- agg12[agg12$Avg_ArrDelay >= 10 & agg12$Avg_ArrDelay < 60,]
destNames_larger0_lower10 <- agg12[agg12$Avg_ArrDelay >= 0 & agg12$Avg_ArrDelay < 10,]
destNames_lower0 <- agg12[agg12$Avg_ArrDelay < 0,]

destNames_larger10_lower60 <- destNames_larger10_lower60[,1] 
destNames_larger0_lower10 <- destNames_larger0_lower10[,1] 
destNames_lower0 <- destNames_lower0[,1]  
#Delete duplicate pairs
atl_2004_unique <- atl_2004[!duplicated(t(apply(atl_2004, 1, sort))),]
g <- graph_from_data_frame(atl_2004_unique, directed = T)
#The social network graph
par(bg="black")
plot(g,layout =  layout.kamada.kawai,vertex.label = V(g)$name,
     vertex.frame.color="black",
     vertex.label.color= "Black",
     vertex.size=4,
     vertex.label.cex=0.3,
     edge.arrow.size=0.5,  
     edge.curved=T, 
     edge.label=E(g)$Freq, 
     edge.label.color="pink", 
     edge.label.font=5,
     edge.color="grey", 
     asp=0,edge.arrow.color="Black")
#title
title("Atlanta's Airport Destinations",
      sub = "Figure 13. Atlantas Airport Destinations and their Average Delays",cex.main=1,col.main="white")
#colors of nodes
x=2
for (i in V(g)$name){
  if (i %in% destNames_lower0){
    V(g)$color[x] <- 'green'
    x <- x+1
  } else if (i %in% destNames_larger0_lower10){
    V(g)$color[x] <- 'yellow'
    x <- x+1
  } else if(i %in% destNames_larger10_lower60){
    V(g)$color[x] <- 'orange'
    x <- x+1
  } else{
    V(g)$color[x] <- 'red'
    x <- x+1
  }
}
V(g)$color[1] <- 'purple'
#legend
legendText <- c('>=60 Minutes Average Delay',
                '>=10 & <60 Minutes Average Delay',
                '>=0 & <10 Minutes Average Delay', 
                '<0 Average Delay',
                'Atlanta Airport')
legend(0.5,-1, legend=legendText,
       fill=c("red","orange","yellow","green", "purple"),cex=0.8,bg='white')


#-------------------------------Visualization 12----------------------------#
#Find the most important reasons for delays of the worst performing airports in 2004
par(bg="white")
library(fmsb)
#create dataset of the worst performing airports
worst_perform_origins <- df2[(df2$Origin %in% c("FMN","OGD","PUB","DUT","ADK","APF")) & (df2$Year==2004),]
worst_perform_origins <- worst_perform_origins[,c(25:29)]
#Add a row for the total delay per column
total_delay <- sum(sum(worst_perform_origins$CarrierDelay),
                   sum(worst_perform_origins$WeatherDelay),
                   sum(worst_perform_origins$NASDelay),
                   sum(worst_perform_origins$SecurityDelay),
                   sum(worst_perform_origins$LateAircraftDelay))
#Add a row for the maximum total delay per column
worst_perform_origins <- rbind(worst_perform_origins,
                               c(sum(worst_perform_origins$CarrierDelay),
                                 sum(worst_perform_origins$WeatherDelay),
                                 sum(worst_perform_origins$NASDelay),
                                 sum(worst_perform_origins$SecurityDelay),
                                 sum(worst_perform_origins$LateAircraftDelay)))
worst_perform_origins <- rbind(worst_perform_origins,c(total_delay,total_delay,total_delay,total_delay,total_delay))
#Add column for the minimum delay per column
worst_perform_origins <- rbind(worst_perform_origins,c(0,0,0,0,0)) 

#Create the radar chart
radar_data <- worst_perform_origins[c(279,280,278), ]
op <- par(mar = c(6, 2, 2, 1))
radarchart(radar_data,axistype=4, pcol = "#00AFBB", 
           pfcol = scales::alpha("#00AFBB", 0.5), plwd = 2, plty = 1,
           cglcol = "grey", cglty = 1, cglwd = 0.5,
           axislabcol = "grey", title="Reasons of Delay for Worst Performing Airports", 
           sub = "Figure 14. Reasons that cause Delay in Worst Performing Airports")
