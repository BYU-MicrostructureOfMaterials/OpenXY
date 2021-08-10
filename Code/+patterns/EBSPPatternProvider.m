classdef EBSPPatternProvider < patterns.PatternProvider
    %EBSPPATTERNPROVIDER PatternProvider for .EBSP files
    
    properties
        imSize double
    end
    
    properties 
        fileMap
    end
    
    methods 
        function obj = EBSPPatternProvider(fileName,Settings)
            %open file so its contents can be accessed
            file=fopen(Settings.FirstImagePath);
            %total cells found by multiplying x and y cells
            total_cells=Settings.Nx*Settings.Ny;
            %total number of cells or images is the product of x and y cells
            fseek(file,8,'bof'); %Move past the 1st 8 bytes (header information)
            
            offset=fread(file,total_cells,'uint64'); 
            %The offset values are contained after the first 8 bytes and
            %are 64 bit uints. There are total_cells number of them.  
            fseek(file, offset(1), 'bof');
            %Go to the location of the 1st image
            pattern=fread(file,8,'uint16');
            %read in the first 8 bytes at the initial offset to find the
            %size of each image
            width=pattern(3);
            %width is the third element in the pattern array
            height=pattern(5);
            %height of image is fifth element in the pattern array
            obj@patterns.PatternProvider(fileName, min(width, height));
            %image size contains width and height
            obj.imSize = [width, height];
            %create memmapfile for each image
            for i=1:total_cells
                  obj.fileMap{i}=memmapfile(fileName,'Offset',offset(i),...
                  'Format',{'uint16',[8 1],'imheader';'uint8',...
                  [height, width],'image'},'Repeat',1);
            end

        end
        
        function sobj = saveobj(obj)
            sobj = saveobj@patterns.PatternProvider(obj);
            
        end
        
    end
    
    methods (Access = protected)
       
        function pattern = getPatternData(obj,ind)
            pattern=obj.fileMap{1,ind}.Data.image;

        end
        
    end
    
    methods (Static)
        function obj = restore(loadStruct)
            obj = patterns.EBSPPatternProvider(loadStruct.fileName);
        end
        
    end
end

