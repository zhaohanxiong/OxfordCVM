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
visit1_cols_sub = substring(visit1_cols, 1, regexpr("\\.", visit1_cols) - 1)

# find cols 1st visit contain repeat visit
for (i in 1:length(visit1_cols_sub)) {

  # find all related columns in original dataframe
  cols = grep(paste0(visit1_cols_sub[i], "\\."), all_cols, value = TRUE)

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
labels = read.csv(file.path(path, "labels_select.csv"), header = TRUE)
patid = labels[, 1]

# read all new columns from raw ukb
ukb_df = fread(ukb_data_file, header = TRUE, select = visit2_cols)

# subset rows with patid
ukb_df = ukb_df[all_patid %in% patid, ]

# ------------------------------------------------------------------------------
# Pre-Process
# ------------------------------------------------------------------------------
# remove outliers
ukb_df = apply(ukb_df, 2, function(x) {
    
                            # compute mean and sd
                            mean_val = mean(x, na.rm = TRUE)
                            std = sd(x, na.rm = TRUE)
                            z_score = abs(x - mean_val)/std
                            
                            # set outliers as NA
                            x[z_score > 5] = NA
                            return(x)
                          
                        })

# filter out rows with too many missing data and 
row_filter = rowMeans(is.na(ukb_df)) <= 0.05
ukb_df = ukb_df[row_filter, ]
print(sprintf("Number of Missing Data is %0.1f%%",
                                        sum(is.na(ukb_df)/prod(dim(ukb_df)))))

# saw non-normalized values
fwrite(ukb_df, file.path(path, "ukb_num_ft_select_2nd_visit.csv"))

# store patient IDs with sufficient repeat visit information
repeat_patid = patid[row_filter]

# load 1st visit raw values
ukb1 = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"),
                                                              header = TRUE))
ukb1 = ukb1[, visit1_cols]

# normalize data with means/sd from previous visit
data_means = colMeans(ukb1, na.rm = TRUE)
data_std   = apply(ukb1, 2, function(x) sd(x, na.rm = TRUE))
ukb_df     = sweep(ukb_df, 2, data_means, "-")
ukb_df     = sweep(ukb_df, 2, data_std, "/")

# impute data
ukb_df = apply(ukb_df, 2, function(x) {
                                x[is.na(x)] = median(x, na.rm=TRUE)
                                return(x)
                          })

# ------------------------------------------------------------------------------
# Write to File
# ------------------------------------------------------------------------------
fwrite(ukb_df, file.path(path, "ukb_num_norm_ft_select_2nd_visit.csv"))

# display outputs
print(sprintf("---------- Repeat Visit Data Subset Complete"))
print(sprintf("Imaging Visit 1: Originally %i Rows and %i Columns",
              nrow(ukb1), ncol(ukb1)))
print(sprintf("Imaging Visit 2: Extracted %i Rows and %i Columns",
              nrow(ukb_df), ncol(ukb_df)))
print("Distribution of Repeat Imaging Patients Per Blood Pressure Group:")
table(labels$bp_group[labels[, 1] %in% repeat_patid])
