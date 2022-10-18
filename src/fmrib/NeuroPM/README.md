## Loading Dataset

### Ensure loading the inputs in the correct format. The code applies the following,

```
1. Load the dataset file in .csv format (pre-processed through "preprocess_data_preparation.R")
2. Convert the dataset from tabular to numerical format.
The dataset is represented as [No.Subjects by No.Features], that is [27,439 by 1,073]. 
3. Load the labels file in .csv format as [No.Subjects by 4]
The labels files include 4 columns of information for every subject (27,439 rows). 
Labels corresponding to the blood pressure categorisation are stored in the 4th column
```

### The categories are as follows,

```
0 is for the between group (120 < BPS < 160 / 80 < BPD < 100 )
1 is for the background group (BPS < 120 / BPD < 80)
2 is for the target group (BPS > 160 / BPD > 100 )
```

### The code changes the labels to 1, 2, and 3, respectively, for plotting purposes

## Pre-processing Dataset

### The code applies the below steps, if needed,

```
1. Adjusting covariates to remove the effect of sex and age
2. Apply data harmonization
```

## Processing contrastive trajectory inference (cTI)

## To use the cTI algorithm, run the "pseudotimes_cTI_v4" function with the following inputs,

```
1. Input dataset of features in [No.Subjects by No.Features] format
2. Indices for the background subjects in the dataset in [No.Subjects by 1] format
3. Labels used for plotting purposes (changed to 1, 2, and 3) in [Total No.Subjects by 1] format
4. Indices for the target subjects in the dataset in [No.Subjects by 1] format
5. The selected dimensionality reduction method, contrasive principal component analysis (cPCA)
6. The selected number of principal components
```

### The function will return the following results,
```
1. Global pseudotimes (risk score) for every subject
2. Node contribution to the representation space for every feature
3. Expected contribution assuming equal weights in the final representation space
```
### The code saves the final results (3 files) in .csv format
