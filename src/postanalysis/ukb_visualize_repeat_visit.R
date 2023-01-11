library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)
suppressMessages(library(R.matlab))

var_i = 1

# define columns of interest (visit 1 and 2) to this dataframe
analyze = c("X22423", # LV stroke volume
            "X22421", # LV end diastole volume
            "X25781", # white matter hyperintensities
            "X25019", # Hippocampus volume (left)
            "X25020") # Hippocampus volume (right)
analyze_names = c("LV Stroke Volume",
                  "LV End Diastolic Volume",
                  "White Matter Hyperintensity",
                  "Hippocampus Volume (Left)",
                  "Hippocampus Volume (Right)")

# ------------------------------------------------------------------------------
# Load Data
# ------------------------------------------------------------------------------
# define data path
path = "../modelling/NeuroPM/io/"

# load data
scores1 = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)
scores2 = read.csv(file.path(path, "2nd_visit_pseudotimes.csv"), header = TRUE)

# load 1st visit values
ukb1 = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"), 
                                                                header = TRUE))
ukb1_norm = data.frame(fread(file.path(path, "ukb_num_norm_ft_select.csv"), 
                                                                header = TRUE))

# load 2nd visit values
ukb2 = data.frame(fread(file.path(path, "2nd_visit_ukb_num_ft_select.csv"), 
                                                                header = TRUE))
ukb2_norm = data.frame(fread(file.path(path, "2nd_visit_ukb_num_norm_ft_select.csv"), 
                                                                header = TRUE))

# load transformation matrix into PC space
PC_transform = readMat(file.path(path, "PC_Transform.mat"))$Node.Weights

# ------------------------------------------------------------------------------
# Perform KNN Prediction
# ------------------------------------------------------------------------------
# prepare reference dataset from visit 1
PC_ukb1 = unname(as.matrix(ukb1_norm)) %*% PC_transform

# transform visit 2 data into PC space
PC_ukb2 = unname(as.matrix(ukb2_norm)) %*% PC_transform

# create dataframe for this score
pred = data.frame(patid = ukb2$patid, global_pseudotimes2 = NA)

# define number of K for KNN, also transpose ref matrix
K = 25
PC_ukb1_transpose = t(PC_ukb1)

# loop through each row and predict score 
for (i in 1:nrow(pred)) {
        
     # only use same bp group as current patient for reference
     group_i = scores1$bp_group[scores1$patid == pred$patid[i]]
     g_ind = scores1$bp_group == group_i
     
     # compute KNN
     diff  = t(PC_ukb2[i, ] - PC_ukb1_transpose[, g_ind])
     dist  = rowMeans(abs(diff))
     top_k = scores1$global_pseudotimes[g_ind][order(dist)[1:K]]
     
     # store result
     pred$global_pseudotimes2[i] = mean(top_k)
        
}

# ------------------------------------------------------------------------------
# Merge Data For Analysis
# ------------------------------------------------------------------------------
# append 1st imaging visit values to original hyper score df
scores_analyze = cbind(scores1, ukb1[, sapply(analyze, function(s) 
                                        grep(s, colnames(ukb1), value = TRUE))])

# append 2nd imaging visit values to original hyper score df
pred_analyze = cbind(pred, ukb2[, sapply(analyze, function(s)
                                        grep(s, colnames(ukb2), value = TRUE))])

# merge 2nd visit hyper scores into the 1st visit dataframe
follow_up = merge(scores_analyze, pred_analyze, by.x = "patid", by.y = "patid") 

# change blood pressure groups into a ordered factor for plotting
groups = c("Between", "Healthy", "Disease")
follow_up$bp_group = ordered(groups[follow_up$bp_group + 1], groups[c(2, 1, 3)])

# normalize scores to same range
follow_up$global_pseudotimes2 = follow_up$global_pseudotimes2 - 
          min(follow_up$global_pseudotimes2) + min(follow_up$global_pseudotimes)
follow_up$global_pseudotimes2 = follow_up$global_pseudotimes2 / 
          max(follow_up$global_pseudotimes2) * max(follow_up$global_pseudotimes)

# ------------------------------------------------------------------------------
# Aggregate Data for Plots
# ------------------------------------------------------------------------------
# define 2 variable columns to analyze
var_1st = grep(paste0(analyze[var_i], "\\.2\\."),
               colnames(follow_up), value = TRUE)
var_2nd = grep(paste0(analyze[var_i], "\\.3\\."),
               colnames(follow_up), value = TRUE)

# subset and remove missing values
df_plot = follow_up[, c("bp_group", "global_pseudotimes", "global_pseudotimes2",
                        var_1st, var_2nd)]

# convert from wide to long format for the 2 variables
df_plot1 = data.frame(score = c(df_plot$global_pseudotimes,
                                df_plot$global_pseudotimes2),
                      var   = c(df_plot[, var_1st], df_plot[, var_2nd]),
                      group = rep(df_plot$bp_group, 2),
                      visit = as.factor(rep(c("1st", "2nd"),
                                            each = nrow(df_plot))))

# clean data frame for missing values
df_plot2 = df_plot[!is.na(df_plot[, var_1st]) & !is.na(df_plot[, var_2nd]), ]

# filter dataframe for outliers
return_non_outliers = function(x) {
        lq = quantile(x, 0.25)
        uq = quantile(x, 0.75)
        iqr = uq - lq
        return(x >= lq - 1.5*iqr & x <= uq + 1.5*iqr)
}
df_plot2 = df_plot2[return_non_outliers(df_plot2[, var_1st]), ]
df_plot2 = df_plot2[return_non_outliers(df_plot2[, var_2nd]), ]

# compute averages per hyper score interval for the variables
df_plot3 = df_plot1[!is.na(df_plot1$var), ]
df_plot3$score_int = cut(df_plot3$score, breaks = seq(0, 1, length = 21))
df_plot3 = aggregate(list(y = df_plot3$var),
                     by = list(x = df_plot3$score_int, visit = df_plot3$visit),
                     "mean")
df_plot3$x = sapply(strsplit(gsub("\\(|\\]", "", df_plot3$x), ","), 
                    function(x) mean(as.numeric(x)))

# ------------------------------------------------------------------------------
# Statistical Analysis for Change in Visit 1 vs 2 for Variable & Score
# ------------------------------------------------------------------------------
# extract training data for hyper score and variable at visit 1
x = scores_analyze[!is.na(scores_analyze[, var_1st]), c("global_pseudotimes")]
y = scores_analyze[!is.na(scores_analyze[, var_1st]), c(var_1st)]

# aggregate data into intervals for smoother fit into model
data = aggregate(list(y = y), 
                 by = list(x = cut(x, breaks = seq(0, 1, length = 21))),
                 "mean")
data$x = sapply(strsplit(gsub("\\(|\\]", "", data$x), ","), 
                function(x) mean(as.numeric(x)))

# fit loess model for interval-averaged var vs hyperscore intervals
model = loess(y ~ x, data = data, span = 1, 
              se = TRUE, control = loess.control(surface = "direct"))

# use model to predict visit 1 fitted to the loess curve
y1_fit = predict(model, 
                 newdata = data.frame(x = follow_up$global_pseudotimes))

# use model to predict variable givven hyper score in visit 2
y2_pred = predict(model,
                  newdata = data.frame(x = follow_up$global_pseudotimes2))

# since we are using an interval-averaged model, we want to apply the change
# of the hyperscore (from visit 1 to 2) with the corresponding expected change
# in the variable value (visit 1) to the variable at visit 2 given we know
# the anticipated change from the fitted loess curve
y2_pred = follow_up[, var_1st] + y2_pred - y1_fit

# create data frame for plotting, add terms, and clean df
df_plot4 = data.frame(var_true = follow_up[, var_2nd],
                      var_pred = y2_pred)
df_plot4$err = abs(df_plot4$var_pred - df_plot4$var_true) / df_plot4$var_true
df_plot4$avg = (df_plot4$var_true + df_plot4$var_pred) / 2
df_plot4$diff = df_plot4$var_true - df_plot4$var_pred
df_plot4 = df_plot4[!is.na(df_plot4$var_true) & !is.na(df_plot4$var_pred), ]

# ------------------------------------------------------------------------------
# Produce Output Visualizations
# ------------------------------------------------------------------------------
# produce plots
p1 = ggplot(df_plot1, aes(y = score, x = group, fill = visit)) + 
        geom_boxplot() +
        ggtitle("1st & 2nd Imaging Visit Hyper Scores") +
        ylab("Hyper Score") + 
        xlab("Blood Pressure Group") +
        theme(plot.title = element_text(size = 15, face = "bold"))

p2 = ggplot(df_plot, aes(x = global_pseudotimes, y = global_pseudotimes2)) + 
        geom_point(size = 7.5, alpha = 0.1, color = "black") +
        geom_smooth(method = "lm", linewidth = 2, se = TRUE, color = "yellow") +
        ggtitle("Hyperscore Comparison (Imaging Visit 1 vs 2)") +
        xlab("Hyperscore Computed at Visit 1 (2014+)") + 
        ylab("Hyperscore Estimated at Visit 2 (2019+)") + 
        coord_cartesian(xlim = range(df_plot$global_pseudotimes),
                        ylim = range(df_plot$global_pseudotimes2)) +
        theme(plot.title = element_text(size = 15, face = "bold"))

# start offline plot, arrange multi-plot, then close plot
png("plots/Validation_FollowUpHyperscore.png", width = 1250, height = 750)
grid.arrange(p1, p2, ncol = 2, widths = c(1, 2))
dev.off()

# produce plots
p1 = ggplot(df_plot2, aes(x = df_plot2[, var_1st], y = df_plot2[, var_2nd])) + 
        geom_point(size = 7.5, alpha = 0.25, color = "black") +
        geom_smooth(method = "lm", linewidth = 2, se = TRUE, color = "yellow") +
        ggtitle(sprintf("%s Comparison (Imaging Visit 1 vs 2)",
                        toTitleCase(analyze_names[var_i]))) +
        xlab("Imaging Visit 1 (2014+)") + 
        ylab("Imaging Visit 2 (2019+)") + 
        theme(plot.title = element_text(size = 20, face = "bold"),
              axis.text = element_text(size = 15),
              axis.title = element_text(size = 15, face = "bold"))

p2 = ggplot(df_plot3, aes(x = x, y = y, colour = visit)) + 
        geom_point(size = 7.5, alpha = 0.25) +
        geom_smooth(span = 25, linewidth = 2, se = FALSE, fullrange = TRUE) +
        ggtitle(sprintf("%s vs Hyper Score (Imaging Visit 1 vs 2))",
                        toTitleCase(analyze_names[var_i]))) +
        xlab("Hyper Score (Split into Fixed Intervals)") + 
        ylab(sprintf("%s", toTitleCase(analyze_names[var_i]))) + 
        scale_fill_brewer(palette = "Dark2") +
        theme(plot.title = element_text(size = 20, face = "bold"),
              axis.text = element_text(size = 15),
              axis.title = element_text(size = 15, face = "bold"))

p3 = ggplot(df_plot4, aes(x = var_true, y = var_pred)) + 
        geom_point(size = 7.5, alpha = 0.5, color = "violet") +
        geom_smooth(method = "lm", linewidth = 2, se = TRUE, color = "yellow") +
        ggtitle(sprintf("Accuracy of Hyper Score for Inferring %s (Visit 2)",
                        toTitleCase(analyze_names[var_i]))) +
        xlab(sprintf("True Value of %s",
                     toTitleCase(analyze_names[var_i]))) +
        ylab(sprintf("Hyper Score-Inferred Value of %s",
                     toTitleCase(analyze_names[var_i]))) +
        theme(plot.title = element_text(size = 20, face = "bold"),
              axis.text = element_text(size = 15),
              axis.title = element_text(size = 15, face = "bold"))

mean_diff = mean(df_plot4$diff)
sd_diff = sd(df_plot4$diff) * 1.05
u_bound = mean_diff + (1.96 * sd_diff)
l_bound = mean_diff - (1.96 * sd_diff)
yy = round(abs(diff(range(df_plot4$diff))) * 0.02)

p4 = ggplot(df_plot4, aes(x = avg, y = diff)) +
        geom_point(size = 7.5, alpha = 0.1) +
        geom_hline(yintercept = mean_diff,
                   colour = "deepskyblue2", linewidth = 3) +
        annotate("text",
                 x = max(df_plot4$avg), y = mean_diff + c(yy, -yy),
                 label = c("Mean:", sprintf("%.3f", mean_diff)),
                 size = 8, hjust = 1, colour = "deepskyblue3") +
        geom_hline(yintercept = l_bound, colour = "tomato1", linewidth = 3) +
        annotate("text",
                 x = max(df_plot4$avg), y = l_bound + c(yy, -yy),
                 label = c("-1.96SD:", sprintf("%.1f", l_bound)),
                 size = 8, hjust = 1, colour = "tomato3") +
        geom_hline(yintercept = u_bound, colour = "tomato", linewidth = 3) +
        annotate("text",
                 x = max(df_plot4$avg), y = u_bound + c(yy, -yy),
                 label = c("+1.96SD:", sprintf("%.1f", u_bound)),
                 size = 8, hjust = 1, colour = "tomato3") +
        ggtitle(sprintf("Bland-Altman (Accuracy of Hyper Score for Inferring %s)",
                        toTitleCase(analyze_names[var_i]))) +
        xlab(sprintf("Average of %s (Prediction vs Ground Truth)",
                        toTitleCase(analyze_names[var_i]))) +
        ylab(sprintf("Difference of %s (Prediction vs Ground Truth)",
                        toTitleCase(analyze_names[var_i]))) +
        theme(plot.title = element_text(size = 20, face = "bold"),
              axis.text = element_text(size = 15),
              axis.title = element_text(size = 15, face = "bold"))

# start offline plot, arrange multi-plot, then close plot
out_name = gsub(" ", "_", analyze_names[var_i])
png(paste0("plots/Validation_FollowUpVariable_", out_name, ".png"),
    width = 1500, height = 1500)
grid.arrange(p1, p2, p3, p4, ncol = 2)
dev.off()
