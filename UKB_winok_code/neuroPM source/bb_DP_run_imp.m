
function[pseudotimes_file, FigList, node_contributions, expected_contribution]=bb_DP_run_imp(dir)

[num,txt,raw] = xlsread(strcat(dir,'data_sub.xlsx')); 
var_names = string(deblank(char(txt(1,:))));

RecordId=raw(:,find(contains(txt(1,:),'Record.Id')));
RecordId=RecordId(2:end);

dp_bpgroup_o = raw(:,find(contains(txt(1,:),'bp_group')));
dp_bpgroup = dp_bpgroup_o(2:end);
dp_bpgroup = cell2mat(dp_bpgroup);

% starting_point
ind_bck = dp_bpgroup(:,[end]) == 1; % indices, pathology-free subjects.
ind_background=find(ind_bck);

% final_subjects
ind_trg     = dp_bpgroup(:,[end]) == 2; % indices, hypertensives.
ind_target=find(ind_trg);

% in between subjects
ind_betw =  dp_bpgroup(:,[end]) == 0; % indices, not background or hypertensive.
ind_between=find(ind_betw);

var_names(find(contains(var_names(:,:),{'Record.Id' 'StudyName'})))=[];

A=find(contains(var_names(:,:),{'bp_group'}));
data_dp=num;
data_dp(:,[A])=[];
var_names(find(contains(var_names(:,:),{'bp_group'})))=[];

%%
if find(contains(dir,{'cov'}))
    [num_cov,txt_cov,raw_cov]  = xlsread(strcat(dir,'cov.xlsx'));
    covariables = num_cov;
    data_dpz  = zscore(removing_covariable_effects(data_dp,covariables,ind_background,[1:size(covariables,2)]));
else
    data_dpz = zscore(data_dp)
end

%%
% classes for colours
classes_for_colours= [];
classes_for_colours(ind_target) = 1; classes_for_colours(ind_background) = 2;
classes_for_colours(ind_between) = 3;

%% call function
[global_ordering,global_pseudotimes,mappedX,contrasted_data,Node_contributions,Expected_contribution] = pseudotimes_cTI(data_dpz,ind_background,classes_for_colours,ind_target,'cPCA',10);

%% save results
pseudotimes_file=table(RecordId,dp_bpgroup,global_pseudotimes);
FigList=findobj(allchild(0), 'flat', 'Type', 'figure')

%% weighting
node_contributions=table(var_names,Node_contributions);
expected_contribution=table(Expected_contribution);

end

