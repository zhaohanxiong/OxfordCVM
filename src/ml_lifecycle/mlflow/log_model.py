import mlflow
import numpy as np
import pandas as pd
import tensorflow as tf

# load model
cTI_model = tf.keras.models.load_model("../tf_serving_container/saved_models/2/")

# set random seed
rs = 2

# load data & labels
test_sample = pd.read_csv("../../fmrib/NeuroPM/io/ukb_num_norm.csv").fillna(0)
test_sample = test_sample.sample(n = 100, random_state = rs).to_numpy()
test_label = pd.read_csv("../../fmrib/NeuroPM/io/pseudotimes.csv")
test_label = test_label.sample(n = 100, random_state = rs)

# start mlflow session for tracking
with mlflow.start_run():

    # make inference for each row
    pred = []
    for i in range(test_sample.shape[0]):
        pred.append(cTI_model.predict(test_sample[None, i, :], verbose = 0)[0])

    # transform gt/pred into array
    gt, pred = test_label["global_pseudotimes"].to_numpy(), np.array(pred)

    # evaluate accuracy of predictions against ground truths
    rmse = np.mean(np.sqrt((gt - pred)**2))

    # log metric to mlflow server manually
    # automatic logging can also be performed: https://www.mlflow.org/docs/latest/tracking.html#tensorflow-and-keras
    mlflow.log_metric(key = "RMSE", value = rmse)
