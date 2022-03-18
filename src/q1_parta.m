%% Clearing console and variables
clc; clear all;
%% Reading the image and adding noise to it
imagePath = "../barbara256.png";
X = imread(imagePath);
paddedX = padarray(X, [4, 4], 'replicate', 'both');
% paddedX = padarray(X, [4, 4], 0, 'both');
rng(42);
variance = 3;
N = sqrt(variance).*randn(size(paddedX));
Y = cast(double(paddedX) + N, 'uint8');

% Y1 = imnoise(X, 'gaussian', 0, 3);
figure();
subplot(1,2,2);
imshow(Y);
title('Noisy Image');
subplot(1,2,1)
imshow(X);
title('Original Image');
tic;
%% ISTA algorithm
U = kron(dctmtx(8)', dctmtx(8)');   % We are using 8x8 patches to reconstruct x
phi = eye(64);                      % measurement matrix
A = phi*U;
alpha = max(eig(A'*A)) + 1;
[rows, cols] = size(X);
reconstructed_img = zeros(size(paddedX));
counts = zeros(size(paddedX));
for i=1:rows
    for j=1:cols
        patch = double(reshape(Y(i:i+7, j:j+7), 64,1));
        lambda = 1;
        theta = randn([64,1]);
        for k=1:100
            theta = softhresh((theta + A'*(patch - A*theta)*(1/alpha)), (lambda/(2*alpha)));
        end
        reconstructed_patch = reshape(U*theta, 8, 8);
        reconstructed_img(i:i+7, j:j+7) = reconstructed_img(i:i+7, j:j+7) + reconstructed_patch;
        counts(i:i+7, j:j+7) = counts(i:i+7, j:j+7) + ones(8);
    end 
end
reconstructed_img = reconstructed_img./counts;
X_hat = reconstructed_img(5:rows+4, 5:cols+4);
rmse = norm(double(X)-X_hat, 'fro')/norm(double(X), 'fro');
%% Printing plots
fprintf("RMSE error = %.5f\n", rmse);
figure();
subplot(1,3,1);
imshow(X);
title('Original Image');
subplot(1,3,2);
imshow(Y);
title('Noisy Image');
subplot(1,3,3);
imshow(uint8(X_hat));
title('Reconstructed Image');
toc;