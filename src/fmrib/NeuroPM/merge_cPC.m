addpath("cTI-codes\","cTI-codes\auxiliary\","cTI-codes\dijkstra_tools\");

N_nodes = 15000;

% load and combine the labels
labels_0001 = readtable('C:/Users/zxiong/Desktop/io 1-3000/labels.csv');
bp_group = table2array(labels_0001(:, 'bp_group'));
starting_point_0001 = find(bp_group == 1);
final_subjects_0001 = find(bp_group == 2);

labels_3001 = readtable('C:/Users/zxiong/Desktop/io 3001-6000/labels.csv');
bp_group = table2array(labels_3001(:, 'bp_group'));
starting_point_3001 = find(bp_group == 1)+3000;
final_subjects_3001 = find(bp_group == 2)+3000;

labels_6001 = readtable('C:/Users/zxiong/Desktop/io 6001-9000/labels.csv');
bp_group = table2array(labels_6001(:, 'bp_group'));
starting_point_6001 = find(bp_group == 1)+6000;
final_subjects_6001 = find(bp_group == 2)+6000;

labels_9001 = readtable('C:/Users/zxiong/Desktop/io 9001-12000/labels.csv');
bp_group = table2array(labels_9001(:, 'bp_group'));
starting_point_9001 = find(bp_group == 1)+9000;
final_subjects_9001 = find(bp_group == 2)+9000;

labels_12001 = readtable('C:/Users/zxiong/Desktop/io 12001-15000/labels.csv');
bp_group = table2array(labels_12001(:, 'bp_group'));
starting_point_12001 = find(bp_group == 1)+12000;
final_subjects_12001 = find(bp_group == 2)+12000;

starting_point = [starting_point_0001; starting_point_3001; starting_point_6001; starting_point_9001; starting_point_12001];
final_subjects = [final_subjects_0001; final_subjects_3001; final_subjects_6001; final_subjects_9001; final_subjects_12001];
labels = [labels_0001; labels_3001; labels_6001; labels_9001; labels_12001];

% load and combine the cPCs
mappedX_0001 = padarray(mappedX_0001, [0 4], 0, 'post');
mappedX_3001 = padarray(mappedX_3001, [0 5], 0, 'post');
mappedX_6001 = padarray(mappedX_6001, [0 5], 0, 'post');
mappedX_9001 = padarray(mappedX_9001, [0 6], 0, 'post');
mappedX_12001 = padarray(mappedX_12001, [0 5], 0, 'post');
mappedX = [mappedX_0001; mappedX_3001; mappedX_6001; mappedX_9001; mappedX_12001];
%mappedX(abs(mappedX) > std(mappedX,0,"all")*3) = 0;

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

out_background_target = setdiff(1:N_nodes,in_background_target)';
temp_dist = dist_matrix0(out_background_target,in_background_target);
[i,j] = min(temp_dist,[],2);
global_pseudotimes(out_background_target,1) = global_pseudotimes(in_background_target(j),1);
[~,global_ordering] = sort(global_pseudotimes);

% load and combine nodal weights distribution
Node_contributions = (Node_contributions_0001 + Node_contributions_3001 + Node_contributions_6001 + Node_contributions_9001)./4;
ukb_data = readtable('C:/Users/zxiong/Desktop/io 1-3000/ukb_num_norm.csv');
node_contributions = table(ukb_data.Properties.VariableNames', Node_contributions);

% save
pseudotimes_file = [labels, table(global_pseudotimes)];
writetable(pseudotimes_file, strcat('C:/Users/zxiong/Desktop/pseudotimes.csv'));
writetable(node_contributions, strcat('C:/Users/zxiong/Desktop/var_weighting.csv'));
