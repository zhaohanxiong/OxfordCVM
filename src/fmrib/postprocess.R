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

# perform statistical tests to evaluate model
# seperate groups into different variable
g1 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Background"]
g2 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Between"]
g3 = psuedotimes$global_pseudotimes[psuedotimes$bp_group=="Disease"]

# perform t-test between groups
t.test(g1,g2) # background vs between
t.test(g2,g3) # between vs disease
t.test(g1,g3) # background vs disease

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
