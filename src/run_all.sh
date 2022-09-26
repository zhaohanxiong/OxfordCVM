#!/bin/sh

# activate conda environment (need conda for fmrib) for Python/R Libraries
source activate env_conda

# preprocess entire UKB data set to subset into smaller data frame (very long runtime)
cd ./fmrib
#Rscript ukb_whole_data_subset.R

# run R preprocessing script, writes to NeuroPM/io directory
Rscript preprocess_data_preparation.R
Rscript preprocess_feature_selection.R

# compile matlab script (only if there were code changes)
cd ./NeuroPM
./compile_NeuroPM.sh

# execute the compiled matlab program
nohup ./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-processing file organization/evaluation
cd ..
Rscript postprocess_files.R
Rscript postprocess_eval_model.R

# run python trajectory visualization/computation
python postprocess_traj.py

# run cross validation (very long runtime)
#bash ./run_x_validate.sh

# ml lifecycle (train, test, save, log, deploy, monitor)
cd ../ml_lifecycle
python ./ml_model_build.py
python ./ml_model_test_pred.py --random_seed=4321
cd ./mlflow
#python ./log_model.py --random_n=1000 --random_seed=1234
#mlflow server --backend-store-uri sqlite:///mlruns.db --default-artifact-root ./mlruns

# run test cases (in root directory)
cd ../../..
pytest
