function [ImageNamesList IsNewOIMNaming] = GetImageNamesList(ScanFormat, ScanLength, Dimensions, FirstImagePath, XStep, YStep)
%GETIMAGENAMESLIST
%ImageNamesList = GetImageNamesList(ScanFormat, ScanLength, Dimensions, FirstImagePath, XStep, YStep)
%Returns a list of image names belonging to a scan, given the scan format,
%length, dimensions, and the path of the first image. XStep and YStep are
%currently not used, but may be in the future.
%Jay Basinger 5/10/2011

%Read EBSD images
%Determine the number of characters in the file extension
[path, ImageName, ext] = fileparts(FirstImagePath);
DotPosition = find(FirstImagePath=='.');
if length(DotPosition) > 1
    DotPosition = DotPosition(length(DotPosition));
end

DistFromEnd = length(FirstImagePath) - DotPosition;
if DistFromEnd ~= 3 && DistFromEnd ~= 4
    error('Had trouble reading in the file names')
end

NumColumns = Dimensions(1);
NumRows = Dimensions(2);

%Check to see if we have a new OIM naming scheme starting somewhere around OIM 6.2 or greater
IsNewOIMNaming = 1;
IsLineScan = 0;
NameParts = textscan(ImageName,'%s');
NameParts = NameParts{1};

%Looks for pairs of x,y or r,c that have numbers after them
for i = 1:length(NameParts)
    Xinds = strfind(NameParts{i},'x');
    Yinds = strfind(NameParts{i},'y');
    Rinds = strfind(NameParts{i},'r');
    Cinds = strfind(NameParts{i},'c');
    if (~isempty(Xinds) && ~isempty(Yinds))
        if (isstrprop(NameParts{i}(Xinds(end)+1),'digit')) && (isstrprop(NameParts{i}(Yinds(end)+1),'digit'))
            rcNaming = false;
            break;
        end
    elseif (~isempty(Rinds) && ~isempty(Cinds))
        if (isstrprop(NameParts{i}(Rinds(end)+1),'digit')) && (isstrprop(NameParts{i}(Cinds(end)+1),'digit'))
            Xinds = Rinds;
            Yinds = Cinds;
            rcNaming = true;
            break;
        end
    end
end
Xinds = Xinds(end); Yinds = Yinds(end);
PositionPart = NameParts{i};

%Break up the Position string around the position numbers
preStr = '';
for ii = 1:i-1
    preStr = [preStr NameParts{ii} ' '];
end
preStr = [preStr PositionPart(1:Xinds)];
i = Xinds + 1;
while isstrprop(PositionPart(i),'digit') || strcmp(PositionPart(i),'.')
    i = i + 1;
end
Xval = str2num(PositionPart(Xinds+1:i-1));
midStr = PositionPart(i:Yinds);
i = Yinds + 1;
while isstrprop(PositionPart(i),'digit') || strcmp(PositionPart(i),'.')
    i = i + 1;
    if i > length(PositionPart), 
        i = i - 1;
        break; 
    end
end
Yval = str2num(PositionPart(Yinds+1:i));
endStr = PositionPart(i+1:end);
%Find the next image file
for i = 1:NumColumns
    testname = fullfile(path,[preStr num2str(Xval+i) midStr num2str(Yval) endStr ext]);
    if exist(testname,'file')
        X2val = Xval + i;
        break;
    end
end
for i = 1:NumRows
    testname = fullfile(path,[preStr num2str(Xval) midStr num2str(Yval+i) endStr ext]);
    if exist(testname,'file')
        Y2val = Yval + i;
        break;
    end
end

%Determine multiplication factor between position in .ang file and position in image name
TimesFactor = 0;
for i = 1:5
    testname = fullfile(path,[preStr num2str(XStep*(10^i)) midStr num2str(YStep*(10^i)) endStr ext]);
    if exist(testname,'file')
        TimesFactor = 10^i;
        break;
    end
end
%Or look for sequential numbering
if TimesFactor == 0
    for i = 1:10
        testname = fullfile(path,[preStr num2str(i) midStr num2str(Yval) endStr ext]);
        if exist(testname,'file')
            TimesFactor = 1;
            XStep = i - Xval;
            break;
        end
    end
    for i = 1:10
        testname = fullfile(path,[preStr num2str(Xval) midStr num2str(i) endStr ext]);
        if exist(testname,'file')
            TimesFactor = 1;
            YStep = i - Yval;
            break;
        end
    end
end
XStep = XStep * TimesFactor;
YStep = YStep * TimesFactor;

%Create ImageNamesList
ImageNamesList = cell(ScanLength,1);
switch ScanFormat
    case 'Square'
        for i = 1:ScanLength
            X = mod(i-1,NumColumns)*XStep;
            Y = floor((i-1)/NumColumns)*YStep;
            if rcNaming
                ImageNamesList{i} = fullfile(path,[preStr num2str(Y) midStr num2str(X) endStr ext]);
            else
                ImageNamesList{i} = fullfile(path,[preStr num2str(X) midStr num2str(Y) endStr ext]);
            end
        end
    case 'Hexagonal'
        NumColsOdd = ceil(Dimensions(1)/2);
        NumColsEven = floor(Dimensions(1)/2);
        i = 1;
        for Y = 0:NumRows-1
            if mod(Y,2) %Even
                for X = 0:NumColsEven-1
                    if rcNaming
                        ImageNamesList{i} = fullfile(path,[preStr num2str(Y*YStep) midStr num2str(X*XStep) endStr ext]);
                    else
                        ImageNamesList{i} = fullfile(path,[preStr num2str(X*XStep) midStr num2str(Y*YStep) endStr ext]);
                    end 
                    i = i + 1;
                end
            else
                for X = 0:NumColsOdd-1
                    if rcNaming
                        ImageNamesList{i} = fullfile(path,[preStr num2str(Y*YStep) midStr num2str(X*XStep) endStr ext]);
                    else
                        ImageNamesList{i} = fullfile(path,[preStr num2str(X*XStep) midStr num2str(Y*YStep) endStr ext]);
                    end
                    i = i + 1;
                end
            end
        end
end
   
end