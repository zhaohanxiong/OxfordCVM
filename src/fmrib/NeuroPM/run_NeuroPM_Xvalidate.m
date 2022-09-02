%% read data
% loads data (main feature matrix) and labels (bp_group)
ukb_data = readtable('io/ukb_num_norm_ft_select.csv');
labels   = readtable('io/labels_select.csv');

% extract parts of dataframe to array
data = table2array(ukb_data);

%% Cross Validation
N_patients = size(data,1);
folds = 10;
fold_ranges = floor(linspace(1, N_patients, folds + 1));

for i = 1:(length(fold_ranges) - 1)
    
    disp(['..... Running Cross Validation Fold ' num2str(i)]);
    
    % define indices for fold i
    start_ind = fold_ranges(i);
    end_ind = fold_ranges(i + 1) - (i ~= folds);
    
    % leave out indices of this fold for training
    fold_leave_in = setdiff(1:N_patients, start_ind:end_ind, 'stable');
    
    % subset data for each fold
    data_i = data(fold_leave_in, :);
    labels_i = labels(fold_leave_in, :);
    bp_group_i = table2array(labels_i(:, 'bp_group'));
    
    % set indices of background/target/between
    ind_between = find(bp_group_i == 0);
    ind_background = find(bp_group_i == 1);
    ind_target = find(bp_group_i == 2);

    % run cTI for this fold
    [global_pseudotimes] = pseudotimes_cTI_Xvalidate(data_i, ind_background, ind_target, 25);

    % convert outputs to dataframe and write to csv for fold i
    writetable([labels_i, table(global_pseudotimes)], strcat(['io/pseudotimes_fold' num2str(i) '.csv']));

end