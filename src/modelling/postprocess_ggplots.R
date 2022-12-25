library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

# load outputs from NeuroPM
path = "NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)
scores$bp_group[scores$bp_group == 0] = "Between"
scores$bp_group[scores$bp_group == 1] = "Background"
scores$bp_group[scores$bp_group == 2] = "Disease"
scores$bp_group = ordered(scores$bp_group,
                               levels = c("Background", "Between", "Disease"))

# load variable weighting outputs
var_weights = read.csv(file.path(path, "var_weighting.csv"),
                                             header=TRUE, stringsAsFactor=FALSE)

# load variable names
ukb_varnames =  read.csv(file.path(path, "ukb_varnames.csv"), 
                                             header=TRUE, stringsAsFactor=FALSE)
# load uk raw variables
ukb = data.frame(fread(file.path(path, "ukb_num_norm.csv"), header=TRUE))

# ------------------------------------------------------------------------------
# Plot 1 - Distribution of Disease Scores Separated by Group
# ------------------------------------------------------------------------------
# produce the plot
png(file.path(path, "final_plot1_Score_Distribution.png"), width = 1000, height = 500)
p1 = ggplot(scores, aes(y = global_pseudotimes, x = as.factor(bp_group), 
                        fill = as.factor(bp_group))) +
          geom_boxplot(alpha = 0.8) +
          scale_fill_discrete(labels = scores$bp_group) +
          scale_y_continuous(limits = c(0, 1)) +
          ggtitle("Pseudo-Time (Disease Score) By Group") + 
          xlab("Disease Group") + 
          ylab("Disease Score") +
          theme(legend.title = element_blank())

p2 = ggplot(scores, aes(x = global_pseudotimes, fill = as.factor(bp_group))) +
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
y_pred = scores$global_pseudotimes[scores$bp_group != "Between"]
y_true = ifelse(scores$bp_group[scores$bp_group != "Between"] == "Background", 0, 1)

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
upper = min(scores$global_pseudotimes[scores$bp_group == "Disease"])
lower = max(scores$global_pseudotimes[scores$bp_group == "Background"])

# compute AUC (using sum of trapeziums)
auc = sum((tpr[1:(length(intervals) - 1)] + tpr[2:length(intervals)]) * diff(1 - fpr) / 2)

# produce the plot
png(file.path(path, "final_plot2_AUROC.png"), width = 1000, height = 600)
p1 = ggplot(scores, aes(y = global_pseudotimes, x = as.factor(bp_group), 
                        fill = as.factor(bp_group))) +
          geom_boxplot() +
          scale_fill_discrete(labels = scores$bp_group) +
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
# Plot 3 - Hyperscore vs Blood Pressure Measurements
# ------------------------------------------------------------------------------
# produce the plot
png(file.path(path, "final_plot3_BP_vs_Score.png"), width = 1000, height = 600)
p1 = ggplot(scores, aes_string(x = "global_pseudotimes", y = "BPSys.2.0")) +
          geom_point(aes_string(color = "bp_group"), shape = 19, alpha = 0.25, size = 2) +
          geom_smooth(orientation = "x", span = 1.5, linewidth = 1.5 , col = "deepskyblue") +
          ggtitle("Disease Scores vs Systolic BP") +
          xlab("Pseudotime (Disease Progression) Scores (0-1)") + 
          ylab("Systolic Blood Pressure (mmHg)") +
          scale_colour_brewer(palette = "Dark2")

p2 = ggplot(scores, aes_string(x = "global_pseudotimes", y = "BPDia.2.0")) +
          geom_point(aes_string(color = "bp_group"), shape = 19, alpha = 0.25, size = 2) +
          geom_smooth(orientation = "x", span = 1.5, linewidth = 1.5 , col = "deepskyblue") +
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
# Plot 5 - Clinical Variables Against Hyperscore
# ------------------------------------------------------------------------------

# manually list out variables to plot hyperscore against
vars      = c("X22423.2.0",
              "X22421.2.0",
              "X25781.2.0", 
              "X25019.2.0",
              "X25020.2.0")
var_names = c("LV SV",
              "LV EDV",
              "WM Hyperintensity",
              "Hippo (Left Volume)",
              "Hippo (Right Volume)")

# intialize the dataframe with all the hyperscores repeated, and var column
df_conc = data.frame(x = rep(scores$global_pseudotimes, length(vars)),
                     y = NA, # placeholder
                     name = rep(var_names, each = nrow(scores)))

# partition hyper scores into intervals (could be variable)
df_conc$x = cut(df_conc$x, breaks = seq(min(df_conc$x, na.rm = TRUE),
                                        max(df_conc$x, na.rm = TRUE),
                                        length = 11))

# iterate all the variables and compile 
for (i in 1:length(vars)) {

        # define variable values from ukb column
        v = ukb[, vars[i]]

        # assign values to collated df
        df_conc$y[((i - 1) * nrow(scores) + 1):(i * nrow(scores))] = v

}

# remove rows with missing values
df_conc = df_conc[!is.na(df_conc$x), ]

# Compute median hyperscore per interval for each variable
df_plot = aggregate(list(y = df_conc$y),
                    by = list(x = df_conc$x, name = df_conc$name),
                    "mean")
df_plot$x = sapply(strsplit(gsub("\\(|\\]", "", df_plot$x), ","),
                    function(xx) mean(as.numeric(xx)))
df_plot$name = as.factor(df_plot$name)

# produce the plot
png(file.path(path, "final_plot5_ClinicalVariables.png"), width = 600, height = 600)

# produce plot
ggplot(df_plot, aes(x = x, y = y, group = name, color = name)) + 
        geom_point(size = 7.5, alpha = 0.25) +
        geom_smooth(orientation = "x", method = "loess", span = 1.5, 
                     linewidth = 2, se = FALSE, fullrange = TRUE) +
        ggtitle("Trend of Clinical Variables vs Hyper Score") +
        xlab("Hyper Score [0 to 1]") +
        ylab("Clinical Variables (Normalized between 0 to 1)") +
        scale_color_manual(name = "Variable Name") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

dev.off()
