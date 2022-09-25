import json

def test_check_all_flags_shouldpass():

    '''
    This function loads the test dictionary flag file and checks if all
    the values are true, meaning all tests have passed successfully in 
    our pytest environment
    '''
    
    # Arrange
    # load test flag dictionary
    test_dict = json.load(open("test/test.json"))

    # Action
    # loop through all keys
    for key_group in test_dict:
        for key, val in test_dict[key_group].items():

    # Assert
            # check if current condition is true for the group
            assert val, "test failed: " + key_group + " (" + key + ")"
