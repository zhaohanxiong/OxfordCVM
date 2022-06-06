function [selected_features,ratio_sigma2_s2,sigma2_g,S2_g] = select_features(norm_data,network_option,cdf_prob_threshold)
% norm_data: [N_samples x N_features] matrix. z-score already normalized
% network_option = 1; % for minimum number of nearest neighbors needed to
% yield a fully connected graph (like in Welch et al., 2016, Genome
% Biology).
% network_option = 2; % for minimum node degree needed to yield a fully
% connected graph backbone.
% cdf_prob_threshold: cut-off value (e.g. 0.95 will keep only the features with a 0.95 probably of being in a trajectory).
%---------------------------------------------------------------%
% Author: Yasser Iturria medina, 17/05/2018.
% See Welch et al., 2016, Genome Biology, 17, 1�15.

if nargin < 2 || isempty(network_option)
    network_option = 1; % like in Welch et al., 2016, Genome Biology.
end
[N_samples,N_features] = size(norm_data);

if network_option == 1, % Calculating minimum number of nearest neighbors needed to yield a fully connected graph
    kc = 1;
    while 1
        kc = kc + 1;
        if N_features > N_samples
            if kc == 2
                coeff = pca(norm_data); mappedX = norm_data*coeff;
            end
            distance    = find_nn(mappedX, kc);
        else
            distance    = find_nn(norm_data, kc);            
        end
        distance = full(distance);
        [S,C] = conncomp(distance);
        if S == 1,
            break;
        end
    end
elseif network_option == 2, % Calculating minimum degree (kc) for obtaining a fully connected backbone
    kc = 4;
    while 1
        if kc == 4
            if N_features > N_samples
                coeff = pca(norm_data); mappedX = norm_data*coeff;
                distance  = L2_distance(mappedX', mappedX');
            else
                distance  = L2_distance(norm_data', norm_data');
            end
        end
        sim = (distance > 0).*(max(distance(:)) - distance);
        sim = sim - diag(diag(sim));
        sim = double(sim + sim');
        BackBone = network_backbone1(full(sim), kc);
        [S,C] = conncomp(BackBone);
        if S == 1,
            distance = (BackBone > 0).*(max(BackBone(:)) - BackBone);
            break;
        end
        kc = kc + 1;
    end
end

% Calculating sample variance with respect neighboring points
sigma2_g = var(norm_data,[],1)';
S2_g     = zeros(N_features,1);
distance = distance - diag(diag(distance));

for i = 1:N_samples
    kc_node = length(nonzeros(distance(i,:)));
    ind     = find(distance(i,:));
    S2_g    = S2_g + var(repmat(norm_data(i,:),[length(ind) 1]) - norm_data(ind,:),0,1)'/N_samples;
end

% Selecting features more likely to be involved in a trajectory, i.e.
% features that show more gradual variation across neighboring points than
% at global scale:
if nargin < 3 || isempty(cdf_prob_threshold)
    selected_features = find(sigma2_g > S2_g);
else
    [x,f]     = ecdf(sigma2_g./(S2_g+eps));
    threshold = min(f(find(x > cdf_prob_threshold)));
    selected_features = find(sigma2_g./(S2_g+eps) >= threshold);
end
ratio_sigma2_s2 = sigma2_g./(S2_g+eps);
return;