
# load functions
source("preprocess_filter_dataset.R")

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
ukb_df = return_cols_rows_filter_dataset(df = ukb$ukb_data,
                                         cols = ukb_filtered_cols,
                                         rows = ukb_filtered_rows)
#rm(ukb) # delete UKB variable from workspace to save RAM

# clean dataset of rows/columns with too many missing values
ukb_df = return_clean_NA_from_df(df = ukb_df,
                                 threshold_col = 0.5,
                                 threshold_row = 0.05)

# get corresponding vector of labels depending on criteria
bp_group = get_ukb_target_background_labels(df_subset = ukb_df,
                                            target_criteria = "> 140/80")

# # use function to convert into neuroPM toolbox inputs (3 files)

# compute neighborhood variance
# # 

# functions to perform cPCA
# # #http://www.bioconductor.org/packages/devel/bioc/vignettes/scPCA/inst/doc/scpca_intro.html


# calculate pseudotime score
# # 