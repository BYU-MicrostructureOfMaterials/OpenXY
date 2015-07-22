function ResizeScan(ScanFilePath)
if nargin == 0
    [filename, filepath] = uigetfile({'*.ang;*.ctf','Scan Files'},'Select Scan File');
    if filename == 0
        return;
    end
    ScanFilePath = fullfile(filepath,filename);
end
%ScanFilePath = 'K:\DROBO SHARED\TSL Scans of clear steel morphology\Steel Ferrite-Martensite 40000X w 1x1 Pats.ang';
[~,~,ext] = fileparts(ScanFilePath);
[SquareFileVals, ScanParams] = ReadScanFile(ScanFilePath);

%Extract variables from Ang Files
Settings.Angles(:,1) = SquareFileVals{1};
Settings.Angles(:,2) = SquareFileVals{2};
Settings.Angles(:,3) = SquareFileVals{3};
Settings.XData = SquareFileVals{4};
Settings.YData = SquareFileVals{5};
Settings.IQ = SquareFileVals{6};
Settings.CI = SquareFileVals{7};
Settings.Fit = SquareFileVals{10};
Settings.ScanLength = size(SquareFileVals{1},1);

%Unique x and y
X = unique(Settings.XData);
Y = unique(Settings.YData);

%Number of steps in x and y
Nx = length(X); Settings.Nx = Nx;
Ny = length(Y); Settings.Ny = Ny;
Settings = CropScan(Settings);

%Copy variables into correctly sized matrices
Angles1New = reshape(Settings.Angles(:,1),Nx,Ny);
Angles2New = reshape(Settings.Angles(:,2),Nx,Ny);
Angles3New = reshape(Settings.Angles(:,3),Nx,Ny);
XDataNew = reshape(Settings.XData,Nx,Ny);
YDataNew = reshape(Settings.YData,Nx,Ny);
IQNew = reshape(Settings.IQ,Nx,Ny)';
CINew = reshape(Settings.CI,Nx,Ny);

%Location Selection GUI
XStep = Settings.XData(2)-Settings.XData(1);
YStep = Settings.YData(Settings.YData > 0);
YStep = YStep(1);
indi = 1:1:Nx*Ny;
indi = reshape(indi,Nx,Ny)';
selectfig = figure;
imagesc(IQNew);
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
        imagesc(IQNew)
        axis image
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

%Extract Sub-scan
Angles1New = Angles1New(X(1):X(2),Y(1):Y(2));
Angles2New = Angles2New(X(1):X(2),Y(1):Y(2));
Angles3New = Angles3New(X(1):X(2),Y(1):Y(2));
XDataNew = XDataNew(X(1):X(2),Y(1):Y(2));
YDataNew = YDataNew(X(1):X(2),Y(1):Y(2));
CINew = CINew(X(1):X(2),Y(1):Y(2));

%Reshape into vector arrays
Angles1New = Angles1New(:);
Angles2New = Angles2New(:);
Angles3New = Angles3New(:);
XDataNew = XDataNew(:);
YDataNew = YDataNew(:);
CINew = CINew(:);
CINew = num2cell(CINew);

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
for i=1:length(Angles1New)
    C = textscan(curline,'%f');
    C = C{1};
    if strcmp(ext,'.ang')
        fprintf(fout,'%1.5f\t %1.5f %1.5f %1.5f %1.5f %5.1f\t %1.3f %i %i %1.3f \n', ...
            Angles1New(i), Angles2New(i), Angles3New(i), XDataNew(i), YDataNew(i), C(6), ...
            CINew{i}, C(8), C(9), C(10));
    elseif strcmp(ext,'.ctf')
        fprintf(fout,'%i %#.5g %#.5g %i %i %#.5g %#.5g %#.5g %#.5g %i %i \n', ...
            C(1), XDataNew(i), YDataNew(i), C(4), ...
            CINew{i}, Angles1New(i), Angles2New(i), Angles3New(i),...
            C(9),C(10),C(11));
    end
    curline=fgetl(fin);
end
fclose(fin);
fclose(fout);
end