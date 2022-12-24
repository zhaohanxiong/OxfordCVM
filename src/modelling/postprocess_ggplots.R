library(ggplot2)
library(gridExtra)

# load outputs from NeuroPM
path = "NeuroPM/io/"

# load data
psuedotimes = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background", "Between", "Disease"))

# load variable weighting outputs
var_weights = read.csv(file.path(path, "var_weighting.csv"),
                                             header=TRUE, stringsAsFactor=FALSE)

# load variable names
ukb_varnames =  read.csv(file.path(path, "ukb_varnames.csv"), 
                                             header=TRUE, stringsAsFactor=FALSE)

# ------------------------------------------------------------------------------
# Plot 1 - Distribution of Disease Scores Separated by Group
# ------------------------------------------------------------------------------
# produce the plot
png(file.path(path, "final_plot1_Score_Distribution.png"), width = 1000, height = 500)
p1 = ggplot(psuedotimes, aes(y = global_pseudotimes, x = as.factor(bp_group), 
                        fill = as.factor(bp_group))) +
          geom_boxplot(alpha = 0.8) +
          scale_fill_discrete(labels = psuedotimes$bp_group) +
          scale_y_continuous(limits = c(0, 1)) +
          ggtitle("Pseudo-Time (Disease Score) By Group") + 
          xlab("Disease Group") + 
          ylab("Disease Score") +
          theme(legend.title = element_blank())

p2 = ggplot(psuedotimes, aes(x = global_pseudotimes, fill = as.factor(bp_group))) +
          geom_density(alpha = 0.5) + theme_bw() +
          ggtitle("Distribution of Disease Score By Group") + 
          xlab("Disease Group") + 
          ylab("Disease Score") +
          theme(legend.title = element_blank())
  
grid.arrange(p1, p2, ncol = 2, widths = c(1, 1.5))
dev.off()

# ------------------------------------------------------------------------------
# Plot 2 - Perform AUROC Analysis
# ------------------------------------------------------------------------------
# define pred/ground truths in a labelled structure
y_pred = psuedotimes$global_pseudotimes[psuedotimes$bp_group != "Between"]
y_true = ifelse(psuedotimes$bp_group[psuedotimes$bp_group != "Between"] == "Background", 0, 1)

# compute FPR (false positive rate) and TPR (true positive rate) for different thresholds
intervals = seq(0, 1, by = 0.001)
threshold_mat = sapply(intervals, function(thres) ifelse(y_pred > thres, 1, 0))
fpr = apply(threshold_mat, 2, function(x) 
                                sum(x == 1 & y_true == 0) / 
                                  (sum(x == 1 & y_true == 0) + sum(x == 0 & y_true == 0)))
tpr = apply(threshold_mat, 2, function(x)
                                sum(x == 1 & y_true == 1) / 
                                  (sum(x == 1 & y_true == 1) + sum(x == 0 & y_true == 1)))

# construct data frame to plot
metrics_plot = data.frame(fpr = fpr, tpr = tpr)

# define upper and lower thresholds for overlapping region
upper = min(psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Disease"])
lower = max(psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Background"])

# compute AUC (using sum of trapeziums)
auc = sum((tpr[1:(length(intervals) - 1)] + tpr[2:length(intervals)]) * diff(1 - fpr) / 2)

# produce the plot
png(file.path(path, "final_plot2_AUROC.png"), width = 1000, height = 600)
p1 = ggplot(psuedotimes, aes(y = global_pseudotimes, x = as.factor(bp_group), 
                        fill = as.factor(bp_group))) +
          geom_boxplot() +
          scale_fill_discrete(labels = psuedotimes$bp_group) +
          scale_y_continuous(limits = c(0, 1)) +
          ggtitle("Pseudo-Time (Disease Score) By Group") + 
          xlab("Disease Group") + 
          ylab("Disease Score") +
          theme(legend.title = element_blank()) +
          geom_hline(yintercept = c(upper, lower), col = "red")

p2 = ggplot(metrics_plot, aes(x = fpr, y = tpr)) +
          geom_line(color = "purple", lwd = 1) + 
          ggtitle("ROC (Receiver Operating Characteristic) Curve") + 
          xlab("False Positive Rate (1 - Specificity)") + 
          ylab("True Positive Rate (Sensitivity)") +
          geom_abline(col = "red")

grid.arrange(p1, p2, ncol = 2, widths = c(1, 1.5))
dev.off()

# ------------------------------------------------------------------------------
# Plot 3 - Disease Score vs Blood Pressure Measurements
# ------------------------------------------------------------------------------
# produce the plot
png(file.path(path, "final_plot3_BP_vs_Score.png"), width = 1000, height = 600)
p1 = ggplot(psuedotimes, aes_string(x = "global_pseudotimes", y = "BPSys.2.0")) +
          geom_point(aes_string(color = "bp_group"), shape = 19, alpha = 0.25, size = 2) +
          geom_smooth(orientation = "x", span = 1, col = "deepskyblue") +
          ggtitle("Disease Scores vs Systolic BP") +
          xlab("Pseudotime (Disease Progression) Scores (0-1)") + 
          ylab("Systolic Blood Pressure (mmHg)") +
          scale_colour_brewer(palette = "Dark2")

p2 = ggplot(psuedotimes, aes_string(x = "global_pseudotimes", y = "BPDia.2.0")) +
          geom_point(aes_string(color = "bp_group"), shape = 19, alpha = 0.25, size = 2) +
          geom_smooth(orientation = "x", span = 1, col = "deepskyblue") +
          ggtitle("Disease Scores vs Diastolic BP") +
          xlab("Pseudotime (Disease Progression) Scores (0-1)") + 
          ylab("Diastolic Blood Pressure (mmHg)") +
          scale_colour_brewer(palette = "Dark2")

grid.arrange(p1, p2, ncol = 2)
dev.off()

# ------------------------------------------------------------------------------
# Plot 4 - Distriubtion of Variable Weightings by Modality
# ------------------------------------------------------------------------------

# compute summary of weighting by group
weight_plot = aggregate(var_weights$Node_contributions,
                        by = list(var_weights$group),
                        FUN = "sum")
names(weight_plot) = c("Var_Group", "Total_Weighting")
significant_total = sum(weight_plot$Total_Weighting)
weight_plot$Total_Weighting = as.numeric(weight_plot$Total_Weighting)
weight_plot$Total_Weighting = round(weight_plot$Total_Weighting * 100, 2)

# compute summary of weighting by group for only the significant variables
var_weight_sig = var_weights[var_weights$significant, ]
var_weight_sig$Node_contributions = var_weight_sig$Node_contributions / 
                                        sum(var_weight_sig$Node_contributions)
weight_plot_sig = merge(aggregate(var_weight_sig$Node_contributions,
                                  by = list(var_weight_sig$group),
                                  FUN = "sum"),
                        aggregate(var_weight_sig$group,
                                  by = list(var_weight_sig$group),
                                  FUN = "length"),
                        by = "Group.1")
names(weight_plot_sig) = c("Var_Group", "Total_Weighting", "Count")
weight_plot_sig$Total_Weighting = as.numeric(weight_plot_sig$Total_Weighting)
weight_plot_sig$Total_Weighting = round(weight_plot_sig$Total_Weighting * 100, 2)
print(sprintf("----- Significant Variable Weighting Distribution is:"))
print(weight_plot_sig)

# produce the plot
png(file.path(path, "final_plot4_Variable_Contribution.png"), width = 1000, height = 500)

p1 = ggplot(weight_plot, aes(x = "", y = Total_Weighting, fill = Var_Group)) + 
        geom_bar(width = 1, stat = "identity") + 
        coord_polar("y", start = 0) + 
        scale_y_continuous(breaks = seq(0, 100, 5)) +
        scale_fill_brewer(palette = "Spectral") + 
        ggtitle("All Variable Weighting Contribution") +
        xlab("") + ylab("")

p2 = ggplot(weight_plot_sig, aes(x = "", y = Total_Weighting, fill = Var_Group)) + 
        geom_bar(width = 1, stat = "identity") + 
        coord_polar("y", start = 0) + 
        scale_y_continuous(breaks = seq(0, 100, 5)) +
        scale_fill_brewer(palette = "Spectral") + 
        ggtitle("cTI Significant Variable Weighting Contribution") +
        xlab("") + ylab("")

grid.arrange(p1, p2, ncol = 2)
dev.off()

# ------------------------------------------------------------------------------
# Plot - Individual Trajectory Scores
# ------------------------------------------------------------------------------


