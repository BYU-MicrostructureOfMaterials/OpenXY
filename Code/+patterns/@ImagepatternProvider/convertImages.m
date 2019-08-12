function convertImages(obj, saveFile)
%CONVERTIMAGES convert images into an OIM uncompressed image file
%  Either pass an OpenXY settings struct and the location you would like to
%  save the pattern file, or call with no arguments and select an OpenXY
%  save and the save location in an interactive mode. Chosing a file with
%  the .up1 file extension will save the patterns in 8 bit mode, while .up2
%  will save them in 16 bit mode. If the patterns are in a different bit
%  depth, the saved patterns will be bit-shifted

if nargin == 1
    [file, path] = uiputfile({
        '*.up1', '8 bit images'
        '*.up2', '16 bit images'
        }, 'Select save location', 'patterns.up1');
    saveFile = fullfile(path, file);
end

[~, ~, ext] = fileparts(saveFile);
switch lower(ext)
    case '.up1'
        precision = 'uint8';
    case '.up2'
        precision = 'uint16';
    case ''
        return
    otherwise
        error('%s is not supported as a save file', ext)
end

info = imfinfo(obj.imageNames{1});
version = 1;
width = info.Width;
height = info.Height;

fid = fopen(saveFile, 'w');
whenDone = onCleanup(@() fclose(fid));

fwrite(fid, version, 'int');
fwrite(fid, width, 'int');
fwrite(fid, height, 'int');
offsetLocation = ftell(fid);
fwrite(fid, -1, 'int');
offset = ftell(fid);
fseek(fid, offsetLocation, 'bof');
fwrite(fid, offset, 'int');

N = length(obj.imageNames);
wb = UI_utils.singleThreadProgBar(N);
for ii = 1:N
    im = obj.getPatternData(ii);
    fwrite(fid, im', precision, 0, 'b');
    wb.update(ii);
end
end

