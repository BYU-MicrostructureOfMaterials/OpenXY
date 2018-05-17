function varargout = SuperCompGUI(varargin)
% SUPERCOMPGUI MATLAB code for SuperCompGUI.fig
%      SUPERCOMPGUI, by itself, creates a new SUPERCOMPGUI or raises the existing
%      singleton*.
%
%      H = SUPERCOMPGUI returns the handle to a new SUPERCOMPGUI or the handle to
%      the existing singleton*.
%
%      SUPERCOMPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUPERCOMPGUI.M with the given input arguments.
%
%      SUPERCOMPGUI('Property','Value',...) creates a new SUPERCOMPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SuperCompGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SuperCompGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SuperCompGUI

% Last Modified by GUIDE v2.5 16-May-2018 11:56:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SuperCompGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SuperCompGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SuperCompGUI is made visible.
function SuperCompGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for SuperCompGUI
handles.output = hObject;

% Save a handle to the MainGUI
handles.mainHandles = varargin{1};

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = SuperCompGUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in submitButton.
function submitButton_Callback(hObject, eventdata, handles)
batch = initBatch(handles);
%TODO Add a try catch for bad connections
batch.run();


function batch = initBatch(handles)
batch = superComp.Batch();
options = batch.options;
options.hostName = handles.hostNameEditText.String;
options.userName = handles.userNameEditText.String;
options.password = handles.passwordEditText.UserData;
% TODO Add checkboxes for these two variables
options.sendSource = true;
options.sendImages = true;
batch.options = options;


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
keyboard


% --- Executes on key press with focus on passwordEditText and none of its controls.
function passwordEditText_KeyPressFcn(hObject, eventdata, handles)
% Function to replace all characters in the password edit box with
% asterisks
password = get(hObject,'Userdata');
key = eventdata.Key;

switch key
    case 'backspace'
        password = password(1:end-1); % Delete the last character in the password
    case 'return'  % This cannot be done through callback without making tab to the same thing
        submitButton_Callback(hObject, eventdata, handles);
    case 'tab'  % Avoid tab triggering the OK button
        gui = getappdata(0,'logindlg');
        uicontrol(gui.OK);
    case 'escape'
    otherwise
        password = [password eventdata.Character]; % Add the typed character to the password
end

SizePass = size(password); % Find the number of asterisks
if SizePass(2) > 0
    asterisk(1,1:SizePass(2)) = '*'; % Create a string of asterisks the same size as the password
    set(hObject,'String',asterisk) % Set the text in the password edit box to the asterisk string
else
    set(hObject,'String','')
end

set(hObject,'Userdata',password) % Store the password in its current state

% hObject    handle to passwordEditText (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
