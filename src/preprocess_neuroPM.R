library(R.matlab)

return_fractional_df = function(df, N=5000) {
  
  # this function returns a subset of the given data frame in case 
  # we only need a subset, or to reduce computational cost, or if we 
  # simply want to test on a smaller sample. The number sampled will be 
  # provided as input by N. This is mostly used for the neuroPM box
  # preprocessing stage.
  
  # print proportion of class before subsetting
  cat("\n")
  cat(sprintf("Proportion of Each Class Before Subsetting"))
  print(table(df$bp_group)/nrow(df)*100)
  cat("\n")
  
  # create random vector of indices to subset
  set.seed(0633)
  ind = sample(1:nrow(df), N)
  
  # index fraction of data frame
  df = df[ind, ]
  
  # print proportion of class before subsetting
  cat(sprintf("Proportion of Each Class After Subsetting"))
  print(table(df$bp_group)/nrow(df)*100)
  cat("\n")
  
  return(df)
  
}

neuroPM_convert_and_write_df = function(dat, dat_filename) {
  
  # this function writes dataframes/vectors to the format
  # required by the neuroPM toolbox given an input dataframe/matrix
  # and its full path
  
  write.table(formatC(as.matrix(dat), format = "e", digits = 7),
              dat_filename,
              row.names=FALSE, col.names=FALSE, quote=FALSE,
              sep="\t")
  
}

neuroPM_write_all_df = function(df, labels, path) {
  
  # given dataframe from ukb which has been post processed, write to 
  # the path given in the format of the neuroPM box input requirements
  
  neuroPM_convert_and_write_df(df,
                               file.path(path, "cPCA_data.txt"))
  neuroPM_convert_and_write_df(which(labels == 1),
                               file.path(path, "cPCA_background.txt"))
  neuroPM_convert_and_write_df(which(labels == 2),
                               file.path(path, "cPCA_target.txt"))

}

neuroPM_matlab_write_all_df = function(df, labels, path) {
  
  # given a dataframe containing the filtered patient values of the UKB
  # write the entire thing to one .mat output file to read into matlab
  # and run on the matlab source code of the neuroPM toolbox
  writeMat(file.path(path, "ukb_data.mat"), 
           data = as.matrix(df),
           bp_group = labels)
  
}

neuroPM_load_pseudotime_output_df = function(path) {
  
  # read in neuroPM toolbox output and assign column names given the 
  # path to the directory containing the file
  
  pseudotimes = read.table(file.path(
                            path,
                            "cTI_IDs_pseudotimes_pseudopaths_cPCA_data.txt")
                          )
  names(pseudotimes) = c("row.id", "V1_pseudotimes", "traj1", "traj2")
  
  # remove first column as it is only the row name
  pseudotimes = pseudotimes[,-1]
  
  return(pseudotimes)
  
}

merge_pseudotime_with_ukb = function(pseudotime, ukb_df) {
  
  # given the processed pseudotime output from the neuroPM box, merge this
  # with the original UKB data that was inputted so that we can perform
  # futher visualization between the disease progression score and the 
  # various variables in the UKB
  
  df_merged = cbind(pseudotime, ukb_df)
  
  return(df_merged)
  
}