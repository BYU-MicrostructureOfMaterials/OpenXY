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
else
    commentchar = '';
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
            tmp = textscan(tline,'%s');
            filedata.cols = length(tmp{1});
        end
        datacnt = datacnt+ 1;
    end
end

filedata.datarows = datacnt - 1;
filedata.rows = datacnt + cnt;
fmt = '%f';
tmp = fmt;
for i = 1:filedata.cols-1
    tmp = [tmp ' ' fmt];
end
filedata.format = tmp;

fclose(fid);
    