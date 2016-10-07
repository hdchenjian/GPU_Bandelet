function  y = dwt_haar_2d(x , colum , row , scale, dir)

    y=x; 
    if(dir == 1)		%perform forward haar transform
        for j=1:scale
            for i=1:row	%for every row
                    x0 = x(i , :)';
                    x(i , 1:colum / 2) = (x0(1:2:end , :) + x0(2:2:end , :))  /  sqrt(2);
                    x(i , colum / 2+1:colum) = (x0(1:2:end , :) - x0(2:2:end , :))  /  sqrt(2);
            end
            for i=1:colum	%for every colum
                    x0 = x(: , i);
                    x(1:row / 2 , i) = (x0(1:2:end , :) + x0(2:2:end , :))  /  sqrt(2);
                    x(row / 2+1:row , i) = (x0(1:2:end , :) - x0(2:2:end , :))  /  sqrt(2);
            end
            y(row / 2+1:row , 1:colum)=x(row / 2+1:row , 1:colum);
            y(1:row / 2 , colum / 2+1:colum)=x(1:row / 2 , colum / 2+1:colum);
            x=x(1:row / 2 , 1:colum / 2);
            colum=colum / 2;
            row=row / 2;
        end
        y(1:row , 1:colum)=x;
    else				%perform backward haar transform
        for j = log2(colum) - scale : log2(colum) - 1
            for i=1:2^(j+1)	%for every colum
                x0 = y(: , i)';
                n = 2^j;
                y0 = zeros(1, 2*n);
                coarse = x0(1 : n);
                fine = x0(n + 1 : 2 * n);
                y0(1 : 2 : 2^(j + 1)) = (coarse + fine) / sqrt(2);
                y0(2 : 2 : 2^(j + 1)) = (coarse - fine) / sqrt(2);
                y(1 : 2*n, i) = y0';
            end
            for k = 1:2^(j+1)       %for every row
                x0 = y(k , :);
                n = 2^j;
                y0 = zeros(1, 2*n);
                coarse = x0(1 : n);
                fine = x0(n + 1 : 2 * n);
                y0(1 : 2 : 2^(j + 1)) = (coarse + fine) / sqrt(2);
                y0(2 : 2 : 2^(j + 1)) = (coarse - fine) / sqrt(2);
                y(k, 1 : 2*n) = y0;
            end
        end
    end
end