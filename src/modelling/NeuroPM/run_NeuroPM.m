%% add paths (uncomment if youre not running the compiled mcc matlab version)
addpath("cTI-codes/","cTI-codes/auxiliary/","cTI-codes/dijkstra_tools/","cTI-codes/data_harmonization/");

%% read data
% loads data (main feature matrix) and labels (bp_group)
ukb_data = readtable('io/ukb_num_norm_ft_select.csv'); % N patients by M features
ukb_data_raw = readtable('io/ukb_num_ft_select.csv'); % N patients by M features
labels   = readtable('io/labels_select.csv'); % N patients with arbitrary number of columns

% extract parts of dataframe to array
data     = table2array(ukb_data);
bp_group = table2array(labels(:,'bp_group')); % ensure column name for grouping is correct

% set indices of background/target/between, ensure labels are correct, numeric only
ind_between    = find(bp_group == 0);
ind_background = find(bp_group == 1);
ind_target     = find(bp_group == 2);

% set colors to use for each class
classes_for_colours = [];
classes_for_colours(ind_background) = 1;
classes_for_colours(ind_between)    = 2;
classes_for_colours(ind_target)     = 3;

%% (dont use as takes very long to run) impute data
%data(ismissing(data)) = nan;
%data = TSR(data);

%% (dont use as takes very long to run) feature selection
%[selected_features, ratio_sigma2_s2, sigma2_g, S2_g] = select_features(data, 1, 0.5);
%data = data(:, selected_features);
%disp(['Reduced Data To ' num2str(size(data,2)) ' Features'])

%% adjust for covariates
try
    cov = table2array(readtable('io/cov.csv'));
    data = removing_covariable_effects(data, cov, ind_background, 1:size(cov,2));
catch
    warning("No Covariate Adjustment Performed");
end

%% data harmonization
try
    loc = readtable('io/loc.csv');
    loc = table2array(loc(:, 'loc_var'));
    data = combat(data', loc, [], 1);
    data = data';
catch
    warning("No Data Harmonization Performed");
end

%% call function
[global_pseudotimes, mappedX, ~, Node_contributions, Expected_contribution] = ...
    pseudotimes_cTI_v4(data, ind_background, classes_for_colours, ind_target, 'cPCA', 50);

%% convert outputs to dataframes
% store cTI outputs
pseudotimes_file = [labels, table(global_pseudotimes)];
node_contributions = table(ukb_data.Properties.VariableNames', Node_contributions);
expected_contribution = table(Expected_contribution);

%% write to csv
writetable(pseudotimes_file, strcat('io/pseudotimes.csv'));
writetable(node_contributions, strcat('io/var_weighting.csv'));
writetable(expected_contribution, strcat('io/threshold_weighting.csv'));
