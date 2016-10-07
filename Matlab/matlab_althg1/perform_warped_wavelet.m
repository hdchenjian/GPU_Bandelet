function M = perform_warped_wavelet(M,theta,dir)
% perform_warped_wavelet - perform a warped haar transform

if theta==Inf   % special token : no geometry
    return; % nothing to do
end

n = size(M,1);
% sampling location
[Y,X] = meshgrid(1:n,1:n);
% projection on orthogonal direction
t = -sin(theta)*X(:) + cos(theta)*Y(:);
% order points in increasing order
[tmp,I] = sort(t);
M(I) = perform_haar_transform(M(I),dir);  % 修改
