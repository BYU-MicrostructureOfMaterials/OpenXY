function [MaxMisAng,MisAng] = PlotMisAng(g,dims,layout)
%PLOTMISANG
% [MaxMisAng,MisAng] = PlotMisang(g,dims,layout)
% 
% INPUTS
%   g: 3x3xN matrix of orientation matrices
%   dims: Dimensions of the scan [Nx Ny]
%   layout: Selects which plots are shown
%       cross: 5 plots. Center is the max in any of the 4 directions.
%           Others are the miorientation with the point at that side (top graph
%           is a plot of the misorientation of the point with the top
%           neightbor)
%       top, left, right, bottom: Plot of misorientation of the point with
%           the specified neighbor
%       total: max misorientation of in any direction
%       all: Returns all of the plots as separate figures

if nargin<3
    layout = 'cross';
end
top = 1:dims(1);
bottom = prod(dims)-dims(1)+1:prod(dims);
left = 1:dims(1):prod(dims);
right = dims(1):dims(1):prod(dims);
MaxMisAng = zeros(prod(dims),1);
MisAng = zeros(prod(dims),4);
for i = 1:prod(dims)
    if ismember(i,top)
        t = i;
    else
        t = i-dims(1);
    end
    if ismember(i,bottom)
        b = i;
    else
        b = i+dims(1);
    end
    if ismember(i,left)
        l = i;
    else
        l = i-1;
    end
    if ismember(i,right)
        r = i;
    else
        r = i+1;
    end
    MisAng(i,1) = GeneralMisoCalc(g(:,:,i),g(:,:,r),'tetragonal');
    MisAng(i,2) = GeneralMisoCalc(g(:,:,i),g(:,:,b),'tetragonal');
    MisAng(i,3) = GeneralMisoCalc(g(:,:,i),g(:,:,l),'tetragonal');
    MisAng(i,4) = GeneralMisoCalc(g(:,:,i),g(:,:,t),'tetragonal');
    MaxMisAng(i) = max(MisAng(i,:));
end
map = reshape(MaxMisAng,dims(1),dims(2))';
mapr = reshape(MisAng(:,1),dims(1),dims(2))';
mapb = reshape(MisAng(:,2),dims(1),dims(2))';
mapl = reshape(MisAng(:,3),dims(1),dims(2))';
mapt = reshape(MisAng(:,4),dims(1),dims(2))';
switch layout
    case 'cross'
        figure
        subplot(3,3,2)
        imagesc(mapl)
        subplot(3,3,4)
        imagesc(mapt)
        subplot(3,3,5)
        imagesc(map)
        subplot(3,3,6)
        imagesc(mapb)
        subplot(3,3,8)
        imagesc(mapr)
    case 'top'
        figure
        imagesc(mapt)
    case 'bottom'
        figure
        imagesc(mapb)
    case 'left'
        figure
        image(mapl)
    case 'right'
        figure
        imagesc(mapr)
    case 'total'
        figure
        imagesc(map)
    case 'all'
        figure
        imagesc(mapl)
        figure
        imagesc(mapr)
        figure
        imagesc(mapt)
        figure
        imagesc(mapb)
        figure
        imagesc(map)
        
end
