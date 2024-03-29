classdef (Abstract) PatternProvider
    %IMAGEPROVIDER Provides the pattern images for a scan
    
    properties 
        % The name of the file provided (e.g. ims.up2, im_x0y.jpg etc.)
        fileName char

        filter patterns.ImageFilter 
        doCropSquare logical = true;
    end
    
    properties (Abstract)
        imSize double
    end
    
    methods (Abstract, Access = protected)
        pattern = getPatternData(obj, ind)
    end
    
    methods (Abstract, Static)
        obj = restore(loadStruct)
    end
    
    methods
        
        function obj = PatternProvider(fileName, imSize)
            obj.fileName = fileName;
            obj.filter = patterns.ImageFilter(imSize);
        end
        
        function pattern = getPattern(obj, Settings, ind1, ind2)
            persistent obj_two i
            switch nargin
                case 3
                    ind = ind1;
                case 4
                    %TODO Add row, column indexing
                otherwise
                     error('OpenXY:UPPatternProvider', ...
                    "Pattern index or row, colum coordinate required")
            end
            [~, ~, ext] = fileparts(Settings.FirstImagePath);
            if strcmp(ext,'.ebsp') && isempty(i)
                obj_two=patterns.EBSPPatternProvider(Settings.FirstImagePath,Settings);
                pattern=single(obj_two.getPatternData(ind));
                i=1;
            elseif strcmp(ext,'.ebsp')
                pattern=single(obj_two.getPatternData(ind));
                if obj_two.doCropSquare
                    pattern = obj_two.cropIm(pattern);
                end
                
                if obj_two.filter.doFilter
                    pattern = obj_two.filter.filterImage(pattern);
                end
            else
                pattern=single(obj.getPatternData(ind));
                if obj.doCropSquare
                    pattern = obj.cropIm(pattern);
                end
                
                if obj.filter.doFilter
                    pattern = obj.filter.filterImage(pattern);
                end
            end
        end
        function pattern = getUnfilteredPattern(obj, ind)
            pattern = single(obj.getPatternData(ind));
            if obj.doCropSquare
                pattern = obj.cropIm(pattern);
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
            if ~exist(loadStruct.fileName, 'file')
                obj = patterns.DummyPatternProvider(loadStruct.fileName);
                return
            end
            
            [~, ~, extension] = fileparts(loadStruct.fileName);
            switch lower(extension)
                case '.ebsp'
                    obj = patterns.EBSPPatternProvider.restore(loadStruct);
                case {'.up1', '.up2'}
                    obj = patterns.UPPatternProvider.restore(loadStruct);
                case '.h5'
                    obj = patterns.H5PatternProvider.restore(loadStruct);
                case {'.jpg', '.jpeg', '.tif', '.tiff', '.bmp', '.png'}
                    obj = patterns.ImagepatternProvider.restore(loadStruct);
                otherwise
                    error('patterns:PatternProvider',...
                        'unrecognized file extension %s', extension)
            end
            
            obj.doCropSquare = loadStruct.doCropSquare;
            obj.filter = loadStruct.filter;
            obj.doCropSquare = loadStruct.doCropSquare;
        end
    end
end

