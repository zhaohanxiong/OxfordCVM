function [cPCs,gap_values,alphas_f,no_dims,contrasted_data,Vmedoid,Dmedoid] = contrastiveKernelPCA(X,indices_background,indices_target,d_max,classes_for_colours,alphas)
% Based on Abid et al., 2018, Nature Comms., 9:2134. The PCA implementation
% is also based in the Matlab Toolbox for Dimensionality Reduction
% (http://homepage.tudelft.nl/19j49).

% % Example data:
% n = 200; k = 1;
% X = [[mvnrnd([0 0 0],[1 1 1],n) 0.1*randn(n,50)]; ...
%     [mvnrnd([2 2 2],ones(3,3),k*n) 0.1*randn(k*n,50)]; ...
%     [mvnrnd([10 10 10],ones(3,3),n) 0.1*randn(n,50)]];
% indices_background  = [1:n]';
% indices_target      = [n+1:size(X,1)]';
% classes_for_colours = [ones(n,1); 2*ones(k*n,1); 3*ones(n,1)];

if nargin < 4
    d_max = min([size(X,2) 10]);
end
if ~exist('classes_for_colours') || isempty(classes_for_colours)
    classes_for_colours = ones(size(X,1),1);
end
if nargin < 6 || isempty(alphas)
    alphas = [0 logspace(-2,2,100)];
end
n_alphas = length(alphas);

% Transforming and centering data
X = zscore(X);
if size(X,2) > 5*size(X,1) % reducing dimensionality if the number of features is considerably higher than the number of subjects
    disp('Preliminary PCA for dimensionality reduction...')
    f = warndlg('Your number of subjects is considerably lower than the number of features. A preliminary PCA will be applied for dimensionality reduction. This may cause a lack of interpretability in the most influential features of the final result. Suggestion, reduce more the features space (please see Help)','Warning');
    mapping_PCA1 = pca(X); X = X*mapping_PCA1; X = zscore(X);
end

% gaussian kernel density estimator
if ~exist('mapping_PCA1')
    for d = 1:size(X,2)
        param1(d)    = kde(X(:,d)); % param1 = 1;
        mappedX(:,d) = exp(-(X(:,d).^2 / (2 * param1(d).^2)));
    end
    mean_data = mean(mappedX); std_data = std(mappedX);
    mappedX   = zscore(mappedX);
else
    mean_data = mean(X); std_data = std(X);
    mappedX   = X;
end
mappedX_background = mappedX(indices_background,:);
mappedX_target     = mappedX(indices_target,:);

% Calculating Kernels/covariance matrices
Cb = cov(mappedX_background);
Ct = cov(mappedX_target); 

% cPCA with autoselection of alpha_f:
for alpha_i = 1:n_alphas
    if alpha_i == 1,
        beta = regress(Ct(:),Cb(:));
        C = Ct - beta*Cb; alphas(alpha_i) = beta;
    else
        C = (Ct - alphas(alpha_i)*Cb);
    end
    % Eigenmodes decomposition
    rng('default');  % For reproducibility
    % based on original cPCA paper
    [V_i,D_i] = eig(C);    
    [D_i, ind] = sort(diag(D_i), 'descend'); % sort eigenvectors in descending order
    V(:,:,alpha_i) = V_i(:,ind(1:min([d_max length(ind)])));
    D(:,alpha_i)   = D_i(1:min([d_max length(ind)])); clear V_i D_i ind
    % calculating intrinsic dimensionality for current alpha
    D(:,alpha_i) = D(:,alpha_i) - min(D(:,alpha_i));
    lambda       = D(:,alpha_i)/sum(D(:,alpha_i));
    no_dims_alpha(alpha_i) = 0;
    ind = find(lambda > 0.025);
    if length(ind) > d_max
        no_dims_alpha(alpha_i) = d_max;
    else 
        no_dims_alpha(alpha_i) = max([2 length(ind)]);         
    end
end
% affinity_matrix
for alpha_i = 1:n_alphas
    for alpha_j = 1:n_alphas
        if alpha_i ~= alpha_j
            theta = subspacea(V(:,1:min([no_dims_alpha(alpha_i) no_dims_alpha(alpha_j)]),alpha_i),...
                V(:,1:min([no_dims_alpha(alpha_i) no_dims_alpha(alpha_j)]),alpha_j));
            affinity_matrix(alpha_i,alpha_j) = prod(cos(theta));
        end
    end
end
affinity_matrix = double(affinity_matrix);

% Clustering: If using instead the Community Detection Toolbox (from http://users.auth.gr/~kehagiat/Software/)
rng('default'); Ci = GCSpectralClust1(affinity_matrix,10); Kbst=CNDistBased(Ci,affinity_matrix); Ci = Ci(:,Kbst);
% rng('default'); C = SpectralClustering(affinity_matrix+affinity_matrix', 2, 3); for k = 1:size(C,2), Ci(find(C(:,k)),1) = k; end

Ci(1) = 1; Ci(2:end) = Ci(2:end)+1;
n_clusters = length(unique(Ci));

% computing medoid for each cluster
for clus_i = 1:n_clusters
    ind = find(Ci == clus_i);
    [~,j] = max(sum(affinity_matrix(ind,ind),2));
    Vmedoid(:,:,clus_i) = V(:,:,ind(j));
    Dmedoid(:,clus_i)   = D(:,ind(j));
    alphas_f(clus_i)    = alphas(ind(j));
    no_dims(clus_i)     = no_dims_alpha(ind(j));
    
    % Transforming data, applying mapping on the data
    cPCs(:,:,clus_i) = mappedX * Vmedoid(:,:,clus_i);
    contrasted_data(:,:,clus_i) = cPCs(:,:,clus_i)*Vmedoid(:,:,clus_i)'*diag(std_data) + mean_data; % see https://stats.stackexchange.com/questions/229092/how-to-reverse-pca-and-reconstruct-original-variables-from-several-principal-com

    % Calculating intrinsic dimensionality for current alpha
    lambda = Dmedoid(:,clus_i) ./ sum(Dmedoid(:,clus_i));
    ind = find(lambda > 0.025);
    if length(ind) > d_max
        no_dims(clus_i) = d_max;
    else 
        no_dims(clus_i) = max([2 length(ind)]);         
    end
    
    % Evaluating relative clustering tendency of the intrinsic target data, for this cluster
    dist_matrix = find_nn(cPCs(:,1:no_dims(clus_i),clus_i), ceil(0.01*size(cPCs,1))); dist_matrix = dist_matrix + dist_matrix'; dist_matrix(isnan(dist_matrix)) = 0;
    gap_values(clus_i) = 1/sum(sum(dist_matrix(indices_background,indices_target)))+1/sum(sum(dist_matrix(indices_target,indices_target)));
end

%save('io/cPCA_interm.mat'); % save all variables to workspace to study intermediary values

return;