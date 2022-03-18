%% Clearing console and variables
clc; clear all;
%% Reading the image and adding noise to it
imagePath = "../barbara256.png";
X = double(imread(imagePath));
paddedX = padarray(X, [4, 4], 'replicate', 'both');
% paddedX = padarray(X, [4, 4], 0, 'both');
tic;
%% ISTA algorithm
U = kron(dctmtx(8)', dctmtx(8)');   % We are using 8x8 patches to reconstruct x
rng(80);
phi = randn(32, 64);                      % measurement matrix
A = phi*U;
alpha = max(eig(A'*A)) + 1;
[rows, cols] = size(X);
reconstructed_img = zeros(size(paddedX));
counts = zeros(size(paddedX));
for i=1:rows
    for j=1:cols
        patch = phi*reshape(paddedX(i:i+7, j:j+7), 64,1);
        lambda = 1;
        theta = zeros([64,1]);
        for k=1:300
            theta = softhresh((theta + A'*(patch - A*theta)*(1/alpha)), (lambda/(2*alpha)));
        end
        reconstructed_patch = reshape(U*theta, 8, 8);
        reconstructed_img(i:i+7, j:j+7) = reconstructed_img(i:i+7, j:j+7) + reconstructed_patch;
        counts(i:i+7, j:j+7) = counts(i:i+7, j:j+7) + ones(8);
    end 
end
final_image = reconstructed_img./counts;
X_hat = final_image(5:rows+4, 5:cols+4);
X_hat = X_hat*2;
rmse = norm(X-X_hat, 'fro')/norm(X, 'fro');
%% Printing plots
fprintf("RMSE error = %.5f\n", rmse);
figure();
subplot(1,2,1);
imshow(uint8(X));
title('Original Image');
subplot(1,2,2);
imshow(uint8(X_hat));
title('Reconstructed Image');
toc;