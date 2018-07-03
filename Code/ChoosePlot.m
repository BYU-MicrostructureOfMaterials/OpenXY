function [im,sel] = ChoosePlot(mapsize,IQ,Angles)
if nargin == 1
   Settings = mapsize;
   mapsize = [Settings.Nx Settings.Ny];
   IQ = Settings.IQ(Settings.Inds);
   Angles = Settings.Angles(Settings.Inds,:);
end

%Determine ScanType
Nx = mapsize(1);
Ny = mapsize(2);
ScanType = FindScanType(mapsize,length(IQ));

%Convert angles to gmat
g = euler2gmat(Angles);

%Ask image type
if nargin == 1
    sel = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Misorientation','Image Quality');
else
    sel = questdlg('Select Image to Display','Resize Scan','Image Quality','IPF','Image Quality');
end
if isempty(sel)
    error('OpenXY:ChoosePlot:NoSelectionMade',...
        'No selection made during call to ChoosePlot!');
end
if strcmp(sel,'Image Quality')
    if strcmp(ScanType,'Square')
        im = reshape(IQ,Nx,Ny)';
    elseif strcmp(ScanType,'Hexagonal')
        im = Hex2Array(IQ,mapsize(1));
    end
elseif strcmp(sel,'IPF')
    im = PlotIPF(g,[Nx Ny],ScanType,0);
    
elseif strcmp(sel,'Misorientation')
    im = makeMisoMap(Settings);
end