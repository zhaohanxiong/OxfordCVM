
# functions to visualize output
source("postprocess_visualization.R")

# load outputs from NeuroPM
path = "C:/Users/zxiong/Desktop/io 2 - no zscore" #"fmrib/NeuroPM/io/"

#ukb_df = read.csv(file.path(path,"ukb_num.csv"),header=TRUE)
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
                      ylim=c(0,1),
                      title = "Disease Progression by Blood Pressure Group",
                      xlab = "Blood Pressure Groups", ylab = "Disease Score",
                      labels = levels(psuedotimes$bp_group))

# line plot by group
plot_line_by_group(data = psuedotimes,
                   x = psuedotimes$BPSys_2_0,
                   #x = ukb_df[,c(var_sorted[10])],
                   y = psuedotimes$global_pseudotimes,
                   group = psuedotimes$bp_group,
                   title = "Disease Progression by Variable",
                   xlab = "Variable", ylab = "Disease Score")
