
setDTthreads(8)

# load functions
source("preprocess_utils.R")

clean_NAs = function(data) {

  # keep columns with under 50% missing data
  data = data[, colMeans(is.na(data)) <= 0.5]
  
  # keep rows with under 5% missing data
  data = data[rowMeans(is.na(data)) <= 0.05, ]

  return(data)

}

# read data
df = load_raw_ukb_patient_dataset(path_ukb_data = "../../../ukb51139.csv",
                                  path_ukb_vars = "../../../bb_variablelist.csv")[[1]]

# print information regarding outputs
print(sprintf("Percentage of Missing Data Before Filtering %0.1f%%",
              sum(is.na(df))/prod(dim(df))*100))
print(sprintf("Data Frame is of Size %0.0f by %0.0f", 
              nrow(df), ncol(df)))

# remove NAs
df = clean_NAs(df)

# print information regarding outputs
print(sprintf("Percentage of Missing Data After Filtering %0.1f%%",
              sum(is.na(df))/prod(dim(df))*100))
print(sprintf("Data Frame is of Size %0.0f by %0.0f", 
              nrow(df), ncol(df)))

# write to output
f = seq(1, by = 100000, to = nrow(df))

for (i in 1:length(f)) {
  if (i < length(f)) { # for the first n - 1 files
    fwrite(df[f[i]:(f[i]+100000), ],
           paste0("../../../ukb51139_subset_", i, ".csv"))
  } else { # for the last file
    fwrite(df[f[i]:ncol(df), ],
           paste0("../../../ukb51139_subset_", i, ".csv"))    
  }
}

# combining the files above into a single data frame (processing) done
# in steps as the memory cannot allocate the required memory to both
# read and write the massive data tables
write_final_output = function() {

    # this function simply takes the 5 output files produced above, combines
    # it into one data frame, and writes it to a single file

    # read individual outputs from prior code, concatenate into one data frame
    dat_1 = fread("../../../ukb51139_subset_1.csv")
    dat_2 = fread("../../../ukb51139_subset_2.csv")
    dat_3 = fread("../../../ukb51139_subset_3.csv")
    dat_4 = fread("../../../ukb51139_subset_4.csv")
    dat_5 = fread("../../../ukb51139_subset_5.csv")

    # concatenate and write to file
    dat_out = rbind(dat_1, dat_2, dat_3, dat_4, dat_5)

    dat_out = data.frame(dat_out)
    
    # write to output
    fwrite(dat_out, "../../../ukb51139_subset.csv", row.names = FALSE)

}

#write_final_output()