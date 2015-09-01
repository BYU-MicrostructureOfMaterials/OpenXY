function varargout = MicroscopeSettingsGUI(varargin)
% MICROSCOPESETTINGSGUI MATLAB code for MicroscopeSettingsGUI.fig
%      MICROSCOPESETTINGSGUI, by itself, creates a new MICROSCOPESETTINGSGUI or raises the existing
%      singleton*.
%
%      H = MICROSCOPESETTINGSGUI returns the handle to a new MICROSCOPESETTINGSGUI or the handle to
%      the existing singleton*.
%
%      MICROSCOPESETTINGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MICROSCOPESETTINGSGUI.M with the given input arguments.
%
%      MICROSCOPESETTINGSGUI('Property','Value',...) creates a new MICROSCOPESETTINGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MicroscopeSettingsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MicroscopeSettingsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MicroscopeSettingsGUI

% Last Modified by GUIDE v2.5 17-Aug-2015 07:12:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MicroscopeSettingsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MicroscopeSettingsGUI_OutputFcn, ...
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


% --- Executes just before MicroscopeSettingsGUI is made visible.
function MicroscopeSettingsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MicroscopeSettingsGUI (see VARARGIN)

% Choose default command line output for MicroscopeSettingsGUI
handles.output = hObject;

%Accept Settings from MainGUI or Load Settings.mat
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
else
    Settings = varargin{1};
end
handles.PrevSettings = Settings;

%Accel Voltage
set(handles.AccelVoltage,'String',num2str(Settings.AccelVoltage));
%Sample Tilt
set(handles.SampleTilt,'String',num2str(Settings.SampleTilt*180/pi)); %degrees
%Sample Azimuthal
set(handles.SampleAzimuthal,'String',num2str(Settings.SampleAzimuthal*180/pi)); %degrees
%Camera Elevation
set(handles.CameraElevation,'String',num2str(Settings.CameraElevation*180/pi)); %degrees
%Camera Azimuthal
set(handles.CameraAzimuthal,'String',num2str(Settings.CameraAzimuthal*180/pi)); %degrees
%Microns per Pixel
set(handles.micronperpix,'String',num2str(Settings.mperpix));

%Set Position
if length(varargin) > 1
    MainSize = varargin{2};
    set(hObject,'Units','pixels');
    GUIsize = get(hObject,'Position');
    set(hObject,'Position',[MainSize(1)+MainSize(3)+20 MainSize(2)+MainSize(4)-GUIsize(4) GUIsize(3) GUIsize(4)]);
    movegui(hObject,'onscreen');
end

% Update handles structure
handles.Settings = Settings;
guidata(hObject, handles);

% UIWAIT makes MicroscopeSettingsGUI wait for user response (see UIRESUME)
uiwait(handles.MicroscopeSettingsGUI);


% --- Outputs from this function are returned to the command line.
function varargout = MicroscopeSettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.Settings;
delete(hObject);

% --- Executes when user attempts to close MicroscopeSettingsGUI.
function MicroscopeSettingsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MicroscopeSettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MicroscopeSettingsGUI_CloseRequestFcn(handles.MicroscopeSettingsGUI, eventdata, handles);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Settings = handles.PrevSettings;
guidata(hObject,handles);
MicroscopeSettingsGUI_CloseRequestFcn(handles.MicroscopeSettingsGUI, eventdata, handles);


function AccelVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to AccelVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AccelVoltage as text
%        str2double(get(hObject,'String')) returns contents of AccelVoltage as a double
handles.Settings.AccelVoltage = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function AccelVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AccelVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SampleTilt_Callback(hObject, eventdata, handles)
% hObject    handle to SampleTilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampleTilt as text
%        str2double(get(hObject,'String')) returns contents of SampleTilt as a double
handles.Settings.SampleTilt = str2double(get(hObject,'String'))*pi/180;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SampleTilt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleTilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SampleAzimuthal_Callback(hObject, eventdata, handles)
% hObject    handle to SampleAzimuthal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampleAzimuthal as text
%        str2double(get(hObject,'String')) returns contents of SampleAzimuthal as a double
handles.Settings.SampleAzimuthal = str2double(get(hObject,'String'))*pi/180;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SampleAzimuthal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleAzimuthal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CameraElevation_Callback(hObject, eventdata, handles)
% hObject    handle to CameraElevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CameraElevation as text
%        str2double(get(hObject,'String')) returns contents of CameraElevation as a double
handles.Settings.CameraElevation = str2double(get(hObject,'String'))*pi/180;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function CameraElevation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CameraElevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CameraAzimuthal_Callback(hObject, eventdata, handles)
% hObject    handle to CameraAzimuthal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CameraAzimuthal as text
%        str2double(get(hObject,'String')) returns contents of CameraAzimuthal as a double
handles.Settings.CameraAzimuthal = str2double(get(hObject,'String'))*pi/180;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function CameraAzimuthal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CameraAzimuthal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function micronperpix_Callback(hObject, eventdata, handles)
% hObject    handle to micronperpix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of micronperpix as text
%        str2double(get(hObject,'String')) returns contents of micronperpix as a double
handles.Settings.mperpix = str2double(get(hObject,'String'));
if isfield(handles.Settings,'PixelSize')
    handles.Settings.PhosphorSize = handles.Settings.PixelSize*handles.Settings.mperpix;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function micronperpix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to micronperpix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
