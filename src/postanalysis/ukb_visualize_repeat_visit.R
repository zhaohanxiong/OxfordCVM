library(tools)
library(ggplot2)
library(R.matlab)
library(gridExtra)
library(data.table)

var_i = 1

# define columns of interest (visit 1 and 2) to this dataframe
analyze = c("X22423", # LV stroke volume
            "X22421", # LV end diastole volume
            "X25781", # white matter hyperintensities
            "X25019", # Hippocampus volume (left)
            "X25020") # Hippocampus volume (right)
analyze_names = c("LV SV",
                  "LV EDV",
                  "WM Hyperintensity",
                  "Hippocampus Volume (Left)",
                  "Hippocampus Volume (Right)")

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

# filter out ill-defined scores
ind = (scores$bp_group != 0)

# subset reference matrix rows based on new row index filter
PC_ukb1 = PC_ukb1[ind, ]
gt      = gt[ind]

# transform visit 2 data into PC space
PC_ukb2 = unname(as.matrix(ukb2_norm)) %*% PC_transform

# compute distance with each row
pred = apply(PC_ukb2, 1, function(p)
                                gt[which.min(rowMeans((PC_ukb1**2 - p**2)**0.5))])

# create dataframe for this score
pred = data.frame(patid = ukb2$eid, global_pseudotimes2 = pred)

# ------------------------------------------------------------------------------
# Merge Data For Analysis
# ------------------------------------------------------------------------------
# append 1st imaging visit values to original hyper score df
scores_analyze = cbind(scores, ukb1[, sapply(analyze, function(s) 
                                        grep(s, colnames(ukb1), value = TRUE))])

# append 2nd imaging visit values to original hyper score df
pred_analyze = cbind(pred, ukb2[, sapply(analyze, function(s)
                                        grep(s, colnames(ukb2), value = TRUE))])

# merge 2nd visit hyper scores into the 1st visit dataframe
follow_up = merge(scores_analyze, pred_analyze, by.x = "patid", by.y = "patid") 

# ------------------------------------------------------------------------------
# Produce Basic Plots for Score Distribution
# ------------------------------------------------------------------------------
# change blood pressure groups into a ordered factor for plotting
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
# define 2 variable columns to analyze
var_1st = grep(paste0(analyze[var_i], "\\.2\\."),
               colnames(follow_up), value = TRUE)
var_2nd = grep(paste0(analyze[var_i], "\\.3\\."),
               colnames(follow_up), value = TRUE)

# subset and remove missing values
df_plot = follow_up[, c("global_pseudotimes", "global_pseudotimes2",
                        var_1st, var_2nd)]
df_plot = df_plot[!is.na(df_plot[, var_1st]) & !is.na(df_plot[, var_2nd]), ]

# convert from wide to long format for the 2 variables
df_plot = data.frame(score = c(df_plot$global_pseudotimes, df_plot$global_pseudotimes),
                     var   = c(df_plot[, var_1st], df_plot[, var_2nd]),
                     visit = as.factor(rep(c("1st", "2nd"), each = nrow(df_plot))))
df_plot$score = cut(df_plot$score, breaks = seq(0, 1, length = 11))

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
                        toTitleCase(analyze_names[var_i]))) +
        ylab(toTitleCase(analyze_names[var_i])) + 
        xlab("Hyper Score") +
        scale_fill_brewer(palette = "Dark2") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

p2 = ggplot(df_plot2, aes(x = x, y = y, group = visit, color = visit)) + 
        geom_point(size = 7.5, alpha = 0.25) +
        geom_smooth(orientation = "x", span = 15,
                    linewidth = 2, se = FALSE, fullrange = TRUE) +
        ggtitle(sprintf("%s vs Hyper Score (1st & 2nd Visit)",
                        toTitleCase(analyze_names[var_i]))) +
        ylab(sprintf("%s (averaged per interval)", toTitleCase(analyze_names[var_i]))) + 
        xlab("Hyper Score [0-1]") +
        scale_color_brewer(palette = "Dark2") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# start offline plot
png("plots/temp_follow_up.png", width = 1200, height = 600)

# mutli-plot
grid.arrange(p1, p2, ncol = 2)

# stop offline plot
dev.off()
