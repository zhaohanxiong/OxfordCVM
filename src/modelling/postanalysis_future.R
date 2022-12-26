library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

# define data path
path = "NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)

# load 1st visit values
ukb = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"), header = TRUE))

# load 2nd visit values
future = read.csv(file.path(path, "future.csv"), header = TRUE)

# keep only variable name for ease of comparison between two data frames
ukb_cols    = substring(colnames(ukb), 2, regexpr("\\.", colnames(ukb)) - 1)
ukb_cols    = ukb_cols[ukb_cols != ""]
future_cols = substring(colnames(future), 2, regexpr("\\.", colnames(future)) - 1)
future_cols = future_cols[future_cols != ""]

# merge data frames into one
df = cbind(scores, ukb[, ukb_cols %in% future_cols])
df = merge(df, future, by.x = "patid", by.y = "eid")

# 
