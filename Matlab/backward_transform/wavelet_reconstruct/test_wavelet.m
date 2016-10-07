clc
clear all
close all

M = imread('test.png');
M = double(M);
% perform the wavelet transform
nx = length(M);
ny = length(M);
width = nx;
Jmin = 7;
dir = -1;
scale = log2(nx) - Jmin;
MW = dwt_haar_2d(M,nx,ny,scale, 1);
reconstruct = dwt_haar_2d(MW,width,width,scale, dir);
subplot(1,2,1), imshow(M,[]); title('origin image');
subplot(1,2,2), imshow(reconstruct,[]); title('wavelet reconstruct image');