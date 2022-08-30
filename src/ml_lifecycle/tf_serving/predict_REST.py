import requests
import pandas as pd

# load data
sample = pd.read_csv("../../fmrib/NeuroPM/io/ukb_num_norm.csv").iloc[0]

# (to do later) normalize data values according to original ukb_mat column-wise mean/sd

# convert to dict list for input
json_data = {"instances": sample.to_numpy()[None,:].tolist()}

# define endpoint
endpoint = "http://localhost:8501/v1/models/cti_model:predict"

# send request using REST API
response = requests.post(endpoint, json=json_data)

# retrieve prediction
print(response.json()["predictions"])
