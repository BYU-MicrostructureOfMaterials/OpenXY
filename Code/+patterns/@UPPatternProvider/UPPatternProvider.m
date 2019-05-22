classdef UPPatternProvider < patterns.PatternProvider
    %UPPATTERNPROVIDER PatternProvider for .up1 and .up2 files
    
    properties (Access = private, Transient)
        fileMap
    end
    
    methods
        function obj = UPPatternProvider(fileName)
            [~, ~, extension] = fileparts(fileName);
            switch lower(extension)
                case '.up1'
                    precision = 'uint8';
                case '.up2'
                    precision = 'uint16';
                otherwise
                    error('OpenXY:PatternProvider',...
                        '%s is not a valid file', fileName)
            end
            
            [version, width, height, offset] = ...
                patterns.UPPatternProvider.readHeader(fileName);
            
            obj@patterns.PatternProvider(fileName, min(width, height));
            
            if version > 2
                % Extra information can be read from the file if it is
                % version 3+, but all of that is the same as the info from
                % the ang file. Maybe validate that info?
            end
            
            formatCell = {precision, [width, height], 'image'};
            
            obj.fileMap = memmapfile(fileName,...
                'Offset', offset, 'Format', formatCell);
        end
        
        function sobj = saveobj(obj)
            sobj = saveobj@patterns.PatternProvider(obj);
        end
        
    end
    
    methods (Access = protected)
        function pattern = getPatternData(obj, ind)
            pattern = obj.fileMap.Data(ind).image';
        end
        
    end
    
    methods (Static)
        function obj = restore(loadStruct)
            obj = patterns.UPPatternProvider(loadStruct.fileName);
        end
        
        

        function [version, width, height, offset] = readHeader(fileName)
            fid = fopen(fileName);
            if fid < 0
                error('OpenXY:patterns', ...
                    'Could not open file %s', fileName)
            end
            whenDone = onCleanup(@() fclose(fid));
            version = fread(fid, 1, 'int');
            width = fread(fid, 1, 'int');
            height = fread(fid, 1, 'int');
            offset = fread(fid, 1, 'int');
            
        end
    end
end

