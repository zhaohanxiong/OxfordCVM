import os
import sys
import plotly
import numpy as np
import pandas as pd
import plotly.graph_objects as go

# source path & set the current working directory
path = "NeuroPM/io/"
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("pseudotimes.csv", index_col = False)

# load cPCs
cPC = pd.read_csv("cPC.csv", index_col = False)

# produce plot
fig = go.Figure(data = [go.Scatter3d(x = cPC["mappedX_1"],
                                     y = cPC["mappedX_2"],
                                     z = cPC["mappedX_3"],
                                     mode = 'markers',
                                     marker = dict(size = 12,
                                                   color = labels["trajectory"],
                                                   opacity = 0.8))
                        ]
                )

fig.show()

# print message to indicate completion
print("Python -- Completed Trajectory Visualization")
