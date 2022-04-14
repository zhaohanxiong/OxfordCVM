
# load dependencies
library(data.table)

# define helper functions to isolate memory usage
read_file = function(path) {

    # read data using fast method
    df = fread(path)

    # convert into data frame (for ease of manipulation)
    df = data.frame(df)

    return(df)

}

clean_NAs = function(data) {

    # keep columns with under 50% missing data
    data = data[, colMeans(is.na(data)) <= 0.5]

    # keep rows with under 5% missing data
    data = data[rowMeans(is.na(data)) <= 0.05, ]

    return(data)

}

# read data using fast method
df = read_file("../../../ukb51139.csv")

# print information regarding outputs
print(sprintf("Percentage of Missing Data Before Filtering %0.1f%%",
              sum(is.na(df))/prod(dim(df))*100))
print(sprintf("Data Frame is of Size %0.0f by %0.0f", nrow(df), ncol(df)))

# get cols here (make sure BP and Record ID is in here somewhere)

# remove NAs
df = clean_NAs(df)

# print information regarding outputs
print(sprintf("Percentage of Missing Data After Filtering %0.1f%%",
              sum(is.na(df))/prod(dim(df))*100))
print(sprintf("Data Frame is of Size %0.0f by %0.0f", nrow(df), ncol(df)))

# write to output using fast method
fwrite(df[1:100000,], "../../../ukb51139_subset_1.csv")
fwrite(df[100001:200000,], "../../../ukb51139_subset_2.csv")
fwrite(df[200001:300000,], "../../../ukb51139_subset_3.csv")
fwrite(df[300001:400000,], "../../../ukb51139_subset_4.csv")
fwrite(df[400000:nrow(df),], "../../../ukb51139_subset_5.csv")

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