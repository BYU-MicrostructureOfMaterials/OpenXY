function sendSource(obj)
% TODO Add this
disp('Sending SourceCode');
list = obj.getSourceList();

command = 'mkdir ~/compute/OpenXY;mkdir ~/compute/OpenXY/Code;';
obj.connection = ssh2_command(obj.connection,command);
obj.connection = scp_put(obj.connection,list,'~/compute/OpenXY/Code/');
end
