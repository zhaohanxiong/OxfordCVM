import numpy as np
import pandas as pd
import tensorflow as tf

def test_cti_model():

    # load model
    cTI_model = tf.keras.models.load_model("tf_serving_container/saved_models/2/")

    # Arrange
    # load test data
    #test_sample1 = pd.read_csv("../fmrib/NeuroPM/io/ukb_num_norm.csv").iloc[0].fillna(0).to_numpy()
    test_sample = pd.read_csv("../fmrib/NeuroPM/io/ukb_num_norm.csv").fillna(0).to_numpy()

    # load labels
    test_label = pd.read_csv("../fmrib/NeuroPM/io/pseudotimes.csv")

    # Action
    # make inference for each row
    pred = []
    for i in range(1000,1200):#range(test_sample.shape[0]):
        pred.append(cTI_model.predict(test_sample[None, i, :])[0])

    gt, pred = test_label["global_pseudotimes"].to_numpy(), np.array(pred)
    gt = gt[1000:1200]

    # compute accuracy
    rmse = np.mean(np.sqrt((gt - pred)**2))

    # Assert
    assert rmse < 0.1
    assert rmse < 0.05

test_cti_model()