
# load dependencies
library("data.table")

# helpfer functions
isolate_batch_data = function(path, start_at = 1) {
  
  # this function uses the fread function to load a large table into memory
  # given the path of the data. this line of code was isolated into a local
  # environment to ensure that memory is cleaned up after every run to
  # ensure there is no memory leakage between batches.
  # you also have to specify at what row of the table u wish to read from for
  # batching
  
  data = fread(path, sep = ",", header = TRUE, nrows = 10000, skip = start_at)
  
  return(data)
  
}

remove_na_data = function(data) {
  
  # this function removes columns and rows with a majority of NAs. The 
  # threshold for removing a row/column can be pre-set
  
  
###### FIGURE OUT data.table syntax
  
  # remove date columns
  
  
  # remove character columns
  
  
  
  # keep columns with under 50% missing data
  data = data[, colMeans(is.na(data)) <= 0.5 | ]
  
  # keep rows with under 5% missing data
  data = data[rowMeans(is.na(data)) <= 0.05, ]
  
  return(data)
  
}

# temporary arrays to see how many empty values are present in the dataset
na_before = c()
na_after = c()
rows_after = c()

# initialize counter variables for while loop
batch_size = 10000
rows_count = batch_size
counter = 1

while (rows_count == batch_size) {
  
  # read batch into memory
  # find how many rows were found, if less than 10k, next loop with stop
  df = isolate_batch_data("../../ukb51139.csv", start_at = counter)
  rows_count = nrow(df)
   
  # store number of missing values before cleaning
  na_before = c(na_before, sum(is.na(df))/prod(dim(df)))
  
  # remove columns/rows with a lot of missing values
  df = remove_na_data(df)
  
  # store number of missing values after cleaning
  na_after = c(na_after, sum(is.na(df))/prod(dim(df)))

  # write data frame to file
  fwrite(df, sprintf("C:/Users/zxiong/Desktop/temp/ukb%03.0f.csv", counter))
  
  # store number of rows left
  rows_after = c(rows_after, nrow(df))
  
  # increment counter variable
  counter = counter + batch_size
  
}

# display how much reduction in rows there were
print(sprintf("Number of Rows Reduced from %.0f to %.0f", 
                      batch_size*(counter-1)+rows_count, sum(rows_after)))
