#!/bin/sh

# preprocess entire UKB data set to subset into smaller data frame
#Rscript ukb_whole_data_subset.R

# run R preprocessing script, writes to NeuroPM/io directory
Rscript preprocess.R

# compile matlab script (only if there were code changes)
cd ./NeuroPM
./compile_NeuroPM.sh

# execute the compiled matlab program (single run or X-validation)
nohup ./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-analysis evaluation/file organization
cd ..
Rscript postprocess_files.R
Rscript postprocess_eval.R

# activate anaconda environment (need conda for fmrib)
source activate env_conda

# run python trajectory visualization/computation
python postprocess_traj.py

# deploy output data to remote database
python aws_deploy_data.py
