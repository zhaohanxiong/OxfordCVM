
# load functions
source("preprocess_utils.R")

# load UKB datasets
# these datsets have to be located directly outside the base dir (OxfordCVM)
# which is tracked by git
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../../ukb51139_subset.csv",
                                   path_ukb_vars = "../../../bb_variablelist.csv")

# extract UKB columns (variables) we want to keep
ukb_filtered_cols = get_ukb_subset_column_names(df = ukb$ukb_data,
                                                df_vars = ukb$ukb_vars,
                                                subset_option = "all")

# extract UKB dataset rows (patients) we want to keep
ukb_filtered_rows = get_ukb_subset_rows(df = ukb$ukb_data,
                                        subset_option = "all") #no heart attack, angina, stroke

# subset UKB dataframe based on row/column filters, and remove missing
ukb_df = return_cols_rows_filter_df(df = ukb$ukb_data,
                                    cols = ukb_filtered_cols,
                                    rows = ukb_filtered_rows)

# remove initial variable to clear memory
rm(ukb)

# display final dataframe size
print(sprintf("Subset Data Frame is of Size %0.0f by %0.0f",
                                                    nrow(ukb_df), ncol(ukb_df)))

# clean dataset of rows/columns with too many missing values
ukb_df = return_clean_df(df = ukb_df,
                         threshold_row1 = 0.95, threshold_col = 0.5,
                         threshold_row2 = 0.05,
                         char_cols = c(1))

# remove outliers
ukb_df[, 2:ncol(ukb_df)] = return_remove_outlier(data =
                                                    ukb_df[, 2:ncol(ukb_df)])

# remove rows with missing blood pressure values
ukb_df = ukb_df[(!is.na(ukb_df$`BPSys-2.0`)) & (!is.na(ukb_df$`BPDia-2.0`)),]

# display claned dataframe size
print(sprintf("Cleaned Data Frame is of Size %0.0f by %0.0f",
                                                    nrow(ukb_df), ncol(ukb_df)))

# get corresponding vector of labels depending on criteria background (1), 
# target (2), between (0). The first 5 columns are now ID/label columns
# to omit during further processing
ukb_df = return_ukb_target_background_labels(df_subset = ukb_df,
                                             target_criteria = "> 160/100")

# impute data
ukb_df[, 5:ncol(ukb_df)] = return_imputed_data(data = ukb_df[, 5:ncol(ukb_df)], 
                                               method = "median")

# mean and standard deviation normalization for all feature columns (from 5th)
ukb_df[, 5:ncol(ukb_df)] = return_normalize_zscore(data = 
                                                      ukb_df[, 5:ncol(ukb_df)])

# display final dataframe size
print(sprintf("Final Data Frame is of Size %0.0f by %0.0f", 
                                                    nrow(ukb_df), ncol(ukb_df)))
print(sprintf("Final Number of Missing Data: %0.f", sum(is.na(ukb_df))))

# write to output
fwrite(ukb_df[, 5:ncol(ukb_df)], "NeuroPM/io/ukb_num.csv")
fwrite(ukb_df[, 1:4], "NeuroPM/io/labels.csv")
