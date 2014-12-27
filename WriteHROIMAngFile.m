function WriteHROIMAngFile(AngFilePath,OutputFilePath,phi1List,PhiList,phi2List,SSE)
%WRITEHROIMANGFILE
%WriteHROIMAngFile(AngFilePath,OutputFilePath,phi1List,PhiList,phi2List,SSE)
%Replaces Euler angle and IQ data in the .ang file with new HROIM Euler  
%angles and IQ with the SSE (HROIM per-point quality measure)

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
    fprintf(fout,'%1.5f   %1.5f   %1.5f  %s %5g %s \n', ...
        phi1List(i),PhiList(i), phi2List(i), ...
        curline(30:63),SSE{i},curline(72:end));
    curline=fgetl(fin);
end
fclose(fin);
fclose(fout);

