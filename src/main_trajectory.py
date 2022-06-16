import os
import plotly
import scipy.io
import numpy as np
import pandas as pd
import networkx as nx
import plotly.graph_objects as go
from scipy.sparse.csgraph import laplacian

# source path & set the current working directory
path = "fmrib/NeuroPM/io/"
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("pseudotimes.csv", index_col = False)
MST_labels = labels["bp_group"]==1

# load minimum spanning tree, and labels for each node in the graph
MST_mat = scipy.io.loadmat("MST.mat")["MST"]
G = nx.from_numpy_matrix(MST_mat)
MST_label = pd.read_csv("MST.csv",index_col=False)

# root node (least diseased node)
root_node = np.argmin(MST_label["pseudotime"])

# load dijkstra for determining trajectories of each path
dijkstra_F = scipy.io.loadmat("dijkstra.mat")["dijkstra_F"][:,0]

# determine the trajectory route of each node from the root node
# - find nodes which are not father nodes, these are the most extreme points, use this to back track to the root node.

# add the trajectory to the MST label

# map this back to the label file

# infer the traj of between group with the same pseudotime score as the background/target nodes


# compute spectral layout using lapacian and eigen decomp (1 minute run time)
L = laplacian((MST_mat>0).astype(int))
vals, vecs = np.linalg.eigh(L)
x, y = vecs[:,0], vecs[:,1]
graph_coordinates = {i: (x[i], y[i]) for i in range(MST_mat.shape[0])}

# compute spring layout (3 minutes run time), but looks very messy
#graph_coordinates = nx.spring_layout(G)

# build list of edges and nodes
edge_x,edge_y = [],[]
for edge in G.edges():
    x0, y0 = graph_coordinates[edge[0]]
    x1, y1 = graph_coordinates[edge[1]]
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

node_x,node_y = [],[]
for node in G.nodes():
    x, y = graph_coordinates[node]
    node_x.append(x)
    node_y.append(y)

# define edge and node plots using GPU rendering
edge_trace = go.Scattergl(x=edge_x, y=edge_y,
                          line=dict(width=1, color='black'),
                          hoverinfo='none',mode='lines')

node_trace = go.Scattergl(x=node_x, y=node_y,
                          mode='markers',hoverinfo='text',
                          marker=dict(showscale=True,reversescale=False,
                                      color=[],colorscale='YlOrRd',
                                      size=15,
                                      opacity=0.75,
                                      colorbar=dict(thickness=15,title='Disease Score',
                                                    xanchor='left',titleside='right'),
                                      line=dict(width=2.5,color='black'))
                         )

# re-scale colors in disease group to make them more pronouced
score_col = np.copy(MST_label["pseudotime"].to_numpy())
score_col[MST_label["bp_group"]==2] *= 3
score_col[score_col>1] = 1
node_trace.marker.color = score_col

# highlight most healthy and most diseased nodes
node_trace_b = go.Scatter(x=[node_x[root_node]], y=[node_y[root_node]],
                          mode='markers',marker_symbol="star",marker_line_color="black",
                          marker_size=30,marker_line_width=2,marker_color="Green",
                          hovertemplate="Root Node (Least Diseased Node)"
                          )
                    
# produce the overall plot
fig = go.Figure(data=[edge_trace, node_trace, node_trace_b],
                layout=go.Layout(
                    title='<br>Disease Trajectory Map of Patients in the UK Biobank',
                    titlefont_size=20,
                    showlegend=False,
                    hovermode='closest',
                    margin=dict(b=20,l=5,r=5,t=40),
                    annotations=[dict(text="add annotation here",xref="paper", yref="paper",
                                      showarrow=False,x=0.005, y=-0.002)],
                    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False))
                )

# save the plot to offline html file
plotly.offline.plot(fig, filename='Trajectory.html', auto_open=False)
