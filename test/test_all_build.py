import json

def test_check_all_flags_shouldpass():

    '''
    This function loads the test dictionary flag file and checks the
    flags that should be true are indeed true. This function checks for
    all flags related to functionality of the entire pipeline to make
    sure our code changes havent impacted the entire workflow.

    This test has no dependencies and is designed to be lightweight to 
    run on the cloud.
    '''
    
    # Arrange
    # load test flag dictionary
    test_dict = json.load(open("test/test.json"))

    # Action
    # none

    # Assert
    # check criteria 
    assert test_dict["ml"]["does_model_exist"]
    assert test_dict["neuropm"]["does_output_df_exist"]
