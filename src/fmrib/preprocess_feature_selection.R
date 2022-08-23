# load dependencies
library(data.table)

# load data
features_original = data.frame(fread('NeuroPM/io/ukb_num.csv'));
features = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'));

# 