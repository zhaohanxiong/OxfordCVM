
# functions to visualize output
source("postprocess_visualization.R")

# load outputs from NeuroPM
path = "fmrib/NeuroPM/io/" # "C:/Users/zxiong/Desktop/io"

ukb_df = data.frame(fread(file.path(path,"ukb_num_norm.csv"),header=TRUE))
labels = read.csv(file.path(path,"labels.csv"), header=TRUE)
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)
weight_vars = read.csv(file.path(path,"var_weighting.csv"), header=TRUE)
#weight_thres = as.numeric(read.csv(file.path(path,"threshold_weighting.csv"), 
#                                   header=TRUE))

# assign bp_groups as the real labels
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background","Between","Disease"))

# new column for whether weight is above or below thresholding
#weight_vars$thres_above = weight_vars$Node_contributions > weight_thres

# display number of variables above the threshold
#print(sprintf("Number of Variables Above Weight Threshold is %.0f/%0.f",
#              sum(weight_vars$thres_above),nrow(weight_vars)))

# normalize weighting vars
weight_vars$Node_contributions = weight_vars$Node_contributions / 
                                      sum(weight_vars$Node_contributions) * 100

# get list of variables sorted from high to low weighting
# also re-format these variable names since matlab screwed it up
weight_vars$Var1 = gsub("x","X",gsub("_","\\.",weight_vars$Var1))
var_sorted = weight_vars$Var1[order(weight_vars$Node_contributions, 
                                                            decreasing=TRUE)]

# write highly weighted vars to file
var_list = weight_vars$Var1[weight_vars$thres_above]
var_list = gsub("X","",var_list)
var_list = sub("\\.","-",var_list)
#fwrite(data.frame(x=var_list), file.path(path, "var_list.csv"))

# box plot by group
plot_boxplot_by_group(data = psuedotimes,
                      y = psuedotimes$global_pseudotimes,
                      group = psuedotimes$bp_group,
                      ylim=c(0, 1),
                      title = "Disease Progression by Blood Pressure Group",
                      xlab = "Blood Pressure Groups", ylab = "Disease Score",
                      labels = levels(psuedotimes$bp_group))

# perform statistical tests to evaluate model
# seperate groups into different variable
g1 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Background"]
g2 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Between"]
g3 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Disease"]

# perform t-test between groups
t.test(g1,g3)
t.test(g2,g3)

# perform quantile differences between groups, % overlap
g1_box = unname(c(quantile(g1, 0.25), quantile(g1, 0.75))) # background
g2_box = unname(c(quantile(g2, 0.25), quantile(g2, 0.75))) # between
g3_box = unname(c(quantile(g3, 0.25), quantile(g3, 0.75))) # disease

sprintf(paste0("Overlap in IQR of Background vs Between is ",
               "%0.1f%% (Background) %0.1f%% of (Between)"),
        (g1_box[2] - g2_box[1]) / diff(g1_box) * 100,
        (g1_box[2] - g2_box[1]) / diff(g2_box) * 100)
sprintf(paste0("Overlap in IQR of Boxes Between vs Disease is ",
               "%0.1f%% (Between) %0.1f%% (Disease)"),
        (g2_box[2] - g3_box[1]) / diff(g2_box) * 100,
        (g2_box[2] - g3_box[1]) / diff(g3_box) * 100)

# analysis for variable weightings compared to disease score
plot(psuedotimes$global_pseudotimes, ukb_df[, var_sorted[1]],
     col=alpha(c("green","blue","red")[labels$bp_group+1], 0.25), pch=20)

# View unusually high weight variables and their variable distribution
View(cbind(psuedotimes[,4:5],ukb_df[,var_sorted[1:15]]))

# load distance matrix and visualize distance distributions
mat = readMat(file.path(path,"all.mat"))$dist.matrix
range(mat)
hist(mat, breaks = seq(0,max(mat)+0.1,by=0.1))
