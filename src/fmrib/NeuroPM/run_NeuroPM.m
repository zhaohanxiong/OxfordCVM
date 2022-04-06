%% add paths (not for compile version)
%addpath("cTI-codes\","cTI-codes\auxiliary\","cTI-codes\dijkstra_tools\");

%% read data
% loads data (main feature matrix) and labels (bp_group)
ukb_data = readtable('io/ukb_num.csv');
labels = readtable('io/labels.csv');

% extract parts of dataframe to array
data = table2array(ukb_data);
bp_group = table2array(labels(:,'bp_group'));

% set indices of background/target/between
ind_between = find(bp_group == 0);
ind_background = find(bp_group == 1);
ind_target = find(bp_group == 2);

% set colors to use for each class
classes_for_colours = [];
classes_for_colours(ind_target) = 1;
classes_for_colours(ind_background) = 2;
classes_for_colours(ind_between) = 3;

%% impute data (dont use as takes very long to run)
&data(data == -999999) = nan;
&data = TSR(data);

%% call function
[global_ordering, global_pseudotimes, mappedX, contrasted_data, Node_contributions, Expected_contribution] = ...
          pseudotimes_cTI(data, ind_background, classes_for_colours, ind_target, 'cPCA', 10);

%% convert outputs to dataframes
pseudotimes_file = [labels, table(global_pseudotimes)];
node_contributions = table(ukb_data.Properties.VariableNames', Node_contributions);
expected_contribution = table(Expected_contribution);

%% output csv
writetable(pseudotimes_file, strcat('io/pseudotimes.csv'));
writetable(node_contributions, strcat('io/var_weighting.csv'));
writetable(expected_contribution, strcat('io/threshold_weighting.csv'));
