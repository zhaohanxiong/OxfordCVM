library(tools)
library(ggplot2)
library(R.matlab)
library(gridExtra)
library(data.table)
rm(list=ls())
var_i = 1

# define columns of interest (visit 1 and 2) to this dataframe
analyze = c("X22423", # LV stroke volume
            "X22421", # LV end diastole volume
            "X25781", # white matter hyperintensities
            "X25019", # Hippocampus volume (left)
            "X25020") # Hippocampus volume (right)
analyze_names = c("LV SV",
                  "LV EDV",
                  "WM Hyperintensity",
                  "Hippocampus Volume (Left)",
                  "Hippocampus Volume (Right)")

# ------------------------------------------------------------------------------
# Load Data
# ------------------------------------------------------------------------------
# define data path
path = "../modelling/NeuroPM/io/"

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header = TRUE)

# load 1st visit values
ukb1 = data.frame(fread(file.path(path, "ukb_num_ft_select.csv"), 
                                                                header = TRUE))
ukb1_norm = data.frame(fread(file.path(path, "ukb_num_norm_ft_select.csv"), 
                                                                header = TRUE))

# load 2nd visit values
ukb2 = data.frame(fread(file.path(path, "ukb_num_ft_select_2nd_visit.csv"), 
                                                                header = TRUE))
ukb2_norm = data.frame(fread(file.path(path, "ukb_num_norm_ft_select_2nd_visit.csv"), 
                                                                header = TRUE))

# load transformation matrix into PC space
PC_transform = readMat(file.path(path, "PC_Transform.mat"))$Node.Weights

# ------------------------------------------------------------------------------
# Perform KNN Prediction
# ------------------------------------------------------------------------------
# prepare reference dataset from visit 1
PC_ukb1 = unname(as.matrix(ukb1_norm)) %*% PC_transform

# transform visit 2 data into PC space
PC_ukb2 = unname(as.matrix(ukb2_norm)) %*% PC_transform

# create dataframe for this score
pred = data.frame(patid = ukb2$eid, global_pseudotimes2 = NA)

# define number of K for KNN, also transpose ref matrix
k = 1
PC_ukb1_t = t(PC_ukb1)

# loop through each row and predict score 
for (i in 1:nrow(pred)) {
  
  # only use same bp group as current patient for reference
  group_i = scores$bp_group[scores$patid == pred$patid[i]]
  g_ind = scores$bp_group == group_i

  # compute KNN
  diff  = t(PC_ukb2[i, ] - PC_ukb1_t[, g_ind])
  dist  = rowMeans(abs(diff))
  top_k = scores$global_pseudotime[g_ind][order(dist)[1:k]]

  # store result
  pred$global_pseudotimes2[i] = mean(top_k)
  
}

# normalize results
#pred$global_pseudotimes2 = pred$global_pseudotimes2 - min(pred$global_pseudotimes2)
#pred$global_pseudotimes2 = pred$global_pseudotimes2 / max(pred$global_pseudotimes2)

# ------------------------------------------------------------------------------
# Merge Data For Analysis
# ------------------------------------------------------------------------------
# append 1st imaging visit values to original hyper score df
scores_analyze = cbind(scores, ukb1[, sapply(analyze, function(s) 
                                        grep(s, colnames(ukb1), value = TRUE))])

# append 2nd imaging visit values to original hyper score df
pred_analyze = cbind(pred, ukb2[, sapply(analyze, function(s)
                                        grep(s, colnames(ukb2), value = TRUE))])

# merge 2nd visit hyper scores into the 1st visit dataframe
follow_up = merge(scores_analyze, pred_analyze, by.x = "patid", by.y = "patid") 

# change blood pressure groups into a ordered factor for plotting
groups = c("Between", "Healthy", "Disease")
follow_up$bp_group = ordered(groups[follow_up$bp_group + 1], groups[c(2, 1, 3)])

# ------------------------------------------------------------------------------
# Aggregate Data for Plots
# ------------------------------------------------------------------------------
# define 2 variable columns to analyze
var_1st = grep(paste0(analyze[var_i], "\\.2\\."),
               colnames(follow_up), value = TRUE)
var_2nd = grep(paste0(analyze[var_i], "\\.3\\."),
               colnames(follow_up), value = TRUE)

# subset and remove missing values
df_plot = follow_up[, c("bp_group", "global_pseudotimes", "global_pseudotimes2",
                        var_1st, var_2nd)]
df_plot = df_plot[!is.na(df_plot[, var_1st]) & !is.na(df_plot[, var_2nd]), ]

# compute change in score and change in variable
df_plot$score_change = df_plot$global_pseudotimes2 - df_plot$global_pseudotimes
df_plot$var_change = df_plot[, var_2nd] - df_plot[, var_1st]

# convert from wide to long format for the 2 variables
df_plot2 = data.frame(score = c(df_plot$global_pseudotimes,
                                df_plot$global_pseudotimes2),
                      var   = c(df_plot[, var_1st], df_plot[, var_2nd]),
                      group = rep(df_plot$bp_group, 2),
                      visit = as.factor(rep(c("1st", "2nd"),
                                            each = nrow(df_plot))))

# ------------------------------------------------------------------------------
# Produce Outputs
# ------------------------------------------------------------------------------
# perform correlation test
cortest = cor.test(df_plot$score_change, df_plot$var_change)
print(sprintf("Pearson Correlation Test: R = %0.1f, p = %0.3f",
              cortest$estimate, cortest$p.value))

# produce plots
p1 = ggplot(df_plot2, aes(y = score, x = group, fill = visit)) + 
        geom_boxplot() +
        ggtitle("1st & 2nd Imaging Visit Hyper Scores") +
        ylab("Hyper Score") + 
        xlab("Blood Pressure Group") +
        theme(plot.title = element_text(size = 15, face = "bold"))

p2 = ggplot(df_plot, aes(x = score_change, y = var_change)) + 
        geom_point(size = 7.5, alpha = 0.25, color = "orange") +
        geom_smooth(span = 15, linewidth = 2, se = TRUE, color = "purple") +
        ggtitle(sprintf("Change in %s vs Change in Hyper Score",
                        toTitleCase(analyze_names[var_i]))) +
        xlab("Change in Hyper Score (2nd - 1st Imaging Visit)") + 
        ylab(sprintf("Change in %s (2nd - 1st Imaging Visit)",
                     toTitleCase(analyze_names[var_i]))) + 
        scale_fill_brewer(palette = "Dark2") +
        theme(plot.title = element_text(size = 15, face = "bold"))

# start offline plot, arrange multi-plot, then close plot
png("plots/temp_follow_up.png", width = 1200, height = 600)
grid.arrange(p1, p2, ncol = 2)
dev.off()
