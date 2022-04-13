
# load dependencies
library(data.table)

# read data using fast method
df = fread("../../../ukb51139.csv")

# convert into data frame (for ease of manipulation)
df = data.frame(df)

# convert empties into missing value (gives memory error)
#df[df == ""] = NA

# print information regarding outputs
print(sprintf("Percentage of Missing Data Before Filtering %0.1f%%",
              sum(is.na(df))/prod(dim(df))*100))
print(sprintf("Number of Samples Before Filtering %0.0f", nrow(df)))

# keep columns with under 50% missing data
df = df[, colMeans(is.na(df)) <= 0.5]

# keep rows with under 5% missing data
df = df[rowMeans(is.na(df)) <= 0.05, ]

# print information regarding outputs
print(sprintf("Percentage of Missing Data After Filtering %0.1f%%",
              sum(is.na(df))/prod(dim(df))*100))
print(sprintf("Number of Samples After Filtering %0.0f", nrow(df)))

# write to output using fast method
fwrite(df, "../../../ukb51139_subset.csv")
