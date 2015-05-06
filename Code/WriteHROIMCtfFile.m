function WriteHROIMCtfFile(CtfFilePath,OutputFilePath,phi1List,PhiList,phi2List,SSE)
%WRITEHROIMCTFFILE
%WriteHROIMCtfFile(CtfFilePath,OutputFilePath,phi1List,PhiList,phi2List,SSE)
%Replaces Euler angle and IQ data in the .ctf file with new HROIM Euler  
%angles and IQ with the SSE (HROIM per-point quality measure)

%Write corrected version of the .ang file
fin=fopen(CtfFilePath,'r');
fout=fopen(OutputFilePath,'wt+');
curline=fgetl(fin);
fprintf(fout,'%s\n',curline);
curline=fgetl(fin);
while isempty(str2num(curline))
    fprintf(fout,'%s\n',curline);
    curline=fgetl(fin);
end

for i=1:length(phi1List)
    C = textscan(curline,'%f');
    C = C{1};
    fprintf(fout,'%i %#.5g %#.5g %i %i %#.5g %#.5g %#.5g %#.5g %i %i \n', ...
        C(1), C(2), C(3), C(4), ...
        SSE{i}, phi1List(i), PhiList(i), phi2List(i),...
        C(9),C(10),C(11));
    curline=fgetl(fin);
end
fclose(fin);
fclose(fout);
