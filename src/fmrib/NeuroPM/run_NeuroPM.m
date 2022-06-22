%% add paths (not for compile version)
%addpath("cTI-codes\","cTI-codes\auxiliary\","cTI-codes\dijkstra_tools\");

%% read data
% loads data (main feature matrix) and labels (bp_group)
ukb_data = readtable('io/ukb_num_norm.csv');
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
classes_for_colours(ind_target) = 3;
classes_for_colours(ind_background) = 1;
classes_for_colours(ind_between) = 2;

%% impute data (dont use as takes very long to run)
%data(ismissing(data)) = nan;
%data = TSR(data);

%% adjust for covariates
%cov = table2array(readtable('io/cov.csv'));
%data = removing_covariable_effects(data, cov, ind_background, 1:size(cov,2));

%% feature selection
%[selected_features, ratio_sigma2_s2, sigma2_g, S2_g] = select_features(data, 1, 0.5);
%data = data(:, selected_features);
%disp(['Reduced Data To ' num2str(size(data,2)) ' Features'])

%% call function
[global_ordering, global_pseudotimes, mappedX, contrasted_data, Node_contributions, Expected_contribution] = ...
                        pseudotimes_cTI_v2(data, ind_background, classes_for_colours, ind_target, 'cPCA', 25);

%% convert outputs to dataframes
pseudotimes_file = [labels, table(global_pseudotimes)];
node_contributions = table(ukb_data.Properties.VariableNames', Node_contributions);
%expected_contribution = table(Expected_contribution);

%% output csv
writetable(pseudotimes_file, strcat('io/pseudotimes.csv'));
writetable(node_contributions, strcat('io/var_weighting.csv'));
%writetable(expected_contribution, strcat('io/threshold_weighting.csv'));
