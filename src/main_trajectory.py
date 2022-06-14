import os
import scipy.io
import numpy as np
import pandas as pd
import networkx as nx
import plotly.graph_objects as go
from scipy.sparse.csgraph import laplacian

# source path
path      = "C:/Users/86155/Desktop/io 10 batches 160 100"
file_path = "" #"io - iter_cPCA full run 10"
path      = os.path.join(path, file_path)

# set the current working directory
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("pseudotimes.csv", index_col = False)

#fig = px.scatter(labels, x="BPSys_2_0", y="global_pseudotimes", trendline="ols", render_mode='webgl')
#fig.show()

# load minimum spanning tree
MST_mat = scipy.io.loadmat("MST.mat")["MST"]
G = nx.from_numpy_matrix(MST_mat)
#nx.draw_spectral(G, with_labels = False)
#plt.savefig("filename.png")
#MST = pd.read_csv("MST.csv",index_col=False)
#MST["group"] = labels["bp_group"][MST["Edges_Index_Matched_1"]-1].to_numpy()
#MST["disease_score"] = labels["global_pseudotimes"][MST["Edges_Index_Matched_1"]-1].to_numpy()

# compute spectral layout
L = laplacian(MST_mat)
vals, vecs = np.linalg.eigh(L)
x, y = vecs[:,1], vecs[:,2]
spectral_coordinates = {i : (x[i], y[i]) for i in range(MST_mat.shape[0])}

edge_x,edge_y = [],[]
for edge in G.edges():
    x0, y0 = spectral_coordinates[edge[0]] #G.nodes[edge[0]]['pos']
    x1, y1 = spectral_coordinates[edge[1]] #G.nodes[edge[1]]['pos']
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

edge_trace = go.Scattergl(x=edge_x, y=edge_y,
                          line=dict(width=0.5, color='#888'),
                          hoverinfo='none',mode='lines')

node_x,node_y = [],[]
for node in G.nodes():
    x, y = spectral_coordinates[node] #G.nodes[node]['pos']
    node_x.append(x)
    node_y.append(y)

node_trace = go.Scattergl(x=node_x, y=node_y,
                          mode='markers',
                          hoverinfo='text',
                          marker=dict(
                                    showscale=True,reversescale=True,
                                    colorscale='YlGnBu',
                                    color=[],size=10,
                                    colorbar=dict(thickness=15,title='Node Connections',
                                                  xanchor='left',titleside='right'),
                                    line_width=2)
                          )

node_adjacencies,node_text = [],[]
for node, adjacencies in enumerate(G.adjacency()):
    node_adjacencies.append(len(adjacencies[1]))
    node_text.append('# of connections: '+str(len(adjacencies[1])))

node_trace.marker.color = node_adjacencies
node_trace.text = node_text

fig = go.Figure(data=[edge_trace, node_trace],
                layout=go.Layout(
                    title='<br>Network graph made with Python',
                    titlefont_size=16,
                    showlegend=False,
                    hovermode='closest',
                    margin=dict(b=20,l=5,r=5,t=40),
                    annotations=[dict(
                        text="annotation",xref="paper", yref="paper",
                        showarrow=False,x=0.005, y=-0.002)],
                    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False))
                )
fig.show()
