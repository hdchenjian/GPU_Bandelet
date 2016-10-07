function y = perform_haar_transform(x, dir);
% perform_haar_transform - compute a wavelet haar transform

x = x(:);
n = length(x);
J = floor( log2(n) )-1;
y = x;	% x contains the coarse scale signal
if(1 == dir)
	for j=J:-1:0		%perform forward haar transform
		n = length(x);
		y(n/2+1:n) = ( x(1:2:n) - x(2:2:n) )/sqrt(2);	 % fine scale
		y(1:n/2) = ( x(1:2:n) + x(2:2:n) )/sqrt(2);		 % coarse scale
		x = y(1:n/2);
	end
else		%perform backward haar transform
	for j= 0 : J
		n = 2^j;
		coarse = y(1 : n);
		fine = y(n + 1 : 2 * n);
		y(1 : 2 : 2^(j + 1)) = (coarse + fine) / sqrt(2);
		y(2 : 2 : 2^(j + 1)) = (coarse - fine) / sqrt(2);
	end
end		
