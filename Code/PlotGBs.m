function PlotGBs(GrainMap,mapsize,Type)
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

%Convert to Map
if nargin > 1
    GrainMap = vec2map(GrainMap,mapsize(1),Type);
end

%Line Width
lw = 2;

%Horizontal Boundaries
diffMap = diff(GrainMap,1,1);
[row,col] = find(diffMap);
%imagesc(GrainMap)
hold on
plot([col-.5 col+0.5]',([row row]+0.5)','k','LineWidth',lw)

%Vertical
diffMap = diff(GrainMap,1,2);
[row,col] = find(diffMap);
plot(([col col]+0.5)',[row-.5 row+.5]','k','LineWidth',lw)