classdef H5PatternProvider < patterns.PatternProvider
    %H5PATTERNPROVIDER Provides patterns from an HDF5 file
    
    properties
        imSize
    end
    
    properties(Access = private)
        patternPath(1,:) char
        patternSize
        
        hexOffset
    end
    
    methods
        function obj = H5PatternProvider(fileName)
            fileInfo = h5info(fileName);
            assert(length(fileInfo.Groups) == 1,...
                ['More than one root group in the HDF5 file %s,\n'...
                'could not determine correct path to patterns.'], fileName);
            rootGroupName = fileInfo.Groups.Name;
            dataPath = [rootGroupName '/EBSD/Data'];
            patternPath = [dataPath '/Pattern'];
            patternInfo = h5info(fileName, patternPath);
            patternSize = patternInfo.ChunkSize;
            
            obj@patterns.PatternProvider(fileName, max(patternSize));
            obj.patternPath = patternPath;
            obj.patternSize = patternSize;
            obj.imSize = patternSize(1:2);
            
            gridTypePath = [rootGroupName '/EBSD/Header/Grid Type'];
            gridType = h5read(fileName, gridTypePath);
            
            validPath = [dataPath '/Valid'];
            validVector = h5read(fileName, validPath);

            switch deblank(gridType{1})
                case 'HexGrid'
                    offsetPoints = validVector == 2;
                    scanLength = sum(~offsetPoints);
                    obj.hexOffset = zeros(1, scanLength);
                    
                    offset = 0;
                    for ii = 1:scanLength
                        while offsetPoints(ii + offset)
                            offset = offset + 1;
                        end
                        
                        obj.hexOffset(ii) = offset;
                    end
                    
                case 'SqrGrid'
                    obj.hexOffset = zeros(1, length(validVector));
                otherwise
                    error('OpenXY:patterns:H5PatternProvider',...
                        ['Unrecognized grid type!\n'...
                        'Expected ''HexGrid'' or ''SqrGrid'',\n'...
                        'got %s in stead'], gridType{1})
            end
        end
        
        function sobj = saveobj(obj)
            sobj = saveobj@patterns.PatternProvider(obj);
            sobj.patternPath = obj.patternPath;
            sobj.patternSize = obj.patternSize;
            sobj.hexOffset = obj.hexOffset;
        end
    end
    
    methods (Access = protected)
        function pattern = getPatternData(obj, ind)
            start = ones(size(obj.patternSize));
            start(obj.patternSize == 1) = ind + obj.hexOffset(ind);
            count = obj.patternSize;
            pattern = h5read(obj.fileName, obj.patternPath, start, count)';
        end
    end
    
    methods (Static)
        function obj = restore(loadStruct)
            obj = patterns.H5PatternProvider(loadStruct.fileName);
            obj.patternPath = loadStruct.patternPath;
            obj.patternSize = loadStruct.patternSize;
            obj.hexOffset = loadStruct.hexOffset;
        end
        
        
    end
end

