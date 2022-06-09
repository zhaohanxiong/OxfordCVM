
library(plotly)
library(ggplot2)
library(ggplotly)

library(GGally)
library(network)

# source path
path      = "C:/Users/zxiong/Desktop"
file_path = "io - iter_cPCA full run 10"
path      = file.path(path, file_path)

# set the current working directory
setwd(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = read.csv("labels.csv")

# load minimum spanning tree
MST = read.csv("MST.csv")
MST$group = labels$bp_group[MST$Edges_1]

# convert graph
net = network(MST[1:1000,1:2])

# plot graph
p = ggnet2(net, size = 1)
ggplotly(p)
