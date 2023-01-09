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

# display message for how many columns new values are being used for
print(sprintf("Number of New Columns Found in Follow Up: %i (Out of %i)",
              sum(visit2_cols != visit1_cols), length(visit1_cols)))

# ------------------------------------------------------------------------------
# Extract Repeat Visit Rows
# ------------------------------------------------------------------------------
# read all new columns from raw ukb
ukb_all = fread(ukb_data_file, header = TRUE, select = visit2_cols)
labels_all = fread(ukb_data_file, header = TRUE, 
                   select = c("eid", "X4080.3.0", "X4079.3.0"))

# load 1st visit patient IDs
labels = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)

# subset rows with patid
ukb2 = ukb_all[labels_all$eid %in% labels$patid, ]
labels2 = labels_all[labels_all$eid %in% labels$patid, ]

# ------------------------------------------------------------------------------
# Pre-Process
# ------------------------------------------------------------------------------
# remove outliers
ukb2 = apply(ukb2, 2, function(x) {
    
                            # compute mean and sd
                            mean_val = mean(x, na.rm = TRUE)
                            std = sd(x, na.rm = TRUE)
                            z_score = abs(x - mean_val)/std
                            
                            # set outliers as NA
                            x[z_score > 10] = NA
                            return(x)
                          
                        })

# find out rows with too many missing data 
print(sprintf("Number of Missing Data Before Filtering is %i (%0.1f%%)",
                      sum(is.na(ukb2)), sum(is.na(ukb2))/prod(dim(ukb2))*100))
row_filter = rowMeans(is.na(ukb2)) <= 0.05

# filter out these rows, also filter out patiend ids
ukb2 = ukb2[row_filter, ]
labels2 = labels2[row_filter, ]
print(sprintf("Number of Missing Data After Filtering is %i (%0.1f%%)",
                      sum(is.na(ukb2)), sum(is.na(ukb2))/prod(dim(ukb2))*100))

# save non-normalized values
fwrite(data.frame(cbind(patid = labels2$eid, ukb2)),
                            file.path(path, "2nd_visit_ukb_num_ft_select.csv"))

# load 1st visit raw values to transfer mean and standard deviation
ukb1 = fread(file.path(path, "ukb_num_ft_select.csv"), 
                                          header = TRUE, select = visit1_cols)

# normalize data with means/sd from previous visit
data_means = colMeans(ukb1, na.rm = TRUE)
data_std   = apply(ukb1, 2, function(x) sd(x, na.rm = TRUE))
ukb2       = sweep(ukb2, 2, data_means, "-")
ukb2       = sweep(ukb2, 2, data_std, "/")

# remove large z scores
ukb2[abs(ukb2) > 10] = NA

# impute data
ukb2 = apply(ukb2, 2, function(x) {
                              x[is.na(x)] = median(x, na.rm = TRUE)
                              return(x)
                          })

# ------------------------------------------------------------------------------
# Write to File
# ------------------------------------------------------------------------------

# write patient ID and blood pressure (similar to pseudotimes.csv)
fwrite(labels2, file.path(path, "2nd_visit_pseudotimes.csv"))

# write normailzied variable values
fwrite(data.frame(ukb2), file.path(path, "2nd_visit_ukb_num_norm_ft_select.csv"))

# display outputs
print(sprintf("Imaging Visit 1: Originally %i Rows and %i Columns",
                                                    nrow(ukb1), ncol(ukb1)))
print(sprintf("Imaging Visit 2: Extracted %i Rows and %i Columns",
                                                    nrow(ukb2), ncol(ukb2)))
print(sprintf("---------- Repeat Visit Data Subset Complete"))
