import os
import json
import sqlalchemy
import pandas as pd

# load AWS RDS credentials
aws_cred = json.load(open("../../../keys/aws/postgresql.json"))

# source path of data and switch to this path
path = "../modelling/NeuroPM/io/"
os.chdir(path)

# set up connection to AWS RDS postgresql
url = 'postgresql+psycopg2://' + aws_cred['user'] + ':' + aws_cred['passw'] + \
       '@' + aws_cred['host'] + ':' + aws_cred['port'] + '/' + aws_cred['database']
engine = sqlalchemy.create_engine(url, echo = False)

# load data frames to deploy
pseudotimes = pd.read_csv("pseudotimes.csv", index_col = False)
ukb_varnames = pd.read_csv("ukb_varnames.csv", index_col = False)
ukb_num = pd.read_csv("ukb_num_reduced.csv", index_col = False)

# deploy data frames to to AWS
pseudotimes.to_sql(name = "psuedotimes", con = engine, if_exists = "replace")
ukb_varnames.to_sql(name = "ukb_varnames", con = engine, if_exists = "replace")
ukb_num.to_sql(name = "ukb_num_reduced", con = engine, if_exists = "replace")

'''
# for writing to s3 (when ukb_num was too big for RDS)
import boto3

# AWS S3 credentials
aws_cred = pd.read_csv("../../../keys/aws/s3.csv")

# set up connection to AWS S3
s3_client = boto3.client('s3', aws_access_key_id = aws_cred['Access key ID'][0], \
                               aws_secret_access_key = aws_cred['Secret access key'][0])

# load large ukb variable dataframe (over 1000 columns)
ukb_num = pd.read_csv("ukb_num.csv", index_col = False)

# deploy to AWS S3
response = s3_client.upload_file("ukb_num.csv", "biobank-s3", "ukb_num.csv")
'''

'''
# RDS query tool
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

# retrive s3 object
# connect to bucket
s3 = boto3.resource(service_name = 's3',
                    aws_access_key_id = aws_cred['Access key ID'][0],
                    aws_secret_access_key = aws_cred['Secret access key'][0]
                    )

# Load csv file directly into python
s3_obj = s3.Bucket('biobank-s3').Object('ukb_num.csv').get()
ukb_mat = pd.read_csv(s3_obj['Body'], index_col=0)
'''
