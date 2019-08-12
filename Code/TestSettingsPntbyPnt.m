function TestSettingsPntbyPnt(Settings,MainGUI)

%% Prep
Settings = HREBSDPrep(Settings);
Settings.doGif = false;
%% Plot Setup
n = Settings.Nx;
m = Settings.Ny;
try
[im,PlotType] = ChoosePlot(Settings);
catch ME
    if strcmp(ME.identifier, 'OpenXY:ChoosePlot:NoSelectionMade')
        return
    end
    rethrow(ME);
end
if ~isfield(Settings,'Resize')
    if strcmp(Settings.ScanType,'Square')
        indi = 1:1:m*n;
        indi = reshape(indi, n,m)';
        if m == 1 %Lines Scans
            im = repmat(im,floor(Settings.ScanLength/4),1);
        end
    elseif strcmp(Settings.ScanType,'Hexagonal')
        NumColsOdd = n;
        indi = 1:length(Settings.Inds);
        indi = Hex2Array(indi,NumColsOdd);
    end
else
    if strcmp(Settings.ScanType,'Square')
        indi = reshape(Settings.Inds, n,m)';
        if m == 1 %Lines Scans
            im = repmat(im,floor(Settings.ScanLength/4),1);
        end
    elseif strcmp(Settings.ScanType,'Hexagonal')
        error('TestSettingsPntbyPnt:UnfinishedFeature',...
        'Test feature not currently implemented for subscans of hexagonal scans')
    end
end

StdDev = std(im(:));
Mean = mean(im(:));
Limits(1) = Mean - 3*StdDev;
Limits(2) = Mean + 3*StdDev;

Settings.DoShowPlot = 1;
Settings.SinglePattern = 0;

%% Open GUI and Run Test
morepoints = true;
gb = false;

figure(100);
figure(101);
while(morepoints)
    
    figure(99);
    PlotScan(im,PlotType);
    if length(unique(Limits)) ~= 1
        caxis(Limits)
    end
    title({'\fontsize{14} Select a point to calculate the deformation tensor';'\fontsize{10}Scroll-click to select by index number';'\fontsize{10} Right-click to exit'},'HorizontalAlignment','center')
    if gb
        GrainMap = vec2map(Settings.grainID,Settings.Nx,Settings.ScanType);
        PlotGBs(GrainMap);
    end
    
    figure(99)
    [x,y, button] = ginput(1);
    if isempty(button)
        button = 0;
    end
    
    switch button
        case {1,2}
            if button == 1
                x = round(x); y = round(y);
                if x < 0; x = 1; end;
                if y < 0; y = 1; end;
                if x > n; x = n; end;
                if y > m; y = m; end;
                
                ind = indi(y,x);
            else
                input = inputdlg('Enter an Index Number');
                ind = str2double(input{1});
            end
            
            pos = get(figure(99),'Position');
            set(figure(100),'Position',[pos(1)-pos(3)/2-10 pos(2)-pos(4) - 100 pos(3) pos(4)])
            set(figure(101),'Position',[pos(1)+pos(3)/2+10 pos(2)-pos(4) - 100 pos(3) pos(4)])
            
            tic
            [F, g, U, SSE] = GetDefGradientTensor(ind,Settings,Settings.Phase{ind});
            toc
            
            set(figure(100),'Position',[pos(1)-pos(3)/2-10 pos(2)-pos(4) - 100 pos(3) pos(4)])
            set(figure(101),'Position',[pos(1)+pos(3)/2+10 pos(2)-pos(4) - 100 pos(3) pos(4)])
            
            F
            g
            U
            SSE
            
            
%{
        case 2
            gb = ~gb;
%}
        otherwise
            morepoints = false;
    end
    
        
end

%Close figures
close(findall(0,'Type','Figure','number',99,'-or','number',100,'-or','number',101))

%Bring up MainGUI again
if nargin == 2
    figure(MainGUI)
end
