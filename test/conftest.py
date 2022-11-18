import pytest

#########################################################
# tests for cTI/ML output files (CI)
#########################################################
io_data_test_1 = {
    "key_group": "data_processing",
    "key":       "does_R_preprocess_output_exist"
}

io_data_test_2 = {
    "key_group": "neuropm",
    "key":       "does_neuropm_output_exist"
}

io_data_test_3 = {
    "key_group": "neuropm",
    "key":       "does_neuropm_interm_output_exist"
}

io_data_test_4 = {
    "key_group": "data_processing",
    "key":       "does_R_postproces_output_exist"
}

# fixture for parametrization
@pytest.fixture(params = [io_data_test_1])
def mock_test_io_R_preprocess_output_exist_shouldpass(request):
    return request.param
@pytest.fixture(params = [io_data_test_1])
def mock_test_io_R_ft_select_output_exist_shouldpass(request):
    return request.param
@pytest.fixture(params = [io_data_test_2])
def mock_test_io_neuropm_output_exist_shouldpass(request):
    return request.param
@pytest.fixture(params = [io_data_test_3])
def mock_test_io_neuropm_interm_output_exist_shouldpass(request):
    return request.param
# @pytest.fixture(params = [io_data_test_4])
# def mock_test_io_R_postprocess_output_exist_shouldpass(request):
#     return request.param

ml_model_file_test_1 = {
    "key_group": "ml",
    "key":       "does_model_exist"
}

# fixture for parametrization
@pytest.fixture(params = [ml_model_file_test_1])
def mock_test_ml_model_exist_shouldpass(request):
    return request.param

#########################################################
# tests files for deployment to AWS (CD)
#########################################################
aws_files_deploy_test1 = {
    "key_group": "aws",
    "key":       "is_rds_data_correct"
}

aws_files_deploy_test2 = {
    "key_group": "aws",
    "key":       "is_ecr_files_correct"
}

# fixture for parametrization
@pytest.fixture(params = [aws_files_deploy_test1])
def mock_test_deploy_aws_rds_data_shouldpass(request):
    return request.param
@pytest.fixture(params = [aws_files_deploy_test2])
def mock_test_deploy_aws_container_data_shouldpass(request):
    return request.param

#########################################################
# tests for cTI/ML model accuracy (CD)
#########################################################
neuropm_model_test_1 = {
    "key_group": "neuropm",
    "key":       "is_cti_accurate"
}

neuropm_model_test_2 = {
    "key_group": "neuropm",
    "key":       "is_cti_pred_accurate"
}

# fixture for parametrization
@pytest.fixture(params = [neuropm_model_test_1])
def mock_test_neuro_pm_accuracy_shouldpass(request):
    return request.param
# @pytest.fixture(params = [neuropm_model_test_2])
# def mock_test_neuro_pm_cti_pred_shouldpass(request):
#     return request.param

ml_model_test_1 = {
    "key_group": "ml",
    "key":       "is_model_accurate"
}

# fixture for parametrization
@pytest.fixture(params = [ml_model_test_1])
def mock_test_ml_model_accuracy_shouldpass(request):
    return request.param
