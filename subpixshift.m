function [qx,qy]=subpixshift(rimage)

% [r c] = size(rimage);
x = [-1:1]';
y = [-1:1]';

[C00 ind] = max(rimage([1:end]));
l = length(rimage(:,1));
%find the row column location of max
cent = round((length(rimage(:,1))+1)/2);
row = mod(ind-1,l)+1;
col = (ind-row)/l+1;
if abs(row-cent) >  cent-3 || abs(col-cent) >  cent-3
    qx = cent-col;
    qy = cent-row;
else
    xdat = rimage(row,col-1:col+1)';
    ydat = rimage(row-1:row+1,col);
    Ax = [x.^2 x ones(length(x),1)]\xdat;
    Ay = [y.^2 y ones(length(y),1)]\ydat;
    %set derivative equal to zero and solve for x or y
    xc = -Ax(2)/(2*Ax(1));
    yc = -Ay(2)/(2*Ay(1));
    
    %
    qx = -(col+xc)+cent;
    qy = -(row+yc)+cent;
    
end