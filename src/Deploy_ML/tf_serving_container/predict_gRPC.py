import grpc
import pandas as pd
import tensorflow as tf
from tensorflow_serving.apis import predict_pb2, prediction_service_pb2_grpc

# load data
sample = pd.read_csv("../../fmrib/NeuroPM/io/sample_test_data/sample_background.csv").fillna(0)

# transform into input tensor for model
input_tensor = tf.make_tensor_proto(sample.to_numpy().tolist())

# open challenge
channel = grpc.insecure_channel('localhost:8500')

# create connection
stub = prediction_service_pb2_grpc.PredictionServiceStub(channel)

# build request
req = predict_pb2.PredictRequest()
req.model_spec.name = "cti_model"
req.model_spec.signature_name = "serving_default"
req.inputs["cTI_input"].CopyFrom(input_tensor)

# send request and make prediction
response = stub.Predict(req, 240)

# retrieve prediction
print(response.outputs["c_ti_tf_layer"].float_val)