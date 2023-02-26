# load functions
source("preprocess_utils.R")

# load UK Biobank dataset
# these datsets have to be located directly outside the base dir (OxfordCVM)
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../../ukb_subset.csv",
                                   path_ukb_vars = "../../../bb_variablelist.csv")

# display initial dataframe size
print(sprintf("Initial Data Frame is of Size %0.0f by %0.0f",
                                        nrow(ukb$ukb_data), ncol(ukb$ukb_data)))

# extract UKB columns (variables) we want to keep
ukb_column_output = get_ukb_subset_column_names(df = ukb$ukb_data,
                                                df_vars = ukb$ukb_vars,
                                                subset_option = "all")

ukb_filtered_cols = ukb_column_output$vars
ukb_grouped_cols = ukb_column_output$var_df

# write grouped variable headings extracted to output
write.csv(ukb_grouped_cols, "NeuroPM/io/var_grouped.csv", row.names = FALSE)

# extract UKB dataset rows (patients) we want to keep
ukb_filtered_rows = get_ukb_subset_rows(df = ukb$ukb_data,
                                subset_option = "no heart attack, angina, stroke")

# subset UKB dataframe based on row/column filters, and remove missing
ukb_df = return_cols_rows_filter_df(df = ukb$ukb_data,
                                    cols = ukb_filtered_cols,
                                    rows = ukb_filtered_rows)

# define specific variables for certain filters
ukb_df = return_collate_variables(ukb_df)

# free up memory
rm(ukb)

# display subset dataframe size
print(sprintf("Subset Data Frame is of Size %0.0f by %0.0f",
                                                    nrow(ukb_df), ncol(ukb_df)))

# remove outliers
ukb_df[, 2:ncol(ukb_df)] = return_remove_outlier(data =
                                                    ukb_df[, 2:ncol(ukb_df)])

# clean dataset of rows/columns with too many missing values
ukb_df = return_clean_df(df = ukb_df, threshold_col = 0.5, threshold_row = 0.05,
                         ignore_cols = c(1))

# remove rows with missing blood pressure values
ukb_df = ukb_df[(!is.na(ukb_df$`BPSys-2.0`)) & (!is.na(ukb_df$`BPDia-2.0`)),]

# display cleaned dataframe size
print(sprintf("Cleaned Data Frame is of Size %0.0f by %0.0f",
                                                    nrow(ukb_df), ncol(ukb_df)))

# write raw dataframe to file so we can check pre-normalization values
fwrite(ukb_df[, 5:ncol(ukb_df)], "NeuroPM/io/ukb_num.csv")

print(grep("21000", colnames(ukb_df), value = TRUE))
table(ukb_df[, c("X21000.2.0")])
print(aggregate(list(y = ukb_df[, c("21000-2.0")]), by = list(ukb_df[, c("31-0.0")]), "length"))
quit(save="no")
# get corresponding vector of labels depending on criteria background (1), 
# target (2), between (0). The first 4 columns are now ID/label columns
# to omit during further processing
ukb_df = return_ukb_target_background_labels(df_subset = ukb_df,
                                             target_criteria = "> 160/100")

# display the assigned patients per group
print("Distribution of Patients Per Group")
print(table(ukb_df$bp_group))

# remove columns which contain the same value
ukb_df = return_remove_single_value_columns(data = ukb_df)

# write to output (imaging centres)
loc_var = "54-2.0"
loc = data.frame(loc_var = ukb_df[, loc_var])
fwrite(loc, "NeuroPM/io/loc.csv")

# mean and standard deviation normalization for all feature columns (from 5th)
ukb_df[, 6:ncol(ukb_df)] = return_normalize_zscore(data = 
                                                     ukb_df[, 6:ncol(ukb_df)])

# further filtering outliers
ukb_df[, 6:ncol(ukb_df)] = return_remove_large_zscores(ukb_df[, 6:ncol(ukb_df)], 
                                                       sd_threshold = 5)

# impute data
ukb_df[, 6:ncol(ukb_df)] = return_imputed_data(data = ukb_df[, 6:ncol(ukb_df)], 
                                               method = "median")

# filter again to remove low standard deviation variables
ukb_df = cbind(ukb_df[, 1:5], 
               return_remove_low_sd(data = ukb_df[, 6:ncol(ukb_df)]))

# write to output (covariates)
cov = return_covariates(ukb_df, covariate = c("31-0.0", "21003-2.0"))
fwrite(cov, "NeuroPM/io/cov.csv")

# remove columns which we dont want influence the model
ukb_df = edit_ukb_columns(ukb_df, 
            #keep_cols = c("31-0.0", "21003-2.0"),
            remove_cols = c("bp_sys_", "bp_dia_",                      # blood pressure (all)
                            "12675", "12698", "^93-", "4079",          # dia BP
                            "12674", "12677", "12697", "^94-", "4080", # sys BP
                            "bp_medication", "6153", "6177",           # medication (all)
                            "events", "6150",                          # events (all)
                            "^54-0.0", "^54-1.0", "^54-2.0", "^54-3.0" # centre location
                            )
          )

# remove duplicate variable instances
ukb_df = cbind(ukb_df[, 1:5], 
               remove_ukb_duplicate_instances(data = ukb_df[, 6:ncol(ukb_df)]))

# display final dataframe size
print(sprintf("Final Data Frame is of Size %0.0f by %0.0f", 
                                                    nrow(ukb_df), ncol(ukb_df)))
print(sprintf("Final Number of Missing Data: %0.f", sum(is.na(ukb_df))))
print(sprintf("Final Distribution is E(x) = %0.3f +- %0.3f [%0.3f, %0.3f]",
                   mean(as.matrix(ukb_df[, 6:ncol(ukb_df)])),
                   sd(as.matrix(ukb_df[, 6:ncol(ukb_df)])),
                   min(ukb_df[, 6:ncol(ukb_df)]),max(ukb_df[, 6:ncol(ukb_df)])))

# display number of rows after sampling
print(sprintf("Subset Data Frame is of Size %0.0f by %0.0f", 
                                                    nrow(ukb_df), ncol(ukb_df)))

# convert label variables from numeric to string
ukb_df$Sex = ifelse(ukb_df$Sex == 1, "Male", "Female")

# write to output (data & labels)
write.csv(ukb_df[, 1:5], "NeuroPM/io/labels.csv", row.names = FALSE)
fwrite(ukb_df[, 6:ncol(ukb_df)], "NeuroPM/io/ukb_num_norm.csv")

# print ending message
cat(sprintf("---------- Initial Data Extraction Complete"))
cat("\n")
