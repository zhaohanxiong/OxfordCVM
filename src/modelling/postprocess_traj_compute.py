import os
import sys
import plotly
import scipy.io
import argparse
import numpy as np
import pandas as pd
import networkx as nx
import plotly.graph_objects as go
from scipy.sparse.csgraph import laplacian

# parameters
parser = argparse.ArgumentParser()
parser.add_argument("--max_traj_num", default = 8, type = int, help = "Maximum number of trajectories")
parser.add_argument("--overlap_threshold", default = 0.8, type = float, help = "Maximum threshold for trajectory overlap")
parser.add_argument("--color_by", default = "score", type = str, help = "score/group/traj")
args = parser.parse_args(sys.argv[1:])

# source path & set the current working directory
path = "NeuroPM/io/"
os.chdir(path)

# load labels (0 = between, 1 = background, 2 = disease)
labels = pd.read_csv("pseudotimes.csv", index_col = False)
MST_ind = np.append(np.where(labels["bp_group"] == 1)[0], np.where(labels["bp_group"] == 2)[0])

# load minimum spanning tree, and labels for each node in the graph
MST_mat = scipy.io.loadmat("MST.mat")["MST"]
G = nx.from_numpy_matrix(MST_mat)
MST_label = pd.read_csv("MST.csv", index_col=False)

# root node (least diseased node)
root_node = np.argmin(MST_label["pseudotime"])

# load dijkstra for determining trajectories of each path, root node = -1
dijkstra_F = scipy.io.loadmat("dijkstra.mat")["dijkstra_F"][:,0]
dijkstra_F[dijkstra_F!=-1] -= 1 # since matlab is 1-indexed and python is 0-index

# find every node on branch ends (nodes which are not father nodes/does not have child nodes)
end_nodes = np.array([i for i in range(len(dijkstra_F)) if not any(i == dijkstra_F)])
end_nodes = end_nodes[end_nodes!=-1]

# define trajectory for each end-node
trajectories = [] # this will contain every node in the MST
for n in end_nodes: # for each node without child nodes

    path, path_node = [], n

    # traverse from the end node back to the root node and store all nodes along the path
    while path_node != -1: # backtrack through dijkstra until root node is reached
        path.append(path_node)
        path_node = dijkstra_F[path_node]

    trajectories.append(np.array(path)) # add to list of trajectories

# define matrix of number of similar elements between every combination of paths
overlap = np.zeros([len(trajectories), len(trajectories)])

# loop through upper triangular matrix of pair-wise comparison matrix
for i in range(len(trajectories)):

    # define the path to compare with every other path with
    path_set = set(trajectories[i])
    path_length = len(path_set)

    # compare current path to every other path
    for j in range(i+1,len(trajectories)):

        # create a set for the incoming trajectory to compare with the current
        incoming_traj = set(trajectories[j])

        # calculate the length of overlap between 2 nodes
        overlap_length = len(path_set & incoming_traj)

        # calculate overlap as a percentage of the path being compared
        overlap_percentage = overlap_length/np.min([path_length, len(incoming_traj)])
        
        # convert this part into binary, False for not same, True for same
        overlap[i,j] = overlap_percentage > args.overlap_threshold

# using the similarities, collate lists of indices of paths which are similar
trajectory_groups = [] # list of indices of trajectory which are highly similar
for i in range(overlap.shape[0]):
    
    # check which paths have enough overlap to be considered the same
    ij = np.where(overlap[i,:] == True)[0]
    set_i = set().union(set([i]),set(ij))

    # check current list of trajectories groups to see if these can be added to existing groups
    list_similar = []
    for j in range(len(trajectory_groups)):
        
        # if there are overlapping paths, 
        if len(set(trajectory_groups[j]) & set_i) > 0:
            trajectory_groups[j] = set.union(set_i, set(trajectory_groups[j]))
            list_similar.append(j)

    # if there are more than 1 overlapping set of paths, then merge into the first one
    if len(list_similar) > 1:
        
        k0 = list_similar[0]

        # go in reverse order and merge onto first 1st list and delete element once merged
        for k in sorted(list_similar[1:], reverse=True):
            trajectory_groups[k0] = set.union(trajectory_groups[k0], trajectory_groups[k])
            del trajectory_groups[k]
    
    # if the current set has no similarities with the previous sets, add this as new unique set
    if len(list_similar) == 0:
        trajectory_groups.append(set_i)

# retrive reduced trajectories list
trajectories_reduced = [[] for _ in range(len(trajectory_groups))]

for i, traj in enumerate(trajectory_groups):

    # append trajectories
    reduced_traj_i = []
    for traj_i in traj:
        reduced_traj_i.extend(trajectories[traj_i])

    # store unique nodes
    trajectories_reduced[i] = np.unique(np.array(reduced_traj_i))

# initialize list to store trajectories which don't belong with any other
no_group = np.array([False for _ in range(len(trajectories_reduced))])

# perform pairwise comparisons between reduced trajectories to reduce further to <5
while len(trajectories_reduced) > args.max_traj_num:

    # debugging, flatten list and print out unique nodes
    #print(np.unique([item for sublist in trajectories_reduced for item in sublist]).shape[0])

    # find the shortest trajectory
    traj_lengths = [len(t) for t in trajectories_reduced]
    shortest_i = np.argsort(traj_lengths)[0]

    # if this node is already a trajectory that doesnt belong to any paths
    if len(np.where(no_group)[0]) > 0:
        if shortest_i == np.where(no_group)[0][0]:
            shortest_i = np.argsort(traj_lengths)[1]

    shortest_traj = set(trajectories_reduced[shortest_i])

    # merge trajectory with closest match
    match_length = np.array([len(set.intersection(shortest_traj, set(t))) 
                                                    for t in trajectories_reduced])

    # if all the trajectories are 1s, treat this as special case
    if (match_length == 1).sum() == (match_length.shape[0] -1):

        # if there are other trajectories which have no overlap with others, merge
        if no_group.sum() > 0:

            # compute other trajectory which are not grouped
            ind = np.where(no_group)[0][0]
            
            # merge the two
            trajectories_reduced[ind] = np.append(trajectories_reduced[ind], 
                                                    trajectories_reduced[shortest_i])
            trajectories_reduced[ind] = np.unique(trajectories_reduced[ind])

            # remove the former (current shortest) from the array
            del trajectories_reduced[shortest_i]
            no_group = np.delete(no_group, shortest_i)

        else:

            # set index as true if there are no current trajectories which don't belong to others
            no_group[shortest_i] = True

    else:

        # find the index of most overlap (exclude itself)
        closest_ind = np.argsort(match_length)[len(match_length) - 2]

        # merge the two
        trajectories_reduced[closest_ind] = np.append(trajectories_reduced[closest_ind], 
                                                            trajectories_reduced[shortest_i])
        trajectories_reduced[closest_ind] = np.unique(trajectories_reduced[closest_ind])

        # remove the former (current shortest) from the array
        del trajectories_reduced[shortest_i]
        no_group = np.delete(no_group, shortest_i)

# create sets of unique merged trajectory paths using the indices derived above
traj_list = [[] for _ in range(MST_label.shape[0])]
MST_label["trajectory"] = -1

# assign trajectory number to node, each node may have multiple trajectories
for i in range(len(trajectories_reduced)):

    for j in trajectories_reduced[i]:
        traj_list[j].append(i)

# add the trajectory to the MST label as list for each element
for i in range(MST_label.shape[0]):

    # if root node, don't label as trajectory
    if i == root_node:
        MST_label.at[i, "trajectory"] = -1

    # for all other nodes, include in trajectory with most nodes if multiple
    else:

        # get current list of possible trajectories
        traj_list_i = traj_list[i]

        # if node belongs to more than 1 trajectory
        if len(traj_list_i) > 1:
            traj_list_i = traj_list_i[np.argmax([len(trajectories_reduced[t]) 
                                                            for t in traj_list_i])]
        
        # if only 1 trajectory, then just take that value
        else:
            traj_list_i = traj_list_i[0]
            
        # store value in table for the node
        MST_label.at[i, "trajectory"] = traj_list_i

# map this back to the label file, assume order hasnt shuffled, and just between group is gone in MST_label
labels["trajectory"] = -999
labels.loc[MST_ind, "trajectory"] = MST_label["trajectory"].to_numpy()

# infer the traj of between group with the same pseudotime score as the background/target nodes
for i in np.where(labels["bp_group"] == 0)[0]:
    
    ind = np.where((labels["global_pseudotimes"][i] == labels["global_pseudotimes"]).to_numpy() & 
                            (labels["bp_group"] != 0).to_numpy())[0][0]

    labels.at[i, "trajectory"] = labels.at[ind, "trajectory"]

# compute spectral layout using lapacian and eigen decomp (1 minute run time)
L = laplacian((MST_mat>0).astype(int))
vals, vecs = np.linalg.eigh(L)
x, y = vecs[:,1], vecs[:,3]
graph_coordinates = {i: (x[i], y[i]) for i in range(MST_mat.shape[0])}

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

# define edge plots using GPU rendering
edge_trace = go.Scattergl(x=edge_x, y=edge_y,
                          line=dict(width=1, color='black'), mode='lines')

# define colors for continuous value
if args.color_by == "score":

    # continuous scale for disease scores
    score_col = np.copy(MST_label["pseudotime"].to_numpy())

    # re-scale colors in disease group to make them more pronouced
    disease_UQ = np.quantile(score_col[MST_label["bp_group"]==2], 0.75)
    score_col[MST_label["bp_group"]==2] *= 1.0 / disease_UQ
    score_col[score_col>1] = 1

# define colors by discrete value
else:

    if args.color_by == "traj":
    
        # group by trajectory
        #score_col = np.array([int(MST_label.at[i, "trajectory"].split(",")[0]) 
        #                                                    for i in range(MST_label.shape[0])])
        score_col = MST_label["trajectory"]

    elif args.color_by == "group":

        # group by bp
        score_col = MST_label["bp_group"].to_numpy()

    # assign discrete color
    ggplot_cols = np.array(["#F8766D" "#CD9600" "#7CAE00" "#00BE67" 
                            "#00BFC4" "#00A9FF" "#C77CFF" "#FF61CC"])
    #plotly_cols = np.array(['#FD3216', '#00FE35', '#6A76FC', '#FED4C4', '#FE00CE', '#0DF9FF',
    #                        '#F6F926', '#FF9616', '#479B55', '#EEA6FB', '#DC587D', '#D626FF',
    #                        '#6E899C', '#00B5F7', '#B68E00', '#C9FBE5', '#FF0092', '#22FFA7',
    #                        '#E3EE9E', '#86CE00', '#BC7196', '#7E7DCD', '#FC6955', '#E48F72'])
    score_col = ggplot_cols[score_col] # Alphabet Dark24 Light24

# define node plots using GPU rendering
node_trace = go.Scattergl(x=node_x, y=node_y,
                          mode='markers', hoverinfo="x+y",
                          marker=dict(showscale=True,reversescale=False,
                                      size=15,opacity=0.75,
                                      colorbar=dict(thickness=15,title='Disease Score',
                                                    xanchor='left',titleside='right'),
                                      #colorscale='Plasma',
                                      color=score_col,
                                      line=dict(width=2.5,color='black'))
                         )

# highlight most healthy and most diseased nodes
node_trace_b = go.Scatter(x=[node_x[root_node]], y=[node_y[root_node]],
                          mode='markers',marker_symbol="star",marker_line_color="black",
                          marker_size=30,marker_line_width=2,marker_color="Green",
                          hovertemplate="Root Node (Least Diseased Patient)"
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
plotly.offline.plot(fig, filename='Trajectory_Paths.html', auto_open=False)

# write data to output
labels.to_csv("pseudotimes.csv", index=False)

# print message to indicate completion
print("Python -- Completed Trajectory Isolation")
