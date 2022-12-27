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

# load variable weighting outputs
weights = read.csv(file.path(path, "var_weighting.csv"),
                   header = TRUE, stringsAsFactor = FALSE)

# keep only variable name for ease of comparison between two data frames
ukb_cols    = substring(colnames(ukb), 2, regexpr("\\.", colnames(ukb)) - 1)
ukb_cols    = ukb_cols[ukb_cols != ""]
future_cols = substring(colnames(future), 2, regexpr("\\.", colnames(future)) - 1)
future_cols = future_cols[future_cols != ""]

# merge data frames into one
df = cbind(scores, ukb[, ukb_cols %in% future_cols])
df = merge(df, future, by.x = "patid", by.y = "eid")
df$score = cut(df$global_pseudotimes,breaks = seq(0, 1,length = 11))

# clear memory
rm("ukb", "scores", "future")

# ------------------------------------------------------------------------------
# Preprocess Data for Outliers
# ------------------------------------------------------------------------------
# Iterate through all variable columns
for (i in grep("X[0-9]{1,10}\\.[0-9]\\.[0-9]", colnames(df))) {
  
  # compute quantiles  
  qs = unname(quantile(df[, i], prob = c(0.25, 0.5, 0.75), na.rm = TRUE))
  iqr = qs[3] - qs[1]

  # set values outside range as outliers
  df[, i][df[, i] < qs[1] - 2*iqr | df[, i] > qs[3] + 2*iqr] = NA
  
}

# ------------------------------------------------------------------------------
# Aggregate Data for Plots
# ------------------------------------------------------------------------------
# iterate through all variables to analyze
f = paste0("X", future_cols[2])
f_name = weights$name[grep(f, weights$Var1)]

# define 2 variable columns to analyze
var_1st = paste0(f, ".2.0")
var_2nd = paste0(f, ".3.0")

# subset and remove missing values
df_plot = df[, c("score", var_1st, var_2nd)]
df_plot = df_plot[!is.na(df_plot[, var_1st]) & !is.na(df_plot[, var_2nd]), ]

# convert from wide to long format for the 2 variables and aggregate
df_plot = data.frame(score = as.factor(rep(df_plot$score, 2)),
                     var   = c(df_plot[, var_1st], df_plot[, var_2nd]),
                     visit = as.factor(rep(c("first", "repeat"), each = nrow(df_plot))))
#df_plot = aggregate(list(y = df_plot$var),
#                    by = list(x = df_plot$score, visit = df_plot$visit),
#                    "mean")

# convert hyperscore intervals back to numeric (mid-point)
#df_plot$x = sapply(strsplit(gsub("\\(|\\]", "", df_plot$x), ","), 
#                   function(x) mean(as.numeric(x)))

# compute statistical significance between columns
#ttest = t.test(df_plot$y[df_plot$visit == "first"],
#               df_plot$y[df_plot$visit == "repeat"],
#               alternative = "two.sided")
#sprintf("%s has P-Value = %0.3f in Visit 1 vs 2", f, ttest$p.value)

# ------------------------------------------------------------------------------
# Produce Plots
# ------------------------------------------------------------------------------
# produce plot
#ggplot(df_plot, aes(x = x, y = y, group = visit, color = visit)) + 
#    geom_point(size = 7.5, alpha = 0.25) +
#    geom_smooth(orientation = "x", span = 15,
#                linewidth = 2, se = FALSE, fullrange = TRUE) +
#    ggtitle(sprintf("%s (First & Repeat Imaging Visit) vs Hyper Score",
#                    toTitleCase(f_name))) +
#    ylab(toTitleCase(f_name)) + 
#    xlab("Hyper Score [0-1]") +
#    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
#          plot.title = element_text(size = 15, face = "bold"))
ggplot(df_plot, aes(x = score, y = var, fill = visit)) + 
    geom_boxplot() +
    ggtitle(sprintf("%s vs Hyper Score (1st & 2nd Visit)",
                    toTitleCase(f_name))) +
    ylab(toTitleCase(f_name)) + 
    xlab("Hyper Score Range") +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
          plot.title = element_text(size = 15, face = "bold"))



# start offline plot
#png("plots/temp_1st_vs_2nd_visit.png", width = 1200, height = 1200)

# mutli-plot
#grid.arrange(p1, p2, p3, ncol = 2)

# stop offline plot
#dev.off()