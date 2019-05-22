function [ImageNamesList] = GetImageNamesList(firstImagename, scanFormat, scanLength, dimensions, startLocation, steps)
%GETIMAGENAMESLIST
%ImageNamesList = GetImageNamesList(ScanFormat, ScanLength, Dimensions, firstImagename, XStep, YStep)
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
[path, ImageName, ext] = fileparts(firstImagename);

%Split up input data
NumColumns = dimensions(1);
NumRows = dimensions(2);
X0 = startLocation(1);
Y0 = startLocation(2);
XStepData = steps(1);
YStepData = steps(2);
ImageNamesList = cell(scanLength,1);

% Recognize & parse unprocessed images from AZtec
if strcmp(ImageName, '0_0')
    count = 1;
    for j=0:NumRows-1 %Which is inner, which is outer?
        for i=0:NumColumns-1
            ImageNamesList{count} = fullfile(path,[num2str(j) '_' num2str(i) ext]);
            count = count + 1;
        end
    end
    return;
end

%Capture the parts of the image with a regular expression
pattern = ['^(?<namePart>.+)_'...
    '(?<numberPart>x\d+y\d+|r\d+c\d+|\d+)$'];
matches = regexp(ImageName, pattern, 'names');
namePart = matches.namePart;
numberPart = matches.numberPart;
if isempty(namePart) || isempty(numberPart)
    % Throw descriptive error
end

preStr = [namePart '_'];
endStr = '';

if isstrprop(numberPart(1), 'digit') % Serial naming convention
    
    %Get number info
    numberLength = length(numberPart);
    Xval = str2double(numberPart);
    numFormat = ['%0' num2str(numberLength) 'd'];
    
    %Check Starting number for resized scans (not finished)
    if size(dimensions,1) == 2
        col = startLocation(1)/XStepData+1;
        row = startLocation(2)/YStepData;
        Index = col + row*dimensions(2,1);
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
    
    %Check starting position for line scans
    if NumRows == 1 
        Index = startLocation(1)/XStepData+1;
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
    for i = 1:scanLength
        ImageNamesList{i} = fullfile(path,[preStr sprintf(numFormat,Xval+i-1) endStr ext]);
    end
    
    
else %xy or rc naming
    if strcmp(numberPart(1), 'x')
        rcNaming = false;
        pattern = '^x(?<x>\d+)y(?<y>\d+)$';
        preStr = [preStr 'x'];
        midStr = 'y';
    else
        rcNaming = true;
        pattern = '^r(?<x>\d+)c(?<y>\d+)$';
        preStr = [preStr 'r'];
        midStr = 'c';
    end
    matches = regexp(numberPart, pattern, 'names');
    
    Xval = str2double(matches.x);
    Yval = str2double(matches.y);
    
    %%% Determine Naming Scheme
    
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
    
    %Uneven OIM Naming
    uneven = false;
    if TimesFactor == 0
        for i = 0:7
            testname = fullfile(path,[preStr num2str(XStepData*(10^i)-1) midStr num2str(YStepData*(10^i)-1) endStr ext]);
            testname2 = fullfile(path,[preStr num2str(2*XStepData*(10^i)-1) midStr num2str(2*YStepData*(10^i)-1) endStr ext]);
            if exist(testname,'file') && exist(testname2,'file')
                TimesFactor = 10^i;
                uneven = true;
                break;
            end
        end
    end
    
    %Hexagonal Scans
    RoundFactor = 0;
    if strcmp(scanFormat,'Hexagonal')
        if TimesFactor == 0
            for i = 0:7
                testname = fullfile(path,[preStr num2str(XStepData*(10^i)) midStr num2str(0) endStr ext]);
                if exist(testname,'file')
                    TimesFactor = 10^i;
                    break;
                end
            end
            for i = 0:7
                testname = fullfile(path,[preStr num2str(XStepData*TimesFactor) midStr num2str(floor(YStepData*TimesFactor*10^i)/10^i) endStr ext]);
                testname2 = fullfile(path,[preStr num2str(XStepData*TimesFactor/2) midStr num2str(floor(YStepData*TimesFactor/2*10^i)/10^i) endStr ext]);
                if exist(testname,'file') && exist(testname2,'file')
                    RoundFactor = 10^i;
                    break;
                end
            end
        end
    end
    
    X0 = X0 * TimesFactor;
    Y0 = Y0 * TimesFactor;
    XStepData = XStepData * TimesFactor;
    YStepData = YStepData * TimesFactor;
    
    if TimesFactor == 0
        error('Couldn''t parse Image Names')
    end

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
    switch scanFormat
        case 'Square'
            for i = 1:scanLength
                X = mod(i-1,NumColumns)*NameXStep-uneven;
                Y = floor((i-1)/NumColumns)*NameYStep-uneven;
                if X < 0; X = 0; end
                if Y < 0; Y = 0; end
                if rcNaming
                    ImageNamesList{i} = fullfile(path,[preStr num2str(NameY+Y) midStr num2str(NameX+X) endStr ext]);
                else
                    ImageNamesList{i} = fullfile(path,[preStr num2str(NameX+X) midStr num2str(NameY+Y) endStr ext]);
                end
            end
        case 'Hexagonal'
            NumColsOdd = ceil(dimensions(1)); % settings.Nx is the same as NumColsOdd, so this should not be divided by 2 DTF Jul 27 17
            NumColsEven = NumColsOdd-1;
            i = 1;
            for Y = 0:NumRows-1
                if mod(Y,2) %Even
                    for X = 0:NumColsEven-1
                        if rcNaming
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameY+Y*NameYStep) midStr num2str(NameX+X*NameXStep) endStr ext]);
                        else
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameX+X*NameXStep+NameXStep/2) midStr num2str(floor((NameY+Y*NameYStep/2)*RoundFactor)/RoundFactor) endStr ext]);
                        end 
                        i = i + 1;
                    end
                else
                    for X = 0:NumColsOdd-1
                        if rcNaming
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameY+Y*NameYStep) midStr num2str(NameX+X*NameXStep) endStr ext]);
                        else
                            ImageNamesList{i} = fullfile(path,[preStr num2str(NameX+X*NameXStep) midStr num2str(floor((NameY+Y*NameYStep/2)*RoundFactor)/RoundFactor) endStr ext]);
                        end 
                        i = i + 1;
                    end
                end
            end
    end
end
end
