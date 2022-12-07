
# load outputs from NeuroPM
path = "NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)

# load variable weighting outputs
weights = read.csv(file.path(path, "var_weighting_reduced.csv"),
                                           header=TRUE, stringsAsFactor=FALSE)
# load uk raw variables
ukb = read.csv(file.path(path, "ukb_num_reduced.csv"), header=TRUE)

