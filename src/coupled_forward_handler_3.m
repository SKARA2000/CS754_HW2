classdef coupled_forward_handler_3
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
        function obj = coupled_forward_handler_3(u, tomo_transform, measurement_size, ...
                original_size, angles_1, angles_2, angles_3)
            obj.transform_handler = u;
            obj.tomo_transform_handler = tomo_transform;
            obj.measurement_size = measurement_size;
            obj.original_size = original_size;
            obj.angles_1 = angles_1;
            obj.angles_2 = angles_2;
            obj.angles_3 = angles_3;
        end        
        function output = mtimes(A, X)
            lenX = length(X);
            temp = X(1:lenX/3);
            delta_temp1 = X(lenX/3 + 1: 2*lenX/3);
            delta_temp2 = X(2*lenX/3 + 1: end);
            temp = reshape(temp, A.original_size, A.original_size);
            delta_temp1 = reshape(delta_temp1, A.original_size, A.original_size);
            delta_temp2  = reshape(delta_temp2, A.original_size, A.original_size);
            
            Beta = A.transform_handler(temp);
            delta_Beta1 = A.transform_handler(delta_temp1);
            delta_Beta2 = A.transform_handler(delta_temp2);
            
            R1 = A.tomo_transform_handler(Beta, A.angles_1);
            R2 = A.tomo_transform_handler(Beta, A.angles_2);
            R3 = A.tomo_transform_handler(Beta, A.angles_3);
            R1_2 = A.tomo_transform_handler(delta_Beta1, A.angles_2);
            R1_3 = A.tomo_transform_handler(delta_Beta2, A.angles_3);
            output = [R1(:); R2(:) + R1_2(:); R3(:) + R1_3(:)];
        end
    end
end