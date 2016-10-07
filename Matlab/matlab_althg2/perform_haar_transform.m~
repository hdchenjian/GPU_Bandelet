function x = perform_haar_transform(x, dir);
x = x(:); % to be sure we have a column vector
J = floor( log2(length(x)) ); % number of scales
if dir==1 % forward transform
	for j=1:J
		c = x(1:2^(j-1):end); % previous coarse signal
		x(1:2^j:end) = ...  % new coarse signal
		( c(1:2:end) + c(2:2:end) )/sqrt(2);
		x(1+2^(j-1):2^j:end) = ... % new details
		(c(1:2:end)-c(2:2:end))/sqrt(2);
	end
else
	% backward transform
	for j=J:-1:1
		y = x(1:2^(j-1):end);
		x(1:2^j:end) = ...
		( y(1:2:end) + y(2:2:end) )/sqrt(2);
		x(1+2^(j-1):2^j:end) = ...
		( y(1:2:end) - y(2:2:end) )/sqrt(2);
	end
end
