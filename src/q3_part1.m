%% Clearing concole and variables
clc; clear all;
%% Reading and padding the brain slice 
slice_1 = double(imread('../slice_50.png'));
slice_2 = double(imread('../slice_51.png'));
slice_3 = double(imread('../slice_52.png'));
slice_4 = double(imread('../slice_53.png'));
slice_5 = double(imread('../slice_54.png'));
slice_6 = double(imread('../slice_55.png'));
[rows, cols] = size(slice_1);
% paddedX = padarray(X, [(cols-rows)/2, 0], 'replicate', 'both');
% padded_slice_1 = padarray(slice_1, [(cols-rows)/2, 0], 0, 'both');
% padded_slice_2 = padarray(slice_2, [(cols-rows)/2, 0], 0, 'both');
% padded_slice_3 = padarray(slice_3, [(cols-rows)/2, 0], 0, 'both');
% padded_slice_4 = padarray(slice_4, [(cols-rows)/2, 0], 0, 'both');
% padded_slice_5 = padarray(slice_5, [(cols-rows)/2, 0], 0, 'both');
% padded_slice_6 = padarray(slice_6, [(cols-rows)/2, 0], 0, 'both');
padded_slice_1 = padarray(slice_1, [(255-rows)/2, (255-cols)/2], 0, 'both');
padded_slice_2 = padarray(slice_2, [(255-rows)/2, (255-cols)/2], 0, 'both');
padded_slice_3 = padarray(slice_3, [(255-rows)/2, (255-cols)/2], 0, 'both');
padded_slice_4 = padarray(slice_4, [(255-rows)/2, (255-cols)/2], 0, 'both');
padded_slice_5 = padarray(slice_5, [(255-rows)/2, (255-cols)/2], 0, 'both');
padded_slice_6 = padarray(slice_6, [(255-rows)/2, (255-cols)/2], 0, 'both');
figure();
subplot(1,2,1);
imshow(uint8(slice_1));
title('Original Image');
subplot(1,2,2);
imshow(uint8(padded_slice_1));
title('Padded Image');
%% Filtered back-projection using Ram-Lak filter
angles = linspace(0, 170, 18);
[Y, xp] = radon(padded_slice_1, angles);
figure();
imshow(Y,[],'Xdata',angles,'Ydata',xp,'InitialMagnification','fit');
xlabel('\theta {degrees}');
ylabel('x''');
colormap(gca, hot), colorbar;
title('Sinogram with the limited radon projections');

reconstructed_image = iradon(Y, angles, 'linear', 'Ram-Lak');
figure();
subplot(1, 2, 1);
imshow(uint8(padded_slice_1));
title('Original Padded Image');
axis on; axis tight; colormap('gray'); colorbar;
subplot(1, 2, 2);
imshow(uint8(reconstructed_image)); 
title('Reconstructed Padded Image');
axis on; axis tight; colormap('gray'); colorbar;
%% Independent CS-based tomographic reconstruction 
addpath('../l1_ls_matlab');
measurement_size = size(Y, 1);
original_size = size(padded_slice_1, 1);
m = size(Y(:), 1);
n = size(padded_slice_1(:), 1);
A = forward_handler(@idct2, @radon, measurement_size, original_size, angles);
At = forward_handler_t(@dct2, @iradon, measurement_size, original_size, angles);
lambda = 0.1;
rel_tol = 1e-4;
[Beta, status] = l1_ls(A, At, m, n, Y(:), lambda, ...
    rel_tol, true);
reconstructed_image = idct2(reshape(Beta, original_size, original_size));
figure();
imshow(uint8(reconstructed_image));
colormap('gray');
title("Reconstructed Image using CS-based reconstruction");
axis on;
axis tight;
colorbar;
%% Coupled CS-based tomographic reconstruction
tic;
angles_1 = unifrnd(0, 180, 1, 18);
angles_2 = unifrnd(0, 180, 1, 18);
Y_1 = radon(padded_slice_1, angles_1);
Y_2 = radon(padded_slice_2, angles_2);
measurement_size = size(Y_1, 1);
Y_1 = Y_1(:);
Y_2 = Y_2(:);
Y = [Y_1; Y_2];
m = size(Y, 1);
n = size(padded_slice_1(:), 1) + size(padded_slice_2(:), 1);
original_size = size(padded_slice_1, 1);
A = coupled_forward_handler(@idct2, @radon, measurement_size, original_size, angles_1, angles_2);
At = coupled_forward_handler_t(@dct2, @iradon, measurement_size, original_size, angles_1, angles_2);
lambda = 0.1;
rel_tol = 1e-4;
[Beta, status] = l1_ls(A, At, m, n, Y, lambda, rel_tol, true);
Beta_1 = Beta(1:0.5*n);
delta_Beta_1 = Beta(0.5*n + 1:end);
reconstrucetd_slice_50 = idct2(reshape(Beta_1, original_size, original_size));
reconstrucetd_slice_51 = idct2(reshape(Beta_1 + delta_Beta_1, original_size, original_size));
figure();
subplot(1, 2, 1);
imshow(uint8(reconstrucetd_slice_50));
colormap('gray');
title("Coupled CS-based Reconstruction(Slice 50)");
axis on; axis tight; colorbar;
subplot(1, 2, 2);
imshow(uint8(reconstrucetd_slice_51));
colormap('gray');
title("Coupled CS-based Reconstruction(Slice 51)");
axis on; axis tight; colorbar;
toc;
%% Coupled CS-based reconstruction with three slices
tic;
angles_1 = unifrnd(0, 180, 1, 18);
angles_2 = unifrnd(0, 180, 1, 18);
angles_3 = unifrnd(0, 180, 1, 18);
Y_1 = radon(padded_slice_1, angles_1);
Y_2 = radon(padded_slice_2, angles_2);
Y_3 = radon(padded_slice_3, angles_3);
Y = [Y_1(:); Y_2(:); Y_3(:)];
m = size(Y, 1);
n = size(padded_slice_1(:), 1) + size(padded_slice_2(:), 1) + size(padded_slice_3(:), 1);
measurement_size = size(Y_1, 1);
original_size = size(padded_slice_1, 1);
A = coupled_forward_handler_3(@idct2, @radon, measurement_size, original_size, angles_1, ...
    angles_2, angles_3);
At = coupled_forward_handler_3t(@dct2, @iradon, measurement_size, original_size, angles_1, ...
    angles_2, angles_3);
lambda = 0.1;
rel_tol = 1e-4;
[Beta, status] = l1_ls(A, At, m, n, Y, lambda, rel_tol, true);
Beta = Beta(1:n/3);
delta_Beta1 = Beta(n/3+1:2*n/3);
delta_Beta2 = Beta(2*n/3+1:end);
Beta2 = Beta + delta_Beta1;
Beta3 = Beta + delta_Beta1 + delta_Beta2;
reconstrucetd_slice_50 = idct2(reshape(Beta, original_size, original_size));
reconstrucetd_slice_51 = idct2(reshape(Beta2, original_size, original_size));
reconstrucetd_slice_52 = idct2(reshape(Beta3, original_size, original_size));
figure();
subplot(1, 3, 1);
imshow(uint8(reconstrucetd_slice_50));
title("Coupled 3 slices CS-based recosntruction(slice 50)");
axis on; axis tight; colormap('gray'); colorbar;
subplot(1, 3, 2);
imshow(uint8(reconstrucetd_slice_51));
title("Coupled 3 slices CS-based recosntruction(slice 51)");
axis on; axis tight; colormap('gray'); colorbar;
subplot(1, 3, 3);
imshow(uint8(reconstrucetd_slice_52));
title("Coupled 3 slices CS-based recosntruction(slice 52)");
axis on; axis tight; colormap('gray'); colorbar;
toc;