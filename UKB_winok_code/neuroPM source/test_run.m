%% read data
% add paths to workspace (additional functions to access in subfolder)
addpath("cTI-codes\","cTI-codes\auxiliary\","cTI-codes\dijkstra_tools\");

% loads data (main feature matrix) and labels (bp_group)
load('ukb_data.mat');

% set indices of background/target/between
ind_between = find(bp_group == 0);
ind_background = find(bp_group == 1);
ind_target = find(bp_group == 2);

% set colors to use for each class
classes_for_colours = [];
classes_for_colours(ind_target) = 1;
classes_for_colours(ind_background) = 2;
classes_for_colours(ind_between) = 3;

%% call function
[global_ordering, global_pseudotimes, mappedX, contrasted_data, Node_contributions, Expected_contribution] = ...
          pseudotimes_cTI(data, ind_background, classes_for_colours, ind_target, 'cPCA', 10);

%% save results
pseudotimes_file = table(bp_group, global_pseudotimes);
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

%% weighting
node_contributions = table(var_names,Node_contributions);
expected_contribution = table(Expected_contribution);

%% output
writetable(pseudotimes_file, strcat(dir,'global_pseudotimes.csv'));
writetable(node_contributions, strcat(dir,'var_weighting.csv'));
writetable(expected_contribution, strcat(dir,'thr_weighting.csv'));
savefig(FigList,strcat(dir, 'fig_global_pseudotimes'));
close(findobj(allchild(0), 'flat', 'Type', 'figure'))