#!/bin/sh

# preprocess entire UKB data set to subset into smaller data frame
#Rscript ukb_whole_data_subset.R

# run R preprocessing script, writes to NeuroPM/io directory
Rscript preprocess.R

# navigate to directory containing source code
cd ./NeuroPM

# compile matlab script (only if there were code changes)
./compile_NeuroPM.sh

# execute the compiled matlab program
nohup ./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-analysis evaluation
cd ..
Rscript postprocess.R

# run python trajectory visualization/computation (in virtual env)
../../../env/bin/python trajectory_compute.py