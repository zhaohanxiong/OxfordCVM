
# load functions
library("data.table")
source("preprocess_utils.R")

# 
df = fread("../../../ukb51139.csv")

# write to output
write.csv(ukb_df[, 5:ncol(ukb_df)], "NeuroPM/io/ukb_num.csv", row.names=FALSE)
write.csv(ukb_df[, 1:4], "NeuroPM/io/labels.csv", row.names=FALSE)

