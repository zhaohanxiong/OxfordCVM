function [global_pseudotimes,mappedX,contrasted_data,Node_contributions,Expected_contribution] = ... 
                pseudotimes_cTI_v4(data,starting_point,classes_for_colours,final_subjects,method,max_cPCs)

% Author: code re-written by Zhaohan Xiong from the version of Yasser Iturria Medina, 
%     NeuroPM lab, MNI, McGill.
%-- INPUTS:
%     data: [Nsubjects, Nfeatures] data matrix.
%     starting_point: indices of the background subjects.
%     classes_for_colours: [Nsubjects, 1] subjects categories/labels, if
%         available, only for results visualization.
%     final_subjects: you may specify the indices of a target group (a subgroup of the 
%         whole population, e.g. subjects a advanced disease pathology). By
%     default, the algorithm takes all the subjects that don't belong to the
%         background.
%     method: cPCA or Kernel_cPCA
%     max_cPCs: maximum number of principal components to consider.
%
%-- OUTPUTS:
%     global_ordering: subjects ordering in the pseudotime line.
%     global_pseudotimes
%     mappedX: obtained contrasted Principal Components (cPCs).
%     contrasted_data: reconstructed data considering only the final cPCs (of note, output 
%         may not be in the same scale that the initial data).
%     Node_contributions: contribution of each node to the final representation space.
%     Expected_contribution: expected nodes contribution assuming equal weights
%         in the final representation space (usefull as cut-off value).

% Reducing dimensionality
% define disease/background and number of patients in the dataset
starting_point = starting_point(:);
final_subjects = final_subjects(:);

% define range of alphas to compute
n_alphas = 50;
alphas_all = logspace(-2, 1, n_alphas);

% perform contrastive PCA (using background and disease as priors into PCA)
if strcmp(method, 'cPCA')
    [cPCs, gap_values, alphas, no_dims, contrasted_data, Vmedoid,Dmedoid] = ... 
                cPCA(data,starting_point,final_subjects,max_cPCs,classes_for_colours,alphas_all);
elseif strcmp(method, 'Kernel_cPCA')
    [cPCs, gap_values, alphas, no_dims, contrasted_data, Vmedoid,Dmedoid] = ... 
        contrastiveKernelPCA(data,starting_point,final_subjects,max_cPCs,classes_for_colours,alphas_all);
end

% store the output values
[~,j]           = max(gap_values); % the optimun alpha should maximizes the clusterization in the target dataset
mappedX         = cPCs(:,1:no_dims(j),j);
Node_Weights    = Vmedoid(:,1:no_dims(j),j);
Lambdas         = Dmedoid(1:no_dims(j),j);
contrasted_data = contrasted_data(:,:,j);

% print some output metrics (number of PCs and final alpha of Cd - alpha*Cb)
disp(['----- Number of cPCs: ' num2str(no_dims(j))]);
disp(['----- Alpha Selected: ' num2str(alphas(j))]);

% compute nodal weightings (values of the final eigen vectors)
Node_contributions = (100*(Node_Weights.^2)./repmat(sum(Node_Weights.^2,1),size(Node_Weights,1),1))*Lambdas;
Expected_contribution = sum(100*1/size(Node_Weights,1)*Lambdas);

% Node-node distance
dist_matrix = double(L2_distance(mappedX', mappedX'));

% Minimal spanning tree across all the points
% Specifying which node is the root, the closest one to all the starting points
[~,j] = min(sum(dist_matrix(starting_point, starting_point),2));
Root_node = j;

% subset background and diseased groups
in_background_target = [starting_point(:); final_subjects(:)];
dist_matrix0 = dist_matrix;   
out_background_target = setdiff(1:size(data, 1), in_background_target)';
dist_matrix = dist_matrix(in_background_target, in_background_target);

% calculate minimum spanning tree
rng('default'); % For reproducibility
Tree = graphminspantree(sparse(dist_matrix), Root_node);
Tree(Tree > 0) = dist_matrix(Tree > 0);
MST = full(Tree + Tree'); %alternate: MST = minspantree(graph(dist_matrix, "upper"));

% Shortest paths to the starting point(s) and pseudotimes
datas = dijkstra(MST, Root_node');
dijkstra_F = datas.F; % dijkstra father nodes for trajectory analysis
max_distance = max(datas.A(~isinf(datas.A)));

% initialize and define pseudotimes array
global_pseudotimes = zeros(size(data, 1), 1);
global_pseudotimes(in_background_target, 1) = datas.A/max_distance;

% extrapolate between group values
temp_dist = dist_matrix0(out_background_target, in_background_target);
[~, j] = min(temp_dist,[],2);
global_pseudotimes(out_background_target, 1) = global_pseudotimes(in_background_target(j), 1);

% convert MST from adjacency matrix into graph object
MST_graph = graph(MST);

% produce visualization and save the plots
colours_healthy_disease = classes_for_colours(classes_for_colours ~= 2);
f = figure('visible','off');
subplot(1,2,1);
boxplot(global_pseudotimes,classes_for_colours);
title('Disease Score By Group');
subplot(1,2,2);
p = plot(MST_graph);
highlight(p, MST_graph, 'EdgeColor', 'black', 'LineWidth',1);
highlight(p, find(colours_healthy_disease==1), 'NodeColor', 'g', 'MarkerSize',2);
highlight(p, find(colours_healthy_disease==3), 'NodeColor', 'r', 'MarkerSize',2);
highlight(p, Root_node, 'NodeColor', 'black', 'Marker', '^', 'MarkerSize', 5);
title('Minimum Spanning Tree (Background/Disease)');
set(gcf, 'PaperPosition', [0 0 30 10]);
saveas(f, 'io/results_final.png');

% save MST labels as table to output file
MST_groups = colours_healthy_disease';
MST_groups(MST_groups==3) = 2;
MST_labels = table(MST_groups, global_pseudotimes(in_background_target,1), ...
                   'VariableNames', {'bp_group', 'pseudotime', });
writetable(MST_labels,'io/MST.csv', 'WriteVariableNames', true);

% clear and save variables
clear Tree dist_matrix0 dist_matrix
writetable(table(mappedX), 'io/cPC.csv', 'WriteVariableNames', true); % saving cPCs to file
save('io/PC_Transform.mat','Node_Weights'); % eigen matrix to perform transformation into PCA space
save('io/dijkstra.mat','dijkstra_F'); % dijkstra father nodes of every node for computing trajectories
save('io/MST.mat','MST'); % save minimum spanning tree individually
%save('io/all.mat'); % save all variables to workspace to study intermediary values

% evaluate current model efficacy
Q1_disease = quantile(global_pseudotimes(classes_for_colours == 3), 0.25);
lower_disease = min(global_pseudotimes(classes_for_colours == 3));

Q1_between = quantile(global_pseudotimes(classes_for_colours == 2), 0.25);
Q2_between = quantile(global_pseudotimes(classes_for_colours == 2), 0.5);

Q3_background = quantile(global_pseudotimes(classes_for_colours == 1), 0.75);

% define conditions for model efficacy
condition_1 = lower_disease > Q3_background; % minimal overlap for background and disease
condition_2 = Q1_disease > Q2_between;       % no overlap for IQR of disease and between
condition_3 = Q1_between > Q3_background;    % no overlap for IQR of between and background

return;
