import pytest

#########################################################
# tests for cTI/ML output files (CI)
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
# tests for cTI/ML model accuracy (CD)
#########################################################
neuropm_model_test_1 = {
    "key_group": "neuropm",
    "key":       "is_cti_accurate"
}

# define test data list for parametrization
neuropm_model_test = [neuropm_model_test_1]

# fixture for parametrization
@pytest.fixture(params = neuropm_model_test)
def mock_test_neuro_pm_accuracy_shouldpass(request):
    return request.param

neuropm_cti_pred_test_1 = {
    "key_group": "neuropm",
    "key":       "is_cti_pred_accurate"
}

# define test data list for parametrization
neuropm_cti_pred_test = [neuropm_cti_pred_test_1]

# fixture for parametrization
@pytest.fixture(params = neuropm_cti_pred_test)
def mock_test_neuro_pm_cti_pred_shouldpass(request):
    return request.param

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
