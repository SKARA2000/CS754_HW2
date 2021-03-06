%% Soft Thresholding function
function x = softhresh(y, lambda)
    x = zeros(size(y));
    for i=1:length(x)
        if y(i)>=lambda
            x(i) = y(i) - lambda;
        elseif y(i)<=(-lambda)
            x(i) = y(i) + lambda;
        else
            x(i) = 0;
        end
    end
end