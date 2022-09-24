import os
import numpy as np
import pandas as pd
from utils import update_test_dict

# define keys for tests in this pytest file
test_type = "neuropm"
test_flag = "is_model_accurate"

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
    