function DislocationDensityPlot(Settings, alpha_data, cmin, cmax, doShowGB)
%DISLOCATIONDENSITYOUTPUT
%DislocationDensityOutput(Settings,Components, cmin, cmax, MaxMisorientation)
%code bits for this function taken from Step2_DisloDens_Lgrid_useF_2.m
%authors include: Collin Landon, Josh Kacher, Sadegh Ahmadi, and Travis Rampton
%modified for use with HROIM GUI code, Jay Basinger 4/20/2011
% format compact
% tic

%Calculate Dislocation Density
cmap = [0 0 0; parula];
data = Settings.data;

crange = cmax - cmin;
cOffset = crange / length(cmap);
colorAxis = [cmin - cOffset, cmax];

r = data.rows;%
c = data.cols;%

isLineScan = r == 1;

NColsOdd=[];
NColsEven=[];
if strcmp(Settings.ScanType,'Hexagonal')
    NColsOdd = c;
    NColsEven = c-1;
    leftside=1:c:Settings.ScanLength;
    rightside=NColsOdd:c:Settings.ScanLength;
    rightside=[rightside,c:c:Settings.ScanLength];
    rightside=sort(rightside);
    topside=rightside(end-1)+1:Settings.ScanLength;
end

alpha_total3 = alpha_data.alpha_total3;
alpha_total9 = alpha_data.alpha_total9;
alpha = alpha_data.alpha;

grainID = Settings.grainID;
scanSize = [Settings.Nx Settings.Ny];
scanType = Settings.ScanType;

    function drawPlot(map, plotTitle)
        if isLineScan
            map=repmat(map,length(map)/4,1); 
        end
        figure;imagesc(log10(abs(map)))
        title(plotTitle ,'fontsize', 14)
        axis image
        colormap(cmap)
        colorbar
        caxis(colorAxis)
        if doShowGB
            PlotGBs(grainID, ...
                scanSize, scanType)
        end
    end

if strcmp(Settings.ScanType,'Square') ||  strcmp(Settings.ScanType,'LtoSquare')
    if isfield(alpha_data,'misang')        
        ind = alpha_data.misang < 8.5;
    else
        ind = true(Settings.ScanLength,1);
    end
    ind = reshape(ind,[c r])';
    
    drawPlot(reshape(alpha(1,3,:), [c r])' .* ind, 'Alpha_1_3');
    drawPlot(reshape(alpha(2,3,:), [c r])' .* ind, 'Alpha_2_3');
    drawPlot(reshape(alpha(3,3,:), [c r])' .* ind, 'Alpha_3_3');
    drawPlot(reshape(alpha_total3, [c r])' .* ind, 'Alpha Total');
    
elseif strcmp(Settings.ScanType,'Hexagonal')
    Newdd = zeros(r,NColsEven);
    New13=Newdd;
    New23=Newdd;
    New33=Newdd;
    count=1;
    for rr = 1:r
        if bitget(abs(rr),1)~=0 %odd

            for cc = 1:NColsOdd
                Newdd(rr,cc) = alpha_total9(count);
                New13(rr,cc)=alpha(1,3,count);
                New23(rr,cc)=alpha(2,3,count);
                New33(rr,cc)=alpha(3,3,count);
                gid(rr,cc)=Settings.grainID(count);

                count = count + 1;
            end
        else
            for cc = 1:NColsEven
                Newdd(rr,cc) = alpha_total9(count);
                New13(rr,cc)=alpha(1,3,count);
                New23(rr,cc)=alpha(2,3,count);
                New33(rr,cc)=alpha(3,3,count);
                gid(rr,cc)=Settings.grainID(count);

                count = count + 1;
            end
        end
    end
    
    drawPlot(New13, 'Alpha_1_3');
    drawPlot(New23, 'Alpha_2_3');
    drawPlot(New33, 'Alpha_33');
    drawPlot((abs(New13)+abs(New23)+abs(New33))*3, 'Alpha 3 Term')
    drawPlot(Newdd, 'Alpha Total');
    
elseif strcmp(Settings.ScanType,'L')
    
    drawPlot(reshape(alpha(1,3,:),[c r])', 'Alpha_1_3');
    drawPlot(reshape(alpha(3,3,:),[c r])', 'Alpha_3_3');
    drawPlot(reshape(alpha_total3, [c r])', 'Alpha Total');
end
end
