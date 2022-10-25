#!/bin/sh

# activate conda environment (need conda for fmrib) for Python/R Libraries
source activate env_conda

# run R preprocessing script, writes to NeuroPM/io directory
cd ./fmrib
Rscript preprocess_data_preparation.R
Rscript preprocess_feature_selection.R

# compile matlab script (only if there were code changes)
cd ./NeuroPM
#./compile_NeuroPM.sh

# execute the compiled matlab program
nohup ./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-processing file organization/evaluation
cd ..
Rscript postprocess_eval_model.R

# run test cases (in root directory)
cd ../..
pytest ./test/test_neuropm.py -k "test_io_R_preprocess_output_exist_shouldpass"
pytest ./test/test_neuropm.py -k "test_io_R_ft_select_output_exist_shouldpass"
pytest ./test/test_neuropm.py -k "test_io_R_postprocess_output_exist_shouldpas"
pytest ./test/test_neuropm.py -k "test_io_neuropm_output_exist_shouldpass"
pytest ./test/test_neuropm.py -k "test_io_neuropm_interm_output_exist_shouldpass"
pytest ./test/test_neuropm.py -k "test_neuro_pm_accuracy_shouldpass"
