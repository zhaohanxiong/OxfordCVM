#!/bin/sh

# add matlab module to workspace
module add MATLAB/2020a

# compile code and include sub-directories
mcc -m run_NeuroPM.m -a './io/' -a ./cTI-codes/*.m \
    -a ./cTI-codes/auxiliary/*.m -a cTI-codes/dijkstra_tools/*.m

# execute the compiled program
./run_run_NeuroPM.sh /opt/fmrib/MATLAB/MATLAB_Compiler_Runtime/v98

https://www.google.com/search?q=matlab+mcc+addpath&ei=oXFLYpb6BpqChbIPm5mS2AY&ved=0ahUKEwjWzuL0uvv2AhUaQUEAHZuMBGsQ4dUDCA4&uact=5&oq=matlab+mcc+addpath&gs_lcp=Cgdnd3Mtd2l6EAMyBggAEBYQHjIICAAQCBANEB46BwgAEEcQsAM6BQgAEIAESgQIQRgASgQIRhgAUP4DWNwRYJoTaAFwAXgAgAFiiAHQBJIBATiYAQCgAQHIAQjAAQE&sclient=gws-wiz
https://www.google.com/search?q=matlab+mcc+Unable+to+find+or+open+...+Check+the+path+and+filename+or+file+permissions.&ei=hXpLYv6QBcubgQb8m7-oDQ&ved=0ahUKEwi-54Syw_v2AhXLTcAKHfzND9UQ4dUDCA4&uact=5&oq=matlab+mcc+Unable+to+find+or+open+...+Check+the+path+and+filename+or+file+permissions.&gs_lcp=Cgdnd3Mtd2l6EAM6BwgAEEcQsANKBAhBGABKBAhGGABQN1jOCmD8C2gBcAF4AIABR4gBuwKSAQE1mAEAoAEByAEIwAEB&sclient=gws-wiz