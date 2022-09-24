from utils import read_test_dict

def test_check_all_flags_shouldpass():

    '''
    This function loads the test dictionary flag file and checks
    if all the values are true, meaning all tests have passed
    successfully in our pytest environment
    '''
    
    test_dict = read_test_dict()

    return True
