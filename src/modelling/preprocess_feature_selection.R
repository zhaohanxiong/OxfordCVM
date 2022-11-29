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

# # # compute covariance matrices
# background + disease
cov_all = cov(ft_norm[labels$bp_group == 1 | labels$bp_group == 2, ])
cov_all[upper.tri(cov_all)] = NA
diag(cov_all) = NA

# background
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_background[upper.tri(cov_background)] = NA
diag(cov_background) = NA

# disease
cov_disease = cov(ft_norm[labels$bp_group == 2, ])
cov_disease[upper.tri(cov_disease)] = NA
diag(cov_disease) = NA

# contrast cov = cov_d - a * cov_b
cov_contrast = cov(ft_norm[labels$bp_group == 2, ]) - cov(ft_norm[labels$bp_group == 1, ])
cov_contrast[upper.tri(cov_contrast)] = 0
diag(cov_contrast) = NA

# # # feature selection
# find high co-correlation variables
ind_omit = unname(apply(cov_contrast, 1, function(x)
                            max(abs(x), na.rm = TRUE) < 0.25))

# find brain variables
var_brain = var_groups$ukb_var[var_groups$var_group == "Brain_MR"]
var_brain = colnames(ft_norm) %in% var_brain

# remove only brain variables
#ind_omit[!var_brain] = FALSE

# only keep relevant features
ft_norm = ft_norm[, !ind_omit]

# # # Experimentation
# shuffle labels for experimentation
#labels$bp_group = sample(labels$bp_group, nrow(labels))

# only keep subset of background/disease for experimentation
#n_sample = 500
#ft_norm = rbind(ft_norm[labels$bp_group == 1, ][1:n_sample, ],
#                ft_norm[labels$bp_group != 1, ])
#labels = rbind(labels[labels$bp_group == 1, ][1:n_sample, ],
#               labels[labels$bp_group != 1, ])

# # # output
# display messages to see in terminal
print(sprintf("Further Filtering Complete"))
print(sprintf("Distribution of Classes is"))
print(table(labels$bp_group))
print(sprintf("The Filtered Data Frame is of Size %0.0f by %0.0f",
              nrow(ft_norm), ncol(ft_norm)))

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
write.csv(labels, "NeuroPM/io/labels_select.csv")
