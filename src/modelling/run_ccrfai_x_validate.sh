#!/bin/sh

# must be run after run_all.sh to obtain input/val data

# navigate to directory containing source code
cd ./NeuroPM
/home/zhaohanx/Matlab2020a/bin/matlab -nodisplay -nosplash -nodesktop -r "run('run_NeuroPM_Xvalidate.m');exit;"

# run post-analysis evaluation
cd ..
Rscript postprocess_x_validate.R
Rscript postprocess_x_validate_KNNpredPC.R
