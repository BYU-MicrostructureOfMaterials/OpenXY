classdef ImageFilterType 
    
    enumeration
        standard
        localthresh
    end
    
    methods (Static)
        function names = getNames
            [~, names] = enumeration('patterns.ImageFilterType');
        end
    end
end

