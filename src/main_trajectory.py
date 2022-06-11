import os
import scipy.io
import networkx as nx
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import plotly.graph_objects as go

# https://plotly.com/python/network-graphs/
# https://www.geeksforgeeks.org/python-visualize-graphs-generated-in-networkx-using-matplotlib/
# https://hilbert-cantor.medium.com/network-plot-with-plotly-and-graphviz-ebd7778073b

# source path
path      = "C:/Users/zxiong/Desktop"
file_path = "" #"io - iter_cPCA full run 10"
path      = os.path.join(path, file_path)

# set the current working directory
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("labels.csv",index_col=False)

# load minimum spanning tree
MST = scipy.io.loadmat("MST.mat")["MST"]
G = nx.from_numpy_matrix(MST)

#nx.draw_spectral(G, with_labels = True)
#plt.savefig("temptemp.png")

#MST = pd.read_csv("MST.csv",index_col=False)
#MST["group"] = labels["bp_group"][MST["Edges_Index_Matched_1"]-1].to_numpy()

#rows, cols = np.where(MST > 0)
#edges = zip(rows.tolist(), cols.tolist())
#gr = nx.Graph()
#gr.add_edges_from(edges)
#nx.draw(gr, node_size=1)
#plt.show()


'''
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
'''
