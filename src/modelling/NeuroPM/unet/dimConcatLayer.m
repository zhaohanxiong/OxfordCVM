classdef dimConcatLayer < nnet.layer.Layer
    % Example custom dimension concatenation layer.
    
    properties 
        Dimension
    end

    methods
        function layer = dimConcatLayer(numInputs,dimension,args) 
            % layer = dimConcatLayer(numInputs,name) creates a
            % dimension concatenation layer and specifies the number of inputs
            % and the layer name.
            arguments
                numInputs
                dimension
                args.Name = "";
            end

            % Set layer name
            layer.Name = args.Name;

            % Set number of inputs.
            layer.NumInputs = numInputs;
            layer.Dimension = dimension;

            % Set layer description.
            layer.Description = "Dimension concatenation layer";
        
            layer.Type = "Dimension Concatenation";
            
        end
        
        function Z = predict(layer, varargin)
            % Z = predict(layer, X1, ..., Xn) forwards the input data X1,
            % ..., Xn through the layer and outputs the result Z.
            
            X = varargin;
            dim = layer.Dimension;

            for p = 2:length(X)
                if p < 3
                   Z = cat(dim,X{1},X{p});
                else
                   Z = cat(dim,Z,X{p});
                end
            end
           
        end
    end
end