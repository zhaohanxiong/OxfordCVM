rng(1) % For reproducibility
[idx,C,sumd,D] = kmeans(data,5,'Distance','correlation');
% idx = idx - 1;
[highest,highest_id] = max(sumd);
[lowest,lowest_id] = min(sumd);
all_indices = [1:size(sumd,1)];
all_indices([lowest_id highest_id]) = [];
ind_between2    = find(idx == all_indices);
ind_background2 = find(idx == lowest_id);
ind_target2     = find(idx == highest_id);

[idx,C,sumd,D] = kmeans(data,5,'Distance','sqeuclidean');
classes_for_colours2 = classes_for_colours';
count = single.empty;
for o = 1:length(unique(idx))
    ind_background2 = find(idx == o);
    count(o,1) = length(find(ismember(ind_background2,ind_background) == 1));
end
[highest,highest_id] = max(count);
ind_background2 = find(idx == highest_id);

% ind_background2 = find(idx == highest_id);
% ind_background2 = find(ismember(ind_background2,ind_background) == 1);

classes_for_colours2(ind_background2) = 1;


count = single.empty;
for o = 1:length(unique(idx))
    ind_target2 = find(idx == o);
    count(o,1) = length(find(ismember(ind_target2,ind_target) == 1));
end
[highest,highest_id] = max(count);
ind_target2 = find(idx == highest_id);

% ind_target2 = find(idx == highest_id);
% ind_target2 = find(ismember(ind_target2,ind_target) == 1);

classes_for_colours2(ind_target2) = 3;

all_indices = [1:size(data,1)];
all_indices([ind_background2;ind_target2]) = [];
ind_between2 = all_indices;

classes_for_colours2(ind_between2) = 2;