import os
import json
import boto3
import sqlalchemy
import pandas as pd

# source path of data and switch to this path
path = "src/fmrib/NeuroPM/io/"
os.chdir(path)

# AWS RDS credentials
aws_cred = json.load(open("../../../../../keys/aws/postgresql.json"))

# set up connection to AWS RDS postgresql
url = 'postgresql+psycopg2://' + aws_cred['user'] + ':' + aws_cred['passw'] + \
       '@' + aws_cred['host'] + ':' + aws_cred['port'] + '/' + aws_cred['database']
engine = sqlalchemy.create_engine(url, echo = False)

# load data frames to deploy
pseudotimes = pd.read_csv("pseudotimes.csv", index_col = False)
ukb_varnames = pd.read_csv("ukb_varnames.csv", index_col = False)

# deploy data frames to to AWS
pseudotimes.to_sql(name = "psuedotimes", con = engine, if_exists = "replace")
ukb_varnames.to_sql(name = "ukb_varnames", con = engine, if_exists = "replace")

# AWS S3 credentials
aws_cred = pd.read_csv("../../../../../keys/aws/s3.csv")

# set up connection to AWS S3
s3_client = boto3.client('s3', aws_access_key_id = aws_cred['Access key ID'][0], \
                               aws_secret_access_key = aws_cred['Secret access key'][0])

# load large ukb variable dataframe (over 1000 columns)
ukb_num = pd.read_csv("ukb_num.csv", index_col = False)

# deploy to AWS S3
response = s3_client.upload_file("ukb_num.csv", "biobank-s3", "ukb_num.csv")

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
