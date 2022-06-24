library(shiny)
library(ggplot2)
library(data.table)

# load data
path = "../fmrib/NeuroPM/io/" # "C:/Users/zxiong/Desktop/io"

# # # TO DO!!!!!
# load ukb raw variables
ukb_df = data.frame(fread(file.path(path, "ukb_num.csv"),header=TRUE))

# load variables used in cTI
varnames = read.csv(file.path(path, "ukb_varnames.csv"), header=TRUE)

# load output of cTI
pseudotimes = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)

# redefine groups for analysis: assign bp_groups as the real labels
pseudotimes$bp_group[pseudotimes$bp_group == 0] = "Between"
pseudotimes$bp_group[pseudotimes$bp_group == 1] = "Background"
pseudotimes$bp_group[pseudotimes$bp_group == 2] = "Disease"
pseudotimes$bp_group = ordered(pseudotimes$bp_group,
                               levels = c("Background", "Between", "Disease"))

# get first trajectory for nodes in multiple traj (~10 only)
pseudotimes$trajectory = sapply(strsplit(pseudotimes$trajectory, ","), function(x) x[1])

# set deploy option as true or false
deploy = FALSE # TRUE FALSE

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
  runApp(appDir = ".",
         display.mode = "showcase",
         test.mode = getOption("shiny.testmode", FALSE))
  
}
