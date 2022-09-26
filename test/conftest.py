import pytest

#########################################################
# tests for code changes (continuous integration)
#########################################################
path_aws_test1 = {
    "incoming": "file_previous_code_wrote_to",
    "outgoing": "file_current_code_to_load"
}

# define test data list for parametrization
path_aws_test = [path_aws_test1]

# fixture for parametrization
@pytest.fixture(params = path_aws_test)
def mock_test_aws_fileio_paths_shouldpass(request):
    return request.param

#########################################################
# tests for NeuroPM output files
#########################################################
neuropm_data_test_1 = {
    "key_group": "neuropm",
    "key":       "does_output_df_exist"
}

# define test data list for parametrization
neuropm_data_test = [neuropm_data_test_1]

# fixture for parametrization
@pytest.fixture(params = neuropm_data_test)
def mock_test_neuro_pm_output_exist_shouldpass(request):
    return request.param

#########################################################
# tests for NeuroPM model accuracy
#########################################################
neuropm_model_test_1 = {
    "key_group": "neuropm",
    "key":       "is_model_accurate"
}

# define test data list for parametrization
neuropm_model_test = [neuropm_model_test_1]

# fixture for parametrization
@pytest.fixture(params = neuropm_model_test)
def mock_test_neuro_pm_accuracy_shouldpass(request):
    return request.param

#########################################################
# tests for ML model files
#########################################################
ml_model_file_test_1 = {
    "key_group": "ml",
    "key":       "does_model_exist"
}

# define test data list for parametrization
ml_model_file_test = [ml_model_file_test_1]

# fixture for parametrization
@pytest.fixture(params = ml_model_file_test)
def mock_test_ml_model_exist_shouldpass(request):
    return request.param

#########################################################
# tests for ML model accuracy
#########################################################
ml_model_test_1 = {
    "key_group": "ml",
    "key":       "is_model_accurate"
}

# define test data list for parametrization
ml_model_test = [ml_model_test_1]

# fixture for parametrization
@pytest.fixture(params = ml_model_test)
def mock_test_ml_model_accuracy_shouldpass(request):
    return request.param
