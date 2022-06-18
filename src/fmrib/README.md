##### Running NeuroPM
```
- navigate to directory
cd /home/fs0/winokl/zxiong/OxfordCVM/src/fmrib

- run R preprocessing script on raw UKB file
Rscript preprocess.R

- run executible for NeuroPM (compile and run)
./NeuroPM/run_NeuroPM.sh
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
```

##### FMRIB Specific Commands for Running NeuroPM Source Code:
```
module add MATLAB/2020a
mcc -m run_NeuroPM.m -a ./cTI-codes/
./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

- these commands have been packaged into a shell script, run_NeuroPM.sh
- to run this script first turn into an executable, then simply type it to run
chmod a+rx compile_NeuroPM.sh
./compile_NeuroPM.sh

- the entire preprocessing plus neuroPM code has also been packaged into a single shell script in the /fmrib directory
./run_all.sh
```

##### FMRIB Cluster Commands
```
- link to resource
https://sharepoint.nexus.ox.ac.uk/sites/NDCN/FMRIB/IT/User%20Guides/GridEngine.aspx

- to run preprocessing + neuroPM in one script (<12GB RAM, 4 Hours Max, priority)
fsl_sub -q short.q ./run_all.sh

- to run preprocessing + neuroPM in one script (Unlimited RAM and Hours, needed for full UKB, but slow)
fsl_sub -q bigmem.q ./run_all.sh

- manage active jobs
qstat
qdel job_id
```