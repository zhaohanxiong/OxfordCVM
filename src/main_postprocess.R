
# functions to visualize output
source("postprocess_visualization.R")

# load outputs from NeuroPM
path = "fmrib/NeuroPM/io/"

psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)
weight_vars = read.csv(file.path(path,"var_weighting.csv"), header=TRUE)
weight_thres = as.numeric(read.csv(file.path(path,"threshold_weighting.csv"), 
                                   header=TRUE))

# box plot by group
plot_boxplot_by_group(data = psuedotimes, 
                      y = psuedotimes$global_pseudotimes,
                      group = psuedotimes$bp_group,
                      title = "Disease Progression by Blood Pressure Group",
                      xlab = "Blood Pressure Groups", ylab = "Disease Score",
                      labels = c("Between", "Background", "Disease"))

# line plot by group
plot_line_by_group(data = psuedotimes, 
                   x = psuedotimes$BPSys_2_0,
                   y = psuedotimes$global_pseudotimes,
                   group = psuedotimes$bp_group,
                   title = "Disease Progression by Blood Pressure Group",
                   xlab = "Systolic Blood Pressure", ylab = "Disease Score")
