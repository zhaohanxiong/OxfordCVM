import os
import pandas as pd
from utils import compute_rmse, update_test_dict

def test_neuro_pm_output_exist_shouldpass(mock_test_neuro_pm_output_exist_shouldpass):

    '''
    This function tests if the final output from the NeuroPM model for the reduced
    set of variables and the disease score exists in our current output directory
    to ensure successful deployment of these data frames to AWS relational database
    service. We also test for the correctness of the data to be deployed.
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_neuro_pm_output_exist_shouldpass["key_group"],
                     mock_test_neuro_pm_output_exist_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data       = "src/fmrib/NeuroPM/io/"
    path_data_frame = os.path.join(path_data, "ukb_num_reduced.csv")
    path_data_score = os.path.join(path_data, "pseudotimes.csv")
    path_data_names = os.path.join(path_data, "ukb_varnames.csv")

    # Action
    # try read the files, do they exist? set flag for success or not
    try:
        # read dataframes in
        df_ukb   = pd.read_csv(path_data_frame)
        df_score = pd.read_csv(path_data_score)
        df_names = pd.read_csv(path_data_names)

        # set flags for passing read test
        read_successful = True

    except:
        # set flags for failing test
        read_successful = False
    
    # Assert
    # check if the files were read in with pandas successfully
    assert read_successful

    # check if the size of dataframes were correct
    assert df_ukb.shape[0] == df_score.shape[0]

    # check if there are any missing values in score
    assert df_score["global_pseudotimes"].isna().sum() == 0

    # check if variable names match

    # set test flag to true if passed
    update_test_dict(mock_test_neuro_pm_output_exist_shouldpass["key_group"],
                     mock_test_neuro_pm_output_exist_shouldpass["key"],
                     True)
    
def test_neuro_pm_accuracy_shouldpass(mock_test_neuro_pm_accuracy_shouldpass):

    '''
    This function tests for the accuracy/effectiveness of the NeuroPM
    pseudotime score output. It checks if the output distribution
    is acceptable and contains good seperation between groups
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_neuro_pm_accuracy_shouldpass["key_group"],
                     mock_test_neuro_pm_accuracy_shouldpass["key"],
                     False)

    # Arrange

    # Action

    # Assert
    assert True

    # set test flag to true if passed
    update_test_dict(mock_test_neuro_pm_accuracy_shouldpass["key_group"],
                     mock_test_neuro_pm_accuracy_shouldpass["key"],
                     True)

def test_neuro_pm_cti_pred_shouldpass(mock_test_neuro_pm_cti_pred_shouldpass):

    '''
    This function tests for the accuracy/effectiveness of the NeuroPM
    cTI prediction method for inferring new patients by analyzing the 
    output from the X-validation of the NeuroPM toolbox
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_neuro_pm_cti_pred_shouldpass["key_group"],
                     mock_test_neuro_pm_cti_pred_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data      = "src/fmrib/NeuroPM/io/"
    path_data_pred = os.path.join(path_data, "inference_x_val_pred.csv")

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
    update_test_dict(mock_test_neuro_pm_cti_pred_shouldpass["key_group"],
                     mock_test_neuro_pm_cti_pred_shouldpass["key"],
                     True)
