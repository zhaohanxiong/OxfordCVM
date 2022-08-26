# load dependencies
library(data.table)

# load data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')

# compute covariance and preprocess
cov_all = cov(ft_norm)
cov_all[upper.tri(cov_all)] = 0
diag(cov_all) = 0

# remove high correlation variables
ind_filter = !unname(apply(cov_all, 1, function(x) any(abs(x) > 0.75)))

# filter columns
ft_norm = ft_norm[, ind_filter]

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
