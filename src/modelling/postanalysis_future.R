library(tools)
library(ggplot2)
library(gridExtra)

# load outputs from NeuroPM
path = "NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)

# load repeat visit values
future = read.csv(file.path(path, "future.csv"), header = TRUE)

# 
