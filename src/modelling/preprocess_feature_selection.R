# load dependencies
library(data.table)

# # # load data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')
var_groups = read.csv('NeuroPM/io/var_grouped.csv')

# shuffle dataset to remove bias during cross-validation
ind_rand = sample(1:nrow(labels), nrow(labels))
ft_norm = ft_norm[ind_rand, ]
labels = labels[ind_rand, ]

# # # remove low covariance variables in background
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_background[upper.tri(cov_background)] = 0
diag(cov_background) = 0

cov_disease = cov(ft_norm[labels$bp_group == 2, ])
cov_disease[upper.tri(cov_disease)] = 0
diag(cov_disease) = 0

#ind_filter = unname(apply(cov_background, 1, function(x) !any(abs(x) > 0.9)))
#ft_norm = ft_norm[, ind_filter]

# # # reduce brain variables in the background



# # # filter our variables individually more specifically



# # # identify which features contribute to high covariance
# note that cPCA: cov = cov_d - a * cov_b
# what is the difference between cov_background and cov_background_subset
# which makes the cPCA worse when we add more background patients
# * to do *
# compute covariance of background/disease population only
# covariance of a subset of background patients
#cov_background = cov(ft_norm[labels$bp_group == 1, ])
#cov_disease = cov(ft_norm[labels$bp_group == 2, ])
#cov_background_subset = cov(ft_norm[sample(which(labels$bp_group == 1), 500), ])
#c1 = cov_disease - 10*cov_background
#c2 = cov_disease - 10*cov_background_subset
#e1 = eigen(c1)
#e2 = eigen(c2)
#hist(e1$vectors, col = rgb(0,0,1,1/4))
#hist(e2$vectors, col = rgb(1,0,0,1/4), add = TRUE)

# # # shuffle labels for experimentation
# labels$bp_group = sample(labels$bp_group, nrow(labels))

# only keep subset of background/disease for experimentation
# n_sample = 750
# ft_norm = rbind(ft_norm[labels$bp_group == 1, ][1:n_sample, ],
#                 ft_norm[labels$bp_group != 1, ])
# labels = rbind(labels[labels$bp_group == 1, ][1:n_sample, ],
#             labels[labels$bp_group != 1, ])

# display messages to see in terminal
print(sprintf("Further Filtering Complete"))
print(sprintf("Distribution of Classes is"))
print(table(labels$bp_group))

print(sprintf("The Filtered Data Frame is of Size %0.0f by %0.0f",
              nrow(ft_norm), ncol(ft_norm)))

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
write.csv(labels, "NeuroPM/io/labels_select.csv")
