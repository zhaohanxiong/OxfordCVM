### This file defines the logic and functionality of the R Shiny App

# Define server logic required to draw a histogram ----
server = function(input, output) {
  
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot

  # define plot to feed into UI
  output$pseudo_time_plot = renderPlot({
    
    # data base to plot from (currently in RAM, but need to switch to SQL)
    df = ukb_df

    # define name of variable to plot
    x_var_name = "global_pseudotimes"
    y_var_name = varnames$colname[varnames$display == input$y_var_name]
    
    # define grouping variable
    group_name = input$groupby

    # calculate regression line
    if (input$lobf == "lr") {
      lr_model = lm(df[, y_var_name] ~ df[, x_var_name])
      fit = list(x = seq(0, 1, length = nrow(df)))
      fit$y = lr_model$coefficients[1] + fit$x * lr_model$coefficients[2]
    } else if (input$lobf == "loess") {
      fit = lowess(df[ ,x_var_name], df[, y_var_name])
    }
  
    # calculate regression line upper and lower boundaries
    fit$upper = fit$y + qt(0.75, fit$y) * sd(fit$y)
    fit$lower = fit$y - qt(0.75, fit$y) * sd(fit$y)
    
    # produce plot
    ggplot(df, aes_string(x = x_var_name, y = y_var_name)) +
           geom_point(aes_string(color = group_name), shape = 19, alpha = 0.25, size = 2) +
           geom_line(aes(x = fit$x, y = fit$y), size = 1, color = "deepskyblue4", alpha = 0.5) +
           geom_ribbon(aes(fit$x, ymin = fit$lower, ymax = fit$upper), fill = "skyblue", alpha = 0.25) +
           #scale_x_continuous(trans = 'log10') +
           ggtitle("Distribution/Trend of Disease Progression Scores") +
           xlab("Pseudotime (Disease Progression) Scores (0-1)") + 
           ylab(input$y_var_name) +
           coord_cartesian(xlim = input$xlim) +
           #theme(legend.title = element_blank()) +
           scale_colour_brewer(palette = "Dark2")
    
  }, height = 600, width = 800)
  
}
