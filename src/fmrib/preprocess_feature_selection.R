# load dependencies
library(data.table)

# load data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
ft = data.frame(fread('NeuroPM/io/ukb_num.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')

# compute covariance and preprocess
#cov_all = cov(ft_norm)
#cov_all[upper.tri(cov_all)] = 0
#diag(cov_all) = 0

# remove high correlation variables
#ind_filter = !unname(apply(cov_all, 1, function(x) any(abs(x) > 0.75)))

# filter columns
#ft_norm = ft_norm[, ind_filter]

# only keep subset of background/disease
#ft_norm = rbind(ft_norm[labels$bp_group == 1, ][1101:2000, ],
#                ft_norm[labels$bp_group != 1, ])
#ft = rbind(ft[labels$bp_group == 1, ][1101:2000, ],
#           ft[labels$bp_group != 1, ])
#labels = rbind(labels[labels$bp_group == 1, ][1101:2000, ],
#               labels[labels$bp_group != 1, ])

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
fwrite(ft, "NeuroPM/io/ukb_num.csv")
fwrite(labels, "NeuroPM/io/labels_select.csv")
