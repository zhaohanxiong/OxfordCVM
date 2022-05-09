library(data.table)
library(tsne)

df = fread("ukb_num_norm.csv")
df = data.frame(df)

labels = read.csv("labels.csv")

reduce = tsne(df)

plot(reduce[,1],reduce[,2],col=labels$bp_group)
