
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
var_weights = read.csv(file.path(path, "var_weighting_reduced.csv"),
                                             header=TRUE, stringsAsFactor=FALSE)
