### Loading Dataset

##### Ensure loading the inputs in the correct format
Users have to input the path of the dataset file ("ukb_feature_select.csv") on Line 6 and labels file ("labels_select.csv") on Line 7


##### The code applies the following

1. Load the dataset file in .csv format (pre-processed through "preprocess_data_preparation.R" and "preprocess_feature_selection.R")
2. Convert the dataset from tabular to numerical format. The dataset is represented as [No.Subjects by No.Features]. 
3. Load the labels file in .csv format. The labels files include multiple columns of information for every subject. Labels corresponding to the blood pressure categorisation are stored in the "bp_group" column

- The code changes the labels to 1, 2, and 3, respectively, for plotting purposes


### Pre-processing Dataset

##### The code applies the below steps, if needed,

1. Adjusting covariates to remove the effect of sex and age
2. Apply data harmonization

### Processing contrastive trajectory inference (cTI)

##### To use the cTI algorithm, run the "pseudotimes_cTI_v4" function with the following inputs,

1. Input dataset of features in [No.Subjects by No.Features] format named as "data"
2. Indices for the background subjects in the dataset in [No.Subjects by 1] format named as "ind_background"
3. Labels used for plotting purposes (changed to 1, 2, and 3) in [No.Subjects by 1] format named as "classes_for_colours"
4. Indices for the target subjects in the dataset in [No.Subjects by 1] format named as "ind_target"
5. The selected dimensionality reduction method, contrasive principal component analysis (cPCA), named as "cPCA"
6. The selected number of principal components specified as "50"

- The inputs can be modified as per your needs

##### The cTI function will return the following results,
1. Global pseudotimes (risk score) for every subject
2. Node contribution to the representation space for every feature
3. Expected contribution assuming equal weights in the final representation space

- The code saves the final results (3 files) in .csv format
