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
                maxJobLength_priv = []

    end
    
    properties (Access = private, Dependent)
        time
        
        maxJobLength
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
    
    methods 
        function time = get.time(obj)
            start_time = duration(0,0,60);
            point_time = duration(0,0,0.4);
            
            job_time = start_time + point_time * obj.maxJobLength;
            
            time = char(job_time);
        end

        function len = get.maxJobLength(obj)
            if isempty(obj.maxJobLength_priv)
                len = obj.Settings.ScanLength;
            else
                len = obj.maxJobLength_priv;
            end
        end
        
        function set.maxJobLength(obj,maxJobLength)
            obj.maxJobLength_priv = maxJobLength;
        end
    end
    
  
end