library(data.table)
library(tsne)

df = fread("fmrib/NeuroPM/io/ukb_num_norm.csv")
df = data.frame(df)

labels = read.csv("fmrib/NeuroPM/io/labels.csv")

reduce = tsne(df, k = 50)

plot(reduce[,49],reduce[,50],
     col=c("orange","green","red")[labels$bp_group+1],pch=16)
