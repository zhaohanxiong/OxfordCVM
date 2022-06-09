import os
import numpy as np
import pandas as pd
import plotly.graph_objects as go

# https://plotly.com/python/network-graphs/

# source path
path      = "C:/Users/zxiong/Desktop"
file_path = "io - iter_cPCA full run 10"
path      = os.path.join(path, file_path)

# set the current working directory
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("labels.csv",index_col=False)

# # load minimum spanning tree
MST = pd.read_csv("MST.csv",index_col=False)
MST["group"] = labels["bp_group"][np.array(MST["Edges_1"])]