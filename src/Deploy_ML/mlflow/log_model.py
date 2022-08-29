import numpy as np
import pandas as pd
import tensorflow as tf

# load model
cTI_model = tf.keras.models.load_model("../Deploy_ML/tf_serving_container/saved_models/2/")

# Arrange
# load test data
test_sample = pd.read_csv("../../fmrib/NeuroPM/io/ukb_num_norm.csv").fillna(0)
test_sample = test_sample.sample(n = 100, random_state = 1)

# load labels
test_label = pd.read_csv("../../fmrib/NeuroPM/io/pseudotimes.csv")
test_label = test_label.sample(n = 100, random_state = 1)

# Action
# make inference for each row
pred = []
for i in range(test_sample.shape[0]):
    pred.append(cTI_model.predict(test_sample[None, i, :], verbose = 0)[0])

gt, pred = test_label["global_pseudotimes"].to_numpy(), np.array(pred)

