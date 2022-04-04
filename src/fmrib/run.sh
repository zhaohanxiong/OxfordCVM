#!/bin/sh

# add matlab module to workspace
module add MATLAB/2020a

# compile code and include sub-directories
mcc -m run_NeuroPM.m -a ./cTI-codes/auxiliary/*.m -a cTI-codes/dijkstra_tools/*.m -a ./cTI-codes/*.m

# execute the compiled program
./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98