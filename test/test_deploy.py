import os
import pandas as pd
from utils import update_test_dict

def test_deploy_aws_rds_data_shouldpass(mock_test_deploy_aws_rds_data_shouldpass):

    '''
    This function tests if the output from preprocess_data_preparation.R is correct
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_deploy_aws_rds_data_shouldpass["key_group"],
                     mock_test_deploy_aws_rds_data_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data           = "src/modelling/NeuroPM/io/"
    path_data_names = os.path.join(path_data, "ukb_varnames.csv")
    path_data_frame = os.path.join(path_data, "ukb_num_reduced.csv")
    path_data_score = os.path.join(path_data, "pseudotimes.csv")

    # Action
    # try read the files, do they exist? set flag for success or not
    try:
        # read dataframes in
        df_names = pd.read_csv(path_data_names)
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

    # check if file sizes are correct
    assert df_ukb.shape[0] == df_score.shape[0]

    # set test flag to true if passed
    update_test_dict(mock_test_deploy_aws_rds_data_shouldpass["key_group"],
                     mock_test_deploy_aws_rds_data_shouldpass["key"],
                     True)

def test_deploy_aws_container_data_shouldpass(mock_test_deploy_aws_container_data_shouldpass):

    '''
    This function tests if the output from preprocess_data_preparation.R is correct
    '''

    # set test flag to false before running test
    update_test_dict(mock_test_deploy_aws_container_data_shouldpass["key_group"],
                     mock_test_deploy_aws_container_data_shouldpass["key"],
                     False)

    # Arrange
    # define paths for i/o
    path_data = "src/aws/tf_serving/"
    files = os.listdir(path_data)

    # Action
    # define files to check
    path_dockerfile = os.path.join(path_data, "Dockerfile")
    path_configfile = os.path.join(path_data, "model.config")
    path_savedmodel = os.path.join(path_data, "saved_models")

    # define ml model files
    files_ml1 = os.listdir(os.path.join(path_data, "saved_models", "1"))
    files_ml2 = os.listdir(os.path.join(path_data, "saved_models", "2"))

    # Assert
    # check if the files exist
    assert any(["Dockerfile" == s for s in files])
    assert any(["model.config" == s for s in files])
    assert len(files_ml1) > 0
    assert len(files_ml2) > 0
    assert any(["keras_metadata.pb" == s for s in files_ml1])
    assert any(["saved_model.pb" == s for s in files_ml1])
    assert any(["keras_metadata.pb" == s for s in files_ml2])
    assert any(["saved_model.pb" == s for s in files_ml2])

    # set test flag to true if passed
    update_test_dict(mock_test_deploy_aws_container_data_shouldpass["key_group"],
                     mock_test_deploy_aws_container_data_shouldpass["key"],
                     True)
