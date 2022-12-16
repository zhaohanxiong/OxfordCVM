
# load functions
source("preprocess_utils.R")

# load UKB datasets
# these datsets have to be located directly outside the base dir (OxfordCVM)
# to add new ukb dataset, just change the first input argument below
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../ukb51139_v2.csv",
                                   path_ukb_vars = "../../bb_variablelist.csv")

# for exploratory analysis, only get one row/column
#df = fread("../../../ukb51139.csv", nrows = 1)
#df = fread("../../../ukb51139.csv", select = c("6150-0.0"))

# display initial dataframe size
print(sprintf("Initial Data Frame is of Size %0.0f by %0.0f",
                                        nrow(ukb$ukb_data), ncol(ukb$ukb_data)))

# extract UKB columns (variables) we want to keep
ukb_column_output = get_ukb_subset_column_names(df = ukb$ukb_data,
                                                df_vars = ukb$ukb_vars,
                                                subset_option = "all")

# extract UKB dataset rows (patients) we want to keep
ukb_filtered_rows = get_ukb_subset_rows(df = ukb$ukb_data,
                                        subset_option = "all")

# subset UKB dataframe based on row/column filters, and remove missing
ukb_df = return_cols_rows_filter_df(df = ukb$ukb_data,
                                    cols = ukb_column_output$vars,
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
fwrite(ukb_df, "../../ukb_subset.csv")

# display output to indicate full ukb dataset subsetting is complete
print(sprintf("UKB Whole Data Subsetting is Complete"))
