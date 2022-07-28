library('igraph')
library(ggplot2)

# Task 1
#import the datasets of from/to/weight form for each year
data2016 <- read.csv('From_To_Weight_data/data2016final.csv')
data2017 <- read.csv('From_To_Weight_data/data2017final.csv')
data2018 <- read.csv('From_To_Weight_data/data2018final.csv')
data2019 <- read.csv('From_To_Weight_data/data2019final.csv')
data2020 <- read.csv('From_To_Weight_data/data2020final.csv')

#delete first unused column
data2016 <- data2016[,-1]
data2017 <- data2017[,-1]
data2018 <- data2018[,-1]
data2019 <- data2019[,-1]
data2020 <- data2020[,-1]

#create the graphs
graph2016 <- graph_from_data_frame(data2016,directed=FALSE)
graph2017 <- graph_from_data_frame(data2017,directed=FALSE)
graph2018 <- graph_from_data_frame(data2018,directed=FALSE)
graph2019 <- graph_from_data_frame(data2019,directed=FALSE)
graph2020 <- graph_from_data_frame(data2020,directed=FALSE)

#Task 2
graphs <- list(graph2016, graph2017, graph2018, graph2019, graph2020)
date = c(2016,2017,2018,2019,2020)
#number of vertices
vertices <- data.frame(date=date, score=sapply(graphs,vcount))

#number of edges
edges <- data.frame(date=date, score=sapply(graphs,ecount))

#diameter of graphs
diameter <-  data.frame(date=date,score=sapply(graphs,diameter))

#average degree
mean_degree <-  data.frame(date=date,score=sapply(graphs,function(x){mean(degree(x,mode='all'))}))

#plots all the metrics for the 5 years
plot1 <- ggplot(vertices, aes(x=date, y=score))+geom_line()+ggtitle("vertices")                                
plot2 <- ggplot(edges, aes(x=date, y=score)) + geom_line()+ggtitle("edges")                                  
plot3 <- ggplot(diameter, aes(x=date, y=score)) + geom_line()+ggtitle("diameter")                                  
plot4 <- ggplot(mean_degree, aes(x=date, y=score)) + geom_line()+ggtitle("mean_degree") 

#Task 3
#Top-10 authors by degree
data.frame(total_degree=tail(sort(degree(graph2016, v = V(graph2016), mode = c("all"),
                                          loops = FALSE,normalized=FALSE)),10))
data.frame(total_degree=tail(sort(degree(graph2017, v = V(graph2017), mode = c("in"),
                                          loops = FALSE)),10))
data.frame(total_degree=tail(sort(degree(graph2018, v = V(graph2018), mode = c("in"),
                                          loops = FALSE)),10))
data.frame(total_degree=tail(sort(degree(graph2019, v = V(graph2019), mode = c("in"),
                                          loops = FALSE)),10))
data.frame(total_degree=tail(sort(degree(graph2020, v = V(graph2020), mode = c("in"),
                                          loops = FALSE)),10))

#top-10 authors by page rank
rank2016<-page_rank(graph2016, algo = "prpack",
                 vids = V(graph2016), directed = TRUE, damping = 0.85,
                 personalized = NULL, weights = E(graph2016)$weight)
rank2017<-page_rank(graph2017, algo = "prpack",
                 vids = V(graph2017), directed = TRUE, damping = 0.85,
                 personalized = NULL, weights = E(graph2017)$weight)
rank2018<-page_rank(graph2018, algo = "prpack",
                 vids = V(graph2018), directed = TRUE, damping = 0.85,
                 personalized = NULL, weights = E(graph2018)$weight)
rank2019<-page_rank(graph2019, algo = "prpack",
                 vids = V(graph2019), directed = TRUE, damping = 0.85,
                 personalized = NULL, weights = E(graph2019)$weight)
rank2020<-page_rank(graph2020, algo = "prpack",
                 vids = V(graph2020), directed = TRUE, damping = 0.85,
                 personalized = NULL, weights = E(graph2020)$weight)

data.frame(Rank_2016=tail(sort(rank2016$vector),10))
data.frame(Rank_2017=tail(sort(rank2017$vector),10))
data.frame(Rank_2018=tail(sort(rank2018$vector),10))
data.frame(Rank_2019=tail(sort(rank2019$vector),10))
data.frame(Rank_2020=tail(sort(rank2020$vector),10))

#Task 4
#convert the graphs to undirected
graph2016_undirected <- as.undirected(graph2016)
graph2017_undirected <- as.undirected(graph2017)
graph2018_undirected <- as.undirected(graph2018)
graph2019_undirected <- as.undirected(graph2019)
graph2020_undirected <- as.undirected(graph2020)
graphs_undirected <- list(graph2016_undirected,graph2017_undirected,graph2018_undirected,
                          graph2019_undirected,graph2020_undirected)
#Greedy Clustering and time performance
system.time(greedy <- sapply(graphs_undirected,cluster_fast_greedy))
#Infomap Clustering and time performance
system.time(infomap <- sapply(graphs_undirected,cluster_infomap))
#Louvain Clustering and time performance
system.time(louvain <- sapply(graphs_undirected,cluster_louvain))
            
#find 1 author that exists in all years  and compare him for all years
#First find the index of the community the author participates in each year
membership(louvain[[1]])["Jiawei Han 0001"]
membership(louvain[[2]])["Jiawei Han 0001"]
membership(louvain[[3]])["Jiawei Han 0001"]
membership(louvain[[4]])["Jiawei Han 0001"]
membership(louvain[[5]])["Jiawei Han 0001"]

#check the size of the community the author belongs to each year
length(louvain[[1]][[37]])
length(louvain[[2]][[15]])
length(louvain[[3]][[76]])
length(louvain[[4]][[52]])
length(louvain[[5]][[7]])

#find similar nodes of each year to its next year
sum(louvain[[1]][[37]] %in% louvain[[2]][[15]])
sum(louvain[[2]][[15]] %in% louvain[[3]][[76]])
sum(louvain[[3]][[76]] %in% louvain[[4]][[52]])
sum(louvain[[4]][[52]] %in% louvain[[5]][[7]])
sum(louvain[[1]][[37]] %in% louvain[[2]][[15]])

#plot communities
#check the size of each community
louvain_clusters <- list(louvain[[1]],louvain[[2]],louvain[[3]],louvain[[4]],louvain[[5]])
size <- sapply(louvain_clusters,sizes)

#filter out nodes of large communities 
sub2016<-unlist(louvain[[1]][size[[1]] > 50])
plot2016 <- induced.subgraph(graph2016, sub2016)

sub2017<-unlist(louvain[[2]][size[[2]] > 70])
plot2017 <- induced.subgraph(graph2017, sub2017)

sub2018<-unlist(louvain[[3]][size[[3]] > 70])
plot2018 <- induced.subgraph(graph2018, sub2018)

sub2019<-unlist(louvain[[4]][size[[4]] > 50])
plot2019 <- induced.subgraph(graph2019, sub2019)

sub2020<-unlist(louvain[[5]][size[[5]] > 100])
plot2020 <- induced.subgraph(graph2020, sub2020)

#change color of each community
V(plot2016)$color <- factor(membership(louvain[[1]]))
V(plot2017)$color <- factor(membership(louvain[[2]]))
V(plot2018)$color <- factor(membership(louvain[[3]]))
V(plot2019)$color <- factor(membership(louvain[[4]]))
V(plot2020)$color <- factor(membership(louvain[[5]]))

#plot communities of each year with different colors
plot(plot2016, vertex.label = NA, vertex.size = 3, main='Communities 2016')
plot(plot2017, vertex.label = NA, vertex.size = 3, main='Communities 2017')
plot(plot2018, vertex.label = NA, vertex.size = 3, main='Communities 2018')
plot(plot2019, vertex.label = NA, vertex.size = 3, main='Communities 2019')
plot(plot2020, vertex.label = NA, vertex.size = 3, main='Communities 2020')

