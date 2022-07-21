import json
import requests
import pandas as pd

# load test data
sample = pd.read_csv("../fmrib/NeuroPM/io/sample_test_data/sample_disease.csv").fillna(0).to_numpy()

# set request
url = 'http://localhost:8501/v1/IG/default:predict'
data = json.dumps({"instances": sample.tolist()})
headers = {"content-type": "application/json"}
json_response = requests.post(url, data = data, headers = headers)
predictions = json.loads(json_response.text)['predictions']

print(predictions)