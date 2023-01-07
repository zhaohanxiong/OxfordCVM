layer = imageInputLayer([1 557 1],'Normalization',"zscore",'Name',"input1");
lgraph = layerGraph(layer);

initializer = 'glorot';
block_id = 1;
label = ['_block',num2str(block_id)];
firstnumfilt = 4;
[lgraph] = network_blocks22_Deeper(lgraph,firstnumfilt,label,block_id,initializer);

analyzeNetwork(lgraph)

layers = [imageInputLayer([1 557 1],'Normalization',"zscore",'Name',"input1")
          convolution2dLayer([1 3],8)
          batchNormalizationLayer
          reluLayer
          maxPooling2dLayer([1 3],'Stride',[1 2])

          convolution2dLayer([1 3],32)
          batchNormalizationLayer
          reluLayer
          maxPooling2dLayer([1 3],'Stride',[1 2])

          convolution2dLayer([1 3],64)
          batchNormalizationLayer
          reluLayer
          maxPooling2dLayer([1 3],'Stride',[1 2])

          fullyConnectedLayer(64)

          fullyConnectedLayer(1)
          regressionLayer];

analyzeNetwork(layers)

MAP = ( (2.*BP(:,2)) + BP(:,1) ) ./ 3;


miniBatchSize = 32;
options = trainingOptions("adam", ...
    ExecutionEnvironment="gpu", ...
    MiniBatchSize=miniBatchSize, ...
    MaxEpochs=20, ...
    SequencePaddingDirection="right", ...
    InitialLearnRate=0.001, ... 
    L2Regularization=0.0001, ...
    Shuffle='every-epoch', ...
    Plots="training-progress", ...
    Verbose=0);

rng('default')
[net,info] = trainNetwork(data2,MAP,layers,options);

[predicted] = predict(net,data2);

A = data2(:,:,:,1);
B = predicted(:,:,:,1);
figure;
plot(A)
hold on
plot(B)

layerName = 'fc_1';

act = activations(net,data2,layerName);
act = squeeze(act);
act = act';

clear C
data_edit = single.empty;
for j = 1:size(act,4)
    j
clear C
C(:,:) = act(1,:,:,j);
C = C';
C = C(:);
% C = max(C,[],1);
data_edit = [data_edit,C];
end
figure;
plot(C)

G = num2cell(act,[1,2,3,4]);

G = squeeze(act(1,:,:,:));
G = squeeze(G(:,:,:));

data_edit = permute(act,[4 1*2*3]);
out = reshape(act,[size(act,4),size(act,2)*size(act,3)]);

