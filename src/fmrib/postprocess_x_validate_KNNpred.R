library(data.table)

# load outputs from NeuroPM
path = "NeuroPM/io"

# set K (for KNN)
K = 10

# load pseudotime scores
pseudotimes_full = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)
pseudotimes_full$err = NA
pseudotimes_full$knn_dist = NA

# load ukb raw variables
ukb_df = data.frame(fread(file.path(path, "ukb_num_norm.csv"), header=TRUE))

# list X validation files
X_val_files = list.files(path)
X_val_files = X_val_files[grepl("pseudotimes_fold", X_val_files)]

# define number of fold used
n_folds = length(X_val_files)

# define row indices for each fold to place into X validation matrix
ind = floor(seq(from = 1, to = nrow(pseudotimes_full), length = n_folds + 1))

# load pseudotime scores for each fold
for (i in 1:n_folds) {
  
  # load file from i'th fold
  pseudotimes = read.csv(file.path(path, paste0("pseudotimes_fold", i, 
                                                ".csv")), header=TRUE)
  
  # create indices for indexing
  ind_i = ind[i]:(ind[i + 1] - (i != n_folds))
  
  # and reference labels and data for inference
  ref_label = pseudotimes_full$global_pseudotimes[-ind_i]
  ref_data = unname(as.matrix(ukb_df[-ind_i, ]))
  
  # extract data to predict
  pred_data = unname(as.matrix(ukb_df[ind_i, ]))

  # create dataframe of ground truth and predictions for disease score
  eval = data.frame(gt = pseudotimes_full$global_pseudotimes[ind_i],
                    pred = 0,
                    knn_dist = 0,
                    group = pseudotimes_full$bp_group[ind_i])
  
  # perform KNN to infer disease score
  for (j in 1:nrow(pred_data)) {
    
    # compute distance with each row
    dist_j = colSums(abs(t(ref_data) - pred_data[j,]), na.rm = TRUE)
    
    # compute KNN and prediction
    sorted_ind = order(dist_j)[1:K]
    eval$pred[j] = mean(ref_label[sorted_ind])
    eval$knn_dist[j] = mean(sort(dist_j)[1:K])
    
  }

  # compute err
  eval$err = sqrt((eval$pred - eval$gt)**2)
  
  # compute sensitivity/specificity
  y_pred = eval$pred[eval$group != 0]
  y_true = ifelse(pseudotimes_full$bp_group[ind_i][pseudotimes_full$
                                                bp_group[ind_i] != 0] == 1,
                  0, 1)
  intervals = seq(0, 1, by = 0.001)
  threshold_mat = sapply(intervals, function(thres)
                                            ifelse(y_pred > thres, 1, 0))
  fpr = apply(threshold_mat, 2, function(x) 
                sum(x == 1 & y_true == 0) / 
                  (sum(x == 1 & y_true == 0) + sum(x == 0 & y_true == 0)))
  tpr = apply(threshold_mat, 2, function(x)
                sum(x == 1 & y_true == 1) / 
                  (sum(x == 1 & y_true == 1) + sum(x == 0 & y_true == 1)))
  opt_ind = which.max(1 - fpr + tpr)
  
  # display summaries, also by group
  print(sprintf("------------------------------ Evaluating Fold %.0f", i))
  print(sprintf("RMSE = %0.3f (N = %.0f)", mean(eval$err), length(ind_i)))
  print(sprintf("Mean by Group:"))
  print(aggregate(eval[, c("err", "knn_dist")], list(eval$group), mean))
  print(sprintf(paste0("Optimal Threshold at %0.3f (Sensitivty = %0.1f%%, ",
                       "Specificity = %0.1f%%)"), 
                intervals[opt_ind], tpr[opt_ind] * 100, (1 - fpr)[opt_ind] * 100))
  
  # append
  pseudotimes_full$err[ind_i] = eval$err
  pseudotimes_full$knn_dist[ind_i] = eval$knn_dist
  
}

# display overall results
print(sprintf(paste0("Overall: %.0f-Fold X-Validation Results in an ",
                     "RMSE of %0.3f"),
              n_folds, mean(pseudotimes_full$err)))
print(sprintf("Mean by Group:"))
print(aggregate(pseudotimes_full[, c("err", "knn_dist")],
                list(pseudotimes_full$bp_group), 
                function(x) mean(x, na.rm = TRUE)))
