# load dependencies
library(data.table)

# load data
features = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'));
labels = read.csv('NeuroPM/io/labels.csv');
pseudotimes = read.csv('NeuroPM/io/pseudotimes.csv');

# filter outliers in pseudotime scores
features = features[pseudotimes$global_pseudotimes < 0.65, ]
labels = labels[pseudotimes$global_pseudotimes < 0.65, ]

fwrite(features, "NeuroPM/io/ukb_num_norm.csv", row.names = FALSE)
fwrite(labels, "NeuroPM/io/labels.csv", row.names = FALSE)
