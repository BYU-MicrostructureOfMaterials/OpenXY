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
    if isnan(str2double(d_line{i}));
        fmt = '%s';
    else
        fmt = '%f';
    end
    format = [format ' ' fmt];
end
filedata.format = format;

fclose(fid);
    