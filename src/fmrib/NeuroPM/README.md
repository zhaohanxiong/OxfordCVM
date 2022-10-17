### This is guidance for new users of the CCRF-adapted Matlab version of the cTI methodology
##### Put 3 model input files into the "/io" folder;
```
Standardised features
Standardised covariables
cTI_group labels (i.e a single column of 1 label per row)
```

##### Open run_NeuroPM.m file and edit the input 
```
filenames in the 3 relevant lines to match what is in the 
"/io" folder. Change the output filenames if desired.
```

### Ensure loading the inputs in the correct format as follows,
### 1. Load the dataset file in .csv format (pre-processed through "preprocess_data_preparation.R")
### 2. Load the labels file in .csv format

### The code applies the below steps,
```
1. Selecting the blood pressure groups (background, between, target) indices from the loaded labels file.
2. Arranging the indices for background/between/target to be numeric
3. Adjusting covariates to remove the effect of sex and age
4. Apply data harmonization
```

## To use the cTI method, run the "pseudotimes_cTI_v4" function. It will return the following results,
```
1. Global pseudotimes (risk score)
2. Node contribution to the representation space
3. Expected contribution assuming equal weights in the final representation space.
```
## The code saves the final results in .csv format
