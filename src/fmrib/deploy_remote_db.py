import os
import json
import sqlalchemy
import pandas as pd

# source path & set the current working directory
path = "src/fmrib/NeuroPM/io/"

# credentials
aws_cred = json.load(open("../keys/aws/postgresql.json"))

# set up connection to database
url = 'postgresql+psycopg2://' + aws_cred['user'] + ':' + aws_cred['passw'] + \
       '@' + aws_cred['host'] + ':' + aws_cred['port'] + '/' + aws_cred['database']
engine = sqlalchemy.create_engine(url, echo = False)

# load data frames to deploy
pseudotimes = pd.read_csv(os.path.join(path, "pseudotimes.csv"), index_col = False)
ukb_varnames = pd.read_csv(os.path.join(path, "ukb_varnames.csv"), index_col = False)

# deploy data frames to to AWS
pseudotimes.to_sql(name = "psuedotimes", con = engine, if_exists = "replace")
ukb_varnames.to_sql(name = "ukb_varnames", con = engine, if_exists = "replace")

'''
# query tool
# initialize connected database
connection = engine.connect()
metadata = sqlalchemy.MetaData()

# create pointer to database table
table = sqlalchemy.Table('psuedotimes', metadata, autoload = True, \
                                        autoload_with = engine)

# query table
sql_query = sqlalchemy.select([table.columns.patid, \
                               table.columns.global_pseudotimes]). \
                where(sqlalchemy.and_(table.columns.bp_group == 2, \
                                      table.columns.global_pseudotimes > 0.8))
query_result = connection.execute(sql_query).fetchall()
'''
