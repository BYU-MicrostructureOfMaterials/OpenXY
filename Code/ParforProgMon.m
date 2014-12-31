% ParforProgMon - M object to make ParforProgressMonitor objects easier to
% use. Create one of these on the client outside your PARFOR loop with a
% name for the window. Pass it in to the PARFOR loop, and have the workers
% call "increment" at the end of each iteration. This sends notification
% back to the client which then updates the UI.
%
% Example:
% N = 100;
% ppm = ParforProgMon( 'Example', N );
% parfor ii=1:N
%     pause( 0.1 );
%     ppm.increment();
% end


% Copyright 2009 The MathWorks, Inc.

classdef ParforProgMon < handle

    properties ( GetAccess = private, SetAccess = private )
        Port
        HostName
    end
    
    properties (Transient, GetAccess = private, SetAccess = private)
        JavaBit
    end
    
    methods ( Static )
        function o = loadobj( X )
        % Once we've been loaded, we need to reconstruct ourselves correctly as a
        % worker-side object.
            o = ParforProgMon( {X.HostName, X.Port} );
        end
    end
    
    methods
        function o = ParforProgMon( s, n )
        % ParforProgMon Build a Parfor Progress Monitor
        % Use the syntax: ParforProgMon( 'Window Title', N )
        % where N is the number of iterations in the PARFOR loop
            if nargin == 1 && iscell( s )
                % "Private" constructor used on the workers
                o.JavaBit   = ParforProgressMonitor.createWorker( s{1}, s{2} );
                o.Port      = [];
            elseif nargin == 2
                % Normal construction
                o.JavaBit   = ParforProgressMonitor.createServer( s, n );
                o.Port      = double( o.JavaBit.getPort() );
                % Get the client host name from pctconfig
                cfg         = pctconfig;
                o.HostName  = cfg.hostname;
            else
                error( 'Public constructor is: ParforProgressMonitor( ''Text'', N )' );
            end
        end
        
        function X = saveobj( o )
        % Only keep the Port and HostName
            X.Port     = o.Port;
            X.HostName = o.HostName;
        end
        
        function increment( o )
        % Update the UI
            o.JavaBit.increment();
        end
        
        function delete( o )
        % Close the UI
            o.JavaBit.done();
        end
    end
end
