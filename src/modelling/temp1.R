library(tools)
library(ggplot2)
require(gridExtra)

# # # define input parameters
i = 1 # index of variable weighting to view
loess_factor = 1.5 # smoothing factor
n_intervals = 25 # number of intervals to divide

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

# filter out between group
ukb = ukb[scores$bp_group != 0, ]
scores = scores[scores$bp_group != 0, ]

# variable index to view
var = ukb[, weights$Var1[i]]

# define plotly color pallette
cols = c("#F8766D", "#CD9600", "#7CAE00", "#00BE67", 
         "#00BFC4", "#00A9FF", "#C77CFF", "#FF61CC")

# # # Visualize by Intervals
# start offline plot
png(file.path(path, "temp1.png"), width = 1600, height = 800)

# generate plotting data frame
df_plot = data.frame(y = scores$global_pseudotimes,
                     x = cut(var, breaks = seq(min(var, na.rm = TRUE), 
                                               max(var, na.rm = TRUE), 
                                               length = n_intervals)))
df_plot = df_plot[!is.na(df_plot$x), ]

# boxplot by intervals
p1 = ggplot(aes(y = y, x = x, fill = x), data = df_plot) + 
        geom_boxplot() +
        ggtitle(sprintf("Trend of %s Variable (Per Interval)", 
                                            gsub("_", " ", weights$group[i]))) +
        xlab(sprintf("%s (Regular Intervals)", toTitleCase(weights$name[i]))) + 
        ylab("Hyper Score [0-1]") +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# aggregate mean of scores by interval
df_median = aggregate(df_plot$y,
                      by = list(group = df_plot$x),
                      "median")
df_median$group = sapply(strsplit(gsub(",", " ",
                                  gsub("\\(|\\]", "",
                                  df_median$group)), " "), 
                              function(x) mean(as.numeric(x)))

# loess plot by interval means
p2 = ggplot(df_median, aes(x = group, y = x)) + 
        geom_point(size = 5, alpha = 0.5, col = "grey50") +
        geom_smooth(orientation = "x", span = loess_factor, col = "red") +
        ggtitle(sprintf("Trend of %s Variable (Per Interval)",
                                              gsub("_", " ", weights$group[i]))) +
        xlab(sprintf("%s (Median Per Interval)", toTitleCase(weights$name[i]))) + 
        ylab("Hyper Score [0-1]") +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# mutli-plot
grid.arrange(p1, p2, ncol = 2)

# stop offline plot
dev.off()

# # # Visualize by Trajectory
# start offline plot
png(file.path(path, "temp2.png"), width = 600, height = 600)

# generate plotting dataframe with 3 major trajectories
df_plot = data.frame(y = scores$global_pseudotimes,
                     x = cut(var, breaks = seq(min(var, na.rm = TRUE), 
                                               max(var, na.rm = TRUE), 
                                               length = n_intervals)),
                     traj = as.factor(scores$trajectory))
df_plot = df_plot[df_plot$traj %in% names(sort(table(scores$trajectory), 
                                               decreasing = TRUE)[1:4]), ]
df_plot = df_plot[!is.na(df_plot$x), ]

# aggregate score means by interval and trajectory
df_plot = aggregate(df_plot$y,
                    by = list(group = df_plot$x,
                              traj = df_plot$traj),
                    "median")
df_plot$group = sapply(strsplit(gsub(",", " ",
                                     gsub("\\(|\\]", "",
                                         df_plot$group)), " "), 
                                     function(x) mean(as.numeric(x)))
group_cols = cols[unique(df_plot$traj)]
names(group_cols) = unique(df_plot$traj)

# plot loess over interval means and by trajectory
ggplot(df_plot, aes(x = group, y = x, group = traj, color = traj)) + 
    geom_point(size = 7.5, alpha = 0.25) +
    geom_smooth(orientation = "x", method = "loess", span = loess_factor, 
                linewidth = 2, se = FALSE, fullrange = TRUE) +
    ggtitle(sprintf("Trend of %s Variable In 3 Dominant Trajectories",
                    gsub("_", " ", weights$group[i]))) +
    xlab(sprintf("%s (Median Per Interval)", toTitleCase(weights$name[i]))) + 
    ylab("Hyper Score [0-1]") +
    scale_color_manual("Trajectories", values = group_cols) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
          plot.title = element_text(size = 15, face = "bold"))

# stop offline plot
dev.off()
