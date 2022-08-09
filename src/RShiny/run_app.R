# -------------------- Application Dependencies --------------------
library(data.table)
library(shiny)
library(ggplot2)

# -------------------- Connect to Data Base --------------------
# read from AWS or locally
local = TRUE

if (!local) { # connecting to AWS
  
  library(rjson)
  #library(aws.s3)
  library(RPostgres)

  # retrieve s3 credentials
  #aws_cred = read.csv("../../../keys/aws/s3.csv")
  
  # create connection to S3
  #Sys.setenv("AWS_ACCESS_KEY_ID" = aws_cred$Access.key.ID,
  #           "AWS_SECRET_ACCESS_KEY" = aws_cred$Secret.access.key,
  #           "AWS_DEFAULT_REGION" = "us-east-1"
  #)
  
  # read table from s3 using data.table and convert to dataframe
  #ukb_df = s3read_using(FUN = data.table::fread,
  #                      bucket = "biobank-s3", object = "ukb_num.csv")
  #ukb_df = data.frame(ukb_df)
  
  # retrieve rds credentials
  aws_cred =  fromJSON(file = "../../../keys/aws/postgresql.json")
  
  # create connection to RDS
  con = dbConnect(RPostgres::Postgres(),
                  dbname = aws_cred$database, 
                  host = aws_cred$host, port = 5432, 
                  user = aws_cred$user, password = aws_cred$passw)
  
  # load and store tables
  varnames = dbFetch(dbSendQuery(con, "SELECT * FROM ukb_varnames"))
  pseudotimes = dbFetch(dbSendQuery(con, "SELECT * FROM pseudotimes"))
  ukb_df = dbFetch(dbSendQuery(con, "SELECT * FROM ukb_num"))
  
} else { # read from local storage
  
  # set data path
  path = "../fmrib/NeuroPM/io/" # "C:/Users/zxiong/Desktop/io"
  
  # load variables used in cTI
  varnames = read.csv(file.path(path, "ukb_varnames.csv"), header=TRUE)
  
  # load ukb raw variables
  ukb_df = data.frame(fread(file.path(path, "ukb_num_reduced.csv"),header=TRUE))
  
  # load output of cTI
  pseudotimes = read.csv(file.path(path, "pseudotimes.csv"), header=TRUE)
  
}

# -------------------- Preprocess On-The-Fly --------------------
# redefine groups for analysis: assign bp_groups as the real labels
pseudotimes$bp_group[pseudotimes$bp_group == 0] = "Between"
pseudotimes$bp_group[pseudotimes$bp_group == 1] = "Background"
pseudotimes$bp_group[pseudotimes$bp_group == 2] = "Disease"
pseudotimes$bp_group = ordered(pseudotimes$bp_group,
                               levels = c("Background", "Between", "Disease"))

# get first trajectory for nodes in multiple traj (~10 only)
psuedotimes$trajectory = as.numeric(sapply(strsplit(psuedotimes$trajectory, ","), 
                                                                 function(x) x[1]))

# combine data frames together
ukb_df = cbind(pseudotimes, ukb_df)

# set some variables as categorical
ukb_df$X31.0.0 = factor(ifelse(ukb_df$X31.0 == 0, "Female", "Male"))
ukb_df$trajectory = factor(ukb_df$trajectory)

# only keep varnames which are in UKB dataframe
varnames = varnames[varnames$colname %in% colnames(ukb_df), ]

# -------------------- Run Shiny Application --------------------
# set deploy option as true or false
deploy = FALSE

# deploy on shinyapp.io (hosted by R-Shiny)
if (deploy) {
  
  # load shinyapps.io dependency
  library(rsconnect)
  
  # read token and secret
  shiny_io_token = readLines("../../../keys/shiny/account.token")
  shiny_io_secret = readLines("../../../keys/shiny/account.secret")
  
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
