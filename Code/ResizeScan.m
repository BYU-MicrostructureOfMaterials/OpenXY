function ResizeScan()
%New Dimensions
NewX = 10;
NewY = 10;

[filename filepath] = uigetfile('*.ang','Select .ang File');
AngFilePath = fullfile(filepath,filename);
[SquareFileVals ScanParams] = ReadAngFile(fullfile(filepath,filename));

%Extract variables from Ang Files
ScanLength = size(SquareFileVals{1},1);       
Angles1 = SquareFileVals{1};
Angles2 = SquareFileVals{2};
Angles3 = SquareFileVals{3};
XData = SquareFileVals{4};
YData = SquareFileVals{5};
SSE = SquareFileVals{7};
Nx = length(unique(XData));
Ny = length(unique(YData));

%Copy variables into correctly sized matrices
Angles1New = reshape(Angles1,Nx,Ny);
Angles2New = reshape(Angles2,Nx,Ny);
Angles3New = reshape(Angles3,Nx,Ny);
XDataNew = reshape(XData,Nx,Ny);
YDataNew = reshape(YData,Nx,Ny);
SSENew = reshape(SSE,Nx,Ny);

%Extract Sub-scan
Angles1New = Angles1New(1:NewX,1:NewY);
Angles2New = Angles2New(1:NewX,1:NewY);
Angles3New = Angles3New(1:NewX,1:NewY);
XDataNew = XDataNew(1:NewX,1:NewY);
YDataNew = YDataNew(1:NewX,1:NewY);
SSENew = SSENew(1:NewX,1:NewY);

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