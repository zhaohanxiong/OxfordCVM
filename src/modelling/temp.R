library(ggplot2)
library(tools)

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
# boxplot by group
i = 2
var = ukb[,weights$Var1[i]]
df_plot = data.frame(y = scores$global_pseudotimes,
                     x = cut(var, breaks = seq(min(var, na.rm = TRUE), 
                                               max(var, na.rm = TRUE), 
                                               length = 50)),
                     fill = as.factor(scores$bp_group))
df_plot = df_plot[!is.na(df_plot$x), ]
ggplot(aes(y = y, x = x, fill = x), data = df_plot) + 
  geom_boxplot() +
  ggtitle("Trend of Patient Characteristic") +
  xlab(sprintf("%s (Regular Intervals)", toTitleCase(weights$name[i]))) + 
  ylab("Hyper Score [0-1]") +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
