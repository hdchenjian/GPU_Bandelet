function  y = dwt_haar_2d(x,nx,ny,J)
y=zeros(ny,nx);
for j=1:J
    for i=1:ny
            x0 = x(i,:)';
            x(i,1:nx/2) = (x0(1:2:end,:) + x0(2:2:end,:)) / sqrt(2);
            x(i,nx/2+1:nx) = (x0(1:2:end,:) - x0(2:2:end,:)) / sqrt(2);
    end
    for i=1:nx
            x0 = x(:,i);
            x(1:ny/2,i) = (x0(1:2:end,:) + x0(2:2:end,:)) / sqrt(2);
            x(ny/2+1:ny,i) = (x0(1:2:end,:) - x0(2:2:end,:)) / sqrt(2);
    end
    y(ny/2+1:ny,1:nx)=x(ny/2+1:ny,1:nx);
    y(1:ny/2,nx/2+1:nx)=x(1:ny/2,nx/2+1:nx);
    x=x(1:ny/2,1:nx/2);
    nx=nx/2;
    ny=ny/2;
end
y(1:ny,1:nx)=x;
