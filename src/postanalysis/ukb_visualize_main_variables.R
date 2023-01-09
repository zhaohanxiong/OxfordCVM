library(tools)
library(ggplot2)
library(gridExtra)
library(data.table)

path = "../modelling/NeuroPM/io"

# manually list out variables to plot hyperscore against
vars      = c("X22423.2.0",
              "X22421.2.0",
              "X25781.2.0", 
              "X25019.2.0",
              "X25020.2.0")
var_names = c("LV SV",
              "LV EDV",
              "WM Hyperintensity",
              "Hippocampus Volume",
              "Hippocampus Volume")

# load data
scores = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)
ukb = data.frame(fread(file.path(path, "ukb_num_norm_ft_select.csv"), header=TRUE))

# intialize the dataframe with all the hyperscores repeated, and var column
df_conc = data.frame(x = rep(scores$global_pseudotimes, length(vars)),
                     y = NA, # placeholder
                     name = rep(var_names, each = nrow(scores)))

# partition hyper scores into intervals (could be variable)
df_conc$x = cut(df_conc$x, breaks = seq(0, 1, length = 11))

# iterate all the variables and compile into one dataframe
for (i in 1:length(vars)) {

        # define variable values from ukb column
        v = ukb[, vars[i]]

        # assign values to collated df
        df_conc$y[((i - 1) * nrow(scores) + 1):(i * nrow(scores))] = v

}

# remove rows with missing values
df_conc = df_conc[!is.na(df_conc$x) & !is.na(df_conc$y), ]

# Compute median hyperscore per interval for each variable
df_plot = aggregate(list(y = df_conc$y),
                    by = list(x = df_conc$x, name = df_conc$name),
                    "median")
df_plot$x = sapply(strsplit(gsub("\\(|\\]", "", df_plot$x), ","),
                    function(xx) mean(as.numeric(xx)))
df_plot$x = as.factor(df_plot$x)
df_plot$name = as.factor(df_plot$name)

# produce plot
p = ggplot(df_plot, aes(x = x, y = y, group = name, color = name)) + 
        geom_point(size = 7.5, alpha = 0.25) +
        geom_smooth(orientation = "x", method = "loess", span = 5, 
                    linewidth = 2, se = FALSE, fullrange = TRUE) +
        ggtitle("Trend of Clinical Variables vs Hyper Score") +
        xlab("Hyper Score [0 to 1]") +
        ylab("Clinical Variables (Normalized Z-Score)") +
        labs(color = "Variable Name") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
              plot.title = element_text(size = 15, face = "bold"))

# write plot
png(file.path(path, "final_plot5_ClinicalVariables.png"), width = 600, height = 600)
grid.arrange(p)
dev.off()

# print ending message
cat(sprintf("---------- Core Plots Generation Complete"))
cat("\n")
