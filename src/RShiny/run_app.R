library(shiny)

# load R-shiny application setups
source("ui.R") # layout and appearance
source("server.R") # building the app

# set deploy option as true or false
deploy = FALSE

# deploy on shinyapp.io (hosted by R-Shiny)
if (deploy) {
  
  # load shinyapps.io dependency
  library(rsconnect)
  
  # read token and secret
  shiny_io_token = readLines("account.token")
  shiny_io_secret = readLines("account.secret")
  
  # connect to account hosted on shinyapps.io
  rsconnect::setAccountInfo(name = 'zhaohanxiong',
                            token = shiny_io_token,
                            secret = shiny_io_secret)
  
  # deploy to shinyapps.io
  rsconnect::deployApp('.')
  
} else { # host locally on computer
  
  # Create the R shiny app
  #shinyApp(ui = ui, server = server)
  runApp(appDir = ".",
         display.mode = "showcase",
         test.mode = getOption("shiny.testmode", FALSE))
  
}