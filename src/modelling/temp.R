
# # # read input data
# set file path
path = "NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)

# load variable weighting outputs
weights = read.csv(file.path(path, "var_weighting.csv"),
                               header=TRUE, stringsAsFactor=FALSE)

# load uk raw variables
ukb = read.csv(file.path(path, "ukb_num_reduced.csv"), header=TRUE)

# load cPCs
cPC = read.csv(file.path(path, "cPC.csv"), header=TRUE)

# # # process data
# filter out between group for now
ukb = ukb[scores$bp_group != 0, ]
cPC = cPC[scores$bp_group != 0, ]
scores = scores[scores$bp_group != 0, ]

# compute colors (12 max)
col_temp = c('#FD3216', '#00FE35', '#6A76FC', '#FED4C4', '#FE00CE', 
             '#0DF9FF', '#F6F926', '#FF9616', '#479B55', '#EEA6FB', 
             '#DC587D', '#D626FF')
group_cols = col_temp[scores$bp_group + 1]
traj_cols = col_temp[scores$traj + 1]

# # # visualize
# try some random examples
plot(scores$global_pseudotimes, ukb[,weights$Var1[7]], col = group_cols)
plot(ukb[,weights$Var1[7]], ukb[,weights$Var1[8]], col = group_cols)
plot(cPC$mappedX_1, cPC$mappedX_2, col = group_cols)

