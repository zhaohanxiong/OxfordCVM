classdef ReshapeLayer2D < nnet.layer.Layer & ...
         nnet.layer.Formattable
    % Example reshape layer.

    methods
        function layer = ReshapeLayer2D(NameValueArgs)
            % layer = ReshapeLayer(numChannels)
                                  
            % Parse input arguments.
            arguments
                NameValueArgs.Name = '';
            end
            
            name = NameValueArgs.Name;
            
            % Set layer name.
            layer.Name = name;

            % Set layer description.
            layer.Description = "Reshape 2D layer";
            
            % Set layer type.
            layer.Type = "Reshape 2D";
            
        end
        
        function Z = predict(~, X)
            % Forward input data through the layer at prediction time and
            % output the result.
            % 
            % Inputs:
            %         layer - Layer to forward propagate through
            %         X     - Input data, specified as a formatted dlarray
            %                 with a 'C' and optionally a 'B' dimension.
            % Outputs:
            %         Z     - Output of layer forward function returned as 
            %                 a formatted dlarray with format 'SSCB'.
            
            % Reshape as image
            inputSize = size(X);
            Z = reshape(X, [], inputSize(3), inputSize(1), inputSize(2));
            
            % Relabel.
            Z = dlarray(Z,'SSCB');

            % Reshape as feature input
%             inputSize = size(X);
%             X2 = reshape(X, inputSize(3), inputSize(2), []);
            
%             Z = permute(X,[3,2,1]);
            % Relabel.
%             Z = dlarray(X2);
        end
    end
end