# load dependencies
library(data.table)

# load data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
ft      = data.frame(fread('NeuroPM/io/ukb_num.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')

# feature selection

