# load dependencies
library(data.table)

# # # Prepare data
# read data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
ft_raw = data.frame(fread('NeuroPM/io/ukb_num.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')
var_groups = read.csv('NeuroPM/io/var_grouped.csv')

# shuffle dataset to remove bias during cross-validation
set.seed(11111)
ind_rand = sample(1:nrow(labels), nrow(labels))
labels = labels[ind_rand, ]
ft_norm = ft_norm[ind_rand, ]
ft_raw = ft_raw[ind_rand, ]

# compute co-correlation
cor_all = cor(ft_norm)
cor_all[upper.tri(cor_all)] = 0
diag(cor_all) = 0

# filtering out very highly co-correlated variables
ft_norm = ft_norm[, !apply(cor_all, 2, function(x) 
                                any(abs(x) >= 0.95, na.rm = TRUE))]

# # # Reducing Body Composition Variables
# compute contrast covariance
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_disease = cov(ft_norm[labels$bp_group == 2, ])
cov = cov_disease - cov_background
cov[upper.tri(cov)] = NA
diag(cov) = 0

# find body composition varaibles
var_list = var_groups$ukb_var[var_groups$var_group == "Body_Composition"]
var_filter = colnames(ft_norm) %in% var_list

# mask out non-body composition variables
cov[, !var_filter] = NA
cov[!var_filter, ] = NA

# remove high co-correlated variables
ind_keep = unname(apply(cov, 1, function(x)
             !any(abs(x) > sd(cov, na.rm = TRUE) * 1.25, na.rm = TRUE)))

# mask out non-body comp variables
ind_keep[!var_filter] = TRUE

# only keep relevant features
ft_norm = ft_norm[, ind_keep]

# # # Reducing Brain MR Variables
# compute contrast covariance
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_disease = cov(ft_norm[labels$bp_group == 2, ])
cov = cov_disease - cov_background
cov[upper.tri(cov)] = NA
diag(cov) = 0

# find brain variables
var_list = var_groups$ukb_var[var_groups$var_group == "Brain_MR"]
var_filter = colnames(ft_norm) %in% var_list &
             # force brain variables to be kept at the end
             !(colnames(ft_norm) %in% c("X25781.2.0", # WM Hyperintensity
                                        "X25019.2.0", # Hippocampus (Left)
                                        "X25020.2.0") # Hippocampus (Right)
                                        )

# mask out non-brain variables
cov[, !var_filter] = NA
cov[!var_filter, ] = NA

# remove high co-correlated variables
ind_keep = unname(apply(cov, 1, function(x)
             !any(abs(x) > sd(cov, na.rm = TRUE) * 2.25, na.rm = TRUE)))

# mask out non-brain variables
ind_keep[!var_filter] = TRUE

# only keep relevant features
ft_norm = ft_norm[, ind_keep]

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
fwrite(ft_raw, "NeuroPM/io/ukb_num_ft_select.csv")
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
fwrite(labels, "NeuroPM/io/labels_select.csv")
