classdef forward_handler
    properties
        transform_handler
        tomo_transform_handler
        measurement_size
        original_size
        angles
    end
    
    methods
        function obj = forward_handler(u, tomo_transform, measurement_size, ...
                original_size, angles)
            obj.transform_handler = u;
            obj.tomo_transform_handler = tomo_transform;
            obj.measurement_size = measurement_size;
            obj.original_size = original_size;
            obj.angles = angles;
        end
        function output = mtimes(A, X)
            X = reshape(X, A.original_size, A.original_size);
            Beta = A.transform_handler(X);
            output = A.tomo_transform_handler(Beta, A.angles);
            output = output(:);
        end
    end
end