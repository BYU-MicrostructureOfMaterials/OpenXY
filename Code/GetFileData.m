function filedata = GetFileData(FilePath, commentchar)
%Returns struct containing information about file format:
%.headersize gives number of header lines
%.cols gives number of data columns
%.datarows gives number of data rows
%.rows gives total number of rows in file
%.format gives format string to be used in functions such as textscan, to
%   read in columns of doubles
%Brian Jackson 11/6/2014

if nargin == 0
    [FileName, FilePath] = uigetfile();
    FilePath = [FilePath FileName];
    commentchar = inputdlg('Input comment character', 'GetFileData');
elseif nargin == 1
    commentchar = 1;
end

fid = fopen(FilePath);
cnt=0;
datacnt = 1;
while ~feof(fid)
    tline = fgetl(fid);
    
    if strcmp(tline(1),commentchar)
        cnt = cnt + 1;
    elseif (isempty(commentchar) || (nargin == 1)) && (isempty(str2num(tline)))
        cnt = cnt + 1;
    else
        if datacnt == 1
            filedata.headersize = cnt;
            d_line = textscan(tline,'%s');
            d_line = d_line{1};
            filedata.cols = length(d_line);
        end
        datacnt = datacnt+ 1;
    end
end

filedata.datarows = datacnt - 1;
filedata.rows = datacnt + cnt;
format = '';
for i = 1:filedata.cols
    if isnan(str2double(d_line{i}))
        fmt = '%s';
    else
        fmt = '%f';
    end
    format = [format ' ' fmt];
end

if strcmp(format(end),'s')
    
    %If any '%s' at end of format string, find out how many
    typeLocations = ismember(format,'fs');
    types = format(typeLocations);
    
    sNum = 0;
    loc = length(types);
    while loc>0 && strcmp(types(loc),'s')
        sNum = sNum + 1;
        loc = loc-1;
    end
    
    % Concatenate any strings at the end
    inds = find(ismember(format,'s')); %inds -> list of locations in format that are 's'
    keyInd = inds(length(inds)-sNum+1);%keyInd -> location of first 's' that is part of group of '%s' at the end of format
    format = [format(1:keyInd-1) '[^\n]'];
    
end


filedata.format = format;

fclose(fid);
    