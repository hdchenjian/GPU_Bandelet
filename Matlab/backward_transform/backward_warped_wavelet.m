function MB = backward_warped_wavelet(MB, theta,dir)
%perform backward__warped_wavelet

if theta==Inf   % special token : no geometry
    return; % nothing to do
end

n = size(MB, 1);
% sampling location
[Y,X] = meshgrid(1:n,1:n);
% projection on orthogonal direction
t = -sin(theta)*X(:) + cos(theta)*Y(:);
% order points in increasing order
[tmp,I] = sort(t);

%perform invert transforma get the wavelet coefficient
MB(I) = perform_haar_transform(MB(I),dir);
