#!/bin/sh

# run R preprocessing script, writes to NeuroPM/io directory
Rscript main_preprocess.R

# execute the compiled matlab program
nohup ./NeuroPM/run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98