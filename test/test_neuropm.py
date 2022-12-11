import os
import numpy as np
import pandas as pd
from utils import compute_rmse, update_test_dict

def test_io_R_preprocess_output_exist_shouldpass(mock_test_io_R_preprocess_output_exist_shouldpass):

    '''
    This function tests if the output from preprocess_data_preparation.R is correct
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_io_R_preprocess_output_exist_shouldpass["key_group"],
                     mock_test_io_R_preprocess_output_exist_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data           = "src/modelling/NeuroPM/io/"
    path_data_frame_raw = os.path.join(path_data, "ukb_num.csv")
    path_data_frame     = os.path.join(path_data, "ukb_num_norm.csv")
    path_data_score     = os.path.join(path_data, "labels.csv")

    # Action
    # try read the files, do they exist? set flag for success or not
    try:
        # read dataframes in
        df_ukb_raw = pd.read_csv(path_data_frame_raw)
        df_ukb     = pd.read_csv(path_data_frame)
        df_score   = pd.read_csv(path_data_score)

        # set flags for passing read test
        read_successful = True

    except:
        # set flags for failing test
        read_successful = False
    
    # Assert
    # check if the files were read in with pandas successfully
    assert read_successful

    # check if the size/contents of dataframes were correct
    assert df_ukb.shape[0] == df_ukb_raw.shape[0]
    assert df_ukb.shape[0] == df_score.shape[0]
    assert len(df_score["bp_group"]) == df_score.shape[0]
    assert df_score["bp_group"].isna().sum() == 0
    assert len(df_score["BPSys-2.0"]) == df_score.shape[0]
    assert df_score["BPSys-2.0"].isna().sum() == 0
    assert len(df_score["BPDia-2.0"]) == df_score.shape[0]
    assert df_score["BPDia-2.0"].isna().sum() == 0

    # set test flag to true if passed
    update_test_dict(mock_test_io_R_preprocess_output_exist_shouldpass["key_group"],
                     mock_test_io_R_preprocess_output_exist_shouldpass["key"],
                     True)
    
def test_io_R_ft_select_output_exist_shouldpass(mock_test_io_R_ft_select_output_exist_shouldpass):

    '''
    This function tests if the output from preprocess_feature_selection.R is correct
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_io_R_ft_select_output_exist_shouldpass["key_group"],
                     mock_test_io_R_ft_select_output_exist_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data       = "src/modelling/NeuroPM/io/"
    path_data_frame = os.path.join(path_data, "ukb_num_norm_ft_select.csv")
    path_data_score = os.path.join(path_data, "labels_select.csv")

    # Action
    # try read the files, do they exist? set flag for success or not
    try:
        # read dataframes in
        df_ukb   = pd.read_csv(path_data_frame)
        df_score = pd.read_csv(path_data_score)

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
    assert len(df_score["bp_group"]) == df_score.shape[0]
    assert df_score["bp_group"].isna().sum() == 0
    assert len(df_score["BPSys.2.0"]) == df_score.shape[0]
    assert df_score["BPSys.2.0"].isna().sum() == 0
    assert len(df_score["BPDia.2.0"]) == df_score.shape[0]
    assert df_score["BPDia.2.0"].isna().sum() == 0

    # set test flag to true if passed
    update_test_dict(mock_test_io_R_ft_select_output_exist_shouldpass["key_group"],
                     mock_test_io_R_ft_select_output_exist_shouldpass["key"],
                     True)

def test_io_neuropm_output_exist_shouldpass(mock_test_io_neuropm_output_exist_shouldpass):

    '''
    This function tests if the output from NeuroPM matlab code is correct
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_io_neuropm_output_exist_shouldpass["key_group"],
                     mock_test_io_neuropm_output_exist_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data       = "src/modelling/NeuroPM/io/"
    path_data_score = os.path.join(path_data, "pseudotimes.csv")
    path_var_weight = os.path.join(path_data, "var_weighting.csv")
    path_threshold  = os.path.join(path_data, "threshold_weighting.csv")

    # read in ukb data file for comparison
    df_ukb = pd.read_csv(os.path.join(path_data, "ukb_num_norm_ft_select.csv"))

    # Action
    # try read the files, do they exist? set flag for success or not
    try:
        # read dataframes in
        df_score  = pd.read_csv(path_data_score)
        df_weight = pd.read_csv(path_var_weight)
        df_thresh = pd.read_csv(path_threshold)

        # set flags for passing read test
        read_successful = True

    except:
        # set flags for failing test
        read_successful = False
    
    # Assert
    # check if the files were read in with pandas successfully
    assert read_successful

    # check if the size/content of dataframes were correct
    assert df_score.shape[0] == df_ukb.shape[0]
    assert df_thresh.shape[0] == 1
    assert df_thresh["Expected_contribution"][0] > 0
    assert df_ukb.shape[1] == df_weight.shape[0]
    assert all(df_weight["Node_contributions"] > 0)

    # check if there are any missing values in score
    assert len(df_score["global_pseudotimes"]) == df_score.shape[0]
    assert df_score["global_pseudotimes"].isna().sum() == 0
    assert len(df_score["bp_group"]) == df_score.shape[0]
    assert df_score["bp_group"].isna().sum() == 0
    assert len(df_score["BPSys.2.0"]) == df_score.shape[0]
    assert df_score["BPSys.2.0"].isna().sum() == 0
    assert len(df_score["BPDia.2.0"]) == df_score.shape[0]
    assert df_score["BPDia.2.0"].isna().sum() == 0

    # set test flag to true if passed
    update_test_dict(mock_test_io_neuropm_output_exist_shouldpass["key_group"],
                     mock_test_io_neuropm_output_exist_shouldpass["key"],
                     True)

def test_io_neuropm_interm_output_exist_shouldpass(mock_test_io_neuropm_interm_output_exist_shouldpass):

    '''
    This function tests if the intermediate values from NeuroPM matlab code is correct
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_io_neuropm_interm_output_exist_shouldpass["key_group"],
                     mock_test_io_neuropm_interm_output_exist_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data = "src/modelling/NeuroPM/io/"
    files = os.listdir(path_data)

    # Action
    # define files to check
    path_MST     = os.path.join(path_data, "MST.mat")
    path_MST_csv = os.path.join(path_data, "MST.csv")
    path_dijk    = os.path.join(path_data, "dijkstra.mat")
    path_eig_mat = os.path.join(path_data, "PC_Transform.mat")

    # Assert
    # check if the files exist
    assert any(["MST.mat" == s for s in files])
    assert any(["MST.csv" == s for s in files])
    assert any(["dijkstra.mat" == s for s in files])
    assert any(["PC_Transform.mat" == s for s in files])

    # set test flag to true if passed
    update_test_dict(mock_test_io_neuropm_interm_output_exist_shouldpass["key_group"],
                     mock_test_io_neuropm_interm_output_exist_shouldpass["key"],
                     True)

# def test_io_R_postprocess_output_exist_shouldpas(mock_test_io_R_postprocess_output_exist_shouldpass):

#     '''
#     This function tests if the output from postprocess_files.R is correct
#     '''

#     # set test flag to false before running test
#     update_test_dict(mock_test_io_R_postprocess_output_exist_shouldpass["key_group"],
#                      mock_test_io_R_postprocess_output_exist_shouldpass["key"],
#                      False)

#     # Arrange
#     # define paths for i/o
#     path_data        = "src/modelling/NeuroPM/io/"
#     path_data_score  = os.path.join(path_data, "pseudotimes.csv")
#     path_var_names   = os.path.join(path_data, "ukb_varnames.csv")
#     path_var_weights = os.path.join(path_data, "var_weighting.csv")
#     path_data_frame  = os.path.join(path_data, "ukb_num_reduced.csv")

#     # Action
#     # try read the files, do they exist? set flag for success or not
#     try:
#         # read dataframes in
#         df_score       = pd.read_csv(path_data_score)
#         df_var_names   = pd.read_csv(path_var_names)
#         df_var_weights = pd.read_csv(path_var_weights)
#         df_ukb         = pd.read_csv(path_data_frame)

#         # set flags for passing read test
#         read_successful = True

#     except:
#         # set flags for failing test
#         read_successful = False
    
#     # Assert
#     # check if the files were read in with pandas successfully
#     assert read_successful

#     # check if the size of dataframes were correct
#     assert df_score.shape[0] == df_ukb.shape[0]
#     assert df_var_weights.shape[0] == df_ukb.shape[1]

#     # check if there are any missing values in score
#     assert df_score["global_pseudotimes"].isna().sum() == 0

#     # set test flag to true if passed
#     update_test_dict(mock_test_io_R_postprocess_output_exist_shouldpass["key_group"],
#                      mock_test_io_R_postprocess_output_exist_shouldpass["key"],
#                      True)

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
    # define paths for i/o
    path_data       = "src/modelling/NeuroPM/io/"
    path_data_score = os.path.join(path_data, "pseudotimes.csv")
    
    # read dataframes in
    df_score  = pd.read_csv(path_data_score)
    
    # compute group overlap
    scores_background = df_score.loc[df_score["bp_group"] == 1, 
                                     "global_pseudotimes"]
    scores_between = df_score.loc[df_score["bp_group"] == 0, 
                                  "global_pseudotimes"]
    scores_disease = df_score.loc[df_score["bp_group"] == 2,
                                  "global_pseudotimes"]
    q_background = np.quantile(scores_background, [0.25, 0.5, 0.75])
    q_between = np.quantile(scores_between, [0.25, 0.5, 0.75])
    q_disease = np.quantile(scores_disease, [0.25, 0.5, 0.75])

    # Assert
    # check values
    assert df_score["global_pseudotimes"].min() == 0
    assert df_score["global_pseudotimes"].max() == 1
    assert scores_background.min() == 0
    assert scores_disease.max() == 1
    assert q_background[1] <= 0.2
    assert q_disease[2] >= 0.25

    # evaluate group distributions
    assert scores_between.min() > scores_background.min()
    assert scores_disease.min() > scores_between.min()
    assert scores_between.max() > scores_background.max()
    assert scores_disease.max() >= scores_between.max()
    assert np.round(q_background[1],2) <= np.round(q_between[0],2)
    assert np.round(q_background[2],2) <= np.round(q_disease[0],2)
    assert np.round(q_between[0],2) <= np.round(q_disease[0],2)
    assert np.round(q_between[1],2) <= np.round(q_disease[1],2)
    assert np.round(q_between[2],2) <= np.round(q_disease[2],2)

    # set test flag to true if passed
    update_test_dict(mock_test_neuro_pm_accuracy_shouldpass["key_group"],
                     mock_test_neuro_pm_accuracy_shouldpass["key"],
                     True)

# def test_neuro_pm_cti_pred_shouldpass(mock_test_neuro_pm_cti_pred_shouldpass):

#     '''
#     This function tests for the accuracy/effectiveness of the NeuroPM
#     cTI prediction method for inferring new patients by analyzing the 
#     output from the X-validation of the NeuroPM toolbox
#     '''

#     # set test flag to false before running test
#     update_test_dict(mock_test_neuro_pm_cti_pred_shouldpass["key_group"],
#                      mock_test_neuro_pm_cti_pred_shouldpass["key"],
#                      False)

#     # Arrange
#     # define paths for i/o
#     path_data      = "src/modelling/NeuroPM/io/"
#     path_data_pred = os.path.join(path_data, "inference_x_val_pred.csv")

#     # load data
#     ml_inf = pd.read_csv(path_data_pred)

#     # Action
#     # transform gt/pred into array
#     gt   = ml_inf["score_gt"].to_numpy()
#     pred = ml_inf["score_pred"].to_numpy()

#     # compute overall accuracy
#     rmse = compute_rmse(gt, pred)

#     # compute group-wise accuracy
#     group        = ml_inf["bp_group"].to_numpy()
#     rmse_healthy = compute_rmse(gt[group == 1], pred[group == 1])
#     rmse_disease = compute_rmse(gt[group == 2], pred[group == 2])

#     # Assert
#     # if the error is under the acceptable value
#     assert rmse < 0.05
#     assert rmse_healthy < 0.01
#     assert rmse_disease < 0.05

#     # set test flag to true if passed
#     update_test_dict(mock_test_neuro_pm_cti_pred_shouldpass["key_group"],
#                      mock_test_neuro_pm_cti_pred_shouldpass["key"],
#                      True)
