library(tools)
library(ggplot2)
require(gridExtra)

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

# # # process data
# filter out between group for now
ukb = ukb[scores$bp_group != 0, ]
scores = scores[scores$bp_group != 0, ]

# compute colors (12 max)
col_temp = c('#FD3216', '#00FE35', '#6A76FC', '#FED4C4', '#FE00CE', 
             '#0DF9FF', '#F6F926', '#FF9616', '#479B55', '#EEA6FB', 
             '#DC587D', '#D626FF')
group_cols = col_temp[scores$bp_group + 1]
traj_cols = col_temp[scores$traj + 1]

# # # visualize
png(file.path(path, "temp.png"), width = 1000, height = 600)
# variable index to view
i = 4
loess_factor = 0.75
n_intervals = 25
var = ukb[, weights$Var1[i]]

# boxplot by intervals
df_plot = data.frame(y = scores$global_pseudotimes,
                     x = cut(var, breaks = seq(min(var, na.rm = TRUE), 
                                               max(var, na.rm = TRUE), 
                                               length = n_intervals)),
                     fill = as.factor(scores$bp_group))
df_plot = df_plot[!is.na(df_plot$x), ]
p1 = ggplot(aes(y = y, x = x, fill = x), data = df_plot) + 
        geom_boxplot() +
        ggtitle(sprintf("Trend of %s Variable (Per Interval)", 
                                            gsub("_", " ", weights$group[i]))) +
        xlab(sprintf("%s (Regular Intervals)", toTitleCase(weights$name[i]))) + 
        ylab("Hyper Score [0-1]") +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# loess plot by interval means
df_median = aggregate(df_plot$y, by = list(df_plot$x), "median")
df_median$group = sapply(strsplit(gsub(",", " ",
                                  gsub("\\(|\\]", "",
                                  df_median$Group.1)), " "), 
                              function(x) mean(as.numeric(x)))
p2 = ggplot(df_median, aes(x = group, y = x)) + 
        geom_point(size = 5, alpha = 0.5, fill = "grey50") +
        geom_smooth(orientation = "x", span = loess_factor, col = "red") +
        ggtitle(sprintf("Trend of %s Variable (Per Interval)",
                                              gsub("_", " ", weights$group[i]))) +
        xlab(sprintf("%s (Median Per Interval)", toTitleCase(weights$name[i]))) + 
        ylab("Hyper Score [0-1]") +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

grid.arrange(p1, p2, ncol = 2)
dev.off()
