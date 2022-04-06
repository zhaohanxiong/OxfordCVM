library(ggplot2)

plot_boxplot_by_group = function(data, y, group,
                                 title = "Plot By Group",
                                 xlab = "x lab", ylab = "y lab",
                                 labels = c("Group 1", "Group 2"),
                                 ylimits = c(min(y, na.rm=TRUE),
                                             max(quantile(y, 0.95), na.rm=TRUE)),
                                 save = FALSE, save_path = "") {
  
  # this function produces a boxplot given a dataframe, the name of the
  # y-variable, and the name of the group we want to plot by group by
  # there is also an option to save the plot given a file path to write to
  
  # intiailzie the output file if needed
  # else just open new window for plotting
  if (save) pdf(file.path(save_path,".pdf"), width = 20, height = 10)

  # produce the plot
  p = ggplot(data, aes(y = y,
                       x = as.factor(group),
                       fill = as.factor(group))) +
      geom_boxplot() +
      #geom_point(aes(fill = as.factor(group)), 
      #           position = position_jitterdodge(),
      #           shape = 1) +
      scale_fill_discrete(labels = labels) +
      scale_y_continuous(limits = ylimits) +
      ggtitle(title) + xlab(xlab) + ylab(ylab) +
      theme(legend.title = element_blank())
  
  # close the plotting tool if needed
  if (save) dev.off()
  
  return(p)
  
}

plot_line_by_group = function(data, x, y, group,
                              title = "Plot By Group",
                              xlab = "x lab", ylab = "y lab",
                              ylimits = c(min(y, na.rm=TRUE),
                                          max(quantile(y, 0.95), na.rm=TRUE)),
                              save = FALSE, save_path = "") {
  
  # intiailzie the output file if needed
  # else just open new window for plotting
  if (save) pdf(file.path(save_path,".pdf"), width = 20, height = 10)
  
  # 
  n_groups = length(unique(group))
  
  for (i in 1:n_groups) {
    
    
    
  }
  
  # produce plot
  p = ggplot(psuedotimes, aes(y = y,
                              x = x,
                              group = as.factor(group))) +
        geom_point(aes(color = as.factor(group)), shape = 1, alpha = 0.5) +
        scale_y_continuous(limits = ylimits) +
        ggtitle(title) + xlab(xlab) + ylab(ylab) +
        theme(legend.title = element_blank())
  
  # close the plotting tool if needed
  if (save) dev.off()
  
  return(p)

}
