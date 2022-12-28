
# load functions
setwd("modelling")
source("preprocess_utils.R")
setwd("..")

# for exploratory analysis, only get subset rows/columns
#df = fread("../../ukb51139_v2.csv", nrows = 1, skip = 0)
#df = fread("../../ukb51139_v2.csv", select = c("eid", "6150.0.0"))

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Quick ETL (Extract, Transform, Load)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# extract few columns for post-analysis
quick_ETL_ukb(path_in = "../../ukb51139_v2.csv",
              path_out = "modelling/NeuroPM/io/future.csv",
              var_list = c("X22423.3.0", # 2nd imaging visit: LV stroke volume
                           "X22421.3.0", # 2nd imaging visit: LV end diastole volume
                           "X25781.3.0", # 2nd imaging visit: white matter hyperintensities
                           "X25019.3.0", # 2nd imaging visit: Hippocampus volume (left)
                           "X25020.3.0"  # 2nd imaging visit: Hippocampus volume (right)
                          ),
              remove_all_missing = TRUE)

# premature quitting if we only want a quick extraction
quit(save = "no")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Selecting specific outcomes before creating the subset
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
file_name = "../../ukb51139_v2.csv"
df = fread(file_name, nrows = 1)
df_patid = fread(file_name, nrows = Inf, select = c("eid"))
df_death = fread(file_name, nrows = Inf, select = grep("X40000.|X40010.",names(df),value=TRUE))
df_heartattack = fread(file_name, nrows = Inf, select = grep("X3894.",names(df),value=TRUE))
df_stroke = fread(file_name, nrows = Inf, select = grep("X4056.",names(df),value=TRUE))
df_angina = fread(file_name, nrows = Inf, select = grep("X3627.",names(df),value=TRUE))
df_LVEF = fread(file_name, nrows = Inf, select = grep("X24103.",names(df),value=TRUE))

df_outcomes = cbind(df_patid,df_death,df_heartattack,df_stroke,df_angina,df_LVEF)

fwrite(df_outcomes, "modelling/NeuroPM/io/ukb_outcomes.csv")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Preprocessing and subsetting whole UKB dataset
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# load whole UKB datasets + variable name list
ukb = load_raw_ukb_patient_dataset(path_ukb_data = "../../ukb51139_v2.csv",
                                   path_ukb_vars = "../../bb_variablelist.csv")

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
ukb_df = ukb_df[(!is.na(ukb_df$`BPSys-2.0`)) &
                (!is.na(ukb_df$`BPDia-2.0`)), ]

# display subset dataframe size
print(sprintf("Subset Data Frame is of Size %0.0f by %0.0f",
              nrow(ukb_df), ncol(ukb_df)))

# clean dataset of rows with too many missing values (less than 5% data)
ukb_df = ukb_df[rowMeans(is.na(ukb_df)) < 0.95, ]

# write to output (data & labels)
fwrite(ukb_df, "../../ukb_subset.csv")

# display output to indicate full ukb dataset subsetting is complete
print(sprintf("UKB Whole Data Subsetting is Complete"))
