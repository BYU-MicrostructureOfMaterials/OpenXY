function Image = ReadEBSDImage(ImagePath, ImageName, Filter, DoCropSquare)
%READEBSDIMAGE  Reads in an image of any file type and performs cropping or
%filtering as desired.
%ImagePath - either just the file path or the file path+name.
%If just two variables are passed in, ImagePath is assumed to be
%the full path and filename.
%Filter - a 1 by 4 array of numbers for a band-pass filter
%(custimfilt). Can be set to 0 or [0 0 0 0] or left out of the input
%for no filtering.
%DoCropSquare - Default is to crop any images that are rectangular to 
%make them square (DoCropSquare = 1)
%Binning is an integer input that reduces the image size by binning n by n
%pixels as 1 pixel. Binning = 2, is 2 by 2 binning - currently just comment
%this in to use it, and comment out to turn off.

%Output
%Image, a filtered grayscale image
%(RGB images are all converted to gray)
%If a file does not exist, the output image is set to


if nargin == 3
    ImagePath = [ImagePath ImageName];
    DoCropSquare = 1;
elseif nargin == 2
    
    if isnumeric(ImageName)
        Filter = ImageName;
    else
        ImagePath = [ImagePath ImageName];
    end
    
    DoCropSquare = 1;
elseif nargin ~= 4
    DoCropSquare = 1;
    if nargin == 0
        ImageName = ''; ImagePath = '';
        [ImageName,ImagePath] = uigetfile('*.*');
        ImagePath = [ImagePath ImageName];
    end

end

if ~exist(ImagePath,'file')
    
    Image = [];
    disp(['Error reading : ' ImagePath])
    %warndlg('Error reading EBSD Image', 'Warning in ReadEBSDImage.m','replace');
    return;
end

%disp(['Reading: ' ImagePath])
try
    Image = imread(ImagePath);
catch
    Image = [];
    disp(['Error reading : ' ImagePath])
end
%disp(['Success: ' ImagePath])
Image = single(Image);
if ndims(Image) == 3
    Image = sum(single(Image),3)/3;
end

% DTF moved this in front of the filter 7/2/14 ***** it was failing in the
% filter for non square image - note - how does this affect the phosphor
% size and PC if we crop the image???????
if DoCropSquare %Default setting is to do this
    %Crop if image is not square
    if size(Image,1) ~= size(Image,2)
        Image = CropSquare(Image);
    end
end


if exist('Filter','var')
    if any(Filter) %if any of the elements of Filter are nonzero
        Image = custimfilt(Image,Filter(1),Filter(2),Filter(3),Filter(4));
    end
end

%% Temporary binning code to test something. Don't leave in uncommented.
% if exist('Binning','var')
%     if ~isempty(Binning)

%         Binning = 3;
%         [xsize,ysize] = size(Image);
%         DownSampled = Image([1:Binning:xsize],[1:Binning:ysize]); 
%         Image = DownSampled;
        
%     end
% end




