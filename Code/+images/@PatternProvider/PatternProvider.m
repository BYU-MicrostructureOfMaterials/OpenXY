classdef (Abstract) PatternProvider
    %IMAGEPROVIDER Provides the pattern images for a scan
    
    properties
        filter images.ImageFilter 
        doCropSquare logical {isscalar} = false;
    end
    
    properties
    end
    
    methods (Abstract, Access = protected)
        pattern = getPatternData(obj, ind)
    end
    
    methods
        
        function obj = PatternProvider(imSize)
            obj.filter = images.ImageFilter(imSize);
        end
        
        function pattern = getPattern(obj, ind1, ind2)
            switch nargin
                case 2
                    ind = ind1;
                case 3
                    %TODO Add row, column indexing
                otherwise
                     error('OpenXY:UPPatternProvider', ...
                    "Pattern index or row, colum coordinate required")
            end
            
            pattern = single(obj.getPatternData(ind));
            
            if obj.doCropSquare
                pattern = obj.cropIm(pattern);
            end
            
            if obj.filter.doFilter
                pattern = obj.filter.filterImage(pattern);
            end
        end
        
    end
    
    methods (Static, Access = private)
        function im = cropIm(im)
            imSize = size(im);
            if imSize(1) == imSize(2)
                return
            end
            isTall = imSize(1) > imSize(2);
            
            if isTall
                im = permute(im, [2 1 3]);
                imSize = size(im);
            end
            
            startCol = round((imSize(2) - imSize(1)) / 2);
            
            im = im(:, startCol:imSize(1)+startCol-1);
            
            if isTall
                im = permute(im, [2 1 3]);
            end
            
        end
    end
end

