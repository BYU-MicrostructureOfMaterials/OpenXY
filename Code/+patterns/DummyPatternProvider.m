classdef DummyPatternProvider < patterns.PatternProvider
    
    properties
        imSize = -1
    end
    
    methods
        function obj = DummyPatternProvider(fileName)
            obj@patterns.PatternProvider(fileName, 1);
            warning('OpenXY:Patters',...
                'Cannot find file %s, was is moved, or are you on a differnet system? You can still view results, but patterns will not be available.', fileName)
        end
    end
    
    methods (Access = protected)
        function pattern = getPatternData(obj, ind)
            pattern = [];
            error('OpenXY:patterns',...
                'Cannot load patterns without %s', obj.fileName)
        end
    end
    
    methods (Static)
        function obj = restore(loadStruct)
            obj = patterns.PatternProvider(loadStruct.fileName);
        end
    end
end

