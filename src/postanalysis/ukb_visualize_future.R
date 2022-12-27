library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

# define data path
path = "../modelling/NeuroPM/io/"

# ------------------------------------------------------------------------------
# Prepare Data
# ------------------------------------------------------------------------------
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

# clear memory
rm("ukb", "scores", "future")

# ------------------------------------------------------------------------------
# Aggregate Data for Plots
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Produce Plots
# ------------------------------------------------------------------------------
# perform
change = df$X22421.2.0 - df$X22421.3.0
plot(df$global_pseudotimes, change)

df_plot = aggregate(list(y = cut(df$global_pseudotimes,breaks = seq(0, 1,length = 11))),
                    by = list(x = df$global_pseudotimes),
                    function(x) mean(x, na.rm = TRUE))
