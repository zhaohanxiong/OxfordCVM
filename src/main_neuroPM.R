
# load functions
source("preprocess_filter_dataset.R")
source("preprocess_neuroPM.R")

# load UKB datasets
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../bb_data.csv",
                                   path_ukb_vars = "../../bb_variablelist.csv")

# extract UKB columns (variables) we want to keep
ukb_filtered_cols = get_ukb_subset_column_names(df = ukb$ukb_data,
                                                df_vars = ukb$ukb_vars,
                                                subset_option = "brain")

# extract UKB dataset rows (patients) we want to keep
ukb_filtered_rows = get_ukb_subset_rows(df = ukb$ukb_data,
                                        subset_option = "all")

# subset UKB dataframe based on row/column filters, and remove missing
ukb_df = return_cols_rows_filter_df(df = ukb$ukb_data,
                                    cols = ukb_filtered_cols,
                                    rows = ukb_filtered_rows)
#rm(ukb) # delete UKB variable from workspace to save RAM

# clean dataset of rows/columns with too many missing values
ukb_df = return_clean_df(df = ukb_df,
                         threshold_col = 0.5,
                         threshold_row = 0.05)

# get corresponding vector of labels depending on criteria
# background (1), target (2), between (0)
ukb_df = return_ukb_target_background_labels(df_subset = ukb_df,
                                             target_criteria = "> 140/80")

# reduce computational cost by only taking a fraction of whole dataset
ukb_df_small = return_fractional_df(ukb_df, N = 1000)

# write files out for input into neuroPM box
if (FALSE) {
  
  # convert and write into neuroPM toolbox inputs files (3 files)
  neuroPM_write_all_df(df = ukb_df_small[,5:ncol(ukb_df_small)], # from 5th column
                       labels = ukb_df_small$bp_group,
                       path = "../../NeuroPM_cPCA_files")
  
  # convert and write into .mat file for matlab source code of neuroPM box
  neuroPM_matlab_write_all_df(df = ukb_df_small[,5:ncol(ukb_df_small)], # from 5th column
                              labels = ukb_df_small$bp_group,
                              path = "../../NeuroPM_cPCA_files")

}

# load output from neuroPM box for the pseudotimes (disease progression scores)
pseudotimes = neuroPM_load_pseudotime_output_df(path = "../../NeuroPM_cPCA_files/subset run")

##### NeuroPM box method overview
# compute neighborhood variance
# perform cPCA
# calculate pseudotime score using MST

# functions to visualize output
source("postprocess_visualization.R")

# merge pseudotime dataframe with ukb input into the neuroPM box
ukb_final_df = merge_pseudotime_with_ukb(pseudotime = pseudotimes,
                                         ukb_df = ukb_df_small)

# visualizations
plot_boxplot_by_group(data = ukb_final_df, 
                      y = ukb_final_df$V1_pseudotimes,
                      group = ukb_final_df$bp_group,
                      title = "Disease Progression by Blood Pressure Group",
                      xlab = "Blood Pressure Groups", ylab = "Disease Score",
                      labels = c("Between", "Background", "Disease"))


##### Random PCA methods
# compute pca
pca_out = prcomp(ukb_df_small[, 5:ncol(ukb_df_small)], 
                 center = TRUE, scale = TRUE)

screeplot(pca_out, type = "l", npcs = 150, log = "y")
abline(h = 1, col="red", lty=5)

# plot principle components
colours = rep(0,nrow(ukb_df_small))
colours[ukb_df_small$bp_group==0] = "blue"
colours[ukb_df_small$bp_group==1] = "green"
colours[ukb_df_small$bp_group==2] = "red"
plot(pca_out$x[,1], pca_out$x[,2],
     xlab="PC1", ylab = "PC2",
     col = colours, pch = 19)

# compute cPCA
library(scPCA)

cpca_out = scPCA(target = ukb_df_small[,5:ncol(ukb_df_small)],
                 background = ukb_df_small[ukb_df_small$bp_group == 2,
                                           5:ncol(ukb_df_small)],
                 penalties = 0, # run cPCA if this = 0
                 n_centers = 3)

scpca_out = scPCA(target = ukb_df_small[, 5:ncol(ukb_df_small)],
                  background = ukb_df_small[ukb_df_small$bp_group == 2,
                                            5:ncol(ukb_df_small)],
                  penalties = exp(seq(log(0.01), log(0.5), length.out = 10)),
                  n_centers = 3)

# plot principle components
cpca_out = cbind(cpca_out$x, ukb_df_small$bp_group)

plot(cpca_out[,1], cpca_out[,2],
     xlab="PC1", ylab = "PC2",
     col = colours, pch = 19)
