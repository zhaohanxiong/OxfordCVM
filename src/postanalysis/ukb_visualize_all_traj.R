library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

var_i = 3 # index of variable weighting to view: 43, 5, 30, 457, 462
n_traj = 3 # number of trajectories

# # # read input data
# define data path
path = "../modelling/NeuroPM/io/"

# ------------------------------------------------------------------------------
# prepare data
# ------------------------------------------------------------------------------
# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)

# load variable weighting outputs
weights = read.csv(file.path(path, "var_weighting.csv"),
                             header=TRUE, stringsAsFactor=FALSE)

# load uk raw variables
ukb = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"), header = TRUE))

# filter out root node (avoid coloring issues)
ukb = ukb[scores$trajectory != -1, ]
scores = scores[scores$trajectory != -1, ]

# convert traj column to factor
scores$trajectory = as.factor(scores$trajectory)

# define plotly color pallette
cols = c("#F8766D", "#CD9600", "#7CAE00", "#00BE67", 
         "#00BFC4", "#00A9FF", "#C77CFF", "#FF61CC")

# retrive N trajectories with the most number of patients
main_trajs = names(sort(table(scores$trajectory), decreasing = TRUE)[1:n_traj])

# ------------------------------------------------------------------------------
# Aggregate Data for Plotting
# ------------------------------------------------------------------------------

# assign variable index to view
scores$var = ukb[, weights$Var1[var_i]]

# filter out non-major trajectories
scores = scores[scores$trajectory %in% main_trajs, ]

# intialize the dataframe with all the hyperscores repeated, and var column
n_ints = 100
df_conc = data.frame(x = rep(NA, n_ints * length(main_trajs)), y = NA, traj = NA)

# iterate through all traj
for (i in 1:length(main_trajs)) {

        # get relevant rows for each traj
        scores_t = scores[scores$trajectory == main_trajs[i], ]

        # fit loess model for data
        model = loess(var ~ global_pseudotimes, data = scores_t, span = 10, 
                      se = TRUE, control = loess.control(surface = "direct"))

        # get n_ints (100) equal points for pseudotime score, and fit to get var value
        x_fit = seq(0, 1, length = n_ints)
        y_fit = predict(model, newdata = data.frame(global_pseudotimes = x_fit))

        df_conc$x[((i - 1) * n_ints + 1):(i * n_ints)] = x_fit
        df_conc$y[((i - 1) * n_ints + 1):(i * n_ints)] = unname(y_fit)
        df_conc$traj[((i - 1) * n_ints + 1):(i * n_ints)] = main_trajs[i]

}

group_cols = cols[unique(as.numeric(unique(df_conc$traj))) + 1]
names(group_cols) = unique(df_conc$traj)

# ------------------------------------------------------------------------------
# Produce Plots
# ------------------------------------------------------------------------------
# start offline plot
out_name = gsub(" ", "_", toTitleCase(weights$name[var_i]))
png(paste0("plots/Traj_", out_name, ".png"), width = 600, height = 600)

# make plot
ggplot(df_conc, aes(x = x, y = y, group = traj, color = traj)) + 
       geom_smooth(orientation = "x", span = 15,
                   linewidth = 2, se = FALSE, fullrange = TRUE) +
       ggtitle(sprintf("Trend of %s In %i Dominant Trajectories",
                       gsub("_", " ", weights$name[var_i]), length(group_cols))) +
       ylab(toTitleCase(weights$name[var_i])) + 
       xlab("Hyper Score [0-1]") +
       scale_color_manual("Trajectories", values = group_cols) +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# stop offline plot
dev.off()
