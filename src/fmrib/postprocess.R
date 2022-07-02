# load outputs from NeuroPM
path = "NeuroPM/io/"

# load pseudotime scores
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)

# rename first column
names(psuedotimes)[1:3] = c("patid", "BPSys.2.0", "BPDia.2.0")

# save psuedotimes with renamed columns
write.csv(psuedotimes, file.path(path,"pseudotimes.csv"), row.names = FALSE)

# assign bp_groups as the real labels
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background","Between","Disease"))

# perform statistical tests to evaluate model
# seperate groups into different variable
g1 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Background"]
g2 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Between"]
g3 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Disease"]

# perform t-test between groups
t.test(g1,g2) # background vs between
t.test(g2,g3) # between vs disease
t.test(g1,g3) # background vs disease

# perform quantile differences between groups, % overlap
g1_box = unname(c(quantile(g1, 0.25), quantile(g1, 0.75))) # background
g2_box = unname(c(quantile(g2, 0.25), quantile(g2, 0.75))) # between
g3_box = unname(c(quantile(g3, 0.25), quantile(g3, 0.75))) # disease

# display results for quantifying IQR overlap
sprintf(paste0("Overlap in IQR of Background vs Between is ",
               "%0.1f%% (Background) %0.1f%% of (Between)"),
        (g1_box[2] - g2_box[1]) / diff(g1_box) * 100,
        (g1_box[2] - g2_box[1]) / diff(g2_box) * 100)
sprintf(paste0("Overlap in IQR of Boxes Between vs Disease is ",
               "%0.1f%% (Between) %0.1f%% (Disease)"),
        (g2_box[2] - g3_box[1]) / diff(g2_box) * 100,
        (g2_box[2] - g3_box[1]) / diff(g3_box) * 100)

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

# quantifying the proportion of patients inside the overlapping interval
overlap_prop = (n_background_overlap + n_disease_overlap) /
                      (length(sample_background) + length(sample_disease))

# display results for quantifying distribution overlap
sprintf("Comparing the Amount of Overlap Between Background and Disease")
sprintf("Overlapping Interval of Scores is %0.1f%% of the entire range (%0.3f to %0.3f)", 
        overlap * 100, min(sample_disease), max(sample_background))
sprintf("%% of Samples with Non-Overlapping Scores Overall is %0.1f%%",
        (1 - overlap_prop) * 100)
sprintf("%% of Samples in the Background Group with Non-Overlapping Scores is %0.1f%%",
        background_q * 100)
sprintf("%% of Samples in the Disease Group with Non-Overlapping Scores is %0.1f%%",
        disease_q * 100)

# define pred/ground truths in a labelled structure
y_pred = psuedotimes$global_pseudotimes[psuedotimes$bp_group != "Between"]
y_true = ifelse(psuedotimes$bp_group[psuedotimes$bp_group != "Between"] == 
                                                              "Background", 0, 1)

# compute FPR (false positive rate) and TPR (true positive rate) for different thresholds
intervals = c(seq(0, 0.1, by = 0.01), seq(0.2, 1, by = 0.1))
threshold_mat = sapply(intervals, function(thres) ifelse(y_pred >= thres, 1, 0))
fpr = apply(threshold_mat, 2, function(x) 
                                sum(x == 1 & y_true == 0) / 
                                  (sum(x == 1 & y_true == 0) + sum(x == 0 & y_true == 0)))
tpr = apply(threshold_mat, 2, function(x)
                                sum(x == 1 & y_true == 1) / 
                                  (sum(x == 1 & y_true == 1) + sum(x == 0 & y_true == 1)))

# create a data frame to view variation of threshold to fpr/tpr
df = data.frame(threshold = intervals,
                specificity = 1 - fpr,
                sensitivity = tpr)
if (FALSE) {
  View(df)
}

# compute AUC (using sum of trapeziums)
auc = sum((tpr[1:(length(intervals) - 1)] + tpr[2:length(intervals)]) * diff(1 - fpr) / 2)

# display output
sprintf("AUC is %0.5f when using %0.0f Logarithmic Intervals", auc, length(intervals))

# plot AUROC (area under receiver operating characteristic curve)
if (FALSE) {
  
  par(mfrow = c(1, 2))
  boxplot(psuedotimes$global_pseudotimes ~ psuedotimes$bp_group,
          main = "Distribution of Disease Scores Between Groups",
          ylab = "Disease Score", xlab = "")
  abline(h = c(min(sample_disease), max(sample_background)), col = "red")
  
  plot(c(fpr[1], rep(fpr, each = 2)[-length(fpr)]), rep(tpr, each = 2),
       type = "l", col = "purple", lwd = 1,
       main = "ROC (Receiver Operating Characteristic) Curve",
       xlab = "False Positive Rate (1 - Specificity)", 
       ylab = "True Positive Rate (Sensitivity)")
  abline(0, 1, col = "red", lty = 2)
  #abline(v = seq(0, 1, by = 0.01), col = "grey25", lty = 5)
  lines(c(fpr[1], rep(fpr, each = 2)[-length(fpr)]), rep(tpr, each = 2),
        lwd = 3, col = "purple")

}

# prepare data frame of variable names and their descriptors
varnames = read.csv(file.path(path, "var_weighting.csv"), 
                    header=TRUE, stringsAsFactor=FALSE)$Var1

# load bb variable list to compare
ukb_varnames = read.csv("../../../bb_variablelist.csv", 
                        header=TRUE, stringsAsFactor=FALSE)

# match field codes with field descriptors
varnames = c(names(psuedotimes)[2:3], varnames)
varnames = gsub("_", ".", gsub("x", "X", varnames))

var_regexpr = regexpr("\\.", varnames) + 1
varnames_instance = substring(varnames, var_regexpr, var_regexpr)
varnames = data.frame(colname = varnames,
                      FieldID = substring(varnames, 
                                          regexpr("X", varnames) + 1, 
                                          regexpr("\\.", varnames) - 1))
varnames$colname = as.character(varnames$colname)
varnames$FieldID = as.character(varnames$FieldID)
varnames$Field = ukb_varnames$Field[sapply(varnames$FieldID, function(v) 
                                             which(ukb_varnames$FieldID == v))]
varnames$instance = varnames_instance
varnames$display = paste0(varnames$Field, ifelse(varnames$instance == "0",
                                                 "",
                                                 paste0(" (", varnames$instance, ")")))

# write this to file for dataframe of variable codes and original names
write.csv(varnames, file.path(path, "ukb_varnames.csv"), row.names = FALSE)
