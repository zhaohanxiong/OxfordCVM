function [cPCs,gap_values,alphas_f,no_dims,contrasted_data,Vmedoid,Dmedoid] = cPCA(X,indices_background,indices_target,d_max,classes_for_colours,alphas)
% Based on Abid et al., 2018, Nature Comms., 9:2134.
%-------------------------------------------------------------------------%
% Yasser Iturria Medina, NeuroPM lab, MNI, McGill. 31/05/2018.

% Example data:
% n = 200; k = 10;
% X = [[mvnrnd([0 0 0],[1 1 1],n) 0.1*randn(n,50)]; ...
%     [mvnrnd([2 2 2],ones(3,3),k*n) 0.1*randn(k*n,50)]; ...
%     [mvnrnd([4 4 4],ones(3,3),n) 0.1*randn(n,50)]];
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
    alphas = logspace(-2,2,100);
end
n_alphas = length(alphas);

% Transforming non-normal features into a normal shape (didn't change our results, but may be help with some data).
%for d = 1:size(X,2)
%    [~,lambda] = boxcox(X([indices_background; indices_target],d)-min(X(:,d))+eps);
%    if lambda > 0,
%        X(:,d) = ((X(:,d)-min(X(:,d))+eps).^lambda - 1)/lambda;
%    elseif lambda == 0,
%        X(:,d) = log(X(:,d)-min(X(:,d))+eps);
%    end
%end
mean_data = mean(X); std_data = std(X);
%X = (X - repmat(mean(X([indices_background; indices_target],:)),[size(X,1) 1]))./ ...
%    repmat(std(X([indices_background; indices_target],:)),[size(X,1) 1]); % Standardizing data after box-cox

% Assigning background and target data.
X_background = X(indices_background,:); %X(randsample(indices_background,2500),:);
X_target     = X(indices_target,:); %X(randsample(indices_target,4500),:);

% Covariance matrices
Cb = cov(X_background);
Ct = cov(X_target);

% cPCA with multiple alphas:
for alpha_i = 1:n_alphas
    if alpha_i == 1,
        beta = regress(Ct(:),Cb(:));
        C = Ct - beta*Cb; alphas(alpha_i) = beta;
    else
        C = (Ct - alphas(alpha_i)*Cb);
    end
    C(isnan(C)) = 0;
    C(isinf(C)) = 0;
    rng('default');  % For reproducibility
    % eigenmodes decomposition
    [V_i,D_i] = eig(C);
    % sort eigenvalues in descending order
    [D_i, ind] = sort(diag(D_i), 'descend');
    V_sort = V_i(:,ind(1:min([d_max length(ind)])));
    %V_sort(abs(V_sort) > std(V_sort,0,"all")*3) = 0;
    V(:,:,alpha_i) = V_sort;
    D(:,alpha_i)   = D_i(1:min([d_max length(ind)])); clear V_i D_i ind
    % calculating intrinsic dimensionality for current alpha
    D(:,alpha_i) = D(:,alpha_i) - min(D(:,alpha_i));
    lambda = D(:,alpha_i)/sum(D(:,alpha_i));
    no_dims_alpha(alpha_i) = 0;
    ind = find(lambda > 0.025);
    if length(ind) > d_max
        no_dims_alpha(alpha_i) = d_max;
    else
        no_dims_alpha(alpha_i) = max([2 length(ind)]);
    end
end

% Affinity_matrix
for alpha_i = 1:n_alphas
    for alpha_j = 1:n_alphas
        if alpha_i ~= alpha_j
            rng('default');  % For reproducibility
            theta = subspacea(V(:,1:min([no_dims_alpha(alpha_i) no_dims_alpha(alpha_j)]),alpha_i),...
                V(:,1:min([no_dims_alpha(alpha_i) no_dims_alpha(alpha_j)]),alpha_j));
            affinity_matrix(alpha_i,alpha_j) = prod(cos(theta));
        end
    end
end
affinity_matrix = double(affinity_matrix);
%figure; imagesc(affinity_matrix); title('Subspaces affinity matrix'); colorbar; colormap Jet;

% Clustering
warning off;
rng('default');  % For reproducibility
Ci   = GCSpectralClust1(affinity_matrix,10);
Kbst = CNDistBased(Ci,affinity_matrix);
Ci = Ci(:,Kbst); % Using the Community Detection Toolbox (from http://users.auth.gr/~kehagiat/Software/)
Ci(1) = 1; Ci(2:end) = Ci(2:end)+1;
n_clusters = length(unique(Ci));

% Computing medoid for each cluster
for clus_i = 1:n_clusters
    ind = find(Ci == clus_i);
    [~,j] = max(sum(affinity_matrix(ind,ind),2));
    Vmedoid(:,:,clus_i) = V(:,:,ind(j));
    Dmedoid(:,clus_i)   = D(:,ind(j));
    alphas_f(clus_i)    = alphas(ind(j));
    no_dims(clus_i)     = no_dims_alpha(ind(j));
    
    % Transforming data, applying mapping on the data
    cPCs(:,:,clus_i)    = X * Vmedoid(:,:,clus_i);
    contrasted_data(:,:,clus_i) = cPCs(:,:,clus_i)*Vmedoid(:,:,clus_i)'*diag(std_data) + mean_data; % see https://stats.stackexchange.com/questions/229092/how-to-reverse-pca-and-reconstruct-original-variables-from-several-principal-com
    
%     figure;  hold on;
%     if clus_i == 1
%         unique_classes_for_colours = unique(classes_for_colours);
%         colours2classes = [1 1 0; ... % yellow
%             0 1 1; ... % cyan
%             0 1 0; ... % green
%             0 0 1; ... % blue
%             1 0 1; ... % magenta
%             1 0 0; ... % red
%             0.5430 0 0]; % dark red
%         if length(unique_classes_for_colours) > 7
%             disp('Warning: Only 7 different classes (plus background) are considered for the colouring...');
%             color_class = colours2classes(end,:);
%         end
%     end
%     for class = 1:length(unique_classes_for_colours)
%         ind = find(classes_for_colours == unique_classes_for_colours(class));
%         if no_dims(clus_i) < 3
%             plot(cPCs(ind,1,clus_i),cPCs(ind,2,clus_i),'.','color',colours2classes(class,:));
%         else
%             plot3(cPCs(ind,1,clus_i),cPCs(ind,2,clus_i),cPCs(ind,3,clus_i),'.','color',colours2classes(class,:));
%         end
%     end
%     if no_dims(clus_i) < 3
%         plot(cPCs(indices_background,1,clus_i),cPCs(indices_background,2,clus_i),'.','color',[0 0 0]); % Background in black.
%     else
%         plot3(cPCs(indices_background,1,clus_i),cPCs(indices_background,2,clus_i),cPCs(indices_background,3,clus_i),'.','color',[0 0 0]); % Background in black.
%     end
%     title(['cPC, alpha -> ' num2str(alphas_f(clus_i))]);
    
    % Calculating intrinsic dimensionality for current alpha
    lambda = Dmedoid(:,clus_i) ./ sum(Dmedoid(:,clus_i));
    no_dims(clus_i) = 0;
    while no_dims(clus_i) < size(X_background,2) - 1 && lambda(no_dims(clus_i) + 1) > 0.025
        no_dims(clus_i) = no_dims(clus_i) + 1;
    end
    if no_dims(clus_i) < 2, no_dims(clus_i) = 2; end
    
    % Evaluating clustering tendency of the intrinsic target data, for this cluster
    max_num = 10;
    rng('default');  % For reproducibility
    eva = evalclusters(cPCs([indices_background; indices_target],:,clus_i),'kmeans','gap','KList',[1:max_num]);
    N_subspaces(clus_i) = eva.OptimalK;
    gap_values(clus_i)  = max(eva.CriterionValues);
end
save('io/cPCA_interm.mat'); % save all variables to workspace to study intermediary values
return;

function [theta,varargout] = subspacea(F,G,A)
%SUBSPACEA angles between subspaces
%  subspacea(F,G,A)
%  Finds all min(size(orth(F),2),size(orth(G),2)) principal angles
%  between two subspaces spanned by the columns of matrices F and G
%  in the A-based scalar product x'*A*y, where A
%  is Hermitian and positive definite.
%  COS of principal angles is called canonical correlations in statistics.
%  [theta,U,V] = subspacea(F,G,A) also computes left and right
%  principal (canonical) vectors - columns of U and V, respectively.
%
%  If F and G are vectors of unit length and A=I,
%  the angle is ACOS(F'*G) in exact arithmetic.
%  If A is not provided as a third argument, than A=I and
%  the function gives the same largest angle as SUBSPACE.m by Andrew Knyazev,
%  see
%  http://www.mathworks.com/matlabcentral/fileexchange/Files.jsp?type=category&id=&fileId=54
%  MATLAB's SUBSPACE.m function is still badly designed and fails to compute
%  some angles accurately.
%
%  The optional parameter A is a Hermitian and positive definite matrix,
%  or a corresponding function. When A is a function, it must accept a
%  matrix as an argument.
%  This code requires ORTHA.m, Revision 1.5.8 or above,
%  which is included. The standard MATLAB version of ORTH.m
%  is used for orthonormalization, but could be replaced by QR.m.
%
%  Examples:
%  F=rand(10,4); G=randn(10,6); theta = subspacea(F,G);
%  computes 4 angles between F and G, while in addition
%  A=hilb(10); [theta,U,V] = subspacea(F,G,A);
%  computes angles relative to A and corresponding vectors U and V.
%
%  The algorithm is described in A. V. Knyazev and M. E. Argentati,
%  Principal Angles between Subspaces in an A-Based Scalar Product:
%  Algorithms and Perturbation Estimates. SIAM Journal on Scientific Computing,
%  23 (2002), no. 6, 2009-2041.
%  http://epubs.siam.org/sam-bin/dbq/article/37733

%  Tested under MATLAB R10-14
%  Copyright (c) 2000 Andrew Knyazev, Rico Argentati
%  Contact email: knyazev@na-net.ornl.gov
%  License: free software (BSD)
%  $Revision: 4.5 $  $Date: 2005/6/27
% Function downloaded from https://www.mathworks.com/matlabcentral/fileexchange/55-subspacea-m

threshold=sqrt(2)/2; % Define threshold for determining when an angle is small

if size(F,1) ~= size(G,1)
    subspaceaError(['The row dimension ' int2str(size(F,1)) ...
        ' of the matrix F is not the same as ' int2str(size(G,1)) ...
        ' the row dimension of G'])
end

if nargin<3  % Compute angles using standard inner product
    
    % Trivial column scaling first, if ORTH.m is used later
    for i=1:size(F,2),
        normi=norm(F(:,i),inf);
        %Adjustment makes tol consistent with experimental results
        if normi > eps^.981
            F(:,i)=F(:,i)/normi;
            % Else orth will take care of this
        end
    end
    for i=1:size(G,2),
        normi=norm(G(:,i),inf);
        %Adjustment makes tol consistent with experimental results
        if normi > eps^.981
            G(:,i)=G(:,i)/normi;
            % Else orth will take care of this
        end
    end
    
    % Compute angle using standard inner product
    
    QF = orth(F);      %This can also be done using QR.m, in which case
    QG = orth(G);      %the column scaling above is not needed
    
    q = min(size(QF,2),size(QG,2));
    [Ys,s,Zs] = svd(QF'*QG,0);
    if size(s,1)==1
        % make sure s is column for output
        s=s(1);
    end
    s = min(diag(s),1);
    theta = max(acos(s),0);
    U = QF*Ys;
    V = QG*Zs;
    indexsmall = s > threshold;
    if max(indexsmall) % Check for small angles and recompute only small
        RF = U(:,indexsmall);
        RG = V(:,indexsmall);
        %[Yx,x,Zx] = svd(RG-RF*(RF'*RG),0);
        [Yx,x,Zx] = svd(RG-QF*(QF'*RG),0); % Provides more accurate results
        if size(x,1)==1
            % make sure x is column for output
            x=x(1);
        end
        Tmp = fliplr(RG*Zx);
        V(:,indexsmall) = Tmp(:,indexsmall);
        U(:,indexsmall) = RF*(RF'*V(:,indexsmall))*...
            diag(1./s(indexsmall));
        x = diag(x);
        thetasmall=flipud(max(asin(min(x,1)),0));
        theta(indexsmall) = thetasmall(indexsmall);
    end
    
    % Compute angle using inner product relative to A
else
    [m,n] = size(F);
    if ~isstr(A)
        [mA,mA] = size(A);
        if any(size(A) ~= mA)
            subspaceaError('Matrix A must be a square matrix or a string.')
        end
        if size(A) ~= m
            subspaceaError(['The size ' int2str(size(A)) ...
                ' of the matrix A is not the same as ' int2str(m) ...
                ' - the number of rows of F'])
        end
    end
    
    [QF,AQF]=ortha(A,F);
    [QG,AQG]=ortha(A,G);
    q = min(size(QF,2),size(QG,2));
    [Ys,s,Zs] = svd(QF'*AQG,0);
    if size(s,1)==1
        % make sure s is column for output
        s=s(1);
    end
    s=min(diag(s),1);
    theta = max(acos(s),0);
    U = QF*Ys;
    V = QG*Zs;
    indexsmall = s > threshold;
    if max(indexsmall) % Check for small angles and recompute only small
        RG = V(:,indexsmall);
        AV = AQG*Zs;
        ARG = AV(:,indexsmall);
        RF = U(:,indexsmall);
        %S=RG-RF*(RF'*(ARG));
        S=RG-QF*(QF'*(ARG));% A bit more cost, but seems more accurate
        
        % Normalize, so ortha would not delete wanted vectors
        for i=1:size(S,2),
            normSi=norm(S(:,i),inf);
            %Adjustment makes tol consistent with experimental results
            if normSi > eps^1.981
                QS(:,i)=S(:,i)/normSi;
                % Else ortha will take care of this
            end
        end
        
        [QS,AQS]=ortha(A,QS);
        [Yx,x,Zx] = svd(AQS'*S);
        if size(x,1)==1
            % make sure x is column for output
            x=x(1);
        end
        x = max(diag(x),0);
        
        Tmp  = fliplr(RG*Zx);
        ATmp = fliplr(ARG*Zx);
        V(:,indexsmall) = Tmp(:,indexsmall);
        AVindexsmall = ATmp(:,indexsmall);
        U(:,indexsmall) = RF*(RF'*AVindexsmall)*...
            diag(1./s(indexsmall));
        thetasmall=flipud(max(asin(min(x,1)),0));
        
        %Add zeros if necessary
        if sum(indexsmall)-size(thetasmall,1)>0
            thetasmall=[zeros(sum(indexsmall)-size(thetasmall,1),1)',...
                thetasmall']';
        end
        
        theta(indexsmall) = thetasmall(indexsmall);
    end
end
varargout(1)={U(:,1:q)};
varargout(2)={V(:,1:q)};
return; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Q,varargout]=ortha(A,X)
%ORTHA Orthonormalization Relative to matrix A
%  Q=ortha(A,X)
%  Q=ortha('Afunc',X)
%  Computes an orthonormal basis Q for the range of X, relative to the
%  scalar product using a positive definite and selfadjoint matrix A.
%  That is, Q'*A*Q = I, the columns of Q span the same space as
%  columns of X, and rank(Q)=rank(X).
%
%  [Q,AQ]=ortha(A,X) also gives AQ = A*Q.
%
%  Required input arguments:
%  A : either an m x m positive definite and selfadjoint matrix A
%  or a linear operator A=A(v) that is positive definite selfadjoint;
%  X : m x n matrix containing vectors to be orthonormalized relative
%  to A.
%
%  ortha(eye(m),X) spans the same space as orth(X)
%
%  Examples:
%  [q,Aq]=ortha(hilb(20),eye(20,5))
%  computes 5 column-vectors q spanned by the first 5 coordinate vectors,
%  and orthonormal with respect to the scalar product given by the
%  20x20 Hilbert matrix,
%  while an attempt to orthogonalize (in the same scalar product)
%  all 20 coordinate vectors using
%  [q,Aq]=ortha(hilb(20),eye(20))
%  gives 14 column-vectors out of 20.
%  Note that rank(hilb(20)) = 13 in double precision.
%
%  Algorithm:
%  X=orth(X), [U,S,V]=SVD(X'*A*X), then Q=X*U*S^(-1/2)
%  If A is ill conditioned an extra step is performed to
%  improve the result. This extra step is performed only
%  if a test indicates that the program is running on a
%  machine that supports higher precison arithmetic
%  (greater than 64 bit precision).
%
%  See also ORTH, SVD
%
%  Copyright (c) 2000 Andrew Knyazev, Rico Argentati
%  Contact email: knyazev@na-net.ornl.gov
%  License: free software (BSD)
%  $Revision: 1.5.8 $  $Date: 2001/8/28
%  Tested under MATLAB R10-12.1

% Check input parameter A
[m,n] = size(X);
if ~isstr(A)
    [mA,mA] = size(A);
    if any(size(A) ~= mA)
        subspaceaError('Matrix A must be a square matrix or a string.')
    end
    if size(A) ~= m
        subspaceaError(['The size ' int2str(size(A)) ...
            ' of the matrix A does not match with ' int2str(m) ...
            ' - the number of rows of X'])
    end
end

% Normalize, so ORTH below would not delete wanted vectors
for i=1:size(X,2),
    normXi=norm(X(:,i),inf);
    %Adjustment makes tol consistent with experimental results
    if normXi > eps^.981
        X(:,i)=X(:,i)/normXi;
        % Else orth will take care of this
    end
end

% Make sure X is full rank and orthonormalize
X=orth(X); %This can also be done using QR.m, in which case
%the column scaling above is not needed

%Set tolerance
[m,n]=size(X);
tol=max(m,n)*eps;

% Compute an A-orthonormal basis
if ~isstr(A)
    AX = A*X;
else
    AX = feval(A,X);
end
XAX = X'*AX;

XAX = 0.5.*(XAX' + XAX);
[U,S,V]=svd(XAX);

if n>1 s=diag(S);
elseif n==1, s=S(1);
else s=0;
end

%Adjustment makes tol consistent with experimental results
threshold1=max(m,n)*max(s)*eps^1.1;

r=sum(s>threshold1);
s(r+1:size(s,1))=1;
S=diag(1./sqrt(s),0);
X=X*U*S;
AX=AX*U*S;
XAX = X'*AX;

% Check subspaceaError against tolerance
subspaceaError=normest(XAX(1:r,1:r)-eye(r));
% Check internal precision, e.g., 80bit FPU registers of P3/P4
precision_test=[1 eps/1024 -1]*[1 1 1]';
if subspaceaError<tol | precision_test==0;
    Q=X(:,1:r);
    varargout(1)={AX(:,1:r)};
    return
end

% Complete another iteration to improve accuracy
% if this machine supports higher internal precision
if ~isstr(A)
    AX = A*X;
else
    AX = feval(A,X);
end
XAX = X'*AX;

XAX = 0.5.*(XAX' + XAX);
[U,S,V]=svd(XAX);

if n>1 s=diag(S);
elseif n==1, s=S(1);
else s=0;
end

threshold2=max(m,n)*max(s)*eps;
r=sum(s>threshold2);
S=diag(1./sqrt(s(1:r)),0);
Q=X*U(:,1:r)*S(1:r,1:r);
varargout(1)={AX*U(:,1:r)*S(1:r,1:r)};
return; 

function VV=GCSpectralClust1(A,Kmax)
% function VV=GCSpectralClust1(A,Kmax)
%
% Community detection by spectral  clustering. See J. Hespanha's 
% implementation of spectral clustering. For details see 
% Joao Hespanha. "An efficient MATLAB Algorithm for Graph Partitioning". 
% Technical Report, University of California, Oct. 2004. 
% http://www.ece.ucsb.edu/~hespanha/techrep.html.
% 
% INPUT
% A:      adjacency matrix of graph
% Kmax:   max number of clusters  to consider. A clustering of K clusters 
%         will be produced for every K in [1:Kmax]
%
% OUTPUT
% VV:     N-ny-K matrix, VV(n,k) is the cluster to which node n belongs 
%         when algorithm uses a partition of k clusters
%
% EXAMPLE
% [A,V0]=GGGirvanNewman(32,4,13,3,0);
% VV=GCSpectralClust1(A,6)
%
N=length(A);
W=PermMat(N);                     % permute the graph node labels
A=W*A*W';
VV(:,1)=ones(N,1);
for k=2:Kmax
	[ndx,Pi,cost]= grPartition(A,k,1);
	VV(:,k)=ndx;
end
VV=W'*VV;                         % unpermute the graph node labels
return; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ndx,Pi,cost]= grPartition(C,k,nrep)
%
% function [ndx,Pi,cost]= grPartition(C,k,nrep);
%
% Partitions the n-node undirected graph G defined by the matrix C
% 
% Inputs:
% C - n by n edge-weights matrix. In particular, c(i,j)=c(j,i) is equal 
%     to the cost associated with cuting the edge between nodes i and j.
%     This matrix should be symmetric and doubly stochastic. If this
%     is not the case, this matrix will be normalized to
%     satisfy these properties (with a warning).
% k - desired number of partitions
% nrep - number of repetion for the clustering algorithm 
%       (optional input, defaults to 1)
% 
% Outputs:
% ndx  - n-vector with the cluster index for every node 
%       (indices from 1 to k)
% Pi   - Projection matrix [see Technical report
% cost - cost of the partition (sum of broken edges)
%
% Example:
%
% X=rand(200,2);               % place random points in the plane
% C=pdist(X,'euclidean');      % compute distance between points
% C=exp(-.1*squareform(C));    % edge cost is a negative exponential of distance
%
% k=6;                         % # of partitions
% [ndx,Pi,cost]= grPartition(C,k,30);
%
% colors=hsv(k);               % plots points with appropriate colors
% colormap(colors)
% cla
% line(X(:,1),X(:,2),'MarkerEdgeColor',[0,0,0],'linestyle','none','marker','.');
% for i=1:k
%   line(X(find(ndx==i),1),X(find(ndx==i),2),...
%       'MarkerEdgeColor',colors(i,:),'linestyle','none','marker','.');
% end
% title(sprintf('Cost %g',cost))
% colorbar
%
% Copyright (c) 2004, Joao Hespanha
% All rights reserved.
if nargin<3
  nrep=1;
end
[n,m]=size(C);
if n~=m
  error('grPartition: Cost matrix is not square'); 
end  
if ~issparse(C)
  C=sparse(C);  
end
% Test for symmetry
if any(any(C~=C'))
  %warning('grPartition: Cost matrix not symmetric, making it symmetric')
  % Make C symmetric  
  C=(C+C')/2;
end  
% Test for double stochasticity
if any(sum(C,1)~=1)
  %warning('grPartition: Cost matrix not doubly stochastic, normalizing it.','grPartition:not doubly stochastic')
  % Make C double stochastic
  C=C/(1.001*max(sum(C)));  % make largest sum a little smaller
                            % than 1 to make sure no entry of C becomes negative
  C=C+sparse(1:n,1:n,1-sum(C));
  if any(C(:))<0
    error('grPartition: Normalization resulted in negative costs. BUG.')
  end
end  
if any(any(C<0))
  error('grPartition: Edge costs cannot be negative')
end  
% Spectral partition
options.issym=1;               % matrix is symmetric
options.isreal=1;              % matrix is real
options.tol=1e-6;              % decrease tolerance 
options.maxit=500;             % increase maximum number of iterations
options.disp=0;
[U,D]=eigs(C,k,'la',options);  % only compute 'k' largest eigenvalues/vectors
   ndx=mykmeans1(U,k,100,nrep);
if nargout>1
  Pi=sparse(1:length(ndx),ndx,1);
end  
if nargout>2
  cost=full(sum(sum(C))-trace(Pi'*C*Pi));
end
return; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bestNdx=mykmeans1(X,k,nReplicates,maxIterations)
%
% function bestNdx=mykmeans(X,k,nReplicates,maxIterations)
%
% Partitions the points in the data matrix X into k clusters. This
% function behaves much like the stats/kmeans from MATLAB's
% Statitics toolbox called as follows:
%   bestNdx = kmeans(X,k,'Distance','cosine',...
%                    'Replicates',nReplicates,'MaxIter',maxIterations)
% 
% Inputs:
% X    - n by p data matrix, with one row per point.
% k    - desired number of partitions
% nReplicates - number of repetion for the clustering algorithm 
%       (optional input, defaults to 1)
% maxIterations - maximum number of iterations for the k-means algorithm
%           (per repetition)
% 
% Outputs:
% ndx  - n-vector with the cluster index for every node 
%       (indices from 1 to k)
% Pi   - Projection matrix [see Technical report
% cost - cost of the partition (sum of broken edges)
%
% Copyright (c) 2006, Joao Hespanha
% All rights reserved.
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%    * Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
%
%    * Redistributions in binary form must reproduce the above
%    copyright notice, this list of conditions and the following
%    disclaimer in the documentation and/or other materials provided
%    with the distribution.
% 
%    * Neither the name of the <ORGANIZATION> nor the names of its
%    contributors may be used to endorse or promote products derived
%    from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
% COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
if nargin<4,
  maxIterations=100;
end
if nargin<3,
  nReplicates=1;  
end
    
nPoints=size(X,1);
if nPoints<=k, 
  bestNdx=1:nPoints;
  return
end
% normalize vectors so that inner product is a distance measure
normX=sqrt(sum(X.^2,2));
X=X./(normX*ones(1,size(X,2)));
bestInnerProd=0; % best distance so far
for rep=1:nReplicates
  % random sample for the centroids
  ndx = randperm(size(X,1));
  centroids=X(ndx(1:k),:);
  
  lastNdx=zeros(nPoints,1);
  
  for iter=1:maxIterations
    InnerProd=X*centroids'; % use inner product as distance
    [maxInnerProd,ndx]=max(InnerProd,[],2);  % find 
    if ndx==lastNdx,
      break;          % stop the iteration
    else
      lastNdx=ndx;      
    end
    for i=1:k
      j=find(ndx==i);
      if isempty(j)     
	%error('mykmeans: empty cluster')
      end
      centroids(i,:)=mean(X(j,:),1);
      centroids(i,:)=centroids(i,:)/norm(centroids(i,:)); % normalize centroids
    end
  end
  if sum(maxInnerProd)>bestInnerProd
    bestNdx=ndx;
    bestInnerProd=sum(maxInnerProd);
  end
end % for rep
return;

function W=PermMat(N)
% function W=PermMat(N)
% 
% Creates an N-by-N permutation matrix W
%
% INPUT
% N     size of permutation matrix
%
% OUTPUT
% W     the permutation matrix: N-by-N matrix with exactly one 1 in every
%       row and column, all other elements equal to 0
%
% EXAMPLE
% W=PermMat(10);
%
W=zeros(N,N);
q=randperm(N);
for n=1:N; 
	W(q(n),n)=1; 
end
return;

function Kbst=CNDistBased(VV,A)
% function Kbst=CNDistBased(VV,A)
% Partition Distance based cluster number selection
%
% Cluster number selection performed by finding the VV column which
% achieves  highest value of the clustering  quality function QFDB 
% (see documentation in Evaluation/QFDB.m)
%  
% INPUT
% VV:     N-by-K matrix of partitions, k-th column describes a partition
%         of k clusters
% A:      adjacency matrix of graph
%
% OUTPUT
% Kbst:   the number of best VV column and so best number of clusters
% 
% EXAMPLE
% [A,V0]=GGPlantedPartition([0 10 20 30 40],0.9,0.1,0);
% VV=GCAFG(A,[0.2:0.5:1.5]);
% Kbst=CNDistBased(VV,A);
%
[N Kmax]=size(VV);
for K=1:Kmax
	V=VV(:,K);
	Q(K)=QFDistBased(V,A);
end
[Qbst Kbst]=min(Q);
return;

function Q=QFDistBased(V,A)
%function Q=QFDistBased(V,A)
% A partition-distance-based quality function
%
% A partition-distance-based quality function
% For more details see the ComDet Toolbox manual
%
% INPUT
% V:      N-by-1 matrix describes a partition
% A:      adjacency matrix of graph
%
% OUTPUT
% Q:      node-membership-based quality function of V given graph 
%         with adj. matrix A
% 
% EXAMPLE
% [A,V0]=GGPlantedPartition([0 10 20 30 40],0.9,0.1,0);
% VV=GCDanon(A);
% Kbst=CNNM(VV,A);
% V=VV(:,Kbst);
% Q=QFDistBased(V,A)
%
N=length(V);
K=max(V);
AV=zeros(N,N);
for i=1:K
	V1=find(V==i)';
	AV(V1,V1)=1;
end
Q=sum(sum(abs(A-AV)))/(N^2);
return;