# load dependencies
library(data.table)

# # # Prepare data
# read data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')
var_groups = read.csv('NeuroPM/io/var_grouped.csv')

# # # only keep latest instance of each variable (or instance 2)
# sort by ascending such that instance 0 comes first
varnames = sort(colnames(ft_norm))

# filter out all instance information from variable names
v_names = ifelse(grepl("\\.", varnames),
                 substring(varnames, 1, regexpr("\\.", varnames)-1),
                 varnames)

# find and remove duplicates (first instance after sorting)
varnames = varnames[!duplicated(v_names, fromLast = TRUE)]
ft_norm = ft_norm[, varnames]

# shuffle dataset to remove bias during cross-validation
set.seed(125)
ind_rand = sample(1:nrow(labels), nrow(labels))
ft_norm = ft_norm[ind_rand, ]
labels = labels[ind_rand, ]

# # # Filtering Body Composition Variables
# compute contrast covariance
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_disease = cov(ft_norm[labels$bp_group == 2, ])
cov = cov_disease - cov_background
diag(cov) = 0

# find body composition varaibles
var_list = var_groups$ukb_var[var_groups$var_group == "Body_Composition"]
var_filter = colnames(ft_norm) %in% var_list

# mask out body composition variables
cov[, !var_filter] = NA
cov[!var_filter, ] = NA

# remove high co-correlated variables
ind_keep = unname(apply(cov, 1, function(x)
             !any(abs(x) > sd(cov, na.rm = TRUE) * 1.25, na.rm = TRUE)))

# mask out body comp variables
ind_keep[!var_filter] = TRUE

# only keep relevant features
ft_norm = ft_norm[, ind_keep]

# # # Filtering Brain MR Variables
# compute contrast covariance
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_disease = cov(ft_norm[labels$bp_group == 2, ])
cov = cov_disease - cov_background
cov[upper.tri(cov)] = NA
diag(cov) = 0

# find brain variables
var_list = var_groups$ukb_var[var_groups$var_group == "Brain_MR"]
var_filter = colnames(ft_norm) %in% var_list

# mask out brain variables
cov[, !var_filter] = NA
cov[!var_filter, ] = NA

# remove high co-correlated variables
ind_keep = unname(apply(cov, 1, function(x)
             !any(abs(x) > sd(cov, na.rm = TRUE) * 2.25, na.rm = TRUE)))

# mask out brain variables
ind_keep[!var_filter] = TRUE

# only keep relevant features
ft_norm = ft_norm[, ind_keep]

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
