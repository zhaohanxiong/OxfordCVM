library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

# define data path
path = "../modelling/NeuroPM/io/"
ukb_data_file = "../../../ukb51139_v2.csv"

# ------------------------------------------------------------------------------
# Extract Repeat Visit Columns
# ------------------------------------------------------------------------------
# load all columns
all_cols = names(fread(ukb_data_file, nrows = 1, header = TRUE))

# load 1st visit values
visit1_cols = names(fread(file.path(path, "ukb_num_norm_ft_select.csv"),
                          nrows = 1, header = TRUE))

# store a copy of the repeat visit columns using the first column
visit2_cols = visit1_cols

# extract only variable names
visit1_cols = substring(visit1_cols, 1, regexpr("\\.", visit1_cols) - 1)

# find cols 1st visit contain repeat visit
for (i in 1:length(visit1_cols)) {

  # find all related columns in original dataframe
  cols = grep(paste0(visit1_cols[i], "\\."), all_cols, value = TRUE)

  # find if there is instance 3
  repeat_visits = grep("\\.3\\.\\d", cols, value = TRUE)

  # if there is repeat visit, replace the column with the updated one
  if (length(repeat_visits) > 0) {
    
    # if there is more than 1 measurement in the repeat visit
    if (length(repeat_visits) > 1) {

      # query the ukb dataframe
      ukb_cols = fread(ukb_data_file, header = TRUE, select = repeat_visits)
      
      # find which column has the least number of missing values
      index = which.min(apply(ukb_cols, 2, function(x) sum(is.na(x))))

    } else {

      # if there is only one value, then just take the first index
      index = 1

    }

    # update this value in the updated column set
    visit2_cols[i] = repeat_visits[index]

  }

}

# ------------------------------------------------------------------------------
# Extract Repeat Visit Rows
# ------------------------------------------------------------------------------
# load all patient IDs
all_patid = as.list(fread(ukb_data_file, header = TRUE, select = c("eid")))[[1]]

# load 1st visit patient IDs
patid = as.list(fread(file.path(path, "labels_select.csv"), header = TRUE)[, 1])[[1]]

# read all new columns from raw ukb
ukb_df = fread(ukb_data_file, header = TRUE, select = visit2_cols)

# subset rows with patid
ukb_df = ukb_df[all_patid %in% patid, ]

# ------------------------------------------------------------------------------
# Pre-Process
# ------------------------------------------------------------------------------
# filter out rows with too many missing data

# normalize data


# ------------------------------------------------------------------------------
# Write to File
# ------------------------------------------------------------------------------
fwrite(ukb_df, file.path(path, "ukb_num_norm_ft_select_2nd_visit.csv"))

# display outputs
print(sprintf("Repeat Visit Data Subset Complete"))
print(sprintf("Subsetted %i Rows and %i Columns", nrows(ukb_df), ncols(ukb_df)))
