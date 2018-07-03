function outPut = PlotGBs(GrainMap,mapsize,Type,ax, lineWidth, color)
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
if nargin < 6
    %Line Properties
lineWidth = 1;
color = 'k';
end


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
            % If one line ends at the begining of the next, skip that
            %   ending point and move on to the next point, otherwise,
            %   append them to the list of points
            newX(jj-1,2) = head(1);
            newY(jj-1,2) = head(2);
            newX(jj,1) = tail(1);
            newY(jj,1) = tail(2);
            jj = jj+1;
        end% ~isequal(head,tail)
    end% ii = 2:length(X)
    
    newX(jj-1,2) = X(end);
    newY(jj-1,2) = Y(end);
    hX = newX(1:jj-1,:);
    hY= newY(1:jj-1,:);
    
    %hold on
    %plot(ax,X',Y',color,'LineWidth',lineWidth)
end% ~(isempty(row) || isempty(col))

%Vertical Boundaries
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
            % If one line ends at the begining of the next, skip that
            %   ending point and move on to the next point, otherwise,
            %   append them to the list of points
            newX(jj-1,2) = head(1);
            newY(jj-1,2) = head(2);
            newX(jj,1) = tail(1);
            newY(jj,1) = tail(2);
            jj = jj+1;
        end% ~isequal(head,tail)
    end% ii = 2:length(X)
    
    newX(jj-1,2) = X(end);
    newY(jj-1,2) = Y(end);
    vX = newX(1:jj-1,:);
    vY = newY(1:jj-1,:);
        
     lines = combineLines(hX,hY,vX,vY);
    
    hold(ax,'on')
    for ii = 1:size(lines,1)
        plot(ax,lines{ii,1},lines{ii,2},'LineWidth',lineWidth,'Color',color)
    end%ii = 1:size(lines,1)
    hold(ax,'off')
    
    if nargout == 1
       outPut = lines; 
    end

end%if ~(isempty(row) || isempty(col))
end%PlotGBS


function out = combineLines(hX,hY,vX,vY)
% This function combines diagonal lines into one path to reduce the
%   indvidual lines that Matlab has to draw and boost the performance when
%   working with scans containing a large amount of grain boundaries

% Take the vectors describing the x and y positions of the horizontal lines
%   and organize them into matricies relating to the start and end 
%   cartesian coordinates
hStart = [hX(:,1) hY(:,1)];
hEnd = [hX(:,2) hY(:,1)];

% Do the same for the vertical lines
vStart = [vX(:,1) vY(:,1)];
vEnd = [vX(:,1) vY(:,2)];

% Set up an output cell containing the the new combined lines, and create 
%   an iterateor value to track where to place new cells
out = cell(0,2);%TODO Should I preallocate an overly large array? Speed vs memory use
row = 1;

% First handle lines with a negative slope
ii = 1;
while(ii <= length(hStart))
    currentEnd = hEnd(ii,:);
    
    % Check if the current point from the vertical lines are in the
    %   horizontal lines, and get its position if it is
    [isPresent,vLocation] = ismember(currentEnd,vStart,'rows');
    hLocation = ii;
    if isPresent && 1
        % Begin output vectors for the combined line's x and y coordinates
        xOut = [hStart(hLocation,1);hEnd(hLocation,1)];
        yOut = [hStart(hLocation,2);hEnd(hLocation,2)];
        
        % Remove the point that is goint to be joined into the combined
        %   line
        hStart(hLocation,:) = [];
        hEnd(hLocation,:) = [];
        while isPresent
            % Append the found point to the combined line
            xOut(end+1) = vEnd(vLocation,1);
            yOut(end+1) = vEnd(vLocation,2);
            currentEnd = vEnd(vLocation,:);
            
            % Remove the point that is goint to be joined into the combined
            %   line
            vStart(vLocation,:) = [];
            vEnd(vLocation,:) = [];
            
            [isPresent,hLocation] = ismember(currentEnd,hStart,'rows');
            if isPresent
                currentEnd = hEnd(hLocation,:);
                
                % Append the found point to the combined line
                xOut(end+1) = hEnd(hLocation,1);
                yOut(end+1) = hEnd(hLocation,2);
                
                % Remove the point that is goint to be joined into the combined
                %   line
                hStart(hLocation,:) = [];
                hEnd(hLocation,:) = [];

                [isPresent,vLocation] = ismember(currentEnd,vStart,'rows');
            end%if isPresent
        end%while isPresent
        out(row,:) = {xOut,yOut};
        row = row + 1;
    else
        ii = ii + 1;
    end%any(isPresent)
end%while(ii <= length(hStart))

% Now handle lines with a positive slope
ii = 1;
while(ii <= length(hStart))
    currentStart = hStart(ii,:);
    
    % Check if the current point from the horizontal lines are in the 
    %   vertical lines, and get its position if it is
    [isPresent,vLocation] = ismember(currentStart,vStart,'rows');
    hLocation = ii;
    if isPresent && 1
        % Begin output vectors for the combined line's x and y coordinates
        xOut = [hStart(hLocation,1);hEnd(hLocation,1)];
        yOut = [hStart(hLocation,2);hEnd(hLocation,2)];
        
        % Remove the point that is goint to be joined into the combined
        %   line
        hStart(hLocation,:) = [];
        hEnd(hLocation,:) = [];
        while isPresent
            % Append the found point to the combined line
            xOut = [vEnd(vLocation,1); xOut];
            yOut = [vEnd(vLocation,2); yOut];
            currentStart = vEnd(vLocation,:);
            
            % Remove the point that is goint to be joined into the combined
            %   line
            vStart(vLocation,:) = [];
            vEnd(vLocation,:) = [];
            
            [isPresent,hLocation] = ismember(currentStart,hEnd,'rows');
            if isPresent
                currentStart = hStart(hLocation,:);

                % Append the found point to the combined line
                xOut = [hStart(hLocation,1); xOut];
                yOut = [hStart(hLocation,2); yOut];

                % Remove the point that is goint to be joined into the combined
                %   line
                hStart(hLocation,:) = [];
                hEnd(hLocation,:) = [];

                [isPresent,vLocation] = ismember(currentStart,vStart,'rows');
            end%if isPresent
        end%while isPresent
        
        out(row,:) = {xOut,yOut};
        row = row + 1;
    else
        ii = ii + 1;
    end%any(isPresent)
end%while(ii <= length(hStart))

% Add all of the leftover horizontal lines to the output cell
for ii = 1:length(hStart)
    row = row + 1;
    out(row,1) = {[hStart(ii,1);hEnd(ii,1)]};
    out(row,2) =  {[hStart(ii,2);hEnd(ii,2)]};
end%ii = 0:length(hStart)

% Add all of the leftover vertical lines to the output cell
for ii = 1:length(vStart)
    row = row + 1;
    out(row,1) = {[vStart(ii,1);vEnd(ii,1)]};
    out(row,2) =  {[vStart(ii,2);vEnd(ii,2)]};
end%ii = 0:length(vStart)

end%combineLines
