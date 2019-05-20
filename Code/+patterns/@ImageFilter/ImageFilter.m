classdef ImageFilter
    %IMAGEFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lowerRadius(1, 1)...
            double  {mustBeNonnegative, mustBeNumeric} = 9
        upperRadius(1, 1)...
            double  {mustBeNonnegative, mustBeNumeric} = 90
        lowerSmoothing(1, 1)...
            logical = false
        upperSmoothing(1, 1)...
            logical = false
        
    end
    
    properties (SetAccess = private)
        imSize(1,1) {mustBeInteger, mustBeGreaterThan(imSize, 0)} = 1
    end
    
    properties (Dependent, Transient)
        doFilter
        imfilter
    end
    
    properties (Access = private, Transient)
        distGrid = []
    end
        
    methods
        function obj = ImageFilter(imSize)
            obj.imSize = imSize;

            obj.distGrid = obj.makeDistGrid(imSize);
               
        end
        
        function im = filterImage(obj, im)
            
            try
                IM = fftn(im);
            catch
                IM = fftn(double(im));
            end
            IM = fftshift(IM);
            IM = IM .* (1 - obj.imfilter);
            IM = fftshift(IM);
            
            im = real(ifftn(IM));
            
            im = single(im - mean(im(:)));
            
        end
        
        function filt = get.imfilter(obj)
            
            filt = double(...
                obj.distGrid < obj.lowerRadius |...
                obj.distGrid > obj.upperRadius);
            
            if obj.upperSmoothing
                upperEdge =...
                    obj.distGrid > obj.upperRadius &...
                    obj.distGrid < obj.upperRadius + 25;
                filt(upperEdge) = erf(...
                    (obj.distGrid(upperEdge) - obj.upperRadius) / 25 * pi);
            end
            if obj.lowerSmoothing
                lowerEdge =...
                    obj.distGrid < obj.lowerRadius &...
                    obj.distGrid > obj.lowerRadius - 25;
                filt(lowerEdge) = erf(-...
                    (obj.distGrid(lowerEdge) - obj.lowerRadius) / 25 * pi);
            end
        end
        
        function tf = get.doFilter(obj)
            tf = any([obj.lowerRadius obj.upperRadius...
                obj.lowerSmoothing obj.upperSmoothing]);
        end
    end
    
    methods (Static, Access = private)
        function distGrid = makeDistGrid(imSize)
            centerPoint = round((imSize + 1) / 2);
            gridMat = meshgrid(1:imSize);
            
            distGrid = sqrt(...
                (gridMat  - centerPoint) .^2 +...
                (gridMat' - centerPoint) .^2);
        end
        
        function obj = loadobj(a)
           if isstruct(a)
               obj = ImageFilter(a.imageSize);
               obj.lowerRadius = a.lowerRadius;
               obj.upperRadius = a.upperRadius;
               obj.lowerSmoothing = a.lowerSmoothing;
               obj.upperSmoothing = a.upperSmoothing;
               return;
           end
           
           obj = a;
           obj.distGrid = patterns.ImageFilter.makeDistGrid(obj.imSize);
        end
    end
end

