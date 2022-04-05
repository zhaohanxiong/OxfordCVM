##### Running NeuroPM
```
- first run the R preprocessing on the raw UKB csv data file, make sure it is saved to OxfordCVM/src/fmrib/io
./run.sh (to run inside OxfordCVM/src/fmrib)
```
##### Copying Data Files to/from Server to/from Windows (example)
```
pscp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
pscp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/io .
```

##### Dependencies (matlab toolboxes):
```
	- statistics and machine learning toolbox
	- financial toolbox
	- optimization toolbox
	- bioinformatics toolbox
```

##### General compiling on FMRIB (given a script named "temp.m"):
```
module add MATLAB/2020a
module list
module unload MATLAB/2020a
mcc -m temp.m ./path_to_add/*
./run_temp.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98
```

##### Specifically for running neuroPM source code on FMRIB:
```
module add MATLAB/2020a
mcc -m run_NeuroPM.m -a ./cTI-codes/
./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

- these commands have been packaged into a shell script, run.sh
- to run this script first turn into an executable, then simply type it to run
chmod a+rx run.sh
./run.sh
```