classdef Batch < handle
    %SUPERCOMP.BATCH Handle submitting EBSD batches to a supercomputer
    properties (Access = public)
        % The data to control the batch job
        options @superComp.Options
        
        % The settings struct 
        Settings @struct
    end
    
    properties (Access = private)
        connection
    end
    
    methods
        function obj = Batch()
            obj.options = superComp.Options();
        end
        
        run(obj)
        
    end
    
    methods (Access = private)
        sendImages(obj)
        
        sendSource(obj)
        
        sendBatchResources(obj)
        
        list = getSourceList(obj)

    end
    
  
end