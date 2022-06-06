#import library that will read the csv
library (readr)
#create url??
urlfile1 = "https://raw.githubusercontent.com/mathbeveridge/asoiaf/master/data/asoiaf-all-edges.csv"
urlfile2 = "https://raw.githubusercontent.com/mathbeveridge/asoiaf/master/data/asoiaf-all-nodes.csv"
#read urls that contains the csvs of edges and nodes
edges <- read_csv(url(urlfile1))
nodes <- read_csv(url(urlfile2))
#import the library that will create the graphs
library(igraph)
#Task 1
#keep the columns needed
edges <- edges[,c(1,2,5)]
#the graph
g <- graph_from_data_frame(edges, directed=FALSE, vertices=nodes)

#Task 2
#Number of Vertices
vcount(g)
#Number of Edges
ecount(g)
#Diameter of graph
diameter(g)
#number of unique triangles
sum(count_triangles(g))/3
#top-10 characters of the network as far as their degree is concerned
tail(sort(degree(g)),10)
#top-10 characters of the network as far as their weighted degree is concerned
tail(sort(strength(g,mode = c("all"))),10)

#Task 3
#plot the network
plot(g,vertex.label = NA,edge.width=0.7,edge.arrow.width=1, vertex.size = 2.5, main="'A Song of Ice and Fire' Character Relationships")
#edge density of graph
edge_density(g)

#delete vertices with less than 10 connections
subgraph<-delete.vertices(g, V(g)[degree(g) <= 10])
#plot network of vertices with at least 10 connections
plot(subgraph,vertex.label = NA,edge.width=0.7,edge.arrow.width=1, vertex.size = 5, main="Network of Characters with at least 10 Connections")
#edge density of subgraph
edge_density(subgraph)

#Task 4
#top 15 Nodes according to closeness centrality
head(sort(closeness(g, mode = c("all")),decreasing = TRUE),15)

#top 15 Nodes according to betweenness centrality
head(sort(betweenness(g), decreasing = TRUE),15)

#rank of john snow by closeness centrality in ascending order
sorted_closeness <- sort(closeness(g, mode = c("all")))
rank(sorted_closeness)['Jon-Snow']
#rank of john snow by betweenness centrality in ascending order
sorted_betweenness <- sort(betweenness(g))
rank(sorted_betweenness)['Jon-Snow']

#Task 5
#calculate page rank
rank<-page_rank(g, algo = "prpack", vids = V(g), directed = FALSE, damping = 0.85,
                personalized = NULL, weights = E(g)$weights)

plot(g,vertex.label = NA,edge.width=0.7,edge.arrow.width=1, vertex.size = rank$vector*500,
     main = "Network of Characters sized by their Page Rank" )


