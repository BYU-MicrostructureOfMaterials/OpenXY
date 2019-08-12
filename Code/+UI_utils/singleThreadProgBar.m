classdef singleThreadProgBar < handle
    
    
    properties (SetAccess = private)
        timerID(1,1) uint64
        totalSteps(1,1) ...
            {mustBeNumeric(totalSteps), mustBePositive(totalSteps)} = 1
        waitBarWindow
    end
    
    properties (Constant, Access = private)
        messageString = 'Time Remaining:\n%s'
    end
        
    methods
        function obj = singleThreadProgBar(totalSteps)
            obj.totalSteps = totalSteps;
            obj.waitBarWindow = waitbar(0, '');
            obj.timerID = tic;
        end
        
        function update(obj, step)
            progress = step / obj.totalSteps;
            try
                waitbar(progress, obj.waitBarWindow, obj.getMesage(step))
            catch ex
                if strcmp(ex.identifier,...
                        'MATLAB:waitbar:InvalidSecondInput')
                    obj.waitBarWindow = ...
                        waitbar(progress, obj.getMesage(step));
                else
                    rethrow(ex)
                end
            end
        end
        
        function close(obj)
            if isvalid(obj.waitBarWindow)
                close(obj.waitBarWindow)
            end
        end
        
        function delete(obj)
            close(obj)
        end
    end
    
    methods (Access = private)
        function message = getMesage(obj, step)
            elapsedSeconds = toc(obj.timerID);
            elapsedTime = duration(0, 0, elapsedSeconds);
            averageTime = elapsedTime / step;
            prediectedTime = averageTime * obj.totalSteps;
            remainingTime = prediectedTime - elapsedTime;
            
            message = sprintf(obj.messageString, remainingTime);

        end
    end
    
end

