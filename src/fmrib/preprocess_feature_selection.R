# load dependencies
library(data.table)

# load data
ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm.csv'))
labels  = read.csv('NeuroPM/io/labels.csv')

# shuffle dataset to remove bias during cross-validation
ind_rand = sample(1:nrow(labels), nrow(labels))
ft_norm = ft_norm[ind_rand, ]
labels = labels[ind_rand, ]

# remove high co-correlation variables
#cov_all = cov(ft_norm)
#cov_all[upper.tri(cov_all)] = 0
#diag(cov_all) = 0
#ind_filter = !unname(apply(cov_all, 1, function(x) any(abs(x) > 1.0)))
#ft_norm = ft_norm[, ind_filter]

# compute covariance of background/disease population only
cov_background = cov(ft_norm[labels$bp_group == 1, ])
cov_disease = cov(ft_norm[labels$bp_group == 2, ])

# covariance of a subset of background patients (75)
cov_background_subset = cov(ft_norm[sample(which(labels$bp_group == 1), 750), ])

# *** TO DO ***
# identify which features contribute to high covariance
# note that cPCA: cov = cov_d - a * cov_b

# what is the difference between cov_background and cov_background_subset
# which makes the cPCA worse when we add more background patients

# identify which features to keep
keep_cols = rep(TRUE, ncol(ft_norm))

# keep low covariance ones in the patient feature set
ft_norm = ft_norm[, keep_cols]
# *** TO DO ***

# shuffle labels for experimentation
#labels$bp_group = sample(labels$bp_group, nrow(labels))

# only keep subset of background/disease for experimentation
if (FALSE) {
    n_sample = 750
    ft_norm = rbind(ft_norm[labels$bp_group == 1, ][1:n_sample, ],
                    ft_norm[labels$bp_group != 1, ])
    labels = rbind(labels[labels$bp_group == 1, ][1:n_sample, ],
                labels[labels$bp_group != 1, ])
}

# display messages to see in terminal
print(sprintf("Further Filtering Complete"))
print(sprintf("Distribution of Classes is"))
print(table(labels$bp_group))

print(sprintf("The Filtered Data Frame is of Size %0.0f by %0.0f",
              nrow(ft_norm), ncol(ft_norm)))

# write to output
fwrite(ft_norm, "NeuroPM/io/ukb_num_norm_ft_select.csv")
fwrite(labels, "NeuroPM/io/labels_select.csv")
