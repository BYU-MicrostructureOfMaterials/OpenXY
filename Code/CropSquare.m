function [ CroppedImage ] = CropSquare( Image )
%CROPSQUARE Crops an image to be square
%   Assumes the image is larger in the 2nd dimension
%   Moved from ReadEBSDImage.m
[MinSize, MinLoc] = min([size(Image,1) size(Image,2)]);
[MaxSize, MaxLoc] = max([size(Image,1) size(Image,2)]);
MidStart = (MaxSize - MinSize)/2;   %Is this ever a fraction?????******
newpic = Image(1:MinSize,MidStart:MinSize+MidStart-1); % assumes it's always 2nd dimension that is bigger *****
CroppedImage = newpic;
end

