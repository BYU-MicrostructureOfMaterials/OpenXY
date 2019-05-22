classdef ImagepatternProvider < patterns.PatternProvider
    
    properties (Access = private)
        imageNames
        scanFormat
        scanLength
        dimensions
        startLocation
        steps
    end
    
    methods
        function obj = ImagepatternProvider(...
                firstImagename, scanFormat, scanLength,...
                dimensions, startLocation, steps)
            
            info = imfinfo(firstImageName);
            obj@patterns.PatternProvider(...
                firstImageName, min(info.Width, info.Height));
            
            obj.imageNames = obj.getImagenamesList(...
                firstImagename,...
                scanFormat,...
                scanLength,...
                dimensions,...
                startLocation,...
                steps);
            
            obj.scanFormat = scanFormat;
            obj.scanLength = scanLength;
            obj.dimensions = dimensions;
            obj.startLocation = startLocation;
            obj.steps = steps;
        end
        
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
            pattern = imread(obj.imageNames{index});
        end
    end
    
    methods (Static)
        function obj = restore(loadStruct)
            obj = pattterns.ImagepatternProvider(...
                loadStruct.fileName,...
                loadStruct.scanFormat,...
                loadStruct.scanLength,...
                loadStruct.dimensions,...
                loadStruct.startLocation,...
                loadStruct.steps);
        end
        
        imageNames = getImagenamesList(firstImagename, scanFormat, scanLength, dimensions, startLocation, steps)
    end
end

