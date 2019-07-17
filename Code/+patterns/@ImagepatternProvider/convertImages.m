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

imNames = obj.imageNames;
firstIm = imread(imNames{1});

imSize = size(firstIm);
version = 1;
width = imSize(1);
height = imSize(2);

switch ndims(firstIm)
    case 2
        flatten = @(im) im;
    case 3
        if all(all(firstIm(:, :, 1) == firstIm(:, :, 2))) && ...
                all(all(firstIm(:, :, 2) == firstIm(:, :, 3))) 
            flatten = @(im) squeeze(im(:, :, 1));
            
        else
            flatten = @(im) cast(mean(im, 3), 'like', im);
        end
    otherwise
        error(['Images have too many dimensions!\'...
            'nExpected 2 or 3, but got %u in stead'], ndims(firstIm))
end



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

for file = imNames'
    im = imread(file{1});
    im = flatten(im);
    fwrite(fid, im', precision, 0, 'b');
end
end

