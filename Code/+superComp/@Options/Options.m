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
        
        % Should the OpenXY source code be sent
        sendSource
        
        % Should the images be sent
        sendImages
        
        % The ammount of jobs the batch should be spilt into
        numJobs
        
        % Should 2 factor authentication be used
        use2FactorAuth
        
        % 2 Factor authentication verification code
        verificationCode
    end
    
end