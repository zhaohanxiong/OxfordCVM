
# load functions
source("preprocess_filter_dataset.R")
source("preprocess_neuroPM.R")
source("postprocess_visualization.R")

# load UKB datasets
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../bb_data.csv",
                                   path_ukb_vars = "../../bb_variablelist.csv")

# extract UKB columns (variables) we want to keep
ukb_filtered_cols = get_ukb_subset_column_names(df = ukb$ukb_data,
                                                df_vars = ukb$ukb_vars,
                                                subset_option = "all")

# extract UKB dataset rows (patients) we want to keep
ukb_filtered_rows = get_ukb_subset_rows(df = ukb$ukb_data,
                                        subset_option = "all")

# subset UKB dataframe based on row/column filters, and remove missing
ukb_df = return_cols_rows_filter_df(df = ukb$ukb_data,
                                    cols = ukb_filtered_cols,
                                    rows = ukb_filtered_rows)
#rm(ukb) # delete UKB variable from workspace to save RAM

# clean dataset of rows/columns with too many missing values
ukb_df = return_clean_NA_from_df(df = ukb_df,
                                 threshold_col = 0.5,
                                 threshold_row = 0.05)

# get corresponding vector of labels depending on criteria
ukb_df = return_ukb_target_background_labels(df_subset = ukb_df,
                                             target_criteria = "> 160/100")

# write files out for input into neuroPM box
if (FALSE) {
  # reduce computational cost by only taking a fraction of whole dataset
  ukb_df_small = return_fractional_df(ukb_df, N = 5000)

  # convert and write into neuroPM toolbox inputs files (3 files)
  neuroPM_write_all_df(ukb_df_small[,5:ncol(ukb_df_small)], # from 5th column
                       labels = ukb_df_small$bp_group,
                       path = "../../NeuroPM_cPCA_files")
}

# load output from neuroPM box for the pseudotimes (disease progression scores)
pseudotimes = neuroPM_load_pseudotime_output_df(path = "../../NeuroPM_cPCA_files/fulldata cardiac run")

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

##### NeuroPM box method overview
# compute neighborhood variance
# functions to perform cPCA http://www.bioconductor.org/packages/devel/bioc/vignettes/scPCA/inst/doc/scpca_intro.html
# calculate pseudotime score using MST