
# load functions
setwd("modelling")
source("preprocess_utils.R")
setwd("..")

# for exploratory analysis, only get subset rows/columns
#df = fread("../../ukb51139_v2.csv", nrows = 1, skip = 0)
#df = fread("../../ukb51139_v2.csv", select = c("eid", "6150.0.0"))

# load UKB datasets
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../ukb51139_v2.csv",
                                   path_ukb_vars = "../../bb_variablelist.csv")

# save other columns for post-analysis, only keep rows without all NAs
col_list = c("eid",         # ukb patient id
             "X22423.3.0",  # repeat imaging visit: LV stroke volume
             "X22421.3.0",  # repeat imaging visit: LV end diastole volume
             "X25781.3.0",  # repeat imaging visit: white matter hyperintensities
             "X25019.3.0",  # repeat imaging visit: Hippocampus volume (left)
             "X25020.3.0"   # repeat imaging visit: Hippocampus volume (right)
             )
df_future = ukb$ukb_data[, col_list]
df_future = df_future[apply(df_future, 1, function(x) sum(!is.na(x))) > 0, ]
fwrite(df_future, "modelling/NeuroPM/io/future.csv")

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
#fwrite(ukb_df, "../../ukb_subset.csv")

# display output to indicate full ukb dataset subsetting is complete
print(sprintf("UKB Whole Data Subsetting is Complete"))
