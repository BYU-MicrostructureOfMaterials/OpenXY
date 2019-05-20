classdef DummyPatternProvider < patterns.PatternProvider
    
    
    methods
        function obj = DummyPatternProvider(fileName)
            obj@patterns.PatternProvider(fileName, 1);
            warning('OpenXY:Patters',...
                'Cannot find file %s, was is moved, or are you on a differnet system? You can still view results, but patterns will not be available.', fileName)
        end
    end
    
    methods (Access = protected)
        function obj = restore(obj, ~)
            %Restore restores specific properties for this subclass
            % Currently none for this class, so this method is a no-op, but
            % this must be implemented
        end
        
        function pattern = getPatternData(obj, ind)
            pattern = [];
            error('OpenXY:patterns',...
                'Cannot load patterns without %s', obj.fileName)
        end
    end
end

