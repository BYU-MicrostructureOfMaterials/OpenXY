function varargout = SetXYZStarGUI(varargin)
% SETXYZSTARGUI MATLAB code for SetXYZStarGUI.fig
%      SETXYZSTARGUI, by itself, creates a new SETXYZSTARGUI or raises the existing
%      singleton*.
%
%      H = SETXYZSTARGUI returns the handle to a new SETXYZSTARGUI or the handle to
%      the existing singleton*.
%
%      SETXYZSTARGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETXYZSTARGUI.M with the given input arguments.
%
%      SETXYZSTARGUI('Property','Value',...) creates a new SETXYZSTARGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetXYZStarGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetXYZStarGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetXYZStarGUI

% Last Modified by GUIDE v2.5 21-Oct-2015 15:29:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SetXYZStarGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SetXYZStarGUI_OutputFcn, ...
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


% --- Executes just before SetXYZStarGUI is made visible.
function SetXYZStarGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetXYZStarGUI (see VARARGIN)

% Choose default command line output for SetXYZStarGUI
handles.output = hObject;

if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
else
    Settings = varargin{1};
end
handles.PrevSettings = Settings;

set(handles.editPCX, 'String', num2str(Settings.ScanParams.xstar));
set(handles.editPCY, 'String', num2str(Settings.ScanParams.ystar));
set(handles.editPCZ, 'String', num2str(Settings.ScanParams.zstar));

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
uiwait(handles.SetXYZStarGUIwindow);


% --- Outputs from this function are returned to the command line.
function varargout = SetXYZStarGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.Settings;
delete(hObject);

% --- Executes when user attempts to close MicroscopeSettingsGUI.
function SetXYZStarGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MicroscopeSettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

function editPCX_Callback(hObject, eventdata, handles)
% hObject    handle to editPCX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPCX as text
%        str2double(get(hObject,'String')) returns contents of editPCX as a double
handles.Settings.ScanParams.xstar = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editPCX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPCX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editPCY_Callback(hObject, eventdata, handles)
% hObject    handle to editPCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPCY as text
%        str2double(get(hObject,'String')) returns contents of editPCY as a double
handles.Settings.ScanParams.ystar = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editPCY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editPCZ_Callback(hObject, eventdata, handles)
% hObject    handle to editPCZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPCZ as text
%        str2double(get(hObject,'String')) returns contents of editPCZ as a double
handles.Settings.ScanParams.zstar = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editPCZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPCZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReadFromTiffButton.
function ReadFromTiffButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReadFromTiffButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.Settings.ImageTag
    n = handles.Settings.Nx;
    m = handles.Settings.Ny;
    iqRS = reshape(handles.Settings.IQ,n,m)';
    indi = 1:1:m*n;
    indi = reshape(indi, n,m)';
    hf = figure;
    imagesc(iqRS)
    axis image
    colormap('jet')
    title('Select a point to load its pattern center')
    [x,y] = ginput(1);
    i = indi(round(y),round(x));
    VHRatio = Settings.VHRatio;
    try
        info = imfinfo(Settings.patterns.imageNames{1});

        xistart = strfind(info.UnknownTags.Value,'<pattern-center-x-pu>');
        xifinish = strfind(info.UnknownTags.Value,'</pattern-center-x-pu>');

        thisx = str2double(info.UnknownTags.Value(xistart+length('<pattern-center-x-pu>'):xifinish-1));
        xstar = (thisx - (1-VHRatio)/2)/VHRatio;

        yistart = strfind(info.UnknownTags.Value,'<pattern-center-y-pu>');
        yifinish = strfind(info.UnknownTags.Value,'</pattern-center-y-pu>');

        ystar = str2double(info.UnknownTags.Value(yistart+length('<pattern-center-y-pu>'):yifinish-1));

        zistart = strfind(info.UnknownTags.Value,'<detector-distance-pu>');
        zifinish = strfind(info.UnknownTags.Value,'</detector-distance-pu>');

        zstar = str2double(info.UnknownTags.Value(zistart+length('<detector-distance-pu>'):zifinish-1))/VHRatio;
    catch
        xstar = handles.ScanParams.xstar;
        ystar = handles.ScanParams.ystar;
        zstar = handles.ScanParams.zstar;
    end
    handles.Settings.ScanParams.xstar = xstar;
    handles.Settings.ScanParams.ystar = ystar;
    handles.Settings.ScanParams.zstar = zstar;
    
    set(handles.editPCX, 'String', num2str(xstar));
    set(handles.editPCY, 'String', num2str(ystar));
    set(handles.editPCZ, 'String', num2str(zstar));
    
    close(hf)
    
    guidata(hObject,handles);
else
    warndlg({'Image file does not contain any pattern center information'},'OpenXY: Invalid Operation');
end

% --- Executes on button press in SaveAndCloseButton.
function SaveAndCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAndCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetXYZStarGUI_CloseRequestFcn(handles.SetXYZStarGUIwindow, eventdata, handles);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Settings = handles.PrevSettings;
guidata(hObject,handles);
SetXYZStarGUI_CloseRequestFcn(handles.SetXYZStarGUIwindow, eventdata, handles);
