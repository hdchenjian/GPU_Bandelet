clc
clear all
close all

load('../QT.mat');
load('../Theta.mat');
load('../MB.mat');

j_min = 3;	%the minimum scale for quadtree segment
j_max = 3;	%the maximum scale for quadtree segment
Jmin = 3;	%the smallest size of square(width = w^2) of wavelet transform
dir = -1;

width = size(MB, 1);
num_min_square = width / 2^j_min;
MW = zeros(width, width);

%perform backward_warped_wavelet transform get wavelet coeffcient
for kx=0 : num_min_square - 1
    for ky=0 : num_min_square - 1
        selx = kx * 2^j_min + 1 : (kx+ 1) * 2^j_min ;
        sely = ky * 2^j_min + 1 : (ky+ 1) * 2^j_min ;
		theta = Theta(kx * 2^j_min + 1, ky * 2^j_min + 1);
		MW(selx,sely) = backward_warped_wavelet(MB(selx,sely),theta,dir);
	end
end

figure;
subplot(1,2,1), imshow(MB); title('bandelet transform coeffcient');
subplot(1,2,2), imshow(MW); title('backward warped wavelet transform get wavelet coeffcient');

%perform backward wavelet transform, to reconsruction the image
scale = log2(width) - Jmin;
reconstruct = dwt_haar_2d(MW,width,width,scale, dir);
figure;
M = imread('test.png');
M = double(M);
subplot(1,2,1), imshow(M,[]); title('origin image');
subplot(1,2,2), imshow(reconstruct,[]); title('bandelet reconstruct image');
disp('the approximate error (f - fM)^2 is ');
sum(sum((M - reconstruct)^2))