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
# background
#cov_background = cov(ft_norm[labels$bp_group == 1, ])
#cov_background[upper.tri(cov_background)] = NA
#diag(cov_background) = NA

# disease
#cov_disease = cov(ft_norm[labels$bp_group == 2, ])
#cov_disease[upper.tri(cov_disease)] = NA
#diag(cov_disease) = NA

# contrast cov = cov_d - a * cov_b
cov_contrast = cov(ft_norm[labels$bp_group == 2, ]) - cov(ft_norm[labels$bp_group == 1, ])
cov_contrast[upper.tri(cov_contrast)] = 0
diag(cov_contrast) = NA

# # # feature selection
# find high co-correlation variables
ind_keep1 = unname(apply(cov_contrast, 1, function(x)
                            !any(abs(x) > 0.25, na.rm = TRUE)))

# find brain variables
var_filter = var_groups$ukb_var[var_groups$var_group == "Brain_MR" | 
                                var_groups$var_group == "Body_Composition"]
var_filter = colnames(ft_norm) %in% var_filter
ind_keep1[!var_filter] = TRUE

# only keep relevant features
ft_norm = ft_norm[, ind_keep1]

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
print(sprintf("The Filtered Data Frame is of Size %0.0f by %0.0f",
              nrow(ft_norm), ncol(ft_norm)))
print(sprintf("----- Distribution of Classes is:"))
print(table(labels$bp_group))
print(sprintf("----- Distribution of Variable Groups is:"))
print(table(var_groups$var_group[var_groups$ukb_var 
                                        %in% colnames(ft_norm)]))

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
fwrite(labels, "NeuroPM/io/labels_select.csv")
