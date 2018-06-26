function run(obj)
%RUN Start a scan on a supercomputer running SLURM.
%
%   RUN(BATCHDATA)      Start a job on a supercomputer
%                                       using options in BATCHDATA
%   Begin a job on a supercomputer according to the information in
%   BATCHDATA, which is a supercomp.BatchData object. The supercomputer
%   must be running SLURM.
%   
%   Written by Zach Clayburn, May 15, 2018
%
%   Requires David Freedman's <a href="matlab:web...
%   (['https://www.mathworks.com/matlabcentral/fileexchange/'...'
%   '35409-ssh-sftp-scp-for-matlab--v2-')">SSH/SFTP/SCP For Matlab (v2)</a>
%
%   See also supercomp.Options


try
    command = ['export return_=1; type sbatch >/dev/null 2>&1 || '...
        '{ return_=0; }; echo "$return_"; unset return_'];
    slurm_installed = ssh2_simple_command(...
        obj.options.hostName,...
        obj.options.userName,...
        obj.options.password,...
        command...
        );
catch ME
    switch ME.identifier
        case 'MATLAB:UndefinedFunction'
            error(['Please install <a href="matlab:web(''https://'...
                'www.mathworks.com/matlabcentral/fileexchange/'...
                '35409-ssh-sftp-scp-for-matlab--v2-'')">SSH/SFTP/SCP'...
                ' For Matlab (v2)</a> to run jobs on a supercomputer!'])
        case ''
            er = MException('OpenXY:SSHFailure',['Could not connect to '...
                'supercomputer, check host name, user name or password.']);
            er.addCause(ME)
            er.throw;
        otherwise
            ME.rethrow()
    end
end

switch slurm_installed{1}
    case '1'
        % slurm is installed, continue as normal
    case '0'
        error('OpenXY:SlurmNotInstalled', 'Slurm not installed on server!')
    otherwise
        error('OpenXY:UnexpectedResult',...
            'Unexpected result recieved from server!');
end

% Open a persistent conection to the supercomputer
obj.connection = ssh2_config(...
    obj.options.hostName,...
    obj.options.userName,...
    obj.options.password...
    );

% Set up an onCleanup to close the conection when the function exits
    function closeConection(obj)
        ssh2_close(obj.connection);
        obj.connection = [];
    end
connectionCleanup = onCleanup( @() closeConection(obj) );

% Send data to the supercomputer
if obj.options.sendImages
    obj.sendImages()
end
if obj.options.sendSource
    obj.sendSource()
end

obj.sendBatchResources()
[~, jobName, ~] = fileparts(obj.Settings.OutputPath);
% TODO Adjust these according the the size of the scan
jobTime = obj.time;
jobMemory = '1024MB';

command = 'source /etc/profile > /dev/null; ';
command = [command 'cd compute/OpenXY; '];
command = [command 'chmod 766 OpenXY.sh; '];
command = [command './OpenXY.sh '];
command = [command obj.options.email ' '];
command = [command '"' jobName '" '];
if obj.options.sendStart
    command = [command 'y '];
else
    command = [command 'n '];
end
if obj.options.sendEnd
    command = [command 'y '];
else
    command = [command 'n '];
end
if obj.options.sendFail
    command = [command 'y '];
else
    command = [command 'n '];
end
command = [command num2str(obj.options.numJobs) ' '];
command = [command jobTime ' '];
command = [command jobMemory ' '];

obj.connection = ssh2_command(obj.connection, command, 1);
end
