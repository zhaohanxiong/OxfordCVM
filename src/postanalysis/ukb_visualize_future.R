library(tools)
library(ggplot2)
library(R.matlab)
library(gridExtra)
library(data.table)

# ------------------------------------------------------------------------------
# Load Data
# ------------------------------------------------------------------------------
# define data path
path = "../modelling/NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)

# load 1st visit values
ukb1 = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"), 
                                                                header = TRUE))
ukb1_norm = data.frame(fread(file.path(path, "ukb_num_norm_ft_select.csv"), 
                                                                header = TRUE))

# load 2nd visit values
ukb2 = data.frame(fread(file.path(path, "ukb_num_ft_select_2nd_visit.csv"), 
                                                                header = TRUE))
ukb2_norm = data.frame(fread(file.path(path, "ukb_num_norm_ft_select_2nd_visit.csv"), 
                                                                header = TRUE))

# load transformation matrix into PC space
PC_transform = readMat(file.path(path, "PC_Transform.mat"))$Node.Weights

# ------------------------------------------------------------------------------
# Perform KNN Prediction
# ------------------------------------------------------------------------------
# prepare reference dataset from visit 1
PC_ukb1 = unname(as.matrix(ukb1_norm)) %*% PC_transform
gt = scores$global_pseudotime

# only keep obvious scores with good separation
#ind = (ref_label < (min_disease * 5) | ref_label > (max_background * 0.25)) & (ref_group != 0)

# compute subset index of which have well defined disease scores
f1 = quantile(scores$global_pseudotimes[scores$bp_group == 1], 0.25)
f2 = quantile(scores$global_pseudotimes[scores$bp_group == 2], 0.5)

# filter out ill-defined scores
ind = (scores$global_pseudotimes <= f1 |
       scores$global_pseudotimes >= f2) & (scores$bp_group != 0)

# subset reference matrix rows based on new row index filter
PC_ukb1 = PC_ukb1[ind, ]
gt      = gt[ind]

# transform visit 2 data into PC space
PC_ukb2 = unname(as.matrix(ukb2_norm)) %*% PC_transform

# compute distance with each row
pred = apply(PC_ukb2, 1, function(p)
                gt[which.min(rowMeans(abs(PC_ukb1 - p)))])

# create dataframe for this score
pred = data.frame(patid = ukb2$eid, global_pseudotimes2 = pred)

# ------------------------------------------------------------------------------
# Merge Data For Analysis
# ------------------------------------------------------------------------------
# add columns of interest (visit 1 and 2) to this dataframe
analyze = c("X22423", # LV stroke volume
            "X22421", # LV end diastole volume
            "X25781", # white matter hyperintensities
            "X25019", # Hippocampus volume (left)
            "X25020")  # Hippocampus volume (right)

# append 1st imaging visit values to original hyper score df
scores_analyze = cbind(scores, ukb1[, sapply(analyze, function(s) grep(s, colnames(ukb1), value = TRUE))])

# append 2nd imaging visit values to original hyper score df
pred_analyze = cbind(pred, ukb2[, sapply(analyze, function(s) grep(s, colnames(ukb2), value = TRUE))])

# merge 2nd visit hyper scores into the 1st visit dataframe
follow_up = merge(scores_analyze, pred_analyze, by.x = "patid", by.y = "patid") 

# ------------------------------------------------------------------------------
# Produce Basic Plots for Score Distribution
# ------------------------------------------------------------------------------

follow_up$bp_group = ordered(follow_up$bp_group, c(1, 0, 2))

# generate plot for predicted vs ground truth distribution
png(file.path("plots/temp_1st_2nd_visit_scores.png"), width = 600, height = 600)

# create subplots
par(mfrow = c(1, 2))
boxplot(follow_up$global_pseudotimes ~ follow_up$bp_group,
        main = "1st Imaging Visit Hyper Scores",
        xlab = "Blood Pressure Group", ylab = "Disease Score",
        col = c("tomato", "lawngreen", "deepskyblue"),
        ylim = c(0, 1))
boxplot(follow_up$global_pseudotimes2 ~ follow_up$bp_group,
        main = "2nd Imaging Visit Hyper Scores",
        xlab = "Blood Pressure Group", ylab = "Disease Score",
        col = c("tomato", "lawngreen", "deepskyblue"),
        ylim = c(0, 1))

# close plot
dev.off()

quit(save = "no")

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
