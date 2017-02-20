function ResizeScan(filename,filepath)
if nargin == 0
    [filename, filepath] = uigetfile({'*.ang;*.ctf','Scan Files'},'Select Scan File');
    if filename == 0
        return;
    end
elseif nargin == 1
    [filepath,filename,ext] = fileparts(filename);
    filename = [filename ext];
end
ScanFilePath = fullfile(filepath,filename);
[~,~,ext] = fileparts(ScanFilePath);

Settings = GetHROIMDefaultSettings;
Settings = ImportScanInfo(Settings,filename,filepath);
Nx = Settings.Nx;
Ny = Settings.Ny;

%Ask image type
[im, sel] = ChoosePlot([Nx,Ny],Settings.IQ,Settings.Angles);

%Location Selection GUI
XStep = Settings.XData(2)-Settings.XData(1);
YStep = Settings.YData(Settings.YData > 0);
YStep = YStep(1);
indi = 1:1:Nx*Ny;
indi = reshape(indi,Nx,Ny)';
selectfig = figure;
PlotScan(im,sel);
axis image
title('Press RETURN key to select area');


redo = 1;
X = [];
Y = [];
while redo
    Xind = [];
    Yind = [];
    npoints = 1;
    while (npoints < 3) && (redo)
        %Gets X,Y data from user
        [x,y, button] = ginput(1);
        if x > Nx
            x = Nx;
        elseif x < 1
            x = 1;
        end
        if y > Ny
            y = Ny;
        elseif y < 1
            y = 1;
        end
        if ~isempty(x)
            Xind(npoints) = round(x);
            Yind(npoints) = round(y);
            npoints = npoints + 1;
        elseif isempty(button) && (npoints == 1) && (~isempty(X)) %RETURN key is presed
            redo = 0;
            break;
        end   

        hold off
        PlotScan(im,sel)
        hold on
        plot(Xind,Yind,'kd','MarkerFaceColor','k');
    end
    if redo
        X(1) = min(Xind);
        X(2) = max(Xind);
        Y(1) = min(Yind);
        Y(2) = max(Yind);
        offset = 0.6;
        xbox = [X(1)-offset X(1)-offset; X(1)-offset X(2)+offset; X(1)-offset X(2)+offset; X(2)+offset X(2)+offset]';
        ybox = [Y(1)-offset Y(2)+offset; Y(1)-offset Y(1)-offset; Y(2)+offset Y(2)+offset; Y(1)-offset Y(2)+offset]';
        plot(xbox,ybox,'k','LineWidth',2)
    end
end
close(selectfig);


AngleMap = vec2map(Settings.Angles,Settings.Nx,Settings.ScanType);
XDataMap = vec2map(Settings.XData,Settings.Nx,Settings.ScanType);
YDataMap = vec2map(Settings.YData,Settings.Nx,Settings.ScanType);
CIMap = vec2map(Settings.CI,Settings.Nx,Settings.ScanType);
IQMap = vec2map(Settings.IQ,Settings.Nx,Settings.ScanType);
FitMap = vec2map(Settings.Fit,Settings.Nx,Settings.ScanType);

%Extract Sub-scan
AnglesNew = AngleMap(Y(1):Y(2),X(1):X(2),:);
XDataNew = XDataMap(Y(1):Y(2),X(1):X(2));
YDataNew = YDataMap(Y(1):Y(2),X(1):X(2));
CINew = CIMap(Y(1):Y(2),X(1):X(2));
IQNew = IQMap(Y(1):Y(2),X(1):X(2));
FitNew = FitMap(Y(1):Y(2),X(1):X(2));

%Reshape into vector arrays
AnglesNew = map2vec(AnglesNew);
XDataNew = map2vec(XDataNew);
YDataNew = map2vec(YDataNew);
CINew = map2vec(CINew);
IQNew = map2vec(IQNew);
FitNew = map2vec(FitNew);

[outpath, outname, outext] = fileparts(ScanFilePath);
OutputPath = [outpath filesep outname '-Resize' outext];

%Write Ang File
fin=fopen(ScanFilePath,'r');
fout=fopen(OutputPath,'wt+');
curline=fgetl(fin);
fprintf(fout,'%s\n',curline);
curline=fgetl(fin);
if strcmp(ext,'.ang')
    while curline(1)=='#'
        fprintf(fout,'%s\n',curline);
        curline=fgetl(fin);
        while numel(curline)==0
            fprintf(fout,'%s\n',curline);
            curline=fgetl(fin);
        end
    end
elseif strcmp(ext,'.ctf')
    while isempty(str2num(curline))
        fprintf(fout,'%s\n',curline);
        curline=fgetl(fin);
    end
end
for i=1:length(AnglesNew)
    C = textscan(curline,'%f');
    C = C{1};
    if strcmp(ext,'.ang')
        fprintf(fout,'%1.5f\t %1.5f %1.5f %1.5f %1.5f %5.1f\t %1.3f %i %i %1.3f \n', ...
            AnglesNew(i,1), AnglesNew(i,2), AnglesNew(i,3), XDataNew(i), YDataNew(i),IQNew(6), ...
            CINew(i), C(8), C(9), FitNew(10));
    elseif strcmp(ext,'.ctf')
        fprintf(fout,'%i %#.5g %#.5g %i %i %#.5g %#.5g %#.5g %#.5g %i %i \n', ...
            C(1), XDataNew(i), YDataNew(i), C(4), ...
            CINew{i}, AnglesNew(i,1), AnglesNew(i,2), AnglesNew(i,3),...
            C(9),C(10),C(11));
    end
    curline=fgetl(fin);
end
fclose(fin);
fclose(fout);
end