
# load functions
source("preprocess_utils.R")

# load UKB datasets
# these datsets have to be located directly outside the base dir (OxfordCVM)
# which is tracked by git
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../../bb_data.csv",
                                   path_ukb_vars = "../../../bb_variablelist.csv")

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

# remove outliers
ukb_df[, 2:ncol(ukb_df)] = return_remove_outlier(data =
                                                    ukb_df[, 2:ncol(ukb_df)])

# clean dataset of rows/columns with too many missing values
ukb_df = return_clean_df(df = ukb_df,
                         threshold_col = 0.5,
                         threshold_row = 0.05)

# remove rows with missing blood pressure values
ukb_df = ukb_df[(!is.na(ukb_df$`BPSys-2.0`)) & (!is.na(ukb_df$`BPDia-2.0`)),]

# get corresponding vector of labels depending on criteria background (1), 
# target (2), between (0). The first 5 columns are now ID/label columns
# to omit during further processing
ukb_df = return_ukb_target_background_labels(df_subset = ukb_df,
                                             target_criteria = "> 140/80")

# impute data
ukb_df[, 5:ncol(ukb_df)] = return_imputed_data(data = ukb_df[, 5:ncol(ukb_df)],
                                               method = "mean")

# mean and standard deviation normalization for all feature columns (from 5th)
ukb_df[, 5:ncol(ukb_df)] = return_normalize_zscore(data = 
                                                      ukb_df[, 5:ncol(ukb_df)])

# write to output
write.csv(ukb_df[, 5:ncol(ukb_df)], "NeuroPM/io/ukb_num.csv", row.names=FALSE)
write.csv(ukb_df[, 1:4], "NeuroPM/io/labels.csv", row.names=FALSE)
