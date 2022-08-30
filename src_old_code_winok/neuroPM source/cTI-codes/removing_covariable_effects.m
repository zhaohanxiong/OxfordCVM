function [new_features, base_features] = removing_covariable_effects(features, covariables, ind_2_estimate, covs_2_remove, covariable_base, value_base, ind_for_base)
% removing_covariable_effects: this function controls for effects on
% "features" data caused by variables in "covariables" data. It considers a
% lineal model with interactions between the covariables.
% INPUTS
% features: original data that should be used in a posterior analysis.
% organized in a [Nsubjects x Nfeatures] matrix.
% covariables: covariables whose effects should be removed from the
% features. Organized as [Nsubjest x Ncovariables] matrix.
% ind_2_estimate: indices of the subjects to fit the model (default: all subjects)
% covs_2_remove: indices of the predictors/covariables to control. Only
% the effects of these variables will be removed, although all the covariables will be used to fit the model.
% OUTPUTS
% new_features: [Nsubjects x Nfeatures] matrix with the modified features.
% base_features: [Nsubjects x Nfeatures] matrix with the estimated features for the 
% covariable_base predictor evaluated at value_base.

Nfeatures = size(features,2);
Nsubjects = size(features,1);
Ncovs     = size(covariables,2);

if nargin < 3 || isempty(ind_2_estimate)
    ind_2_estimate = 1:Nsubjects; % if we want to calculate only with a "reference subgroup" (e.g. HC subjects)
end
if nargin < 4 || isempty(covs_2_remove)
    covs_2_remove = 1:Ncovs;      % if we want to remove all covariables
end
% if Ncovs > 1, % For considering interactions
%     Interactions = nchoosek(1:Ncovs,2); % for consider interactions of order two
%     for i = 1:size(Interactions,1)      % Adding all possible interactions
%         covariables = [covariables covariables(:,Interactions(i,1)).*covariables(:,Interactions(i,2))];
%         if length(find(Interactions(i,1) == covs_2_remove)) && length(find(Interactions(i,2) == covs_2_remove)),
%             covs_2_remove = [covs_2_remove Ncovs+i];
%         end
%     end
%     %     Interactions_order3 = nchoosek(1:Ncovs,3); % for consider interactions of order three
%     %     for i = 1:size(Interactions_order3,1)      % Adding all possible interactions
%     %         covariables = [covariables covariables(:,Interactions_order3(i,1)).*covariables(:,Interactions_order3(i,2)).*covariables(:,Interactions_order3(i,3))];
%     %         if length(find(Interactions_order3(i,1) == covs_2_remove)) && length(find(Interactions_order3(i,2) == covs_2_remove)) && length(find(Interactions_order3(i,3) == covs_2_remove)),
%     %             covs_2_remove = [covs_2_remove Ncovs+i];
%     %         end
%     %     end
% end
ind_nan = find(isnan(covariables));
[i,j]   = ind2sub(size(covariables),ind_nan);
for ii = 1:length(i)
    ind_non_nan = find(~isnan(covariables(:,j(ii))));
    covariables(i(ii),j(ii)) = mean(covariables(ind_non_nan,j(ii)));    
end
h = waitbar(0,'Removing covariable effects...');
for feature = 1:Nfeatures
    waitbar(feature / Nfeatures)
    
    %     stats = regstats(features(:,feature),covariables,'linear');
    % stats = regstats(features(:,feature),covariables,'interaction');
    %     stats = regstats(features(:,feature),covariables,'purequadratic');
    %     stats = regstats(features(:,feature),covariables,'quadratic');
    % new_features(:, feature) = stats.r + stats.beta(1);
    
    warning off; 
    [b,stats] = robustfit(covariables(ind_2_estimate,:),features(ind_2_estimate,feature));
    
    % new_features(:, feature) = stats.resid + b(1); %
    % new_features(:, feature) = features(:,feature) - covariables*b(2:end);
    % new_features(:, feature) = features(:,feature) - covariables(:,covs_2_remove)*b(1 + covs_2_remove);
    
    % Adjusting only significant associations
    covs_2_remove_sig = covs_2_remove(stats.p(1+covs_2_remove) < 1);
    if ~isempty(covs_2_remove_sig)        
        new_features(:,feature) = features(:,feature) - covariables(:,covs_2_remove_sig)*b(1+covs_2_remove_sig);
    else
        new_features(:,feature) = features(:,feature);
    end
    if nargin > 3 && nargout > 1,
        if feature == 1,
            if nargin < 7 || isempty(ind_for_base), ind_for_base = 1:length(covariables); end
            covs_base = covariables(:,1:size(covariables,2) - size(Interactions,1));
            for i = 1:length(covariable_base)
                covs_base(ind_for_base,covariable_base(i)) = value_base(i);
            end
            for i = 1:size(Interactions,1) % Adding all possible interactions
                covs_base = [covs_base  covs_base(:,Interactions(i,1)).*covs_base(:,Interactions(i,2))];
            end
            non_ind_for_base = setdiff(1:Nsubjects,ind_for_base);
        end
        base_features(ind_for_base, feature)     = b(1) + covs_base(ind_for_base,:)*b(2:end); % simulating baseline
        base_features(non_ind_for_base, feature) = features(non_ind_for_base,feature);        % keeping original values for non-reference subjects
        
        % base_features(:, feature) = base_features(:, feature) - covs_base(:,covs_2_remove)*b(1 + covs_2_remove); % removing effects of covs_2_remove        
    end
end
close(h)