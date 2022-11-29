# load dependencies
library(data.table)

# # # Prepare data
# read data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')
var_groups = read.csv('NeuroPM/io/var_grouped.csv')

# shuffle dataset to remove bias during cross-validation
ind_rand = sample(1:nrow(labels), nrow(labels))
ft_norm = ft_norm[ind_rand, ]
labels = labels[ind_rand, ]

# # # Filtering by contrast covariance matrix
# contrast cov = cov_d - a * cov_b
cov_contrast = cov(ft_norm[labels$bp_group == 2, ]) - 
                                    cov(ft_norm[labels$bp_group == 1, ])
cov_contrast[upper.tri(cov_contrast)] = 0
diag(cov_contrast) = NA

# find high contrast variables
ind_keep = unname(apply(cov_contrast, 1, function(x)
                            !any(abs(x) > 0.25, na.rm = TRUE)))

# mask out brain/body comp variables
var_list = var_groups$ukb_var[var_groups$var_group == "Brain_MR" | 
                              var_groups$var_group == "Body_Composition"]
var_filter = colnames(ft_norm) %in% var_list
ind_keep[!var_filter] = TRUE

# only keep relevant features
ft_norm = ft_norm[, ind_keep]

# # # Filtering out background variables
# compute background covariance
cov_contrast = cov(ft_norm[labels$bp_group == 2, ]) - 
                                    cov(ft_norm[labels$bp_group == 1, ])
cov_contrast[upper.tri(cov_contrast)] = 0
diag(cov_contrast) = NA

# find high covariance variables
ind_keep = unname(apply(cov_contrast, 1, function(x)
                                !any(abs(x) > 0.1, na.rm = TRUE)))

# mask out brain/body comp variables
var_list = var_groups$ukb_var[var_groups$var_group == "Blood"]
var_filter = colnames(ft_norm) %in% var_list
ind_keep[!var_filter] = TRUE

# only keep relevant features
#ft_norm = ft_norm[, ind_keep]

# # # Experimentation
# shuffle labels for experimentation
#labels$bp_group = sample(labels$bp_group, nrow(labels))

# only keep subset of background/disease for experimentation
#n_sample = 500
#ft_norm = rbind(ft_norm[labels$bp_group == 1, ][1:n_sample, ],
#                ft_norm[labels$bp_group != 1, ])
#labels = rbind(labels[labels$bp_group == 1, ][1:n_sample, ],
#               labels[labels$bp_group != 1, ])

# # # Output
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
