library(ggplot2)

plot_box_by_group = function(data, y, group, 
                             title = "Plot By Group",
                             xlab = "x lab", ylab = "y lab",
                             labels = c("Group 1", "Group 2"),
                             save = FALSE, save_path = "") {
  
  # this function produces a boxplot given a dataframe, the name of the
  # y-variable, and the name of the group we want to plot by group by
  # there is also an option to save the plot given a file path to write to
  
  # intiailzie the output file if needed
  if (save)  pdf(file.path(save_path,".pdf"), width = 20, height = 10)
  
  # produce the plot
  p = ggplot(data, aes(y = y,
                       x = as.factor(group),
                       fill = as.factor(group))) +
      geom_boxplot() +
      geom_point(aes(fill = as.factor(group)), 
                 position = position_jitterdodge()) +
      scale_fill_discrete(labels = labels) +
      ggtitle(title) + xlab(xlab) + ylab(ylab) +
      theme(legend.title = element_blank(),
            axis.text.x = element_blank())
  
  # close the plotting tool if needed
  if (save) dev.off()
  
  return(p)
  
}

# # plot per bp_group
#


