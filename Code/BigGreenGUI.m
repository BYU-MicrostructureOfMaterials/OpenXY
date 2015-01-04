%December 2014
%Last Modified by Brian Jackson 12/23/2014
function varargout = BigGreenGUI(varargin)


% BIGGREENGUI M-file for BigGreenGUI.fig
%      BIGGREENGUI, by itself, creates a new BIGGREENGUI or raises the existing
%      singleton*.
%
%      H = BIGGREENGUI returns the handle to a new BIGGREENGUI or the handle to
%      the existing singleton*.
%
%      BIGGREENGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIGGREENGUI.M with the given input arguments.
%
%      BIGGREENGUI('Property','Value',...) creates a new BIGGREENGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BigGreenGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BigGreenGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BigGreenGUI

% Last Modified by GUIDE v2.5 22-Dec-2014 14:01:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BigGreenGUI_OpeningFcn, ...
    'gui_OutputFcn',  @BigGreenGUI_OutputFcn, ...
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


% --- Executes just before BigGreenGUI is made visible.
function BigGreenGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BigGreenGUI (see VARARGIN)

% Choose default command line output for BigGreenGUI
handles.output = hObject;


try
    Settings = GetHROIMPreviousSettings();
catch
    Settings = GetHROIMDefaultSettings();
end

save('Settings.mat','Settings')

LoadSettings(hObject,handles);

%Add in extra code folder to search path
destination = pwd;
slashind = strfind(destination,'\');
destination = destination(1:slashind(end));
destination = [destination 'Unused Code'];
if exist(destination,'dir')
    addpath(destination);
end

%Visuals
axes(handles.background);
pic = imread('OpenXYLogo.png');
% pic = imread('DSCN0416.JPG');
imagesc(pic)
%alpha(0.5)
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
BGColor = 0.94*[1 1 1];
TextColor = 'black';

set(hObject,'Color',BGColor);
labels = findobj('Style','text');
set(labels,'BackgroundColor',BGColor);
set(labels,'ForegroundColor',TextColor);
%set(labels,'FontWeight','bold');

checkboxes = findobj('Style','checkbox');
set(checkboxes,'BackgroundColor',BGColor);
set(checkboxes,'ForegroundColor',TextColor);
set(checkboxes,'FontWeight','bold');

%Resets Run button
set(handles.RunButton,'String','Run');
set(handles.RunButton,'BackgroundColor',[0 1 0]);
set(handles.RunButton,'Enable','on');

%Sets default color scheme for all figures and axes
set(0,'DefaultFigureColormap',jet);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BigGreenGUI wait for user response (see UIRESUME)
% uiwait(handles.BigGreenGUI);


% --- Outputs from this function are returned to the command line.
function varargout = BigGreenGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function background_CreateFcn(hObject, eventdata, handles)
% hObject    handle to background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate background



%%File Boxes*********************************************
function AngFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AngFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AngFileEdit as text
%        str2double(get(hObject,'String')) returns contents of AngFileEdit as a double


% --- Executes during object creation, after setting all properties.
function AngFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GrainFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GrainFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GrainFileEdit as text
%        str2double(get(hObject,'String')) returns contents of GrainFileEdit as a double


% --- Executes during object creation, after setting all properties.
function GrainFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CustScanFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CustScanFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CustScanFileEdit as text
%        str2double(get(hObject,'String')) returns contents of CustScanFileEdit as a double


% --- Executes during object creation, after setting all properties.
function CustScanFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CustScanFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OutputFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to OutputFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutputFileEdit as text
%        str2double(get(hObject,'String')) returns contents of OutputFileEdit as a double


% --- Executes during object creation, after setting all properties.
function OutputFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FirstImageEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FirstImageEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FirstImageEdit as text
%        str2double(get(hObject,'String')) returns contents of FirstImageEdit as a double

% --- Executes during object creation, after setting all properties.
function FirstImageEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FirstImageEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in UsePCFileToggle.
function UsePCFileToggle_Callback(hObject, eventdata, handles)
% hObject    handle to UsePCFileToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UsePCFileToggle
if(get(hObject,'Value'))
    set(handles.PCFileEdit,'Enable','on');
    set(handles.PCFileBrowseButton,'Enable','on');
else
    set(handles.PCFileEdit,'Enable','off');
    set(handles.PCFileBrowseButton,'Enable','off');
end

% --- Executes during object creation, after setting all properties.
function UsePCFileToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UsePCFileToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function PCFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PCFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PCFileEdit as text
%        str2double(get(hObject,'String')) returns contents of PCFileEdit as a double

% --- Executes during object creation, after setting all properties.
function PCFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





%%Browse Buttons*********************************************************
% --- Executes on button press in AngFileBrowseButton.
function AngFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to AngFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    if handles.FileDir ~= 0
        cd(handles.FileDir);
    end
end

[picname picpath] = uigetfile('*.ang','.ang file');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
set(handles.AngFileEdit,'String', [picpath picname]);
cd(w);

% --- Executes during object creation, after setting all properties.
function AngFileBrowseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in GrainFileBrowseButton.
function GrainFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to GrainFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    if handles.FileDir ~= 0
        cd(handles.FileDir);
    end
end

[picname picpath] = uigetfile('*.txt','.txt grain file');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
set(handles.GrainFileEdit,'String', [picpath picname])
cd(w);

% --- Executes during object creation, after setting all properties.
function GrainFileBrowseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in CustFileBrowseButton.
function CustFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to CustFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    if handles.FileDir ~= 0
        cd(handles.FileDir);
    end
end


[picname picpath] = uigetfile('*.txt','.txt file');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
set(handles.CustScanFileEdit,'String', [picpath picname])
cd(w);

% --- Executes during object creation, after setting all properties.
function CustFileBrowseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CustFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in OutputFileBrowseButton.
function OutputFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to OutputFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    if handles.FileDir ~= 0
        cd(handles.FileDir);
    end
end

[picname picpath] = uiputfile('.ang','Output File');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
set(handles.OutputFileEdit,'String', [picpath picname]);
cd(w);

% --- Executes during object creation, after setting all properties.
function OutputFileBrowseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in FirstImageBrowsButton.
function FirstImageBrowsButton_Callback(hObject, eventdata, handles)
% hObject    handle to FirstImageBrowsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    cd(handles.FileDir);
end

[picname picpath] = uigetfile('*.*','EBSD Image');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
set(handles.FirstImageEdit,'String', [picpath picname]);
cd(w);

% --- Executes during object creation, after setting all properties.
function FirstImageBrowsButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FirstImageBrowsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in PCFileBrowseButton.
function PCFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PCFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    if handles.FileDir ~= 0
        cd(handles.FileDir);
    end
end

[picname picpath] = uigetfile({'*.txt';'*.mat'},'PC file');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
set(handles.PCFileEdit,'String', [picpath picname]);

cd(w);

% --- Executes during object creation, after setting all properties.
function PCFileBrowseButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called







%%Settings Elements***********************************************
function AccelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AccelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AccelEdit as text
%        str2double(get(hObject,'String')) returns contents of AccelEdit as a double

% --- Executes during object creation, after setting all properties.
function AccelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AccelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SampleTiltEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SampleTiltEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampleTiltEdit as text
%        str2double(get(hObject,'String')) returns contents of SampleTiltEdit as a double

% --- Executes during object creation, after setting all properties.
function SampleTiltEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleTiltEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SampleAzimuthalEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SampleAzimuthalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SampleAzimuthalEdit as text
%        str2double(get(hObject,'String')) returns contents of SampleAzimuthalEdit as a double

% --- Executes during object creation, after setting all properties.
function SampleAzimuthalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SampleAzimuthalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CameraAzimuthalEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CameraAzimuthalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CameraAzimuthalEdit as text
%        str2double(get(hObject,'String')) returns contents of CameraAzimuthalEdit as a double

% --- Executes during object creation, after setting all properties.
function CameraAzimuthalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CameraAzimuthalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CameraElevationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CameraElevationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CameraElevationEdit as text
%        str2double(get(hObject,'String')) returns contents of CameraElevationEdit as a double

% --- Executes during object creation, after setting all properties.
function CameraElevationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CameraElevationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ScanTypePopup.
function ScanTypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to ScanTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ScanTypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ScanTypePopup
ScanTypeList = get(handles.ScanTypePopup,'String');
ScanTypeInd = get(handles.ScanTypePopup,'Value');
ScanType = ScanTypeList{ScanTypeInd};
if strcmp(ScanType,'L')
    set(handles.CustScanFileEdit,'Enable','on');
    set(handles.CustFileBrowseButton,'Enable','on');
    
else
    set(handles.CustScanFileEdit,'Enable','off');
    set(handles.CustFileBrowseButton,'Enable','off');
end

% --- Executes during object creation, after setting all properties.
function ScanTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in MaterialPopup.
function MaterialPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MaterialPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MaterialPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MaterialPopup

% --- Executes during object creation, after setting all properties.
function MaterialPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaterialPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in NumProcessorsPopup.
function NumProcessorsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to NumProcessorsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NumProcessorsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumProcessorsPopup


% --- Executes during object creation, after setting all properties.
function NumProcessorsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumProcessorsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in DoDisplayCheckBox.
function DoDisplayCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to DoDisplayCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoDisplayCheckBox

% --- Executes during object creation, after setting all properties.
function DoDisplayCheckBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DoDisplayCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called








%%Buttons*********************************************************************
% --- Executes during object creation, after setting all properties.
function PCCalibrationToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCCalibrationToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function RunButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function AdvancedButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdvancedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function HowToButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HowToButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when BigGreenGUI is resized.
function BigGreenGUI_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to BigGreenGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonString = get(handles.RunButton,'String');
if strcmp(ButtonString,'Run')
        stemp=load('Settings.mat');
    Settings=stemp.Settings;
    AngFilePath = get(handles.AngFileEdit,'String');
    if iscell(AngFilePath)
        AngFilePath = AngFilePath{1};
    end
    if ~ exist(AngFilePath,'file')
        warndlg(['Warning: the .ang file: ' AngFilePath ' was not found'],'Warning','modal');
        return
    end

    GrainFilePath = get(handles.GrainFileEdit,'String');
    if iscell(GrainFilePath)
        GrainFilePath = GrainFilePath{1};
    end
    if ~ exist(GrainFilePath,'file')
        warndlg(['Warning: the .txt grain file: ' GrainFilePath ' was not found'],'Warning','modal');
        return
    end

    FirstImagePath = get(handles.FirstImageEdit,'String');
    if iscell(FirstImagePath)
        FirstImagePath = FirstImagePath{1};
    end
    if ~ exist(FirstImagePath,'file')
        warndlg(['Warning: the first image file: ' FirstImagePath ' was not found'],'Warning','modal');
        return
    end
    OutputPath = get(handles.OutputFileEdit,'String');
    LastSlashInd = find(OutputPath == '\');
    OutputDirectory = OutputPath(1:LastSlashInd(end)-1);
    if iscell(OutputPath)
        OutputPath = OutputPath{1};
    end
    if ~ exist(OutputDirectory,'dir')
        warndlg(['Warning: the output file path: ' OutputPath ' not found'],'Warning','modal');
        return
    end

    ScanTypeList = get(handles.ScanTypePopup,'String');
    ScanTypeInd = get(handles.ScanTypePopup,'Value');
    ScanType = ScanTypeList{ScanTypeInd};
    if strcmp(ScanType,'L')
        CustomFilePath = get(handles.CustScanFileEdit,'String');
        if iscell(CustomFilePath)
            CustomFilePath = CustomFilePath{1};
        end
        if ~ exist(CustomFilePath,'file')
            warndlg(['Warning: the custom scan file ''' CustomFilePath ''' was not found'],'Warning','modal');
            return
        end
        Settings.CustomFilePath = CustomFilePath;
    end

    if get(handles.UsePCFileToggle,'Value')
        PCFilePath = get(handles.PCFileEdit,'String');
        if iscell(PCFilePath)
            PCFilePath = PCFilePath{1};
        end
        if ~ exist(PCFilePath,'file')
            warndlg(['Warning: the pattern center file ''' PCFilePath ''' was not found'],'Warning','modal');
            return
        end
    end

    Settings.AccelVoltage = str2double(get(handles.AccelEdit,'String'));

    Settings.SampleTilt = str2double(get(handles.SampleTiltEdit,'String'))*pi/180;

    Settings.SampleAzimuthal = str2double(get(handles.SampleAzimuthalEdit,'String'))*pi/180;

    Settings.CameraAzimuthal = str2double(get(handles.CameraAzimuthalEdit,'String'))*pi/180;

    Settings.CameraElevation = str2double(get(handles.CameraElevationEdit,'String'))*pi/180;

    Settings.AngFilePath = AngFilePath;

    Settings.GrainFilePath = GrainFilePath;

    Settings.FirstImagePath = FirstImagePath;

    Settings.OutputPath = get(handles.OutputFileEdit,'String');

    Settings.DoUsePCFile = get(handles.UsePCFileToggle,'Value');
    if Settings.DoUsePCFile
        Settings.PCFilePath = get(handles.PCFileEdit,'String');
    end

    MaterialList = get(handles.MaterialPopup,'String');
    MatInd = get(handles.MaterialPopup,'Value');
    Settings.Material = MaterialList{MatInd};

    Settings.ScanType = ScanType;

    Settings.DoParallel = get(handles.NumProcessorsPopup,'Value');
    Settings.DoShowPlot = get(handles.DoDisplayCheckBox,'Value');
    Settings.DoPCStrainMin = get(handles.PCCalibrationBox,'Value');
    Settings.Exit = 0;
    
    % Disable Run Button
    set(handles.RunButton,'String','Running...');
    set(handles.RunButton,'BackgroundColor',[1 0 0]);
    set(handles.RunButton,'Enable','off');

    % Run HREBSD Main
    Settings = HREBSDMain(Settings);
    
    %Check if terminated
    if Settings.Exit
        msgbox('Open XY did not finish calculation');
    end
    
    % Reset Run Button
    set(handles.RunButton,'String','Run');
    set(handles.RunButton,'BackgroundColor',[0 1 0]);
    set(handles.RunButton,'Enable','on');
    
    set(handles.PCFileEdit,'String',Settings.PCFilePath);
    
    try
        ppool = gcp('nocreate');
        %delete(ppool);
    catch
        matlabpool close force;
    end
end
    

% OutputFilePath = get(handles.OutputFileEdit,'String')
% if ~ exist(OutputFilePath,'file')
%     warndlg(['Warning: the .ang file: ' Settings.AngFilePath ' does not exist'],'Warning','modal');
%     return
% end


% --- Executes on button press in AdvancedButton.
function AdvancedButton_Callback(hObject, eventdata, handles)
% hObject    handle to AdvancedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% keyboard
% if isfield(handles,'AlreadyOpened')
%     disp('handles open')
%     stemp=load('Settings.mat');
%     Settings=stemp.Settings;
%     clear stemp
%     AdvancedSettings(Settings);
%     
% else
    stemp=load('Settings.mat');
    Settings=stemp.Settings;
    clear stemp
    
    SaveSettings(hObject, handles);
    AdvancedSettings();
    
    handles.AlreadyOpened = 1;
    
% end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in PCCalibrationBox.
function PCCalibrationBox_Callback(hObject, eventdata, handles)
% hObject    handle to PCCalibrationBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PCCalibrationBox


% --- Executes on button press in HowToButton.
function HowToButton_Callback(hObject, eventdata, handles)
% hObject    handle to HowToButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    HowToList();
    
    % --- Executes on button press in RestoreDefaultSettingsButton.
function RestoreDefaultSettingsButton_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreDefaultSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Settings = GetHROIMDefaultSettings;
save('Settings.mat','Settings')
LoadSettings(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RestoreDefaultSettingsButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RestoreDefaultSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    
% --- Executes on button press in LoadSettingsFileButton.
function LoadSettingsFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSettingsFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'FileDir')
    if handles.FileDir ~= 0
        cd(handles.FileDir);
    end
end

[picname picpath] = uigetfile('*.mat','Settings File');
cd(w);
if picname == 0 % If no file is selected
    picpath = 'No file selected';
    picname = '';
else
    analysisparamsfile = load([picpath picname]);
    if isfield(analysisparamsfile, 'Settings')
        Settings = analysisparamsfile.Settings;
        Settings.SampleTilt = Settings.SampleTilt;
        save('Settings.mat','Settings')
        LoadSettings(hObject, handles);
    else
        disp('No Settings structure found')
    end
    
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function LoadSettingsFileButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadSettingsFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in SaveCurrentSettingsButton.
function SaveCurrentSettingsButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveCurrentSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
if isfield(handles,'SavedSettingsPath')
    cd(handles.SavedSettingsPath);
    defaultname = handles.SavedSettingsName;
else
    defaultname = ['Saved Settings ' date];
end
[file path] = uiputfile([defaultname '.mat'], 'Save Settings file');
cd(w);
if ~file == 0 
    Settings = SaveSettings(hObject, handles);
    save([path file],'Settings');
    handles.SavedSettingsPath = path;
    dotindex = find(file == '.');
    file = file(1:dotindex - 1);
    handles.SavedSettingsName = file;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SaveCurrentSettingsButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveCurrentSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function LoadSettings(hObject,handles)
%Sets all fields equal to values in Settings
stemp=load('Settings.mat');
Settings=stemp.Settings;
clear stemp;

[ ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, str] = SelectMaterial('nickel');
MatStrList = str;
set(handles.MaterialPopup, 'String', MatStrList);

ScanTypeList = {'Square','Hexagonal'}; %'L' Removed 12/22/2014
set(handles.ScanTypePopup,'String',ScanTypeList);

NumberOfCores = feature('numCores');
set(handles.NumProcessorsPopup, 'String', 1:NumberOfCores);

if ~isempty(Settings.AccelVoltage)
    set(handles.AccelEdit,'String',num2str(Settings.AccelVoltage));
end
if ~isempty(Settings.SampleTilt)
    set(handles.SampleTiltEdit,'String',num2str(Settings.SampleTilt*180/pi));
end
if ~isempty(Settings.SampleAzimuthal)
    set(handles.SampleAzimuthalEdit,'String',num2str(Settings.SampleAzimuthal*180/pi));
end
if ~isempty(Settings.CameraElevation)
    set(handles.CameraElevationEdit,'String',num2str(Settings.CameraElevation*180/pi));
end
if ~isempty(Settings.CameraAzimuthal)
    set(handles.CameraAzimuthalEdit,'String',num2str(Settings.CameraAzimuthal*180/pi));
end
if ~isempty(Settings.AngFilePath)
    set(handles.AngFileEdit,'String',Settings.AngFilePath);
end
if ~isempty(Settings.GrainFilePath)
    set(handles.GrainFileEdit,'String',Settings.GrainFilePath);
end
if ~isempty(Settings.CustomFilePath)
    set(handles.CustScanFileEdit,'String',Settings.CustomFilePath);
end
if ~isempty(Settings.FirstImagePath)
    set(handles.FirstImageEdit,'String',Settings.FirstImagePath);
end
if ~isempty(Settings.OutputPath)
    set(handles.OutputFileEdit,'String',Settings.OutputPath);
end
if ~isempty(Settings.DoUsePCFile)
    set(handles.UsePCFileToggle,'Value',Settings.DoUsePCFile);
    if Settings.DoUsePCFile
        set(handles.PCFileEdit,'Enable','on');
        set(handles.PCFileBrowseButton,'Enable','on');
    end
end
if ~isempty(Settings.PCFilePath)
    set(handles.PCFileEdit,'String',Settings.PCFilePath);
end
% if ~isempty(Settings.Method)
%     Method = Settings.Method;
%     IndList = 1:length(MethodList);
%     SelectedMethodInd = IndList(strcmp(MethodList,Method));
%     set(handles.MethodPopup, 'String', MethodList, 'Value',SelectedMethodInd)
% end
if ~isempty(Settings.Material)
    Material = Settings.Material;
    IndList = 1:length(MatStrList);
    SelectedMaterialInd = IndList(strcmp(MatStrList,Material));
    set(handles.MaterialPopup, 'Value',SelectedMaterialInd)
end
if ~isempty(Settings.ScanType)
    ScanType = Settings.ScanType;
    IndList = 1:length(ScanTypeList);
    SelectedScanTypeInd = IndList(strcmp(ScanTypeList,ScanType));
    set(handles.ScanTypePopup, 'Value',SelectedScanTypeInd)
    if strcmp(ScanType,'L')
        set(handles.CustScanFileEdit,'Enable','on');
        set(handles.CustFileBrowseButton,'Enable','on');
    else
        set(handles.CustScanFileEdit,'Enable','off');
        set(handles.CustFileBrowseButton,'Enable','off');
    end
end
if ~isempty(Settings.DoParallel)
    set(handles.NumProcessorsPopup,'Value',Settings.DoParallel);
end
if ~isempty(Settings.DoShowPlot)
    set(handles.DoDisplayCheckBox,'Value',Settings.DoShowPlot);
end
if isfield(Settings,'DoPCStrainMin')
    set(handles.PCCalibrationBox,'Value',Settings.DoPCStrainMin);
end

% Update handles structure
guidata(hObject, handles);

function Settings = SaveSettings(hObject, handles)
%Updates Settings to whatever is currently in fields    
stemp=load('Settings.mat');
Settings=stemp.Settings;
clear stemp;

AngFilePath = get(handles.AngFileEdit,'String');
if iscell(AngFilePath)
    AngFilePath = AngFilePath{1};
end
if ~ exist(AngFilePath,'file')
    warndlg(['Warning: the .ang file: ' AngFilePath ' was not found'],'Warning','modal');
    return
end

GrainFilePath = get(handles.GrainFileEdit,'String');
if iscell(GrainFilePath)
    GrainFilePath = GrainFilePath{1};
end
if ~ exist(GrainFilePath,'file')
    warndlg(['Warning: the .txt grain file: ' GrainFilePath ' was not found'],'Warning','modal');
    return
end

FirstImagePath = get(handles.FirstImageEdit,'String');
if iscell(FirstImagePath)
    FirstImagePath = FirstImagePath{1};
end
if ~ exist(FirstImagePath,'file')
    warndlg(['Warning: the first image file: ' FirstImagePath ' was not found'],'Warning','modal');
    return
end

OutputPath = get(handles.OutputFileEdit,'String');
LastSlashInd = find(OutputPath == '\');
OutputDirectory = OutputPath(1:LastSlashInd(end)-1);
if iscell(OutputPath)
    OutputPath = OutputPath{1};
end
if ~ exist(OutputDirectory,'dir')
    warndlg(['Warning: the output file path: ' OutputPath ' not found'],'Warning','modal');
    return
end

ScanTypeList = get(handles.ScanTypePopup,'String');
ScanTypeInd = get(handles.ScanTypePopup,'Value');
ScanType = ScanTypeList{ScanTypeInd};
if strcmp(ScanType,'L')
    CustomFilePath = get(handles.CustScanFileEdit,'String');
    if iscell(CustomFilePath)
        CustomFilePath = CustomFilePath{1};
    end
    if ~ exist(CustomFilePath,'file')
        warndlg(['Warning: the custom scan file ''' CustomFilePath ''' was not found'],'Warning','modal');
        return
    end
    Settings.CustomFilePath = CustomFilePath;
end

if get(handles.UsePCFileToggle,'Value')
    PCFilePath = get(handles.PCFileEdit,'String');
    if iscell(PCFilePath)
        PCFilePath = PCFilePath{1};
    end
    if ~ exist(PCFilePath,'file')
        warndlg(['Warning: the pattern center file ''' PCFilePath ''' was not found'],'Warning','modal');
        return
    end
end

Settings.AccelVoltage = str2double(get(handles.AccelEdit,'String'));

Settings.SampleTilt = str2double(get(handles.SampleTiltEdit,'String'))*pi/180;

Settings.SampleAzimuthal = str2double(get(handles.SampleAzimuthalEdit,'String'))*pi/180;

Settings.CameraAzimuthal = str2double(get(handles.CameraAzimuthalEdit,'String'))*pi/180;

Settings.CameraElevation = str2double(get(handles.CameraElevationEdit,'String'))*pi/180;

Settings.AngFilePath = AngFilePath;

Settings.GrainFilePath = GrainFilePath;

Settings.OutputPath = get(handles.OutputFileEdit,'String');

Settings.FirstImagePath = FirstImagePath;

Settings.DoUsePCFile = get(handles.UsePCFileToggle,'Value');
if Settings.DoUsePCFile
    Settings.PCFilePath = get(handles.PCFileEdit,'String');
end

MaterialList = get(handles.MaterialPopup,'String');
MatInd = get(handles.MaterialPopup,'Value');
Settings.Material = MaterialList{MatInd};

Settings.ScanType = ScanType;

Settings.DoParallel = get(handles.NumProcessorsPopup,'Value');

Settings.DoShowPlot = get(handles.DoDisplayCheckBox,'Value');

Settings.DoPCStrainMin = get(handles.PCCalibrationBox,'Value');

save('Settings.mat','Settings')

guidata(hObject, handles);
    
% --- Executes when user attempts to close BigGreenGUI.
function BigGreenGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to BigGreenGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
Settings = SaveSettings(hObject, handles);
delete(hObject);
