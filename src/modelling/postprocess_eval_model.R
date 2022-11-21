# load outputs from NeuroPM
path = "NeuroPM/io/"

# load pseudotime scores
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)

# assign bp_groups as the real labels
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background","Between","Disease"))

# --------------------------------------------------------------------------------------------
# Basic Statistical Evaluation
# --------------------------------------------------------------------------------------------
# perform statistical tests to evaluate model
# seperate groups into different variable
g1 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Background"]
g2 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Between"]
g3 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Disease"]

# perform t-test between groups
t.test(g1, g2) # background vs between
t.test(g2, g3) # between vs disease
t.test(g1, g3) # background vs disease

# perform quantile differences between groups, % overlap
g1_box = unname(c(quantile(g1, 0.25), quantile(g1, 0.75))) # background
g2_box = unname(c(quantile(g2, 0.25), quantile(g2, 0.75))) # between
g3_box = unname(c(quantile(g3, 0.25), quantile(g3, 0.75))) # disease

# display results for quantifying IQR overlap
print(sprintf(paste0("Overlap in IQR of Background vs Between is ",
                     "%0.1f%% (Background) %0.1f%% of (Between)"),
              (g1_box[2] - g2_box[1]) / diff(g1_box) * 100,
              (g1_box[2] - g2_box[1]) / diff(g2_box) * 100))
print(sprintf(paste0("Overlap in IQR of Boxes Between vs Disease is ",
                     "%0.1f%% (Between) %0.1f%% (Disease)"),
              (g2_box[2] - g3_box[1]) / diff(g2_box) * 100,
              (g2_box[2] - g3_box[1]) / diff(g3_box) * 100))

# --------------------------------------------------------------------------------------------
# Quantifying Group Overlap Evaluation
# --------------------------------------------------------------------------------------------
# compute overlap between background and disease group scores
sample_background = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Background"]
sample_disease = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Disease"]
overlap = max(sample_background) - min(sample_disease)

# calculate number of overlapping samples in the background and disease groups
n_background_overlap = sum(sample_background > min(sample_disease))
n_disease_overlap = sum(sample_disease < max(sample_background))

# quantifying the quantiles for the overlapping values
background_q = 1 - n_background_overlap/length(sample_background)
disease_q = 1 - n_disease_overlap/length(sample_disease)

# display results for quantifying distribution overlap
print(sprintf("Overlapping Interval of Scores is %0.1f%% of the entire range (%0.3f to %0.3f)", 
        overlap * 100, min(sample_disease), max(sample_background)))
print(sprintf("%% of Samples in the Background Group with Non-Overlapping Scores is %0.1f%%",
        background_q * 100))
print(sprintf("%% of Samples in the Disease Group with Non-Overlapping Scores is %0.1f%%",
        disease_q * 100))

# --------------------------------------------------------------------------------------------
# AUROC Evaluation
# --------------------------------------------------------------------------------------------
# define pred/ground truths in a labelled structure
y_pred = psuedotimes$global_pseudotimes[psuedotimes$bp_group != "Between"]
y_true = ifelse(psuedotimes$bp_group[psuedotimes$bp_group != "Between"] == "Background", 0, 1)

# compute FPR (false positive rate) and TPR (true positive rate) for different thresholds
intervals = seq(0, 1, by = 0.001)
threshold_mat = sapply(intervals, function(thres) ifelse(y_pred > thres, 1, 0))
tpr = apply(threshold_mat, 2, function(x)
                sum(x == 1 & y_true == 1) /
                    (sum(x == 1 & y_true == 1) + sum(x == 0 & y_true == 1)))
tnr = apply(threshold_mat, 2, function(x)
                sum(x == 0 & y_true == 0) /
                    (sum(x == 0 & y_true == 0) + sum(x == 1 & y_true == 0)))
fnr = apply(threshold_mat, 2, function(x)
                sum(x == 0 & y_true == 1) /
                    (sum(x == 0 & y_true == 1) + sum(x == 1 & y_true == 1)))
fpr = apply(threshold_mat, 2, function(x)
                sum(x == 1 & y_true == 0) /
                    (sum(x == 1 & y_true == 0) + sum(x == 0 & y_true == 0)))

# compute AUC (using sum of trapeziums)
auc = sum((tpr[1:(length(intervals) - 1)] + tpr[2:length(intervals)]) * diff(1 - fpr) / 2)

# display output
print(sprintf("AUC is %0.5f when using %0.0f Logarithmic Intervals", 
              auc, length(intervals)))

# plot AUROC (area under receiver operating characteristic curve)
if (FALSE) {
  
  par(mfrow = c(1, 2))
  boxplot(psuedotimes$global_pseudotimes ~ psuedotimes$bp_group,
          main = "Distribution of Disease Scores Between Groups",
          ylab = "Disease Score", xlab = "",
          col = c("tomato", "lawngreen", "deepskyblue"))
  abline(h = c(min(sample_disease), max(sample_background)), col = "red")
  
  plot(c(fpr[1], rep(fpr, each = 2)[-length(fpr)]), rep(tpr, each = 2),
       type = "l", col = "purple", lwd = 1,
       main = "ROC (Receiver Operating Characteristic) Curve",
       xlab = "False Positive Rate (1 - Specificity)", 
       ylab = "True Positive Rate (Sensitivity)")
  abline(0, 1, col = "red", lty = 2)
  lines(c(fpr[1], rep(fpr, each = 2)[-length(fpr)]), rep(tpr, each = 2),
        lwd = 3, col = "purple")
  text(0.5, 0.5, labels = sprintf("AUC = %0.3f", auc), cex = 1)

}

# create a data frame to view variation of threshold to fpr/tpr
if (FALSE) {
  View(data.frame(threshold = intervals,
                  specificity = 1 - fpr,
                  sensitivity = tpr))
}

# perform optimization to find optimal threshold, x = threshold
ind = which.min(abs((1 - fpr) - tpr))
print(sprintf(paste0("Optimal Threshold at %0.3f (Sensitivity = %0.1f%%, ",
                     "Specificity = %0.1f%%)"), 
              intervals[ind], tpr[ind] * 100, (1 - fpr)[ind] * 100))

# print confusion matrix
print(sprintf("Confusion Matrix:"))
print(sprintf("(Pred/GT) True  False"))
print(sprintf("True      %0.1f%% %0.1f%%", tpr[ind]*100, fpr[ind]*100))
print(sprintf("False     %0.1f%% %0.1f%%", fnr[ind]*100, tnr[ind]*100))
