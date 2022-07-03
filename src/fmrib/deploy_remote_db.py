# https://towardsdatascience.com/work-with-sql-in-python-using-sqlalchemy-and-pandas-cd7693def708
# https://www.postgresqltutorial.com/postgresql-python/connect/
# https://alexcodes.medium.com/upload-csv-files-to-postgresql-aws-rds-using-pythons-psycopg2-613992fcd7b

import os
import sqlalchemy
from sqlalchemy.types import Integer, Text, String, DateTime
import pandas as pd

# source path & set the current working directory
path = "src/fmrib/NeuroPM/io/"

# load data frames to deploy
pseudotimes = pd.read_csv(os.path.join(path, "pseudotimes.csv"), index_col=False)
ukb_num = pd.read_csv(os.path.join(path, "ukb_num.csv"), index_col=False)

# create connection to database
url = 'postgresql+psycopg2://username:password@host:port/database'
engine = sqlalchemy.create_engine(url)

# write to new table
if True:
    pseudotimes.to_sql("biobank", con = engine, if_exists = "replace", schema = "ukb", 
                       index = True, chucksize = 1000,
                       dytype = {})
    

# convert to SQL


# deploy to AWS
