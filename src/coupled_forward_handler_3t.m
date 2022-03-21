classdef coupled_forward_handler_3t
    properties
        transform_handler
        tomo_transform_handler
        measurement_size
        original_size
        angles_1
        angles_2
        angles_3
    end
    
    methods
        function obj = coupled_forward_handler_3t(u, tomo_transform, measurement_size, ...
                original_size, angles_1, angles_2, angles_3)
            obj.transform_handler = u;
            obj.tomo_transform_handler = tomo_transform;
            obj.measurement_size = measurement_size;
            obj.original_size = original_size;
            obj.angles_1 = angles_1;
            obj.angles_2 = angles_2;
            obj.angles_3 = angles_3;
        end        
        function output = mtimes(At, Y)
            lenY = length(Y);
            Y_1 = Y(1:lenY/3);
            Y_2 = Y(lenY/3 + 1: 2*lenY/3);
            Y_3 = Y(2*lenY/3 + 1:end);
            Y_1 = reshape(Y_1, At.measurement_size, size(At.angles_1, 2));
            Y_2 = reshape(Y_2, At.measurement_size, size(At.angles_2, 2));
            Y_3 = reshape(Y_3, At.measurement_size, size(At.angles_3, 2));
            Beta = At.tomo_transform_handler(Y_1, At.angles_1, 'linear', 'Ram-Lak', 1, At.original_size);
            delta_Beta1 = At.tomo_transform_handler(Y_2, At.angles_2, 'linear', 'Ram-Lak', 1, At.original_size);
            delta_Beta2 = At.tomo_transform_handler(Y_3, At.angles_3, 'linear', 'Ram-Lak', 1, At.original_size);
            X = At.transform_handler(Beta);
            delta_X1 = At.transform_handler(delta_Beta1);
            delta_X2 = At.transform_handler(delta_Beta2);
            output = [X(:) + delta_X1(:); delta_X1(:); delta_X2(:)];
        end
    end
end