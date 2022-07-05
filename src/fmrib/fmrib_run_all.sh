#!/bin/sh

# submit neuroPM model training to cluster
fsl_sub -q bigmem.q ./run_all.sh

# submit cross validation (if needed)
#fsl_sub -q bigmem.q ./run_x_validate.sh

# run python trajectory visualization/computation (in virtual env)
/home/fs0/winokl/zxiong/env/bin/python postprocess_traj.py

# deploy output data to remote database (in virtual env)
/home/fs0/winokl/zxiong/env/bin/python aws_deploy_data.py
