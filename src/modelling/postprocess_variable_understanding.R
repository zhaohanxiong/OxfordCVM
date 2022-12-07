
# # # read input data
# set file path
path = "NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)

# load variable weighting outputs
weights = read.csv(file.path(path, "var_weighting_reduced.csv"),
                                           header=TRUE, stringsAsFactor=FALSE)

# load uk raw variables
ukb = read.csv(file.path(path, "ukb_num_reduced.csv"), header=TRUE)

# # # process data
# filter out between group for now
ukb = ukb[scores$bp_group != 0, ]
scores = scores[scores$bp_group != 0, ]

# # # visualize
# compute colors
col_temp = c('#FD3216', '#00FE35', '#6A76FC', '#FED4C4', '#FE00CE', '#0DF9FF',
             '#F6F926', '#FF9616', '#479B55', '#EEA6FB', '#DC587D', '#D626FF',
             '#6E899C', '#00B5F7', '#B68E00', '#C9FBE5', '#FF0092', '#22FFA7',
             '#E3EE9E', '#86CE00', '#BC7196', '#7E7DCD', '#FC6955', '#E48F72')
group_cols = col_temp[scores$bp_group + 1]
traj_cols = col_temp[scores$traj + 1]

# produce plot
plot(ukb[, weights$Var1[42]], scores$global_pseudotimes, col = traj_cols)
