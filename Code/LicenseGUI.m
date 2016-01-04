function varargout = LicenseGUI(varargin)
% LICENSEGUI MATLAB code for LicenseGUI.fig
%      LICENSEGUI, by itself, creates a new LICENSEGUI or raises the existing
%      singleton*.
%
%      H = LICENSEGUI returns the handle to a new LICENSEGUI or the handle to
%      the existing singleton*.
%
%      LICENSEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LICENSEGUI.M with the given input arguments.
%
%      LICENSEGUI('Property','Value',...) creates a new LICENSEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LicenseGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LicenseGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LicenseGUI

% Last Modified by GUIDE v2.5 03-Nov-2015 10:45:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LicenseGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LicenseGUI_OutputFcn, ...
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


% --- Executes just before LicenseGUI is made visible.
function LicenseGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LicenseGUI (see VARARGIN)

%Get input from MainGUI


% Choose default command line output for LicenseGUI
handles.output = false;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LicenseGUI wait for user response (see UIRESUME)
uiwait(handles.LicenseGUI);


% --- Outputs from this function are returned to the command line.
function varargout = LicenseGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.LicenseGUI);


% --- Executes on button press in continuebutton.
function continuebutton_Callback(hObject, eventdata, handles)
% hObject    handle to continuebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.acceptbox,'Value')
    handles.output = true;
    guidata(hObject,handles);
    LicenseGUI_CloseRequestFcn(handles.LicenseGUI, eventdata, handles);
else
    warndlg('Must check box to accept before continuing','OpenXY License');
end


% --- Executes on button press in acceptbox.
function acceptbox_Callback(hObject, eventdata, handles)
% hObject    handle to acceptbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acceptbox


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = false;
guidata(hObject,handles);
LicenseGUI_CloseRequestFcn(handles.LicenseGUI, eventdata, handles);



% --- Executes when user attempts to close LicenseGUI.
function LicenseGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to LicenseGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
