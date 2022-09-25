import os
import numpy as np
import pandas as pd
import tensorflow as tf
from utils import compute_rmse, update_test_dict

def test_ml_model_exist_shouldpass(mock_test_ml_model_exist_shouldpass):

    '''
    This function tests if the ML models exist in our directory for deploying
    to AWS elastic container registry and elastic container service. We also
    test that the docker files/images exist too as they will be pushed to the 
    remote registry.
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_ml_model_exist_shouldpass["key_group"],
                     mock_test_ml_model_exist_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_model = "src/aws/tf_serving/saved_models"

    # define subdirectories
    path_v1 = os.path.join(path_model, "1")
    path_v2 = os.path.join(path_model, "2")
    
    # Action
    # try load the model, do they exist? set flag for success or not
    try:
        # load model & set flags for passing read test
        cTI_model_v1 = tf.keras.models.load_model(path_v1)
        read_v1_successful = True
    except:
        # set flags for failing test
        read_v1_successful = False

    # try load the model, do they exist? set flag for success or not
    try:
        # load model & set flags for passing read test
        cTI_model_v2 = tf.keras.models.load_model(path_v2)
        read_v2_successful = True
    except:
        # set flags for failing test
        read_v2_successful = False

    # Assert
    # check if directories are empty
    assert len(os.listdir(path_v1)) > 0
    assert len(os.listdir(path_v2)) > 0
    
    # check if models were loaded successfully
    assert read_v1_successful and read_v2_successful

    # check functionality of model (query it)

    # set test flag to true if passed
    update_test_dict(mock_test_ml_model_exist_shouldpass["key_group"],
                     mock_test_ml_model_exist_shouldpass["key"],
                     True)

def test_ml_model_accuracy_shouldpass(mock_test_ml_model_accuracy_shouldpass):

    '''
    This function tests if the ML models passes the accuracy threshold
    requirements for predicting the disease score
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_ml_model_accuracy_shouldpass["key_group"],
                     mock_test_ml_model_accuracy_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_model     = "src/aws/tf_serving/saved_models/2/"
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

    # set test flag to true if passed
    update_test_dict(mock_test_ml_model_accuracy_shouldpass["key_group"],
                     mock_test_ml_model_accuracy_shouldpass["key"],
                     True)
