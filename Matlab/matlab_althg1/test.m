% test bandelet transform

clc
clear all
close all
M=imread('test.png');
origine_image = M;
M = double(M);
dir = 1;

T = 10;		%the threshold to evalue the best direction
j_min = 3;	%the minimum scale for quadtree segment
j_max = 4;	%the maximum scale for quadtree segment
%Jmin = 3;	%the smallest size of square(width = w^2) of wavelet transform
s = 2;		%the super-resolution for the geometry [default 2]

tic
[QT,Theta] = compute_quadtree(M,T,j_min,j_max,s);
[MB,r_geom] = perform_bandelet_transform(M,QT,Theta,dir);
toc

%qt=QT';
% imshow(( (qt-min(qt(:)))/(max(qt(:))-min(qt(:))) ))
% imshow(( (QT-min(QT(:)))/(max(QT(:))-min(QT(:))) ))
% imshow(( (Theta-min(Theta(:)))/(max(Theta(:))-min(Theta(:))) ))
figure;
%plot a line use standard Cartesian coordinates, so we need to transpose the matrix
%matlab use colums sequence arrenge data, C use row sequence
subplot(2,2,1), imshow(( (QT'-min(QT(:)))/(max(QT(:))-min(QT(:))) ));
subplot(2,2,2), imshow(( (Theta'-min(Theta(:)))/(max(Theta(:))-min(Theta(:))) ));
subplot(2,2,3), plot_quadtree(QT,Theta,origine_image,1);
subplot(2,2,4), imshow(( (MB-min(MB(:)))/(max(MB(:))-min(MB(:))) ));
thetaa=Theta';
thetaa(127, 192:208);
thetaa(129, 192:208);
thetaa(129, 128:138);
thetaa(255, 128:138);