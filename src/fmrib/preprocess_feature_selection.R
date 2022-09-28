# load dependencies
library(data.table)

# load data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')

# shuffle dataset
ind_rand = sample(1:nrow(labels), nrow(labels))
ft_norm = ft_norm[ind_rand, ]
labels = labels[ind_rand, ]

# compute covariance and preprocess
cov_all = cov(ft_norm)
cov_all[upper.tri(cov_all)] = 0
diag(cov_all) = 0

# remove high correlation variables
ind_filter = !unname(apply(cov_all, 1, function(x) any(abs(x) > 0.95)))

# filter columns
ft_norm = ft_norm[, ind_filter]

# only keep subset of background/disease
#ft_norm = rbind(ft_norm[labels$bp_group == 1, ][1:1000, ],
#                ft_norm[labels$bp_group != 1, ])
#labels = rbind(labels[labels$bp_group == 1, ][1:1000, ],
#               labels[labels$bp_group != 1, ])

# display messages to see in terminal
print(sprintf("Further Filtering Complete"))
print(sprintf("Distribution of Classes is"))
print(table(labels$bp_group))

print(sprintf("The Filtered Data Frame is of Size %0.0f by %0.0f",
              nrow(ft_norm), ncol(ft_norm)))

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
fwrite(labels, "NeuroPM/io/labels_select.csv")
