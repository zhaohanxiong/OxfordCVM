#!/bin/sh

# activate conda environment (need conda for fmrib) for Python/R Libraries
source activate env_conda

# run R preprocessing script, writes to NeuroPM/io directory
cd ./modelling
Rscript preprocess_data_preparation.R
Rscript preprocess_feature_selection.R

# compile matlab script (only if there were code changes)
cd ./NeuroPM
./compile_NeuroPM.sh

# execute the compiled matlab program
nohup ./run_run_NeuroPM.sh /opt/modelling/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-processing file organization/evaluation
cd ..
Rscript postprocess_files.R
Rscript postprocess_eval_model.R

# run python trajectory visualization/computation
python postprocess_traj.py --max_traj_num=5 --overlap_threshold=0.9

# generate ggplots for key results
Rscript postprocess_ggplots.R

# run cross validation (very long runtime)
bash ./run_fmrib_x_validate.sh

# ml lifecycle (train, test, save, log, deploy, monitor)
cd ../ml_lifecycle
python ./ml_model_build.py
python ./ml_model_test_pred.py --random_seed=4321

cd ./mlflow
mlflow server --backend-store-uri sqlite:///mlruns.db --default-artifact-root ./mlruns
python ./mlflow_tracking.py --experiment_id=1
python ./mlflow_versioning.py --experiment_id=1

# run test cases (in root directory)
cd ../../..
python ./test/init.py
pytest ./test/test_neuropm.py
