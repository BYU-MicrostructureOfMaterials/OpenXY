classdef Options
    %OPTIONS A data holder for supercomputer batch job options
    
    properties
        
        % The address of the supercomputer
        hostName
        
        % The username used to connect to the supercomputer
        userName
        
        % The password used to connect to the supercomputer
        password
        
        % The email that notifications will be sent to
        email
        
        % Should email be sent on job start
        sendStart
        
        % Should email be sent on job finish
        sendEnd
        
        % Should email be sent on job fail
        sendFail
        
        % Should the OpenXY source code be sent or not
        sendSource
        
        % Should the images be sent?
        sendImages
        
        % 
    end
    
end