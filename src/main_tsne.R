library(data.table)
library(tsne)

path = "C:/users/zxiong/desktop/workspace vars 20% run/"
df = fread(file.path(path, "ukb_num_norm.csv"))
df = data.frame(df)

reduce = tsne(df, max_iter = 500, k = 50)
fwrite(data.frame(reduce), file.path(path, "tsne.csv"))