%% Clearing concole and variables
clc; clear all;
%% Reading and padding the brain slice 
imgPath = "../slice_50.png";
X = double(imread(imgPath));
[rows, cols] = size(X);
% paddedX = padarray(X, [(cols-rows)/2, 0], 'replicate', 'both');
paddedX = padarray(X, [(cols-rows)/2, 0], 0, 'both');
figure();
subplot(1,2,1);
imshow(uint8(X));
title('Original Image');
subplot(1,2,2);
imshow(uint8(paddedX));
title('Padded Image');
%% Filtered back-projection using Ram-Lak filter
angles = linspace(0, 170, 18);
[R, xp] = radon(paddedX, angles);
figure();
imshow(R,[],'Xdata',angles,'Ydata',xp,'InitialMagnification','fit');
xlabel('\theta {degrees}');
ylabel('x''');
colormap(gca, hot), colorbar;
title('Sinogram with the limited radon projections');

reconstructed_image = iradon(R, angles, 'linear', 'Ram-Lak');
figure();
imshow(uint8(reconstructed_image)); 
title('Recosntructed Padded Image'); colorbar;
%% Independent CS-based tomographic reconstruction 
r = @radon;
u = @dct2;