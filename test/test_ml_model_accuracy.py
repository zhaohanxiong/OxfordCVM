import os
import numpy as np
import pandas as pd
import tensorflow as tf

def compute_rmse(x, y):

    '''
    This function computes the root mean squared error (RMSE) given ground 
    truth (x) and prediction (y). Inputs must be numpy arrays.
    '''
    return(np.mean(np.sqrt((x - y)**2)))

def test_cti_model():

    # Arrange
    # define paths for i/o
    path_model     = "src/ml_lifecycle/tf_serving/saved_models/2/"
    path_data      = "src/fmrib/NeuroPM/io/"
    path_data_val  = os.path.join(path_data, "ukb_num_norm_ft_select.csv")
    path_data_lab  = os.path.join(path_data, "pseudotimes.csv")
    path_data_pred = os.path.join(path_data, "cTI_inference_all_data.csv")

    # load model
    cTI_model = tf.keras.models.load_model(path_model)

    # load test data
    test_sample = pd.read_csv(path_data_val)
    test_sample = test_sample.fillna(0)
    test_sample = test_sample.sample(n = test_sample.shape[0], random_state = 1).to_numpy()

    # load labels
    test_label = pd.read_csv(path_data_lab)
    test_label = test_label.sample(n = test_sample.shape[0], random_state = 1)

    # Action
    # make inference for each row of data
    pred = []
    for i in range(test_sample.shape[0]):
        pred.append(cTI_model.predict(test_sample[None, i, :], verbose = 0)[0])

    gt, pred = test_label["global_pseudotimes"].to_numpy(), np.array(pred)
    
    # compute overall accuracy
    rmse = compute_rmse(gt, pred)

    # compute group-wise accuracy
    group        = test_label["bp_group"].to_numpy()
    rmse_healthy = compute_rmse(gt[group == 1], pred[group == 1])
    rmse_disease = compute_rmse(gt[group == 2], pred[group == 2])

    # Assert
    # if the error is under the acceptable value
    assert rmse < 0.025
    assert rmse_healthy < 0.01
    assert rmse_disease < 0.05

    # write to output
    pandas_out_dict = {"score_pred": pred,
                       "score_gt":   gt,
                       "bp_group":   test_label["bp_group"]}
    pd.DataFrame(pandas_out_dict).to_csv(path_data_pred, index = False)
    