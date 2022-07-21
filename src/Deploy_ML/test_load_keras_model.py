import pandas as pd
import tensorflow as tf

# load model
cTI_model = tf.keras.models.load_model("tf_serving_container/saved_models/1/")

# load test data
sample = pd.read_csv("../fmrib/NeuroPM/io/sample_test_data/sample_background.csv").fillna(0).to_numpy()

# make inference
pred_out = cTI_model.predict(sample)

print(pred_out)