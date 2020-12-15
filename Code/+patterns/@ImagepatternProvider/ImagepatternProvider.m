classdef ImagepatternProvider < patterns.PatternProvider
    
    properties
        imSize double
    end
    
    properties (GetAccess = public, SetAccess = private)
        imageNames
    end
    
    properties (Access = private)
        scanFormat(1,:) char {mustBeMember(scanFormat, {'Hexagonal', 'Square',''})}
        scanLength(1,1) double
        dimensions(2,1) double
        startLocation(2,1) double
        steps(2,1) double
        readStyle(1,:) char...
            {mustBeMember(readStyle, {'Flat', 'Mean'})} = 'Mean'
    end
    
    methods
        function obj = ImagepatternProvider(...
                firstImageName, scanFormat, scanLength,...
                dimensions, startLocation, steps)
            
            firstImageName = char(firstImageName);
            
            info = imfinfo(firstImageName);
            obj@patterns.PatternProvider(...
                firstImageName, min(info.Width, info.Height));
            
            obj.scanFormat = scanFormat;
            obj.scanLength = scanLength;
            obj.dimensions = dimensions(:)';
            obj.startLocation = startLocation(:)';
            obj.steps = steps(:)';
            
            if isfield(info,'NumberOfSamples')
                if info.NumberOfSamples == 1
                    obj.readStyle = 'Flat';
                else
                    allMatch = true;
                    firstImage = imread(firstImageName);
                    for ii = 2:info.NumberOfSamples
                        allMatch = allMatch &&...
                            all(all(firstImage(:, :, 1) == firstImage(:, :, ii)));
                    end
                    if allMatch
                        obj.readStyle = 'Flat';
                    end
                end
            else
                obj.readStyle = 'Flat';
            end
            
            obj.imageNames = obj.getImageNamesList(...
                firstImageName,...
                scanFormat,...
                scanLength,...
                dimensions,...
                startLocation,...
                steps);
            im = obj.getPatternData(1);
            sz = size(im);
            obj.imSize = sz(1:2);
            
        end
        
        convertImages(obj, saveFile)
        
        function sobj = saveobj(obj)
            sobj = saveobj@patterns.PatternProvider(obj);
            sobj.imageNames = obj.imageNames;
            sobj.scanFormat = obj.scanFormat;
            sobj.scanLength = obj.scanLength;
            sobj.dimensions = obj.dimensions;
            sobj.startLocation = obj.startLocation;
            sobj.steps = obj.steps;
        end
    end
    
    methods (Access = protected)
        function pattern = getPatternData(obj, index)
            try
                rawIm = imread(obj.imageNames{index});
            catch except
                if strcmp(except.identifier,...
                        'MATLAB:imagesci:imread:fileDoesNotExist')
                    warning('OpenXY:ImageNotFound',...
                        ['File %s not found.\n'...
                        'Replacing with empty image'],...
                        obj.imageNames{index})
                    rawIm = zeros(obj.imSize);
                else
                    except.rethrow;
                end
            end
            switch obj.readStyle
                case 'Mean'
                    pattern = mean(rawIm, 3);
                case 'Flat'
                    pattern = squeeze(rawIm(:, :, 1));
            end
        end
    end
    
    methods (Static)
        function obj = restore(loadStruct)
            obj = patterns.ImagepatternProvider(...
                loadStruct.fileName,...
                loadStruct.scanFormat,...
                loadStruct.scanLength,...
                loadStruct.dimensions,...
                loadStruct.startLocation,...
                loadStruct.steps);
        end
        
        imageNames = getImageNamesList(firstImagename, scanFormat, scanLength, dimensions, startLocation, steps)
    end
end

