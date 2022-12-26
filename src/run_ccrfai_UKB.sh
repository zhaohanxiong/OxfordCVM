#!/bin/sh

# activate conda environment for Python/R Libraries
source activate env_conda

# run R preprocessing script, writes to NeuroPM/io directory
cd ./modelling
Rscript preprocess_data_preparation.R
Rscript preprocess_feature_selection.R

# run matlab (local matlab install)
cd ./NeuroPM
/home/zhaohanx/Matlab2020a/bin/matlab -nodisplay -nosplash -nodesktop -r "run('run_NeuroPM.m');exit;"

# run post-processing file organization/evaluation
cd ..
Rscript postprocess_files.R
Rscript postprocess_eval_model.R

# run python trajectory visualization/computation
python postprocess_traj_compute.py --max_traj_num=5 --overlap_threshold=0.8 --color_by="traj"

# generate ggplots for key results and perform further analysis
Rscript postanalysis_ggplots.R

# run test cases (in root directory)
cd ../..
python ./test/init.py
pytest ./test/test_neuropm.py
