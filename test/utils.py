import json
import numpy as np

def read_test_dict(filename = "test/test.json"):
    
    '''
    This function loads the dictionary containing the flags for
    storing whether certain criteria/tests have passed in our
    pytest environment
    '''

    # read the file and encode it as a dictionary
    filedict = json.load(open(filename))

    return(filedict)

def write_test_dict(filecontents, filename = "test/test.json"):

    '''
    This function writes the given dictionary to the test
    dictionary to update flags for determining whether our tests
    have passed our pytests
    '''

    # open file
    filedict = open(filename, 'w')
    
    # encode files as a dict and write contents to it
    json.dump(filecontents, filedict, indent = 4, sort_keys = True)

def update_test_dict(key_group, key, val, filename = "test/test.json"):

    '''
    This function updates a given key-value pair in our test flags
    dictionary and writes it back out to file. Note that the test.json
    file must be nested by key-group then key-value pair.
    '''

    # read file in
    filedict = read_test_dict(filename)

    # assign new value to the given key group and key
    filedict[key_group][key] = val

    # write to output
    write_test_dict(filedict, filename)

def compute_rmse(x, y):

    '''
    This function computes the root mean squared error (RMSE) given  
    ground truth (x) and prediction (y). Inputs must be numpy arrays.
    '''

    return(np.mean(np.sqrt((x - y)**2)))

