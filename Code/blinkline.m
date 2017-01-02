function blinkline(h,period)
% BLINK     Make a graphics component blink
%
% BLINK(H) makes the text in graphics component H blink. If H is already
% blinking, BLINK(H) makes it stop. H is any graphics object with text
% stored in a property named String, such as uicontrol an axes labels.
%
% BLINK(H,PERIOD) makes the text in graphics component H blink at speed
% PERIOD. Period specifies the duration the component is either visible or
% invisible, in seconds.
%
% Examples:
%
%     % Basic blinking
%     figure
%     b = uicontrol('Style','text','String','I blink');
%     blink(b)  % Start blinking
%
%     blink(b)  % Stop blinking
% 
%     % Control blinking rate
%     pb = uicontrol('Style','popupmenu','Position',[20 50 100 20],'String','Please pick me')
%     blink(pb,.2)  % Start blinking quickly
%
%     blink(pb,.1)  % Even faster
%
%     blink(pb)     % Enough already
%
%     % Make text on a plot blink
%     p = plot(rand(10,1));
%     xl = xlabel('This is a blinking X Label');
%     blink(xl,.25)
%
%     blink(xl)     % stop blinking

% Copyright 2015 The MathWorks, Inc.
% mhirsch@mathworks.com

if ~isvalid(h)
    error('First input argument must be a valid graphics object.')
end

if nargin == 1 || isempty(period)
    period = 1; % Default 1 second
end


% Is this already blinking?
t = getappdata(h,'BlinkyTimer');

if isempty(t) % No timer, set one up      
    t = timer;
    t.ExecutionMode = 'fixedRate';
    t.Period = period;
    t.Name = 'BlinkyTimer';
    t.TimerFcn = {@blinkTimer, h};
    t.StopFcn = {@resetBlink, h}; % Make sure it ends in the original state
  
    % Store the blinky timer in the blinking object
    setappdata(h,'BlinkyTimer',t)
    h.DeleteFcn = @killTimer;
    
else %Already blinking
    if nargin==2 % User specified period for running timer. Update the period
        stop(t)
        t.Period = period;
    else          %User said to stop. kill it and be done with it.
        stop(t)
        delete(t)
        rmappdata(h,'BlinkyTimer')
        h.DeleteFcn = '';
        return
    end
end


start(t)

end

function blinkTimer(~,~,h)
    if ~isvalid(h)
        return
    end

    if strcmp(h.Visible,'on') % Matches original text
        h.Visible = 'off';
    else
        h.Visible = 'on';
    end
end

function resetBlink(~,~,h)
    h.Visible =  'on';      
end

function killTimer(h,~)
    t = getappdata(h,'BlinkyTimer');
    stop(t)
    delete(t)
end