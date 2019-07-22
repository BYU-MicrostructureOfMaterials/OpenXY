classdef ImagepatternProvider < patterns.PatternProvider
    
    properties
        imSize
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
            pattern = mean(rawIm, 3);
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

