library(tools)
library(ggplot2)
require(gridExtra)

# # # define input parameters
i = 5 # index of variable weighting to view
n_intervals = 21 # number of intervals to divide
n_traj = 3 # number of trajectories

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

# filter out root node (avoid coloring issues)
ukb = ukb[scores$trajectory != -1, ]
scores = scores[scores$trajectory != -1, ]

# variable index to view
var = ukb[, weights$Var1[i]]

# define plotly color pallette
cols = c("#F8766D", "#CD9600", "#7CAE00", "#00BE67", 
         "#00BFC4", "#00A9FF", "#C77CFF", "#FF61CC")

# # # Visualize by Intervals
# generate plotting data frame
df_plot = data.frame(y = var,
                     x = cut(scores$global_pseudotimes,
                             breaks = seq(0, 1,length = n_intervals)))
df_plot = df_plot[!is.na(df_plot$x) & !is.na(df_plot$y), ]

# boxplot by intervals
p1 = ggplot(aes(y = y, x = x, fill = x), data = df_plot) + 
        geom_boxplot() +
        ggtitle(sprintf("Trend of %s Variable (Per Hyper Score Interval)", 
                                            gsub("_", " ", weights$group[i]))) +
        ylab(toTitleCase(weights$name[i])) + 
        xlab("Hyper Score [0-1]") +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# aggregate mean of scores by interval
df_plot2 = aggregate(list(y = df_plot$y),
                     by = list(x = df_plot$x),
                     "mean")
df_plot2$x = sapply(strsplit(gsub("\\(|\\]", "", df_plot2$x), ","), 
                    function(x) mean(as.numeric(x)))

# loess plot by interval means
p2 = ggplot(df_plot2, aes(x = x, y = y)) + 
        geom_point(size = 5, alpha = 0.5, col = "grey50") +
        geom_smooth(orientation = "x", span = 5, col = "red") +
        ggtitle(sprintf("Trend of %s Variable (Per Hyper Score Interval)",
                                              gsub("_", " ", weights$group[i]))) +
        ylab(toTitleCase(weights$name[i])) + 
        xlab("Hyper Score [0-1]") +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# # # Visualize by Trajectory
# generate plotting dataframe with 3 major trajectories
df_plot = data.frame(y = var,
                     x = cut(scores$global_pseudotimes,
                             breaks = seq(0, 1,length = n_intervals)),
                     traj = as.factor(scores$trajectory))
df_plot = df_plot[df_plot$traj %in% names(sort(table(scores$trajectory), 
                                               decreasing = TRUE)[1:n_traj]), ]
df_plot = df_plot[!is.na(df_plot$x) & !is.na(df_plot$y), ]

# aggregate score means by interval and trajectory
df_plot = aggregate(list(y = df_plot$y),
                    by = list(x = df_plot$x,
                              traj = df_plot$traj),
                    "median")
df_plot$x = sapply(strsplit(gsub("\\(|\\]", "", df_plot$x), ","), 
                   function(x) mean(as.numeric(x)))
group_cols = cols[unique(df_plot$traj)]
names(group_cols) = unique(df_plot$traj)

# plot loess over interval means and by trajectory
p3 = ggplot(df_plot, aes(x = x, y = y, group = traj, color = traj)) + 
        geom_point(size = 7.5, alpha = 0.25) +
        geom_smooth(orientation = "x", span = 5,
                    linewidth = 2, se = FALSE, fullrange = TRUE) +
        ggtitle(sprintf("Trend of %s Variable In %i Dominant Trajectories",
                        gsub("_", " ", weights$group[i]), length(group_cols))) +
        ylab(toTitleCase(weights$name[i])) + 
        xlab("Hyper Score [0-1]") +
        scale_color_manual("Trajectories", values = group_cols) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# start offline plot
png(file.path(path, "temp.png"), width = 1200, height = 1200)

# mutli-plot
grid.arrange(p1, p2, p3, ncol = 2)

# stop offline plot
dev.off()
