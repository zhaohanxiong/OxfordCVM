##### Running NeuroPM
```
- navigate to directory
cd /home/fs0/winokl/zxiong/OxfordCVM/src/fmrib

- run R preprocessing script on raw UKB file
Rscript main_preprocess.R

- run executible for NeuroPM (compile and run)
./NeuroPM/compile_run.sh
```

##### Copying Data Files to/from Server to/from Local Windows (Example)
```
pscp temp.txt winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong
pscp -r winokl@jalapeno.fmrib.ox.ac.uk:/home/fs0/winokl/zxiong/OxfordCVM/src/fmrib/NeuroPM/io .
```

##### Dependencies for NeuroPM (MATLAB Toolboxes):
```
- statistics and machine learning toolbox
- financial toolbox
- optimization toolbox
- bioinformatics toolbox
```

##### FMRIB General MATLAB Compiling:
```
module add MATLAB/2020a
module list
module unload MATLAB/2020a
mcc -m temp.m ./path_to_add/*
./run_temp.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98
```

##### FMRIB Specific Commands for Running NeuroPM Source Code:
```
module add MATLAB/2020a
mcc -m run_NeuroPM.m -a ./cTI-codes/
./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

- these commands have been packaged into a shell script, run.sh
- to run this script first turn into an executable, then simply type it to run
chmod a+rx run.sh
./compile_run.sh
```