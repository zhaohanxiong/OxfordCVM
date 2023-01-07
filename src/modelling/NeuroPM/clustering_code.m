%% read data
% loads data (main feature matrix) and labels (bp_group)
ukb_data = readtable('io/ukb_num_norm.csv'); % N patients by M features
labels   = readtable('io/labels.csv'); % N patients with arbitrary number of columns

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

%%
var_grouped  = readtable('io/var_grouped.csv'); % N patients with arbitrary number of columns
var_grouped = string(table2array(var_grouped));
var_grouped(:,1) = strrep(var_grouped(:,1),"X","x");
var_grouped(:,1) = strrep(var_grouped(:,1),".","_");

variable_names = ukb_data.Properties.VariableNames';
idxa = single.empty;
for o = 1:size(variable_names,1)
    idxa(o,1) = find(string(variable_names{o}) == var_grouped(:,1));
end
var_grouped = var_grouped(idxa,:);
[~,idxa2] = sort(var_grouped(:,2),'ascend');
var_grouped = var_grouped(idxa2,:);

% variable_names = ukb_data.Properties.VariableNames;
% [~,idxa] = ismember(var_grouped(:,1),variable_names);
% [~,idxa2] = sort(idxa,'ascend');
% var_grouped = var_grouped(idxa2,:);

%%% sorting by group
[groups_sorted,sorting_id] = sort(var_grouped(:,2),'ascend');
names_sorted = var_grouped(sorting_id,1);
groups_sorted2 = cell.empty;
names_sorted2 = cell.empty;
for p = 1:length(groups_sorted)
    A = string(groups_sorted(p));
    A = strrep(A,"_"," ");
    groups_sorted2{p,1} = char(A);
    
    B = string(names_sorted(p));
    B = strsplit(B,"_");
    names_sorted2{p,1} = char(B{1,1});
end

%%%% BACKGROUND
% background_subjects = data((labels.bp_group==1) | (labels.bp_group==2),:);
background_subjects = data((labels.bp_group==0) | (labels.bp_group==1) | (labels.bp_group==2),:);
% Blood_group = find(string(groups_sorted2) == "Blood");
% background_subjects_group = background_subjects(:,Blood_group);
% groups_sorted3 = groups_sorted2(Blood_group);
% names_sorted3 = names_sorted2(Blood_group);

all_categories = unique(string(groups_sorted2));
backgrounddisease_subjects = data((labels.bp_group==0) | (labels.bp_group==1) | (labels.bp_group==2),:);
new_data = single.empty;
variable_names = cell.empty;
groups = cell.empty;
% all_thresholds = [33;50;700;12;11;0;0;0];
all_thresholds = [40;60;750;13;12;0;0;0]; %best
% all_thresholds = [0;0;550;0;0;0;0;0];
for category_id = 1:length(all_categories)
    category_id
    selected_group = find(string(groups_sorted2) == all_categories(category_id));
    backgrounddisease_subjects_group = backgrounddisease_subjects(:,selected_group);
    groups_sorted3 = groups_sorted2(selected_group);
    names_sorted3 = names_sorted2(selected_group);
% cgo = clustergram(background_subjects_group,...
%                   'Standardize','none',...
%                   'Symmetric',true,...
%                   'ColorMap','redgreencmap',...
%                   'ColumnLabels',[],...
%                   'RowLabels',[],...
%                   'DisplayRange',1,...
%                   'Cluster','row',...
%                   'ColumnPDist','correlation',...
%                   'RowPDist','correlation',...
%                   'Linkage','average',...
%                   'Dendrogram',0.9,...
%                   'DisplayRatio',0.15);
% 
% % f = figure('Position',[192,46,1235,942]);
% plot(cgo)
% ax = gca;
% ax.FontSize = 7;
% ax.XTickLabel = [];
% ax.YTickLabel = [];
% exportgraphics(ax,'cluster_bg.png');

tree = linkage(backgrounddisease_subjects_group','average','correlation');
% f = figure('Position',[192,46,1235,942]);
rng(1)
selected_parameter = all_thresholds(category_id,1);
[H,T,outperm] = dendrogram(tree,selected_parameter,'Labels',names_sorted3,'ColorThreshold',0.9);
% xtickangle(90)
% close all
%%%% [Group 1 > 40], [Group 2 > 60], [Group 3 > 750], [Group 4 > 11]
%%%% [Group 5 > 12]

similar_variables = cell.empty;
count = 1;
for group_id = 1:size(T,1)
    count_check = length(find(T == group_id));
    if count_check > 1
       similar_variables{count,1} = find(T == group_id);
       count = count + 1;
    end
end

data2 = data(:,selected_group);
for similar_id = 1:length(similar_variables)
    selected_similar = similar_variables{similar_id,1};
    data2 = [data2,mean(data2(:,[selected_similar]),2)];
    data2(:,selected_similar) = NaN;
    new_variable_name = append(names_sorted3{selected_similar});
    new_group_name = append(groups_sorted3{selected_similar});
    names_sorted3 = [names_sorted3;{new_variable_name}];
    groups_sorted3 = [groups_sorted3;{new_group_name}];
end
[NanlocR,NanlocC] = find(isnan(data2) == 1);
NanlocC = unique(NanlocC);
data2(:,NanlocC) = [];

new_data = [new_data,data2];

delete_ids = single.empty;
for o = 1:size(similar_variables,1)
    v_id = similar_variables{o,1};
    delete_ids = [delete_ids;v_id];
end
names_sorted3(delete_ids) = [];
groups_sorted3(delete_ids) = [];

variable_names = [variable_names;names_sorted3];
groups = [groups;groups_sorted3];

end

%% call function
[global_pseudotimes, ~, ~, Node_contributions, Expected_contribution] = ...
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









