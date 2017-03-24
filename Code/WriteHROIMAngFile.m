function WriteHROIMAngFile(AngFilePath,OutputFilePath,phi1List,PhiList,phi2List,SSE)
%WRITEHROIMANGFILE
%WriteHROIMAngFile(AngFilePath,OutputFilePath,phi1List,PhiList,phi2List,SSE)
%Replaces Euler angle and IQ data in the .ang file with new HROIM Euler  
%angles and IQ with the SSE (HROIM per-point quality measure)

%If Output file is only a name, save in the same folder as the ang file
if isempty(fileparts(OutputFilePath))
    OutputFilePath = fullfile(fileparts(AngFilePath),OutputFilePath);
end

%Pass in angles as single vector
if nargin == 4
    SSE = PhiList;
    phi2List = phi1List(:,3);
    PhiList = phi1List(:,2);
    phi1List = phi1List(:,1);
end

%Write corrected version of the .ang file
fin=fopen(AngFilePath,'r');
fout=fopen(OutputFilePath,'wt+');
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


for i=1:length(phi1List)
    C = textscan(curline,'%f');
    C = C{1};
    fprintf(fout,'%1.5f\t %1.5f %1.5f %1.5f %1.5f %5.1f\t %1.3f %i %i %1.3f \n', ...
        phi1List(i),PhiList(i), phi2List(i), ...
        C(4), C(5), C(6),...
        SSE(i),C(8),C(9),C(10));
    curline=fgetl(fin);
end
fclose(fin);
fclose(fout);

