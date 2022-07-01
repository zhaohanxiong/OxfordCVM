# load outputs from NeuroPM
path = "NeuroPM/io/"

# load pseudotime scores
pseudotimes_full = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)

# list X validation files
X_val_files = list.files(path)
X_val_files = X_val_files[grepl("pseudotimes_fold", X_val_files)]

# define number of fold used
n_folds = length(X_val_files)

# initialize matrix of scores
pseudotime_mat = matrix(NA, nrow = nrow(pseudotimes_full), ncol = n_folds)

# define row indices for each fold to place into X validation matrix
ind = floor(seq(from = 1, to = nrow(pseudotimes_full), length = n_folds + 1))

# load pseudotime scores for each fold
for (i in 1:n_folds) {
  
  # load file from i'th fold
  pseudotimes = read.csv(file.path(path, paste0("pseudotimes_fold",i,".csv")), header=TRUE)
  
  # create indices for indexing
  ind_i = ind[i]:(ind[i + 1] - (i != n_folds))
  
  # assign values to matrix with negative indexing
  pseudotime_mat[-ind_i ,i] = pseudotimes$global_pseudotimes
  
}

# perform row-wise analysis to evaluate stability of scores
# root mean squared variation
mean_rms = apply(pseudotime_mat, 1, function(x) sqrt(mean(x^2, na.rm = TRUE)))
mean_rms_confint = unname(quantile(mean_rms, c(0.025, 0.975)))

# standard deviation variation
mean_sd = apply(pseudotime_mat, 1, function(x) sd(x, na.rm = TRUE))
mean_sd_confint = unname(quantile(mean_sd, c(0.025, 0.975)))

# display outputs (raw values)
print(sprintf("\n----------- Evaluating Stability of Disease Scores (Between Folds)"))
print(sprintf("Root Mean Squared Error is: %0.2f +- %0.2f [%0.2f, %0.2f]",
              mean(mean_rms), sd(mean_rms), mean_rms_confint[1], mean_rms_confint[2]))
print(sprintf("Mean Standard Deviation is: %0.2f +- %0.2f [%0.2f, %0.2f]",
              mean(mean_sd), sd(mean_sd), mean_sd_confint[1], mean_sd_confint[2]))

# root mean squared variation from complete run
mean_rms = sapply(1:nrow(pseudotimes_full), function(i) sqrt(mean((pseudotime_mat[i,] - pseudotimes_full$global_pseudotimes[i])^2, na.rm = TRUE)))
mean_rms_confint = unname(quantile(mean_rms, c(0.025, 0.975)))

# standard deviation variation
mean_sd = sapply(1:nrow(pseudotimes_full), function(i) sd(pseudotime_mat[i,] - pseudotimes_full$global_pseudotimes[i], na.rm = TRUE))
mean_sd_confint = unname(quantile(mean_sd, c(0.025, 0.975)))

# display outputs (raw values)
print(sprintf("\n----------- Evaluating Stability of Disease Scores (Against Full Run)"))
print(sprintf("Root Mean Squared Error is: %0.2f +- %0.2f [%0.2f, %0.2f]",
              mean(mean_rms), sd(mean_rms), mean_rms_confint[1], mean_rms_confint[2]))
print(sprintf("Mean Standard Deviation is: %0.2f +- %0.2f [%0.2f, %0.2f]",
              mean(mean_sd), sd(mean_sd), mean_sd_confint[1], mean_sd_confint[2]))
