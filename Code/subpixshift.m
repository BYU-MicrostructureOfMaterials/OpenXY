function [qx,qy]=subpixshift(rimage)
%SUBPIXSHIFT Find the sub-pixel value of the shift in a xcorr image.
%   SUBPIXSHIFT(rimage) computes the shift from the center of the maximum
%   value of the give cross corelation image rimage, and returns the x and
%   y components of that shift, qx and qy
[~, ind] = max(rimage(:));
[row, col] = ind2sub(size(rimage), ind);

cent = round((length(rimage(:,1))+1)/2);
if abs(row-cent) >  cent-3 || abs(col-cent) >  cent-3
    qx = cent-col;
    qy = cent-row;
else
    xdat = rimage(row,col-1:col+1)';
    ydat = rimage(row-1:row+1,col);
    A = [
        1 -1  1
        0  0  1
        1  1  1
    ];
    Ax = A\xdat;
    Ay = A\ydat;
    
    %set derivative equal to zero and solve for x or y
    xc = -Ax(2)/(2*Ax(1));
    yc = -Ay(2)/(2*Ay(1));
    
    qx = -(col+xc)+cent;
    qy = -(row+yc)+cent;
    
end