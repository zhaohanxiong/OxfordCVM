##### Running NeuroPM
```
first run the R preprocessing on the raw UKB csv data file, make sure it is saved to OxfordCVM/src/fmrib/io
./run.sh (to run inside OxfordCVM/src/fmrib)
```
##### Copying Data Files to/from Server to/from Windows (example)
```
pscp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
pscp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/io .
```

The DP_prep_imp_tot.R script prepares the data to be processed in MATLAB 
with the b_DP_imp.m script (which uses the bb_DP_run_imp.m script). The 
script removes outliers and participants with too much missing data. It 
assumes the data will then be imputed in MATLAB and loaded into R again 
(see section #### IMPUTE DATA WITH MATLAB).

Yasser recommended using Trimmed Score Regression (TSR.m script) for imputation, 
but it is probably worth checking if you think this is the optimal way of 
imputation for us. In addition, it’s worth reconsidering the threshold of 
missing data for excluding participants. Usually a large part of the processing 
power/time in the NeuroPM toolbox is taken up by imputing data, so having an 
imputed dataset as input reduces this substantially.

Dependencies (matlab toolboxes):

	- statistics and machine learning toolbox
	- financial toolbox
	- optimization toolbox
	- bioinformatics toolbox

General compiling on FMRIB (given a script named "temp.m"):

	- module add MATLAB/2020a
	- module list
	- module unload MATLAB/2020a
	- mcc -m temp.m ./path_to_add/*
	- ./run_temp.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98
	
Specifically for running neuroPM source code on FMRIB:

	module add MATLAB/2020a
	mcc -m run_NeuroPM.m -a ./cTI-codes/
	./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

	- these commands have been packaged into a shell script, run.sh
	- to run this script first turn into an executable, then simply type it to run
	chmod a+rx run.sh
	./run.sh