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
        pointTime
    end
    
    methods
        function obj = Batch()
            obj.options = superComp.Options();
        end
        
        run(obj, use2FactorAuth)
        
        twoFactorAuthenticate(obj)
    end
    
    methods (Access = private)
        sendImages(obj)
        
        sendSource(obj)
        
        sendBatchResources(obj)
        
        list = getSourceList(obj)
        
    end
    
    methods 
        function time = get.time(obj)
            startUpTime = duration(0,0,60);
            
            jobTime = startUpTime + obj.pointTime * obj.maxJobLength;
            
            time = char(jobTime);
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
        
        function time = get.pointTime(obj)
            switch obj.Settings.HROIMMethod
                case 'Simulated-Kinematic'
                    % TODO Validate this value
                    time = duration(0,0,1);
                case 'Simulated-Dynamic'
                    error('OpenXY:superComp:UnsupportedMethod',...
                        ['Dynamic pattern simulation not supported '...
                        'on the supercomputer!'])
                case {'Real-Grain Ref', 'Real-Single Ref'}
                    time = duration(0,0,0.4);
                case 'Remapping'
                    time = duration(0,0,6);
            end
        end
    end
    
  
end