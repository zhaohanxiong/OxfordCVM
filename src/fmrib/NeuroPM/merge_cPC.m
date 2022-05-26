N_nodes = 6000;

% load and combine the labels
labels_0001 = readtable('C:/Users/zxiong/Desktop/io 1-3000/labels.csv');
bp_group = table2array(labels_0001(:, 'bp_group'));
starting_point_0001 = find(bp_group == 1);
final_subjects_0001 = find(bp_group == 2);

labels_3001 = readtable('C:/Users/zxiong/Desktop/io 3001-6000/labels.csv');
bp_group = table2array(labels_3001(:, 'bp_group'));
starting_point_3001 = find(bp_group == 1);
final_subjects_3001 = find(bp_group == 2);

starting_point = cat(1, starting_point_0001, starting_point_3001);
final_subjects = cat(1, final_subjects_0001, final_subjects_3001);
labels = [labels_0001; labels_3001];

% load and combine the cPCs
mappedX_0001 = padarray(mappedX_0001, [0 4], 0, 'post');
mappedX_3001 = padarray(mappedX_3001, [0 5], 0, 'post');
mappedX = cat(1, mappedX_0001, mappedX_3001);

%%
% rest of graph generation code
dist_matrix = double(L2_distance(mappedX', mappedX'));

% Specifying which node is the root, the closest one to all the starting points
[~,j]     = min(sum(dist_matrix(starting_point,starting_point),2));
Root_node = j;

% Calculating minimum spanning tree
in_background_target  = [starting_point(:); final_subjects(:)];

dist_matrix0 = dist_matrix;   
dist_matrix = dist_matrix(in_background_target,in_background_target); % only considering background and target populations

% calculate spanning tree
rng('default'); % For reproducibility
%Tree = adjacency(shortestpathtree(graph(dist_matrix, "upper"), Root_node), "weighted");
Tree = graphminspantree(sparse(dist_matrix),Root_node);
Tree(Tree > 0) = dist_matrix(Tree > 0);
MST = full(Tree + Tree');

%--- Shortest paths to the starting point(s) and pseudotimes
datas = dijkstra(MST, Root_node');
max_distance = max(datas.A(~isinf(datas.A)));
global_pseudotimes(in_background_target,1) = datas.A/max_distance;

% compute between group
in_background_target_0001 = [starting_point_0001(:); final_subjects_0001(:)];
out_background_target_0001 = setdiff(1:3000, in_background_target_0001)';
temp_dist = dist_matrix0(out_background_target_0001,in_background_target_0001);
[i,j] = min(temp_dist,[],2);
global_pseudotimes(out_background_target_0001,1) = global_pseudotimes(in_background_target_0001(j),1);

in_background_target_3001 = [starting_point_3001(:); final_subjects_3001(:)];
out_background_target_3001 = setdiff(3001:6000, in_background_target_3001)';
temp_dist = dist_matrix0(out_background_target_3001,in_background_target_3001);
[i,j] = min(temp_dist,[],2);
global_pseudotimes(out_background_target_3001,1) = global_pseudotimes(in_background_target_3001(j),1);

[~,global_ordering] = sort(global_pseudotimes);

% load and combine nodal weights distribution
Node_contributions = (Node_contributions_0001 + Node_contributions_3001)./2;
ukb_data = readtable('C:/Users/zxiong/Desktop/io 1-3000/ukb_num_norm.csv');
node_contributions = table(ukb_data.Properties.VariableNames', Node_contributions);

% save
pseudotimes_file = [labels, table(global_pseudotimes)];
writetable(pseudotimes_file, strcat('C:/Users/zxiong/Desktop/pseudotimes.csv'));
writetable(node_contributions, strcat('C:/Users/zxiong/Desktop/var_weighting.csv'));
