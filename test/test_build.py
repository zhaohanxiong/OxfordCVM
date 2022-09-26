import os

def test_aws_fileio_paths_shouldpass(mock_test_aws_fileio_paths_shouldpass):

    '''
    This function tests if the file to be accessed by the code/deployment
    tools located in src/aws match with those outputted from the other
    scripts to feed into src/aws
    '''

    # Arrange
    # define paths for i/o
    path_incoming = mock_test_aws_fileio_paths_shouldpass["incoming"]
    path_outgoing = mock_test_aws_fileio_paths_shouldpass["outgoing"]

    # Action

    # Assert
    assert True

# def test_fmrib_fileio_paths_shouldpass(mock_):

#     '''
#     This function tests if the file to be accessed by the code located
#     in src/fmrib match with those outputted from the other scripts to 
#     feed into src/fmrib
#     '''

#     # Arrange
#     # define paths for i/o

#     # Action

#     # Assert
#     assert True

# def test_ml_lifecycle_fileio_paths_shouldpass(mock_):

#     '''
#     This function tests if the file to be accessed by the code
#     located in src/ml_lifecycle match with those outputted from the 
#     other scripts to feed into src/ml_lifecycle
#     '''

#     # Arrange
#     # define paths for i/o

#     # Action

#     # Assert
#     assert True

# def test_visualization_dashboards_fileio_paths_shouldpass(mock_):

#     '''
#     This function tests if the file to be accessed by the code
#     located in src/visualization_dashboards match with those outputted 
#     from the other scripts to feed into src/visualization_dashboards
#     '''

#     # Arrange
#     # define paths for i/o

#     # Action

#     # Assert
#     assert True
