
# load functions
source("preprocess_filter_dataset.R")
source("preprocess_ml.R")

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
ukb_df = return_clean_df(df = ukb_df,
                         threshold_col = 0.5,
                         threshold_row = 0.05)

# get corresponding vector of labels depending on criteria (1 = background,
# 2 = disease, 0 = between)
ukb_df = return_ukb_target_background_labels(df_subset = ukb_df,
                                             target_criteria = "> 160/100")

# split the data by data and labels
ukb_split = split_ukb_into_data_label(ukb_df)

# normalize data
ukb_norm = normalize_dataset(ukb_split$data)

# split datainto train test
dat = split_train_test(df_data = ukb_norm, 
                       df_label = ukb_split$label$bp_group,
                       test_percentage = 0.1)

# train inference model
library(class)
pr = knn(dat$train_dat, dat$test_dat, cl = dat$train_lab, k = 13)

# test
tab = table(pr, dat$test_lab)
acc = sum(diag(tab)/(sum(rowSums(tab)))) * 100