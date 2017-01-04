function TestGeometryPntbyPnt(Settings,MainGUI)

%% Prep
Settings = HREBSDPrep(Settings);

%% Plot Setup
n = Settings.Nx;
m = Settings.Ny;
[im,PlotType] = ChoosePlot([n m],Settings.IQ(Settings.Inds),Settings.Angles(Settings.Inds,:));

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

StdDev = std(im(:));
Mean = mean(im(:));
Limits(1) = Mean - 3*StdDev;
Limits(2) = Mean + 3*StdDev;

%% Open GUI and Run Test
morepoints = true;
gb = false;

figure(100);
while(morepoints)
    
    figure(99);
    PlotScan(im,PlotType);
    caxis(Limits)
    title({'\fontsize{14} Select a point to calculate the deformation tensor';'\fontsize{10}Scroll-click to toggle grain boundaries';'\fontsize{10} Right-click to exit'},'HorizontalAlignment','center')
    if gb
        GrainMap = vec2map(Settings.grainID,Settings.Nx,Settings.ScanType);
        PlotGBs(GrainMap);
    end

    figure(99)
    
    if isempty(button)
        button = 0;
    end
    
    switch button
        case 1
            x = round(x); y = round(y);
            if x < 0; x = 1; end;
            if y < 0; y = 1; end;
            if x > n; x = n; end;
            if y > m; y = m; end;
            
            ind = indi(y,x);
            
            pos = get(figure(99),'Position');
            set(figure(100),'Position',[pos(1)-pos(3)/2-10 pos(2)-pos(4) - 100 pos(3) pos(4)])
            
            xstar = Settings.XStar(ind);
            ystar = Settings.YStar(ind);
            zstar = Settings.ZStar(ind);

            Av = Settings.AccelVoltage*1000; %put it in eV from KeV

            sampletilt = Settings.SampleTilt;

            elevang = Settings.CameraElevation;

            pixsize = Settings.PixelSize;
            Material = ReadMaterial(Settings.Phase{ind}); 
            if strcmp(Material.lattice,'cubic') %Decide how many bands to overlay
                numfam = 4;
            else
                numfam = 5;
            end
            paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl(1:numfam);Material.dhkl(1:numfam);Material.hkl(1:numfam,:)};
            
            g = euler2gmat(Settings.Angles(ind,1),Settings.Angles(ind,2),Settings.Angles(ind,3));
            
            I2 = ReadEBSDImage(Settings.ImageNamesList{ind},Settings.ImageFilter);
            figure(100); imagesc(I2); axis image; xlim([0 pixsize]); ylim([0 pixsize]); colormap('hot')
            genEBSDPatternHybridLineOverlay(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
            
            set(figure(100),'Position',[pos(1)-pos(3)/2-10 pos(2)-pos(4) - 100 pos(3) pos(4)])

            
            Settings.ImageNamesList{ind}
        case 2
            gb = ~gb;
        otherwise
            morepoints = false;
    end
    
        
end

%Close figures
% close(findall(0,'Type','Figure','number',99,'-or','number',100,'-or'))
close(findall(0,'Type','Figure','number',99,'-or','number',100,'-or','number',101))

%Bring up MainGUI again
if nargin == 2
    figure(MainGUI)
end
