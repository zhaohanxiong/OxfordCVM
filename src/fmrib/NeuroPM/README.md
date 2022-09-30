### This is guidance for new users of the CCRF-adapted Matlab version of the cTI methodology
##### Step 1) Required installs:
```
- Matlab R2020a or earlier version.
- "Bioinformatics Toolbox"
- "Statistics and Machine Learning Toolbox"
```

##### Step 2) Put 3 model input files into the "/io" folder;
```
Standardised features
Standardised covariables
cTI_group labels (i.e a single column of 1 label per row)
```

##### Step 3) Open run_NeuroPM.m file and edit the input 
```
filenames in the 3 relevant lines to match what is in the 
"/io" folder. Change the output filenames if desired.
```
