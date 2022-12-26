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

# run evaluation
cd ..
Rscript postprocess_eval_model.R

# run python trajectory visualization/computation
python postprocess_traj_compute.py --max_traj_num=5 --overlap_threshold=0.8 --color_by="traj"

# perform cross validation
#bash ./run_fmrib_x_validate.sh

# arrange/tidy up files for post-analysis
Rscript postprocess_files.R

# perform series of post-analysis visualizations
cd ../postanalysis
Rscript ukb_visualize_key_cTI_results.R
Rscript ukb_visualize_traj.R

# run test cases (in root directory)
cd ../..
python ./test/init.py
pytest ./test/test_neuropm.py
