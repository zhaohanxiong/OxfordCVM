#!/bin/sh

# add matlab module to workspace
module add MATLAB/2020a

# compile code and include sub-directories
mcc -m run_NeuroPM.m -a ./cTI-codes/