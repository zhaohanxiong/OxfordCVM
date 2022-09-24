import pytest

#########################################################
# tests for NeuroPM model
#########################################################
neuropm_model_test_1 = {
    "key_group": "neuropm",
    "key":       "is_model_accurate"
}

# define test data list for parametrization
neuropm_model_test = [neuropm_model_test_1]

#########################################################
# tests for ML model
#########################################################
ml_model_test_1 = {
    "key_group": "ml",
    "key":       "is_model_accurate"
}

# define test data list for parametrization
ml_model_test = [ml_model_test_1]

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Fixtures for parametrization

@pytest.fixture(params = neuropm_model_test)
def mock_test_neuro_pm_accuracy_shouldpass(request):
    return request.param

@pytest.fixture(params = ml_model_test)
def mock_test_ml_model_accuracy_shouldpass(request):
    return request.param
