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
    path_data_pred = os.path.join(path_data, "inference_cTI_ml_pred.csv")

    # load data
    ml_inf = pd.read_csv(path_data_pred)

    # Action
    # transform gt/pred into array
    gt   = ml_inf["score_gt"].to_numpy()
    pred = ml_inf["score_pred"].to_numpy()

    # compute overall accuracy
    rmse = compute_rmse(gt, pred)

    # compute group-wise accuracy
    group        = ml_inf["bp_group"].to_numpy()
    rmse_healthy = compute_rmse(gt[group == 1], pred[group == 1])
    rmse_disease = compute_rmse(gt[group == 2], pred[group == 2])

    # Assert
    # if the error is under the acceptable value
    assert rmse < 0.05
    assert rmse_healthy < 0.01
    assert rmse_disease < 0.05

    # set test flag to true if passed
    update_test_dict(mock_test_ml_model_accuracy_shouldpass["key_group"],
                     mock_test_ml_model_accuracy_shouldpass["key"],
                     True)
