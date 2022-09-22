library(ggplot2)
library(gridExtra)

# load outputs from NeuroPM
path = "fmrib/NeuroPM/io/"

# load data
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background","Between","Disease"))

# ------------------------------------------------------------------------------
# Plot 1 - Distribution of Disease Scores Separated by Group
# ------------------------------------------------------------------------------
# produce the plot
pdf(file.path(path, "plot1_barplot.pdf"), width = 10, height = 5)
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
  
grid.arrange(p1, p2, ncol = 2)
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
pdf(file.path(path, "plot2_AUROC.pdf"), width = 10, height = 6)
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

grid.arrange(p1, p2, ncol = 2)
dev.off()

# ------------------------------------------------------------------------------
# Plot 3 - Individual Trajectory Scores
# ------------------------------------------------------------------------------
psuedotimes$trajectory = as.factor(as.numeric(sapply(strsplit(psuedotimes$trajectory, ","), 
                                                    function(x) x[1])))
major_traj = names(which(table(psuedotimes$trajectory) > nrow(psuedotimes) * 0.01))
psuedotimes$trajectory[!(psuedotimes$trajectory %in% major_traj)] = NA

ggplot(psuedotimes, aes(y = global_pseudotimes, x = as.factor(trajectory), 
                        fill = as.factor(trajectory))) +
          geom_boxplot(alpha = 0.8) +
          ggtitle("Disease Score in Each Trajectory") + 
          ylab("Disease Score") + 
          xlab("Trajectory")
  
# ------------------------------------------------------------------------------
# 
# ------------------------------------------------------------------------------
#  

# ------------------------------------------------------------------------------
# 
# ------------------------------------------------------------------------------
#  