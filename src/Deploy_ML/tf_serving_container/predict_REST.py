import requests
import pandas as pd

# load data
sample = pd.read_csv("../../fmrib/NeuroPM/io/sample_test_data/sample_background.csv").fillna(0)

# convert to dict list for input
json_data = {"instances": sample.to_numpy().tolist()}

# define endpoint
endpoint = "http://localhost:8501/v1/models/cti_model:predict"

# send request using REST API
response = requests.post(endpoint, json=json_data)

# retrive preidction
print(response.json()["predictions"][0])