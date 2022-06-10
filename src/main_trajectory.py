import os
import numpy as np
import pandas as pd
import plotly.graph_objects as go

# https://plotly.com/python/network-graphs/

# source path
path      = "C:/Users/zxiong/Desktop"
file_path = ""#"io - iter_cPCA full run 10"
path      = os.path.join(path, file_path)

# set the current working directory
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("labels.csv",index_col=False)

# load minimum spanning tree
MST = pd.read_csv("MST.csv",index_col=False)
MST["group"] = labels["bp_group"][MST["Edges_Index_Matched_1"]-1].to_numpy()

# plot graph
node_trace = go.Scatter(
    x=node_x, y=node_y,
    mode='markers',
    hoverinfo='text',
    marker=dict(
        showscale=True,
        colorscale='YlGnBu',
        reversescale=True,
        color=[],
        size=10,
        colorbar=dict(
            thickness=15,
            title='Node Connections',
            xanchor='left',
            titleside='right'
        ),
        line_width=2))

node_adjacencies = []
node_text = []
for node, adjacencies in enumerate(G.adjacency()):
    node_adjacencies.append(len(adjacencies[1]))
    node_text.append('# of connections: '+str(len(adjacencies[1])))

node_trace.marker.color = node_adjacencies
node_trace.text = node_text

fig = go.Figure(data=[edge_trace, node_trace],
                layout=go.Layout(
                    title='Minimum Spanning Tree',
                    titlefont_size=16,
                    showlegend=False,
                    hovermode='closest',
                    margin=dict(b=20,l=5,r=5,t=40),
                    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False))
                )
fig.show()