classdef (Abstract) PatternProvider
    %IMAGEPROVIDER Provides the pattern images for a scan
    
    properties
        % The name of the file provided (e.g. ims.up2, im_x0y.jpg etc.)
        fileName char

        filter patterns.ImageFilter 
        doCropSquare logical {isscalar} = true;
    end
    
    properties
    end
    
    methods (Abstract, Access = protected)
        pattern = getPatternData(obj, ind)
        obj = restore(obj, loadStruct)
    end
    
    methods
        
        function obj = PatternProvider(fileName, imSize)
            obj.fileName = fileName;
            obj.filter = patterns.ImageFilter(imSize);
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
        
        function sobj = saveobj(obj)
            sobj.fileName = obj.fileName;
            sobj.filter = obj.filter;
            sobj.doCropSquare = obj.doCropSquare;
        end
    end
    
    methods (Static, Access = protected)
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
        
        function obj = loadobj(loadStruct)
            [~, ~, extension] = fileparts(loadStruct.fileName);
            switch lower(extension)
                case {'.up1', '.up2'}
                    ctor = @patterns.UPPatternProvider;
                otherwise
                    error('patterns:PatternProvider',...
                        'unrecognized file extension %s', extension)
            end
            
            if ~exist(loadStruct.fileName, 'file')
                ctor = @patterns.DummyPatternProvider;
            end
            
            obj = ctor(loadStruct.fileName);
            obj = obj.restore(loadStruct);
            obj.doCropSquare = loadStruct.doCropSquare;
        end
    end
end

