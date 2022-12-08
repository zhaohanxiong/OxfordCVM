import grpc
import pandas as pd
import tensorflow as tf
from tensorflow_serving.apis import predict_pb2, prediction_service_pb2_grpc

# load data (change index to change different sample)
sample = pd.read_csv("../../modelling/NeuroPM/io/ukb_num_norm.csv").iloc[1]

# (to do later) normalize data values according to original ukb_mat column-wise mean/sd

# transform into input tensor for model (expand first index for tf input)
input_tensor = tf.make_tensor_proto(sample.to_numpy()[None,:].tolist())

# open channel
channel = grpc.insecure_channel('localhost:8500') # local docker
#channel = grpc.insecure_channel('3.234.183.226:8500') # aws fargate/ECS/ECR

# create connection
stub = prediction_service_pb2_grpc.PredictionServiceStub(channel)

# build request
req = predict_pb2.PredictRequest()
req.model_spec.name = "cti_model-stable"
req.model_spec.signature_name = "serving_default"
req.inputs["cTI_input"].CopyFrom(input_tensor)

# send request and make prediction
response = stub.Predict(req, 240)

# retrieve prediction
print(response.outputs["c_ti_tf_layer"].float_val)
