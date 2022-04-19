
# functions to visualize output
source("postprocess_visualization.R")

# load outputs from NeuroPM
path = "C:/Users/zxiong/Desktop/io 2 - imputation" #"fmrib/NeuroPM/io/"

ukb_df = data.frame(fread(file.path(path,"ukb_num.csv"),header=TRUE))
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)
weight_vars = read.csv(file.path(path,"var_weighting.csv"), header=TRUE)
weight_thres = as.numeric(read.csv(file.path(path,"threshold_weighting.csv"), 
                                   header=TRUE))

# assign bp_groups as the real labels
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background","Between","Disease"))

# new column for whether weight is above or below thresholding
weight_vars$thres_above = weight_vars$Node_contributions > weight_thres

# display number of variables above the threshold
print(sprintf("Number of Variables Above Weight Threshold is %.0f/%0.f",
              sum(weight_vars$thres_above),nrow(weight_vars)))

# normalize weighting vars
weight_vars$Node_contributions = weight_vars$Node_contributions / 
                                      sum(weight_vars$Node_contributions) * 100

# get list of variables sorted from high to low weighting
# also re-format these variable names since matlab screwed it up
var_sorted = weight_vars$Var1[order(weight_vars$Node_contributions, 
                                                            decreasing=TRUE)]
var_sorted = gsub("_","\\.",var_sorted)
var_sorted = gsub("x","X",var_sorted)

# box plot by group
plot_boxplot_by_group(data = psuedotimes,
                      y = psuedotimes$global_pseudotimes,
                      group = psuedotimes$bp_group,
                      ylim=c(0, 1),
                      title = "Disease Progression by Blood Pressure Group",
                      xlab = "Blood Pressure Groups", ylab = "Disease Score",
                      labels = levels(psuedotimes$bp_group))

# # line plot by group
# plot_line_by_group(data = psuedotimes,
#                    x = psuedotimes$BPSys_2_0,
#                    #x = ukb_df[,c(var_sorted[10])],
#                    y = psuedotimes$global_pseudotimes,
#                    group = psuedotimes$bp_group,
#                    title = "Disease Progression by Variable",
#                    xlab = "Variable", ylab = "Disease Score")

# perform statistical tests to evaluate model
# seperate groups into different variable
g1 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Background"]
g2 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Between"]
g3 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Disease"]

# perform t-test between groups
t.test(g1,g3)
t.test(g2,g3)

# perform quantile differences between groups, % overlap
g1_bar = unname(c(quantile(g1, 0.25), quantile(g1, 0.75)))
g2_bar = unname(c(quantile(g2, 0.25), quantile(g2, 0.75)))
g3_bar = unname(c(quantile(g3, 0.25), quantile(g3, 0.75)))

sprintf("Overlap Between Background and Between is %0.3f of Background",
                                    (g1_bar[2] - g2_bar[1]) / diff(g1_bar))
sprintf("Overlap Between Background and Between is %0.3f of Between",
                                    (g1_bar[2] - g2_bar[1]) / diff(g2_bar))
sprintf("Overlap Between Disease and Between is %0.3f of Between", 
                                    (g2_bar[2] - g3_bar[1]) / diff(g2_bar))
sprintf("Overlap Between Disease and Between is %0.3f of Between", 
                                    (g2_bar[2] - g3_bar[1]) / diff(g3_bar))
