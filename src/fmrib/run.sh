#!/bin/sh

# add matlab module to workspace
module add MATLAB/2020a

# compile code and include sub-directories
mcc -m run_NeuroPM.m -a ./io/ -a ./cTI-codes/

# execute the compiled program
./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98