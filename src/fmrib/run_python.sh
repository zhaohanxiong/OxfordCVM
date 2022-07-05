#!/bin/sh

# run python trajectory visualization/computation (in virtual env)
/home/fs0/winokl/zxiong/env/bin/python postprocess_traj.py

# deploy output data to remote database (in virtual env)
/home/fs0/winokl/zxiong/env/bin/python aws_deploy_data.py
