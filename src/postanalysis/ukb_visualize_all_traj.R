library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

n_traj = 3 # number of trajectories
figure_out = FALSE # write figures out or not

# define data path
path = "../modelling/NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)

# load variable weighting outputs
weights = read.csv(file.path(path, "var_weighting.csv"),
                             header=TRUE, stringsAsFactor=FALSE)
weights = weights[order(weights$Node_contributions, decreasing = TRUE), ]
weights = weights[weights$Significant, ]

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

# create new columns for assigning trajectories with different trend
traj_cols = rownames(TukeyHSD(aov(global_pseudotimes ~ trajectory,
                                  scores[scores$trajectory %in% main_trajs, ]))$trajectory)
weights[, traj_cols] = NA

# iterate through different variables (top 50 highest weighted)
#for (var_i in c(43, 5, 30, 462)) {
for (var_i in 1:nrow(weights)) {

        print(sprintf("%s ----- %s", var_i, weights$name[var_i]))

        # copy score data frame
        scores_i = scores

        # assign variable index to view
        scores_i$var = ukb[, weights$Var1[var_i]]

        # filter out non-major trajectories
        scores_i = scores_i[scores_i$trajectory %in% main_trajs, ]
        
        # intialize the dataframe with all the hyperscores repeated, and var column
        n_ints = 20
        df_long = data.frame(x = rep(NA, n_ints * length(main_trajs)), y = NA, traj = NA)
        x_fit = seq(0, 1, length = n_ints)

        # iterate through all traj
        for (i in 1:length(main_trajs)) {

                # get relevant rows for each traj
                scores_t = scores_i[scores_i$trajectory == main_trajs[i], ]

                # fit loess model for data
                model = loess(var ~ global_pseudotimes, data = scores_t, span = 5, 
                              se = TRUE, control = loess.control(surface = "direct"))

                # get n_ints equal points for pseudotime score, and fit to get var value
                y_fit = unname(predict(model, 
                                       newdata = data.frame(global_pseudotimes = x_fit)))

                # concatenate the values for this trajectory in long format
                df_long$x[((i - 1) * n_ints + 1):(i * n_ints)] = x_fit
                df_long$y[((i - 1) * n_ints + 1):(i * n_ints)] = y_fit
                df_long$traj[((i - 1) * n_ints + 1):(i * n_ints)] = main_trajs[i]

        }

        if (figure_out) {

                # assign colours and name the colours to be labelled during ggploting
                group_cols = cols[unique(as.numeric(unique(df_long$traj))) + 1]
                names(group_cols) = unique(df_long$traj)

                # start offline plot
                out_name = gsub(" ", "_", toTitleCase(weights$name[var_i]))
                png(paste0("plots/Traj_", out_name, ".png"), width = 600, height = 600)
                
                # make plot
                p = ggplot(df_long, aes(x = x, y = y, group = traj, color = traj)) + 
                        geom_smooth(formula = y ~ x, orientation = "x", method = 'loess',
                                span = 15, linewidth = 2, se = FALSE, fullrange = TRUE) +
                        ggtitle(sprintf("Trend of %s In %i Dominant Trajectories",
                                        gsub("_", " ", weights$name[var_i]), length(group_cols))) +
                        ylab(toTitleCase(weights$name[var_i])) + 
                        xlab("Hyper Score [0-1]") +
                        scale_color_manual("Trajectories", values = group_cols) +
                        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
                        plot.title = element_text(size = 15, face = "bold"))
                
                # including print statment to invoke png i/o function
                print(p)
                
                # stop offline plot
                dev.off()

        }

        # perform comparison
        df_long$traj = as.factor(df_long$traj)
        traj_diff = TukeyHSD(aov(y ~ traj, df_long))
        
        # assign p-values to new columns, assign bool for significant or not
        weights[var_i, traj_cols] = traj_diff$traj[, c("p adj")] < 0.01

}

# write out traj comparison information
write.csv(weights, "plots/weight_traj.csv", row.names = FALSE)
