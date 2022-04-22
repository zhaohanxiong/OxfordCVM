
library(scales)
library(ggplot2)
library(data.table)

gg_color_hue = function(n) {
  
  # this function gets the default gg_plot color template
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]

}

plot_boxplot_by_group = function(data, y, group,
                                 title = "Plot By Group",
                                 xlab = "x lab", ylab = "y lab",
                                 labels = c("Group 1", "Group 2"),
                                 ylimits = c(min(y, na.rm=TRUE),
                                             max(quantile(y, 0.99), na.rm=TRUE)),
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
  
  # this function 
  
  # intiailzie the output file if needed
  # else just open new window for plotting
  if (save) pdf(file.path(save_path,".pdf"), width = 20, height = 10)
  
  # extract the trend of each group
  grad = c()
  y_intercept = c()
  
  for (i in unique(group)) {
    
    # get x and y variables
    x_i = x[group == i]
    y_i = y[group == i]
    
    # fit linear model
    lm_i = lm(formula = y_i ~ x_i)

    # extract coefficients
    y_intercept = c(y_intercept, lm_i$coefficients[1])
    grad = c(grad, lm_i$coefficients[2])
    
  }
  
  # extract the centroids for each group
  centroids = aggregate(cbind(x, y) ~ group, data, mean)
  
  # produce plot
  p = ggplot(psuedotimes, aes(y = y, x = x,
                              group = as.factor(group))) +
        geom_point(aes(color = as.factor(group)), shape = 1, alpha = 0.5) +
        geom_point(data = centroids, aes(fill = as.factor(group)), size = 5, 
                   color = "black", shape = 21) + 
        scale_y_continuous(limits = ylimits) +
        ggtitle(title) + xlab(xlab) + ylab(ylab) +
        theme(legend.title = element_blank()) #+
        #geom_abline(slope = grad, intercept = y_intercept, 
        #            size = 1, linetype = "longdash")
  
  # close the plotting tool if needed
  if (save) dev.off()
  
  return(p)

}
