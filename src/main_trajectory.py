import os
import scipy.io
import numpy as np
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

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
labels = pd.read_csv("pseudotimes.csv", index_col = False)

# load minimum spanning tree
MST_mat = scipy.io.loadmat("MST.mat")["MST"]
G = nx.from_numpy_matrix(MST_mat)
nx.draw_spectral(G, with_labels = True)
plt.savefig("filename.png")

#MST = pd.read_csv("MST.csv",index_col=False)
#MST["group"] = labels["bp_group"][MST["Edges_Index_Matched_1"]-1].to_numpy()
#MST["disease_score"] = labels["global_pseudotimes"][MST["Edges_Index_Matched_1"]-1].to_numpy()

#MST_mat = MST_mat[np.argsort(MST["disease_score"]),:]
#MST_mat = MST_mat[:,np.argsort(MST["disease_score"])]
#G = nx.from_numpy_matrix(MST_mat)

#dist_mat = scipy.io.loadmat("dist_matrix.mat")["dist_matrix"] # only works for a few thousand points
#dist_ind = np.argsort(np.sum(dist_mat,0))
#dist_mat = dist_mat[dist_ind,:]
#dist_mat = dist_mat[:,dist_ind]
#G = nx.from_numpy_matrix(dist_mat)
#T = nx.minimum_spanning_tree(G)
#nx.draw_spectral(T, with_labels = False)

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
