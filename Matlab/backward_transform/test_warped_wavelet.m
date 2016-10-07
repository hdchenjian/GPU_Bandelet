clc
clear all
close all

M = eye(8);
theta = 0;
MW = perform_warped_wavelet(M,theta,1);
reconstruct = backward_warped_wavelet(MW, theta, -1);