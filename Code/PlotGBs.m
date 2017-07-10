function PlotGBs(GrainMap,mapsize,Type,ax)
%PLOTGBS 
%PlotGBs(GrainMap,mapsize,Type)
%Plots the grain boundaries on any map of the scan, using the grainIDs
%
%INPUTS:
%   GrainMap: OPTION 1 - [Nx Ny] sized array of grainID
%             OPTION 2 - grainID vector
%   mapsize: [Nx Ny]. Required only for OPTION 2.
%   Type: Scan Type ('Square','Hexagonal'). Required only for OPTION 2.
%
% Brian Jackson 6/17/2016
% Edited by Zach Clayburn 6/22/2017

%Convert to Map
if nargin > 1
    GrainMap = vec2map(GrainMap,mapsize(1),Type);
end
if nargin < 4
    ax = gca;
end

%Line Width
lw = 2;

%Horizontal Boundaries
diffMap = diff(GrainMap,1,1);
[row,col] = find(diffMap);
%imagesc(GrainMap)

if ~(isempty(row) || isempty(col))
    % Sort the points so they are orgainized horizontaly
    [row,I] = sort(row);
    col = col(I);
    X = [col-.5 col+0.5];
    Y = [row row]+0.5;
    
    newX(length(X),2) = 0;
    newY = newX;
    newX(1) = X(1);
    newY(1) = Y(1);
    jj = 2;
    
    for ii = 2:length(X)
        head = [X(ii-1,2) Y(ii-1,2)];
        tail = [X(ii,1) Y(ii,1)];
        if ~isequal(head,tail)
            % If one line ends at the begining of the next, skip that ending
            % point and move on to the next point, otherwise, append them to the
            % list of points
            newX(jj-1,2) = head(1);
            newY(jj-1,2) = head(2);
            newX(jj,1) = tail(1);
            newY(jj,1) = tail(2);
            jj = jj+1;
        end
    end
    
    newX(jj-1,2) = X(end);
    newY(jj-1,2) = Y(end);
    X = newX(1:jj-1,:);
    Y = newY(1:jj-1,:);
    
    hold on
    plot(ax,X',Y','k','LineWidth',lw)
end

%Vertical
diffMap = diff(GrainMap,1,2);
[row,col] = find(diffMap);

if ~(isempty(row) || isempty(col))
    % Sort the points so they are orgainized verticaly
    [col,I] = sort(col);
    row = row(I);
    X = [col col]+0.5;
    Y = [row-.5 row+0.5];
    
    newX(length(X),2) = 0;
    newY = newX;
    newX(1) = X(1);
    newY(1) = Y(1);
    jj = 2;
    for ii = 2:length(X)
        head = [X(ii-1,2) Y(ii-1,2)];
        tail = [X(ii,1) Y(ii,1)];
        if ~isequal(head,tail)
            % If one line ends at the begining of the next, skip that ending
            % point and move on to the next point, otherwise, append them to the
            % list of points
            newX(jj-1,2) = head(1);
            newY(jj-1,2) = head(2);
            newX(jj,1) = tail(1);
            newY(jj,1) = tail(2);
            jj = jj+1;
        end
    end
    
    newX(jj-1,2) = X(end);
    newY(jj-1,2) = Y(end);
    X = newX(1:jj-1,:);
    Y = newY(1:jj-1,:);
    
    plot(ax,X',Y','k','LineWidth',lw)
end