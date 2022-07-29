#!/bin/sh

# run R preprocessing script, writes to NeuroPM/io directory
Rscript preprocess.R

# navigate to directory containing source code
cd ./NeuroPM

# compile matlab script (only if there were code changes)
./compile_NeuroPM_Xvalidate.sh

# execute the compiled matlab program (single run or X-validation)
nohup ./run_run_NeuroPM_Xvalidate.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

# run post-analysis evaluation
cd ..
Rscript postprocess_x_validate.R
Rscript postprocess_x_validate_KNNpredPC.R
