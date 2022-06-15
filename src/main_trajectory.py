import os
import plotly
import scipy.io
import numpy as np
import pandas as pd
import networkx as nx
import plotly.graph_objects as go
from scipy.sparse.csgraph import laplacian

# source path & set the current working directory
path = "src/fmrib/NeuroPM/io/"
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("pseudotimes.csv", index_col = False)

# load minimum spanning tree
MST_mat = scipy.io.loadmat("MST.mat")["MST"]
G = nx.from_numpy_matrix(MST_mat)
MST = pd.read_csv("MST.csv",index_col=False)
MST["group"] = labels["bp_group"][MST["Edges_Index_Matched_1"]-1].to_numpy()
MST["disease_score"] = labels["global_pseudotimes"][MST["Edges_Index_Matched_1"]-1].to_numpy()

# compute spectral layout using lapacian and eigen decomp
L = laplacian((MST_mat>0).astype(int))
vals, vecs = np.linalg.eigh(L)
x, y = vecs[:,1], vecs[:,2]
spectral_coordinates = {i : (x[i], y[i]) for i in range(MST_mat.shape[0])}

# build list of edges and nodes
edge_x,edge_y = [],[]
for edge in G.edges():
    x0, y0 = spectral_coordinates[edge[0]]
    x1, y1 = spectral_coordinates[edge[1]]
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

node_x,node_y = [],[]
for node in G.nodes():
    x, y = spectral_coordinates[node]
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
                                      line=dict(width=0,color='black'))
                         )

score_col = MST["disease_score"].to_numpy()
score_col[MST["group"]==2] *= 3
score_col[score_col>1] = 1
node_trace.marker.color = score_col

# produce the overall plot
fig = go.Figure(data=[edge_trace, node_trace],
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
