
# load functions
source("preprocess_utils.R")

# load UKB datasets
# these datsets have to be located directly outside the base dir (OxfordCVM)
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../../ukb51139.csv",
                                   path_ukb_vars = "../../../bb_variablelist.csv")

# display initial dataframe size
print(sprintf("Initial Data Frame is of Size %0.0f by %0.0f",
                                        nrow(ukb$ukb_data), ncol(ukb$ukb_data)))

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

# free up memory
rm(ukb)

# remove rows with missing blood pressure values
ukb_df = ukb_df[(!is.na(ukb_df$`BPSys-2.0`)) & (!is.na(ukb_df$`BPDia-2.0`)),]

# display subset dataframe size
print(sprintf("Subset Data Frame is of Size %0.0f by %0.0f",
                                                    nrow(ukb_df), ncol(ukb_df)))

# clean dataset of rows with too many missing values (less than 5% data)
ukb_df = ukb_df[rowMeans(is.na(ukb_df)) < 0.95, ]

# write to output (data & labels)
fwrite(ukb_df, "../../../ukb51139_subset.csv")