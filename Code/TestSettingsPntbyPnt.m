function TestSettingsPntbyPnt(Settings,MainGUI)

%% Get Reference Image Names
if ~strcmp(Settings.HROIMMethod,'Simulated')&& ~isfield(Settings,'RefImageNames')
    RefImageInd = Settings.RefImageInd;
    if RefImageInd~=0
        datalength = Settings.ScanLength;
        Settings.RefImageNames = cell(datalength,1);
        Settings.RefImageNames(:)= Settings.ImageNamesList(RefImageInd);
        Settings.Phi1Ref(1:datalength) = Settings.Angles(RefImageInd,1);
        Settings.PHIRef(1:datalength) = Settings.Angles(RefImageInd,2);
        Settings.Phi2Ref(1:datalength) = Settings.Angles(RefImageInd,3);
        Settings.RefInd(1:datalength)= RefImageInd;
    else
        if strcmp(Settings.GrainRefImageType,'Min Kernel Avg Miso')
            [Settings.RefImageNames, Settings.Phi1Ref, ...
                Settings.PHIRef, Settings.Phi2Ref, Settings.RefInd] = GetRefImageNames(Settings.ImageNamesList, ...
                {Settings.Angles;Settings.IQ;Settings.CI;Settings.Fit}, Settings.grainID, Settings.KernelAvgMisoPath);
        else
            [Settings.RefImageNames, Settings.Phi1Ref, ...
                Settings.PHIRef, Settings.Phi2Ref, Settings.RefInd] = GetRefImageNames(Settings.ImageNamesList, ...
                {Settings.Angles;Settings.IQ;Settings.CI;Settings.Fit}, Settings.grainID);
        end
    end  
end

%% Set up Variables

Settings.ROISize = round((Settings.ROISizePercent * .01)*Settings.PixelSize);

if ~isfield(Settings,'XStar')
    disp('No PC calibration at all')
    %Default Naive Plane Fit
    Settings.XStar(1:Settings.ScanLength) = Settings.ScanParams.xstar-Settings.XData/Settings.PhosphorSize;
    Settings.YStar(1:Settings.ScanLength) = Settings.ScanParams.ystar+Settings.YData/Settings.PhosphorSize*sin(Settings.SampleTilt);
    Settings.ZStar(1:Settings.ScanLength) = Settings.ScanParams.zstar+Settings.YData/Settings.PhosphorSize*cos(Settings.SampleTilt);
end

n = Settings.Nx;
m = Settings.Ny;

if strcmp(Settings.ScanType,'Square')
    iqRS = reshape(Settings.IQ,n,m)';
    indi = 1:1:m*n;
    indi = reshape(indi, n,m)';
    if m == 1 %Lines Scans
        iqRS = repmat(iqRS,floor(Settings.ScanLength/4),1);
    end
else
    NumColsEven = n-1;
    NumColsOdd = n;
    indi = 1:length(Settings.IQ);
    indi = Hex2Array(indi,NumColsOdd,NumColsEven);
    iqRS = Hex2Array(Settings.IQ,NumColsOdd,NumColsEven);
end

StdDev = std(iqRS(:));
Mean = mean(iqRS(:));
Limits(1) = Mean - 3*StdDev;
Limits(2) = Mean + 3*StdDev;

Settings.DoShowPlot = 1;

%% Open GUI and Run Test

button = 1;

figure(100);
figure(101);
while(button==1)
    
    figure(99);
    imagesc(iqRS)
    axis image
    caxis(Limits)
    colormap('jet')
    title({'\fontsize{14} Select a point to calculate the deformation tensor','\fontsize{10} Right-click to exit'},'HorizontalAlignment','center')
    
    figure(99)
    [x,y, button] = ginput(1);
    if button~=1
        break;
    end
    pos = get(figure(99),'Position');
    
    x = round(x); y = round(y);
    if x < 0; x = 1; end;
    if y < 0; y = 1; end;
    if x > n; x = n; end;
    if y > m; y = m; end;
    
    ind = indi(y,x);

    set(figure(100),'Position',[pos(1)-pos(3)/2-10 pos(2)-pos(4) - 100 pos(3) pos(4)])
    set(figure(101),'Position',[pos(1)+pos(3)/2+10 pos(2)-pos(4) - 100 pos(3) pos(4)])
    
    profile on
    tic
    [F g U SSE] = GetDefGradientTensor(ind,Settings,Settings.Phase{ind});
    toc
    profile viewer
    
    set(figure(100),'Position',[pos(1)-pos(3)/2-10 pos(2)-pos(4) - 100 pos(3) pos(4)])
    set(figure(101),'Position',[pos(1)+pos(3)/2+10 pos(2)-pos(4) - 100 pos(3) pos(4)])
   
    F
    g
    U
    SSE
    
    Settings.ImageNamesList{ind}


    
end

%Close figures
close(findall(0,'Type','Figure','number',99,'-or','number',100,'-or','number',101))

%Bring up MainGUI again
if nargin == 2
    figure(MainGUI)
end

