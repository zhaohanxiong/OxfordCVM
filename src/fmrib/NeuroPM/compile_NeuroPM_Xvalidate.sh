#!/bin/sh

# add matlab module to workspace
module add MATLAB/2020a

# compile code and include sub-directories (single run or X-validation)
mcc -m run_NeuroPM_Xvalidate.m -a ./cTI-codes/

# remove useless output files
rm mccExcludedFiles.log readme.txt requiredMCRProducts.txt