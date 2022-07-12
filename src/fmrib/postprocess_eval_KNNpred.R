library(data.table)

# load outputs from NeuroPM
path = "NeuroPM/io/"

# load pseudotime scores
pseudotimes_full = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)

# load ukb raw variables
ukb_df = data.frame(fread(file.path(path, "ukb_num.csv"), header=TRUE))

# list X validation files
X_val_files = list.files(path)
X_val_files = X_val_files[grepl("pseudotimes_fold", X_val_files)]

# define number of fold used
n_folds = length(X_val_files)

# define row indices for each fold to place into X validation matrix
ind = floor(seq(from = 1, to = nrow(pseudotimes_full), length = n_folds + 1))

# store outputs
err_all = rep(NA, n_folds)
acc_all = rep(NA, n_folds)

# load pseudotime scores for each fold
for (i in 1:n_folds) {
  
  # load file from i'th fold
  pseudotimes = read.csv(file.path(path, paste0("pseudotimes_fold",i,".csv")), header=TRUE)
  
  # create indices for indexing
  ind_i = ind[i]:(ind[i + 1] - (i != n_folds))
  
  # and reference labels and data for inference
  ref_label = pseudotimes_full$global_pseudotimes[-ind_i]
  ref_data = unname(as.matrix(ukb_df[-ind_i, ]))
  
  # extract data to predict
  pred_data = unname(as.matrix(ukb_df[ind_i, ]))

  # create dataframe of ground truth and predictions for disease score
  eval = data.frame(gt = pseudotimes_full$global_pseudotimes[ind_i],
                    pred = NA,
                    group = pseudotimes_full$bp_group[ind_i])
  
  # set K (for KNN)
  K = 10
  
  # perform KNN to infer disease score
  for (j in 1:nrow(pred_data)) {

    # compute distance with each row
    dist_j = colSums(abs(t(ref_data) - pred_data[j,]), na.rm = TRUE)
    
    # compute KNN and prediction
    sorted_ind = order(dist_j)[1:K]
    eval$pred[j] = mean(ref_label[sorted_ind])
    
  }
  
  # compute err and accuracy
  eval$mse = sqrt((eval$pred - eval$gt)**2)
  err = mean(eval$mse)
  acc = (1 - err) * 100
  
  # append 
  err_all[i] = err
  acc_all[i] = err
  
  # display summaries, also by group
  sprintf(paste0("Fold %.0f: Predictions were %0.3f from the Ground",
                 " Truth (Accuracy = %0.1f%%, N = %.0f)"),
          i, err, acc, length(ind_i))
  sprintf("Mean by Group:")
  print(aggregate(eval$mse, list(eval$bp_group), mean))
  
}

sprintf(paste0("Overall: %.0f-Fold X-Validation Results in an ",
               "Average Error of %0.2f (Accuracy = %0.1f%%)"),
        n_folds, mean(err_all), mean(acc_all))
