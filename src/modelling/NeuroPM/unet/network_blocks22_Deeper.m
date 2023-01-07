function [lgraph] = network_blocks22_Deeper(lgraph,firstnumfilt,label,block_id,initializer)

%% CNN 1 layer
layer = [convolution2dLayer([1 3],firstnumfilt,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_1',label]),...
         batchNormalizationLayer('Name','bn1'),...
         reluLayer('Name',['relu_1',label]),...
         convolution2dLayer([1 3],firstnumfilt,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_2',label]),...
         batchNormalizationLayer('Name','bn2'),...
         reluLayer('Name',['relu_2',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['input1'],['conv_1',label]);

%%% Maxpool 1 layer
layer = averagePooling2dLayer([1 4],'Stride',[1 4],'Padding',0,'Name','mxpool_1');
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_2',label],['mxpool_1']);

%% CNN 2 layer
layer = [convolution2dLayer([1 3],firstnumfilt*2,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_3',label]),...
         batchNormalizationLayer('Name','bn3'),...
         reluLayer('Name',['relu_3',label]),...
         convolution2dLayer([1 3],firstnumfilt*2,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_4',label]),...
         batchNormalizationLayer('Name','bn4'),...
         reluLayer('Name',['relu_4',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['mxpool_1'],['conv_3',label]);

%%% Maxpool 2 layer
layer = averagePooling2dLayer([1 4],'Stride',[1 4],'Padding',0,'Name','mxpool_2');
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_4',label],['mxpool_2']);

%% CNN 3 layer
layer = [convolution2dLayer([1 3],firstnumfilt*4,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_5',label]),...
         batchNormalizationLayer('Name','bn5'),...
         reluLayer('Name',['relu_5',label]),...
         convolution2dLayer([1 3],firstnumfilt*4,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_6',label]),...
         batchNormalizationLayer('Name','bn6'),...
         reluLayer('Name',['relu_6',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['mxpool_2'],['conv_5',label]);

%%% Maxpool 3 layer
layer = averagePooling2dLayer([1 2],'Stride',[1 2],'Padding',0,'Name','mxpool_3');
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_6',label],['mxpool_3']);

%% CNN 4 layer
layer = [convolution2dLayer([1 3],firstnumfilt*8,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_7',label]),...
         batchNormalizationLayer('Name','bn7'),...
         reluLayer('Name',['relu_7',label]),...
         convolution2dLayer([1 3],firstnumfilt*8,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_8',label]),...
         batchNormalizationLayer('Name','bn8'),...
         reluLayer('Name',['relu_8',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['mxpool_3'],['conv_7',label]);

%%% Maxpool 4 layer
layer = averagePooling2dLayer([1 2],'Stride',[1 2],'Padding',0,'Name','mxpool_4');
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_8',label],['mxpool_4']);

%% Bridge 1 layer
layer = [convolution2dLayer([1 3],firstnumfilt*16,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_9',label]),...
         batchNormalizationLayer('Name','bn9'),...
         reluLayer('Name',['relu_9',label]),...
         convolution2dLayer([1 3],firstnumfilt*16,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_10',label]),...
         batchNormalizationLayer('Name','bn10'),...
         reluLayer('Name',['relu_10',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['mxpool_4'],['conv_9',label]);

%% Decoder 1
layer = [transposedConv2dLayer([1 3],firstnumfilt*32,'stride',[1 2],'Cropping',0,'WeightsInitializer',initializer,'Name',['Tconv_1',label]),...
         reluLayer('Name',['Trelu_1',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_10',label],['Tconv_1',label]);
% 
% layer = concatenationLayer(3,2,'Name','DepthCon1');
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Trelu_1',label],'DepthCon1/in1');
% lgraph = connectLayers(lgraph,['relu_8',label],'DepthCon1/in2');

%% CNN 5 layer
layer = [convolution2dLayer([1 3],firstnumfilt*8,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_11',label]),...
         batchNormalizationLayer('Name','bn11'),...
         reluLayer('Name',['relu_11',label]),...
         convolution2dLayer([1 3],firstnumfilt*8,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_12',label]),...
         batchNormalizationLayer('Name','bn12'),...
         reluLayer('Name',['relu_12',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['Trelu_1',label],['conv_11',label]);

%% Decoder 2
layer = [transposedConv2dLayer([1 2],firstnumfilt*16,'stride',[1 2],'Cropping',0,'WeightsInitializer',initializer,'Name',['Tconv_2',label]),...
         reluLayer('Name',['Trelu_2',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_12',label],['Tconv_2',label]);

% layer = concatenationLayer(3,2,'Name','DepthCon2');
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Trelu_2',label],'DepthCon2/in1');
% lgraph = connectLayers(lgraph,['relu_6',label],'DepthCon2/in2');

%% CNN 6 layer
layer = [convolution2dLayer([1 3],firstnumfilt*4,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_13',label]),...
         batchNormalizationLayer('Name','bn13'),...
         reluLayer('Name',['relu_13',label]),...
         convolution2dLayer([1 3],firstnumfilt*4,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_14',label]),...
         batchNormalizationLayer('Name','bn14'),...
         reluLayer('Name',['relu_14',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['Trelu_2',label],['conv_13',label]);

%% Decoder 3
layer = [transposedConv2dLayer([1 7],firstnumfilt*8,'stride',[1 4],'Cropping',0,'WeightsInitializer',initializer,'Name',['Tconv_3',label]),...
         reluLayer('Name',['Trelu_3',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_14',label],['Tconv_3',label]);

% layer = concatenationLayer(3,2,'Name','DepthCon3');
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Trelu_3',label],'DepthCon3/in1');
% lgraph = connectLayers(lgraph,['relu_4',label],'DepthCon3/in2');

%% CNN 7 layer
layer = [convolution2dLayer([1 3],firstnumfilt*2,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_15',label]),...
         batchNormalizationLayer('Name','bn15'),...
         reluLayer('Name',['relu_15',label]),...
         convolution2dLayer([1 3],firstnumfilt*2,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_16',label]),...
         batchNormalizationLayer('Name','bn16'),...
         reluLayer('Name',['relu_16',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['Trelu_3',label],['conv_15',label]);

%% Decoder 4
layer = [transposedConv2dLayer([1 5],firstnumfilt*4,'stride',[1 4],'Cropping',0,'WeightsInitializer',initializer,'Name',['Tconv_4',label]),...
         reluLayer('Name',['Trelu_4',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_16',label],['Tconv_4',label]);

% layer = concatenationLayer(3,2,'Name','DepthCon4');
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Trelu_4',label],'DepthCon4/in1');
% lgraph = connectLayers(lgraph,['relu_2',label],'DepthCon4/in2');

%% CNN 8 layer
layer = [convolution2dLayer([1 3],firstnumfilt,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_17',label]),...
         batchNormalizationLayer('Name','bn17'),...
         reluLayer('Name',['relu_17',label]),...
         convolution2dLayer([1 3],firstnumfilt,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_18',label]),...
         batchNormalizationLayer('Name','bn18'),...
         reluLayer('Name',['relu_18',label])];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['Trelu_4',label],['conv_17',label]);

%% Final convolution
layer = [convolution2dLayer(1,1,'stride',1,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_19',label]),...
         batchNormalizationLayer('Name','bn19'),...
         regressionLayer('Name','regression')];
lgraph = addLayers(lgraph,layer);
lgraph = connectLayers(lgraph,['relu_18',label],['conv_19',label]);


% 
% lgraph2 = unetLayers([16 10000],2);
% analyzeNetwork(lgraph2)
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
%          ReshapeLayer2D('Name','Reshape2D_1'),...
%          maxPooling2dLayer([1 2],'stride',[1 2],HasUnpoolingOutputs=logical(1),'Name',['mxpool_1',label]),...
%          ReshapeLayer1D('Name','Reshape1D_1')];
% 
% 
% %%% CNN 2 layer
% filterSize = 2;
% numFilters = firstnumfilt;
% stride = 1;
% layer = [convolution1dLayer(filterSize,numFilters,'stride',stride,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_2',label]),...
%          batchNormalizationLayer('Name',['relu_2',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_2',label]),...
%          ReshapeLayer2D('Name','Reshape2D_2'),...
%          maxPooling2dLayer([1 2],'stride',[1 2],HasUnpoolingOutputs=logical(1),'Name',['mxpool_2',label]),...
%          ReshapeLayer1D('Name','Reshape1D_2')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Reshape1D_1'],['conv_2',label]);
% 
% %%% CNN 3 layer
% filterSize = 2;
% numFilters = firstnumfilt;
% stride = 1;
% layer = [convolution1dLayer(filterSize,numFilters,'stride',stride,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_3',label]),...
%          batchNormalizationLayer('Name',['relu_3',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_3',label]),...
%          ReshapeLayer2D('Name','Reshape2D_3'),...
%          maxPooling2dLayer([1 2],'stride',[1 2],HasUnpoolingOutputs=logical(1),'Name',['mxpool_3',label]),...
%          ReshapeLayer1D('Name','Reshape1D_3')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Reshape1D_2'],['conv_3',label]);
% 
% %%% CNN 4 layer
% filterSize = 2;
% numFilters = firstnumfilt;
% stride = 1;
% layer = [convolution1dLayer(filterSize,numFilters,'stride',stride,'DilationFactor',1,'Padding',"same",'WeightsInitializer',initializer,'Name',['conv_4',label]),...
%          batchNormalizationLayer('Name',['relu_4',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_4',label]),...
%          ReshapeLayer2D('Name','Reshape2D_4'),...
%          maxPooling2dLayer([1 2],'stride',[1 2],HasUnpoolingOutputs=logical(1),'Name',['mxpool_4',label]),...
%          ReshapeLayer1D('Name','Reshape1D_4')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,['Reshape1D_3'],['conv_4',label]);
% 
% 
% % %%% Positional encoder
% % % filterSize = 3;
% % % numFilters = firstnumfilt/2;
% % numChannels = firstnumfilt;
% % layer_posenc = posencLayer(numChannels,'Name',['posenc_1',label]);
% % lgraph = addLayers(lgraph,layer_posenc);
% % lgraph = connectLayers(lgraph,['Reshape1D_2'],['posenc_1',label]);
% % 
% % %%% Transformer layer
% % NumBlocks = 1;
% % NumHeads = 2; %%% TRY reducing it
% % for transblockid = 1:NumBlocks
% % layer_transformer = transformerLayer(NumHeads,numChannels,'Name',['transformer_',num2str(transblockid),label]);
% % lgraph = addLayers(lgraph,layer_transformer);
% % if transblockid == 1
% % lgraph = connectLayers(lgraph,['posenc_1',label],['transformer_',num2str(transblockid),label]);
% % else
% % lgraph = connectLayers(lgraph,['transformer_',num2str(transblockid-1),label],['transformer_',num2str(transblockid),label]);
% % end
% % end
% 
% % %%% Decoder
% % layer = [fullyConnectedLayer(firstnumfilt*2,'WeightsInitializer',initializer,'Name',['fc_linear2',label]),...
% %          dropoutLayer(0.05,'Name',['drop1',label])];
% % lgraph = addLayers(lgraph,layer);
% % lgraph = connectLayers(lgraph,['transformer_',num2str(transblockid),label],['fc_linear2',label]);
% % 
% % %%% Linear + Relu + dropout
% % layer = [fullyConnectedLayer(firstnumfilt*2,'WeightsInitializer',initializer,'Name',['fc_linear5',label]),...
% %          reluLayer('Name',['relu_5',label]),...
% %          dropoutLayer(0.05,'Name',['drop2',label])];
% % lgraph = addLayers(lgraph,layer);
% % lgraph = connectLayers(lgraph,['drop1',label],['fc_linear5',label]);
% 
% 
% %%% deconvolution 1
% layer = [transposedConv2dLayer([1 2],firstnumfilt,'stride',1,'Cropping','Same','Name','Tconv1'),...
%          batchNormalizationLayer('Name',['relu_5',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_5',label]),...
%          ReshapeLayer2D('Name','Reshape2D_5'),...
%          maxUnpooling2dLayer('Name',['unmxpool_1',label]),...
%          ReshapeLayer1D('Name','Reshape1D_5')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,'Reshape1D_4','Tconv1');
% lgraph = connectLayers(lgraph, ['mxpool_4',label,'/indices'], ['unmxpool_1',label,'/indices']);
% lgraph = connectLayers(lgraph, ['mxpool_4',label,'/size'], ['unmxpool_1',label,'/size']);
% 
% %%% deconvolution 2
% layer = [transposedConv2dLayer([1 2],firstnumfilt,'stride',1,'Cropping','Same','Name','Tconv2'),...
%          batchNormalizationLayer('Name',['relu_6',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_6',label]),...
%          ReshapeLayer2D('Name','Reshape2D_6'),...
%          maxUnpooling2dLayer('Name',['unmxpool_2',label]),...
%          ReshapeLayer1D('Name','Reshape1D_6')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,'Reshape1D_5','Tconv2');
% lgraph = connectLayers(lgraph, ['mxpool_3',label,'/indices'], ['unmxpool_2',label,'/indices']);
% lgraph = connectLayers(lgraph, ['mxpool_3',label,'/size'], ['unmxpool_2',label,'/size']);
% 
% %%% deconvolution 3
% layer = [transposedConv2dLayer([1 2],firstnumfilt,'stride',1,'Cropping','Same','Name','Tconv3'),...
%          batchNormalizationLayer('Name',['relu_7',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_7',label]),...
%          ReshapeLayer2D('Name','Reshape2D_7'),...
%          maxUnpooling2dLayer('Name',['unmxpool_3',label]),...
%          ReshapeLayer1D('Name','Reshape1D_7')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,'Reshape1D_6','Tconv3');
% lgraph = connectLayers(lgraph, ['mxpool_2',label,'/indices'], ['unmxpool_3',label,'/indices']);
% lgraph = connectLayers(lgraph, ['mxpool_2',label,'/size'], ['unmxpool_3',label,'/size']);
% 
% %%% deconvolution 4
% layer = [transposedConv2dLayer([1 2],firstnumfilt,'stride',1,'Cropping','Same','Name','Tconv4'),...
%          batchNormalizationLayer('Name',['relu_8',label]),...
%          preluLayer(firstnumfilt,'Name',['relu_8',label]),...
%          ReshapeLayer2D('Name','Reshape2D_8'),...
%          maxUnpooling2dLayer('Name',['unmxpool_4',label]),...
%          ReshapeLayer1D('Name','Reshape1D_8')];
% lgraph = addLayers(lgraph,layer);
% lgraph = connectLayers(lgraph,'Reshape1D_7','Tconv4');
% lgraph = connectLayers(lgraph, ['mxpool_1',label,'/indices'], ['unmxpool_4',label,'/indices']);
% lgraph = connectLayers(lgraph, ['mxpool_1',label,'/size'], ['unmxpool_4',label,'/size']);

end

