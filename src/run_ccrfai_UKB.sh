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

# run evaluation (model and cross-validation)
cd ..
Rscript postprocess_eval_model.R
#bash ./run_ccrfai_x_validate.sh

# run python trajectory visualization/computation
python postprocess_traj_compute.py --max_traj_num=5 --overlap_threshold=0.8 --color_by="traj"

# arrange/tidy up files for post-analysis and generate key results
Rscript postprocess_files.R
Rscript visualize_key_cTI_results.R

# perform series of post-analysis visualizations
cd ../postanalysis
Rscript ukb_visualize_main_variables.R

/home/zhaohanx/Matlab2020a/bin/matlab -nodisplay -nosplash -nodesktop -r "run('survival_analysis.m');exit;"

Rscript ukb_extract_repeat_visit.R
Rscript ukb_visualize_repeat_visit.R 1
Rscript ukb_visualize_repeat_visit.R 2
Rscript ukb_visualize_repeat_visit.R 3
Rscript ukb_visualize_repeat_visit.R 5

Rscript ukb_compute_traj_diff.R

# run test cases (in root directory)
cd ../..
python ./test/init.py
pytest ./test/test_neuropm.py
