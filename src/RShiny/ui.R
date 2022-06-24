### This file defines the layout and apperance of the R Shiny App

# Define UI for app that draws a histogram ----
ui = fluidPage(
  
  # App title ----
  titlePanel("Hypertension Progression in the UK Biobank"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # ---- Sidebar panel for inputs ----
    sidebarPanel(
      
      # display help text
      helpText("Interactive Components"),
      
      # Input: Slider for the x limits
      sliderInput(inputId = "xlim",
                  label = h3("Adjust Axis Limits:"), pre = "x = ",
                  min = 0, max = 1, value = c(0, 1)),

      # Input: change between loess and linear regression
      radioButtons(inputId = "lobf",
                   label = h3("Line Of Best Fit:"),
                   choices = list("Linear Regression" = "lr",
                                  "Local Regression (LOESS)" = "loess"),
                   selected = "lr"),
      
      # Input: Slider for smoothing factor of the line of best fit
      #sliderInput(inputId = "smooth",
      #            label = h3("Adjust Linear Smoothing:"), 
      #            min = 0, max = 5, value = 1, step = 0.1, animate = TRUE),
      
      # Input: Buttons to select for grouping variable
      radioButtons(inputId = "groupby",
                   label = h3("Group Plot By:"),
                   choices = list("Blood Pressure Group" = "bp_group",
                                  "Trajectory" = "trajectory"),
                   selected = "bp_group"),
      
      # Input: Drop down list of variables to plot against
      selectInput(inputId = "y_var_name",
                  label = "Choose Y-Axis Variable To Plot:",
                  choices = sort(varnames$display),
                  selected = "LV ejection fraction (2)"),
      
    ),
    
    # ---- Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Main Display
      plotOutput(outputId = "pseudo_time_plot")
      
    )
  
  ),
)

