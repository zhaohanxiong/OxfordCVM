library(tools)
library(ggplot2)
library(R.matlab)
library(gridExtra)
library(data.table)

# define data path
path = "../modelling/NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)

# load 1st visit values
ukb1 = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"), 
                                                                header = TRUE))

# load 2nd visit values
ukb2 = data.frame(fread(file.path(path, "ukb_num_ft_select_2nd_visit.csv"), 
                                                                header = TRUE))
ukb2_norm = data.frame(fread(file.path(path, "ukb_num_norm_ft_select_2nd_visit.csv"), 
                                                                header = TRUE))

# load transformation matrix into PC space
PC_transform = readMat(file.path(path, "PC_Transform.mat"))$eig.mat





ref_data = unname(as.matrix(ukb_df[-ind_i, ])) %*% PC_transform

# compute subset index of which have well defined disease scores
max_background = max(pseudotimes$global_pseudotimes[
                                          pseudotimes$bp_group == 1])
min_disease = min(pseudotimes$global_pseudotimes[
                                          pseudotimes$bp_group == 2])

# filter out ill-defined scores tune these two numbers below depending 
# on distribution to improve results
new_ind_i = (ref_label < (min_disease * 5) | 
              ref_label > (max_background * 0.25)) & (ref_group != 0)
#new_ind_i = c(which(ref_group == 1),
#              sample(which(ref_group == 2), sum(ref_group == 1)))

# subset rows based on new row index filter
ref_label = ref_label[new_ind_i]
ref_group = ref_group[new_ind_i]
ref_data = ref_data[new_ind_i, ]

# extract data to predict
pred_data = unname(as.matrix(ukb_df[ind_i, ]))

# do this one at a time to demonstrate speed/applicability
pred_PC = (pred_data[j,] %*% PC_transform)[1,]

# compute distance with each row
dist_j = rowMeans(t(abs(t(ref_data) - pred_PC)), na.rm = TRUE)

# compute KNN and prediction
sorted_ind = order(dist_j)[1:K]
eval$pred[j] = sum(ref_label[sorted_ind])/K


#Run KNN on new set to make prediction for new score
#Combine new and old pseudo times dataframe
#Perform analysis between these 2 scores for important variables

quit(save = "no")

# define variable to view
var_i = 1

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
df$score = cut(df$global_pseudotimes, breaks = seq(0, 0.5, length = 11))
df = df[!is.na(df$score), ]

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
f = paste0("X", future_cols[var_i])
f_name = weights$name[grep(f, weights$Var1)]

# define 2 variable columns to analyze
var_1st = paste0(f, ".2.0")
var_2nd = paste0(f, ".3.0")

# subset and remove missing values
df_plot = df[, c("score", var_1st, var_2nd)]
df_plot = df_plot[!is.na(df_plot[, var_1st]) & !is.na(df_plot[, var_2nd]), ]

# convert from wide to long format for the 2 variables
df_plot = data.frame(score = as.factor(rep(df_plot$score, 2)),
                     var   = c(df_plot[, var_1st], df_plot[, var_2nd]),
                     visit = as.factor(rep(c("first", "repeat"), each = nrow(df_plot))))

# aggregate by interval means, convert intervals back to numeric (mid-point)
df_plot2 = aggregate(list(y = df_plot$var),
                     by = list(x = df_plot$score, visit = df_plot$visit),
                     "mean")

# ------------------------------------------------------------------------------
# Produce Plots
# ------------------------------------------------------------------------------
# produce plots
p1 = ggplot(df_plot, aes(x = score, y = var, fill = visit)) + 
        geom_boxplot() +
        ggtitle(sprintf("%s vs Hyper Score (1st & 2nd Visit)",
                        toTitleCase(f_name))) +
        ylab(toTitleCase(f_name)) + 
        xlab("Hyper Score") +
        scale_fill_brewer(palette = "Dark2") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

p2 = ggplot(df_plot2, aes(x = x, y = y, group = visit, color = visit)) + 
        geom_point(size = 7.5, alpha = 0.25) +
        geom_smooth(orientation = "x", span = 15,
                    linewidth = 2, se = FALSE, fullrange = TRUE) +
        ggtitle(sprintf("%s vs Hyper Score (1st & 2nd Visit)",
                        toTitleCase(f_name))) +
        ylab(sprintf("%s (averaged per interval)", toTitleCase(f_name))) + 
        xlab("Hyper Score [0-1]") +
        scale_color_brewer(palette = "Dark2") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# start offline plot
png("plots/temp_future.png", width = 1200, height = 600)

# mutli-plot
grid.arrange(p1, p2, ncol = 2)

# stop offline plot
dev.off()
