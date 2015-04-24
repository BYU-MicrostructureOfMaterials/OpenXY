%Fast reading of OIM Grain files of any size. 
%Jay Basinger March 31,2011
 
function [GrainFileVals FileName FilePath ] = ReadGrainFile(FilePath,FileName)
%Used for OIM .txt Grain files of the first type (based on OIM Analysis 6
%and earlier)

%Either leave the input blank, and a text dialog box will appear, or
%if the file and pathname are known, pass those in.

if nargin == 1
    fid = fopen(FilePath);
elseif nargin == 2
    fid = fopen([FilePath FileName]);
else
    [FileName FilePath] = uigetfile('*.txt','grain file');
    fid = fopen([FilePath FileName]);
end

disp('Reading in the grain file . . . ')


tline = '#';
while ~feof(fid)
    if strcmp(tline(1),'#') == 1
        
        tline = fgetl(fid);       
        
    else
        
        position = ftell(fid);
        status = fseek(fid, -length(tline)-2, 'cof');
        if status == -1
           errordlg('Error reading grainfile','Error')
           return;
        end
        GrainFileVals = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %s %s %s'); % commented out 5/15 for 11 column version
        
        size(GrainFileVals{1},1);

        for i=1:size(GrainFileVals{1},1) % commented out 5/15 for 11 column version
            
            GrainFileVals{11}(i)= strcat(GrainFileVals{11}(i),GrainFileVals{12}(i),GrainFileVals{13}(i));

        end
        disp(unique(GrainFileVals{11}(:)));
        GrainFileVals{13}=[];
        GrainFileVals{12}=[];

    end
end

fclose(fid);