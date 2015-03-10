function ResizeScan()
[filename filepath] = uigetfile('*.ang','Select .ang File');
AngFilePath = fullfile(filepath,filename);
%AngFilePath = 'K:\DROBO SHARED\TSL Scans of clear steel morphology\Steel Ferrite-Martensite 40000X w 1x1 Pats.ang';
[SquareFileVals ScanParams] = ReadAngFile(AngFilePath);

%Extract variables from Ang Files
ScanLength = size(SquareFileVals{1},1);       
Angles1 = SquareFileVals{1};
Angles2 = SquareFileVals{2};
Angles3 = SquareFileVals{3};
XData = SquareFileVals{4};
YData = SquareFileVals{5};
IQ = SquareFileVals{6};
SSE = SquareFileVals{7};
Nx = length(unique(XData));
Ny = length(unique(YData));

%Copy variables into correctly sized matrices
Angles1New = reshape(Angles1,Nx,Ny);
Angles2New = reshape(Angles2,Nx,Ny);
Angles3New = reshape(Angles3,Nx,Ny);
XDataNew = reshape(XData,Nx,Ny);
YDataNew = reshape(YData,Nx,Ny);
IQNew = reshape(IQ,Nx,Ny)';
SSENew = reshape(SSE,Nx,Ny);

%Location Selection GUI
XStep = XData(2)-XData(1);
YStep = YData(YData > 0);
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
        elseif isempty(button) && (npoints == 1) && (~isempty(X)) %RETURN key is pressed
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
SSENew = SSENew(X(1):X(2),Y(1):Y(2));

%Reshape into vector arrays
Angles1New = Angles1New(:);
Angles2New = Angles2New(:);
Angles3New = Angles3New(:);
XDataNew = XDataNew(:);
YDataNew = YDataNew(:);
SSENew = SSENew(:);
SSENew = num2cell(SSENew);

[outpath, outname, outext] = fileparts(AngFilePath);
OutputPath = [outpath filesep outname '-Resize' outext];

%Write Ang File
fin=fopen(AngFilePath,'r');
fout=fopen(OutputPath,'wt+');
curline=fgetl(fin);
fprintf(fout,'%s\n',curline);
curline=fgetl(fin);
while curline(1)=='#'
    fprintf(fout,'%s\n',curline);
    curline=fgetl(fin);
    while numel(curline)==0
        fprintf(fout,'%s\n',curline);
        curline=fgetl(fin);
    end
end

for i=1:length(Angles1New)
    C = textscan(curline,'%f');
    C = C{1};
    fprintf(fout,'%1.5f\t %1.5f %1.5f %1.5f %1.5f %5.1f\t %1.3f %i %i %1.3f \n', ...
        Angles1New(i), Angles2New(i), Angles3New(i), XDataNew(i), YDataNew(i), C(6), ...
        SSENew{i}, C(8), C(9), C(10));
    curline=fgetl(fin);
end
fclose(fin);
fclose(fout);
end