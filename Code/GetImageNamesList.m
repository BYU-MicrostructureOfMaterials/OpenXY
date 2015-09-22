function [ImageNamesList] = GetImageNamesList(ScanFormat, ScanLength, Dimensions, FirstImagePath, StartLocation, Steps)
%GETIMAGENAMESLIST
%ImageNamesList = GetImageNamesList(ScanFormat, ScanLength, Dimensions, FirstImagePath, XStep, YStep)
%Returns a list of image names belonging to a scan, given the scan format,
%length, dimensions, and the path of the first image. XStep and YStep are
%currently not used, but may be in the future.
%Jay Basinger 5/10/2011

%Re-written by Brian Jackson 4/2015

%Assumptions:
%   Numberings are the last thing in the filename part
%   Format is either x-y pair, r-c pair, or a line scan
%   Line scan: Last set of numbers in filename is the incremental serial number

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

%Split up input data
NumColumns = Dimensions(1);
NumRows = Dimensions(2);
X0 = StartLocation(1);
Y0 = StartLocation(2);
XStepData = Steps(1);
YStepData = Steps(2);

%Set up parameters
IsSerial = true; %Image names are incrementally serialized
NameParts = textscan(ImageName,'%s');
NameParts = NameParts{1};
rcNaming = false;

%Looks for pairs of x,y or r,c that have numbers after them
for i = 1:length(NameParts)
    Xinds = strfind(NameParts{i},'x');
    Yinds = strfind(NameParts{i},'y');
    Rinds = strfind(NameParts{i},'r');
    Cinds = strfind(NameParts{i},'c');
    if (~isempty(Xinds) && ~isempty(Yinds))
        if (isstrprop(NameParts{i}(Xinds(end)+1),'digit')) && (isstrprop(NameParts{i}(Yinds(end)+1),'digit'))
            rcNaming = false;
            IsSerial = false;
            break;
        end
    elseif (~isempty(Rinds) && ~isempty(Cinds))
        if (isstrprop(NameParts{i}(Rinds(end)+1),'digit')) && (isstrprop(NameParts{i}(Cinds(end)+1),'digit'))
            Xinds = Rinds;
            Yinds = Cinds;
            rcNaming = true;
            IsSerial = false;
            break;
        end
    end
end

preStr = '';
midStr = '';
endStr = '';
for ii = 1:i-1
    preStr = [preStr NameParts{ii} ' '];
end
ImageNamesList = cell(ScanLength,1);

if IsSerial
    %Break up the Position string around the position numbers
    PositionPart = NameParts{end};
    i = length(PositionPart);
    if isempty(str2num(PositionPart(i)))
        while isempty(str2num(PositionPart(i)))
            i = i - 1;
        end
        endStr = PositionPart(i:end);
    end    
    ii = i;
    while ~isempty(str2num(PositionPart(ii)))
        if ii <= 1, break; end;
        ii = ii - 1;
    end
    preStr = [preStr PositionPart(1:ii)];
    
    %Get number info
    numberLength = i-ii;
    Xval = str2double(PositionPart(ii+1:i));
    numFormat = ['%0' num2str(numberLength) 'd'];
    
    %Check Starting number for resized scans
    if size(Dimensions,1) == 2
        col = StartLocation(1)/XStepData+1;
        row = StartLocation(2)/YStepData;
        Index = col + row*Dimensions(2,1);
        if Index ~= Xval
            testname = fullfile(path,[preStr sprintf(numFormat,Index) endStr ext]);
            if exist(testname, 'file')
                button = questdlg(['Accept "' testname '" as new First Image?'],'OpenXY');
                if strcmp(button,'Yes')
                    Xval = Index;
                else
                    error('Start Image Path doesn''t match data starting location');
                end
            else
                error('Start Image Path doesn''t match data starting location');
            end
        end
    end   

    %Write ImageNamesList
    for i = 1:ScanLength
        ImageNamesList{i} = fullfile(path,[preStr sprintf(numFormat,Xval+i-1) endStr ext]);
    end
        
else
    %Break up the Position string around the position numbers
    Xinds = Xinds(end); Yinds = Yinds(end);
    PositionPart = NameParts{i};
    
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
    
    %Determine multiplication factor between position in .ang file and position in image name
    TimesFactor = 0;
    IsIncremental = false;
    for i = 0:7
        testname = fullfile(path,[preStr num2str(XStepData*(10^i)) midStr num2str(YStepData*(10^i)) endStr ext]);
        if exist(testname,'file')
            TimesFactor = 10^i;
            break;
        end
    end
    %Or assume sequential numbering
    if rcNaming
        IsIncremental = true;
        TimesFactor = 1;
    end
    X0 = X0 * TimesFactor;
    Y0 = Y0 * TimesFactor;
    XStepData = XStepData * TimesFactor;
    YStepData = YStepData * TimesFactor;

%     %Find the next image file
%     for i = 1:NumColumns
%         testname = fullfile(path,[preStr num2str((Xval+i)*TimesFactor) midStr num2str(Yval*TimesFactor) endStr ext]);
%         if exist(testname,'file')
%             X2val = Xval + i;
%             NameXStep = X2val - Xval;
%             break;
%         end
%     end
%     for i = 1:NumRows
%         testname = fullfile(path,[preStr num2str(Xval*TimesFactor) midStr num2str((Yval+i)*TimesFactor) endStr ext]);
%         if exist(testname,'file')
%             Y2val = Yval + i;
%             NameYStep = Y2val - Yval;
%             break;
%         end
%     end

    %Validate Start Image/Location
    if IsIncremental
        NameX = floor(X0 / XStepData);
        NameY = floor(Y0 / YStepData);
        NameXStep = 1;
        NameYStep = 1;
    else
        NameX = X0;
        NameY = Y0;
        NameXStep = XStepData;
        NameYStep = YStepData;
    end
    if NameX ~= Xval || NameY ~= Yval %Xval comes from Image Name, NameX comes from Scan File
        if rcNaming
            testname = fullfile(path,[preStr num2str(NameY) midStr num2str(NameX) endStr ext]);
        else
            testname = fullfile(path,[preStr num2str(NameX) midStr num2str(NameY) endStr ext]);
        end
        if exist(testname, 'file')
            button = questdlg(['Accept "' testname '" as new First Image?'],'OpenXY');
            if ~strcmp(button,'Yes')
                error('Start Image Path doesn''t match data starting location');
            end
        else
            error('Start Image Path doesn''t match data starting location');
        end   
    end
    
    %Write ImageNamesList
    switch ScanFormat
        case 'Square'
            for i = 1:ScanLength
                X = mod(i-1,NumColumns)*NameXStep;
                Y = floor((i-1)/NumColumns)*NameYStep;
                if rcNaming
                    ImageNamesList{i} = fullfile(path,[preStr num2str(NameY+Y) midStr num2str(NameX+X) endStr ext]);
                else
                    ImageNamesList{i} = fullfile(path,[preStr num2str(NameX+X) midStr num2str(NameY+Y) endStr ext]);
                end
            end
        case 'Hexagonal'
            NumColsOdd = Dimensions(1);
            NumColsEven = Dimensions(1)-1;
            i = 1;
            for Y = 0:NumRows-1
                if mod(Y,2) %Even
                    for X = 0:NumColsEven-1
                        if rcNaming
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameY+Y*NameYStep) midStr num2str(NameX+X*NameXStep) endStr ext]);
                        else
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameX+X*NameXStep) midStr num2str(NameY+Y*NameYStep) endStr ext]);
                        end 
                        i = i + 1;
                    end
                else
                    for X = 0:NumColsOdd-1
                        if rcNaming
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameY+Y*NameYStep) midStr num2str(NameX+X*NameXStep) endStr ext]);
                        else
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameX+X*NameXStep) midStr num2str(NameY+Y*NameYStep) endStr ext]);
                        end 
                        i = i + 1;
                    end
                end
            end
    end
end
end