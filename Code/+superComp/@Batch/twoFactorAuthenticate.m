function twoFactorAuthenticate(obj)


javaaddpath('+superComp\java\')

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.File;


import ch.ethz.ssh2.*;
import ch.ethz.ssh2.Connection;
import ch.ethz.ssh2.Session;
import ch.ethz.ssh2.StreamGobbler;   
import ch.ethz.ssh2.SCPClient;
import ch.ethz.ssh2.SFTPv3Client;
import ch.ethz.ssh2.SFTPv3FileHandle;

import edu.me.byu.sshvalidator.*;

try
    disp('Running 2 factor auth')
    obj.connection.connection = Connection(...
        obj.options.hostName, ...
        obj.connection.port);
    
    obj.connection.connection.connect();
    
    authenticated = ...
        obj.connection.connection.authenticateWithKeyboardInteractive(...
        obj.options.userName, ...
        SSHValidator(obj.options.password, obj.options.verificationCode));
    if authenticated
        tf = 'True';
    else
        tf = 'False';
    end
    fprintf('Authenticated %s', tf);
    if ~authenticated
        error('OpenXY:SSHValidator', 'Could not authenticate!')
    end
    
    obj.connection.authenticated = authenticated;
catch e
    if isa(e, 'matlab.exception.JavaException')
        ex = e.ExceptionObject;
        assert(isjava(ex));
        ex.printStackTrace;
    else
        e.throw;
    end
end
end