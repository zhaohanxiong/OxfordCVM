#!/bin/sh

# activate conda environment (need conda for fmrib) for Python/R Libraries
source activate env_conda

# preprocess entire UKB data set to subset into smaller data frame
#Rscript ukb_whole_data_subset.R

# run R preprocessing script, writes to NeuroPM/io directory
Rscript preprocess.R

# compile matlab script (only if there were code changes)
cd ./NeuroPM
./compile_NeuroPM.sh

# execute the compiled matlab program (single run or X-validation)
nohup ./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-processing file organization/evaluation
cd ..
Rscript postprocess_files.R
Rscript postprocess_eval_model.R

# run python trajectory visualization/computation
python postprocess_traj.py

# deploy output data to remote database for R-Shiny App
python aws_deploy_data.py

# build/package model inference for tf-serving
python ml_build_model.py

# run test case to test model accuracy
cd ../Deploy_ML
pytest