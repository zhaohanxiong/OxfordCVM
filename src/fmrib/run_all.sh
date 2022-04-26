#!/bin/sh

# preprocess entire UKB data set to subset into smaller data frame
#Rscript ukb_whole_data_subset.R

# run R preprocessing script, writes to NeuroPM/io directory
Rscript main_preprocess.R

# execute the compiled matlab program
cd ./NeuroPM
nohup ./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98