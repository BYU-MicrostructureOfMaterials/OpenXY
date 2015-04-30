function varargout = MainGUI(varargin)
% MAINGUI MATLAB code for MainGUI.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainGUI

% Last Modified by GUIDE v2.5 30-Apr-2015 09:41:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MainGUI_OutputFcn, ...
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


% --- Executes just before MainGUI is made visible.
function MainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainGUI (see VARARGIN)

% Choose default command line output for MainGUI
handles.output = hObject;

%Load in Settings
handles.Settings = GetHROIMDefaultSettings();

%Loads saved Settings data into GUI
if ~isempty(varargin)
    handles.Settings = MergeSettings(handles.Settings,varargin{1});
end

%Visuals
axes(handles.background);
pic = imread('OpenXYLogo.png');
imagesc(pic)
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
BGColor = 0.94*[1 1 1];
TextColor = 'black';

%Set Default handles values
handles.FileDir = pwd;
handles.ScanFileLoaded = false;
handles.ImageLoaded = false;
handles.OutputLoaded = false;

%ScanType
ScanTypeList = {'Auto-detect','Square','Hexagonal'};
set(handles.ScanTypePopup,'String',ScanTypeList);
SetPopupValue(handles.ScanTypePopup,handles.Settings.ScanType);
%Material
MaterialList = GetMaterialsList;
set(handles.MaterialPopup,'String',MaterialList);
SetPopupValue(handles.MaterialPopup,handles.Settings.Material);
%Processors
NumberOfCores = feature('numCores');
set(handles.ProcessorsPopup, 'String', 1:NumberOfCores);
set(handles.ProcessorsPopup,'Value',NumberOfCores-1);
if handles.Settings.DoParallel <= feature('numCores');
    set(handles.ProcessorsPopup,'Value',handles.Settings.DoParallel);
end
%PC Calibration
set(handles.PCCalibrationBox,'Value',handles.Settings.DoPCStrainMin);
%Display Shifts
set(handles.DisplayShiftsBox,'Value',handles.Settings.DoShowPlot);
%Files
[path,name,ext] = fileparts(handles.Settings.ScanFilePath);
SetScanFields(handles,[name ext],path);
handles = guidata(hObject);
[path,name,ext] = fileparts(handles.Settings.FirstImagePath);
SetImageFields(handles,[name ext],path);
handles = guidata(hObject);
[path,name,ext] = fileparts(handles.Settings.OutputPath);
SetOutputFields(handles,[name ext],path);
handles = guidata(hObject);

enableRunButton(handles);

%Set GUI Position
ScreenSize = get(groot,'ScreenSize');
set(hObject,'Units','pixels');
GUIsize = get(hObject,'Position');
set(handles.MainGUI,'Position',[(ScreenSize(3)-GUIsize(3))/2 (ScreenSize(4)-(500+GUIsize(4))) GUIsize(3) GUIsize(4)]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainGUI wait for user response (see UIRESUME)
% uiwait(handles.MainGUI);


% --- Outputs from this function are returned to the command line.
function varargout = MainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close MainGUI.
function MainGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MainGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
Settings = handles.Settings;
save('Settings.mat','Settings');
delete(hObject);


% --- Executes on button press in SelectScanButton.
function SelectScanButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectScanButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wd = pwd;
if ~strcmp(handles.FileDir,pwd)
    cd(handles.FileDir);
end
[name, path] = uigetfile({'*.ang;*.ctf','Scan Files (*.ang,*.ctf)'},'Select a Scan File');
cd(wd);
SetScanFields(handles,name,path);

function SetScanFields(handles,name,path)
if name ~= 0
    handles.FileDir = path;
    prevName = get(handles.ScanNameText,'String');
    prevFolder = get(handles.ScanFolderText,'String');
    if ~strcmp(prevName,name) || ~strcmp(prevFolder,path)
        set(handles.ScanNameText,'String',name);
        set(handles.ScanNameText,'TooltipString',name);
        set(handles.ScanFolderText,'String',path);
        set(handles.ScanFolderText,'TooltipString',path);
        [ScanFileData,handles.Settings.ScanParams] = ReadScanFile(fullfile(path,name));
        if isfield(handles.Settings.ScanParams,'NumColsOdd') && isfield(handles.Settings.ScanParams,'NumRows')
            SizeStr = [num2str(handles.Settings.ScanParams.NumColsOdd) 'x' num2str(handles.Settings.ScanParams.NumRows)];
        else
            SizeStr = 'Size not included in Scan File';
        end
        set(handles.ScanSizeText,'String',SizeStr);
        
        %Read ScanFile Data into Settings
        handles.Settings.ScanLength = size(ScanFileData{1},1);
        handles.Settings.Angles(:,1) = ScanFileData{1};
        handles.Settings.Angles(:,2) = ScanFileData{2};
        handles.Settings.Angles(:,3) = ScanFileData{3};
        handles.Settings.XData = ScanFileData{4};
        handles.Settings.YData = ScanFileData{5};
        handles.Settings.ScanFilePath = fullfile(path,name);
        handles.ScanFileLoaded = true;
    end 
elseif ~handles.ScanFileLoaded
    set(handles.ScanNameText,'String','Select a Scan');
    set(handles.ScanFolderText,'String','Select a Scan');
    set(handles.ScanFolderText,'TooltipString','');
    set(handles.ScanSizeText,'String','Select a Scan');
end
guidata(handles.SelectScanButton, handles);
MaterialPopup_Callback(handles.MaterialPopup, [], handles);
enableRunButton(handles);

    


% --- Executes on button press in SelectImageButton.
function SelectImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wd = pwd;
if ~strcmp(handles.FileDir,pwd)
    cd(handles.FileDir);
elseif handles.ScanFileLoaded
    cd(fileparts(handles.Settings.ScanFilePath));
end
    
[name, path] = uigetfile({'*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.png','Image Files (*.jpg,*.tif,*.bmp,*.png)'},'Select the First Image of the Scan');
cd(wd);
SetImageFields(handles,name,path);

function SetImageFields(handles,name,path)
if name ~= 0
    if strcmp(handles.FileDir,pwd)
        handles.FileDir = path;
    end
    prevName = get(handles.FirstImageNameText,'String');
    prevFolder = get(handles.ImageFolderText,'String');
    if ~strcmp(prevName,name) || ~strcmp(prevFolder,path)
        set(handles.FirstImageNameText,'String',name);
        set(handles.FirstImageNameText,'TooltipString',name);
        set(handles.ImageFolderText,'String',path);
        set(handles.ImageFolderText,'TooltipString',path);
        [x,y] = size(imread(fullfile(path,name)));
        improp = dir(fullfile(path,name));
        SizeStr = [num2str(x) 'x' num2str(y) ' (' num2str(round(improp.bytes/1024)) ' KB)'];
        set(handles.ImageSizeText,'String',SizeStr);
        handles.Settings.FirstImagePath = fullfile(path,name);
        handles.ImageLoaded = true;
    end
elseif ~handles.ImageLoaded
    set(handles.FirstImageNameText,'String','Select an Image');
    set(handles.ImageFolderText,'String','Select an Image');
    set(handles.ImageSizeText,'String','Select an Image');
end
enableRunButton(handles);
guidata(handles.SelectImageButton, handles);


% --- Executes on button press in SelectOutputButton.
function SelectOutputButton_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOutputButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wd = pwd;
if ~strcmp(handles.FileDir,pwd)
    cd(handles.FileDir);
end
[name, path] = uiputfile({'*.ang;*.ctf','Scan Files (*.ang,*.ctf)'},'Select a Scan File');
cd(wd);
SetOutputFields(handles,name,path);

function SetOutputFields(handles,name,path)
if name ~= 0
    handles.FileDir = path;
    prevName = get(handles.FirstImageNameText,'String');
    prevFolder = get(handles.ImageFolderText,'String');
    if ~strcmp(prevName,name) || ~strcmp(prevFolder,path)
        %Make sure output files aren't overwriting other files
        [~,baseName,~] = fileparts(name);
        ResultsName = ['AnalysisParams_' baseName '.mat'];
        ScanName = ['Corr_' name];
        if exist(fullfile(path,ResultsName),'file') || exist(fullfile(path,ScanName),'file')
            button = questdlg({'Output file already exists'; 'Would you like to overwrite it?'},'Run OpenXY');
            switch button
                case 'No'
                    SelectOutputButton_Callback(hObject,eventdata,handles);
                    return;
                case 'Cancel'
                    return;
            end
        end
        
        set(handles.OutputResultsText,'String',ResultsName);
        set(handles.OutputResultsText,'TooltipString',ResultsName);
        set(handles.OutputScanText,'String',ScanName);
        set(handles.OutputScanText,'TooltipString',ScanName);
        set(handles.OutputFolderText,'String',path);
        set(handles.OutputFolderText,'TooltipString',path);
        handles.Settings.OutputPath = fullfile(path,name);
        handles.OutputLoaded = true;
    end     
elseif ~handles.OutputLoaded
    set(handles.OutputResultsText,'String','Select an Output File');
    set(handles.OutputScanText,'String','Select an Output File');
    set(handles.OutputFolderText,'String','Select an Output File');
end
enableRunButton(handles);
guidata(handles.SelectOutputButton, handles);


% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Run');


% --- Executes on button press in PCCalibrationBox.
function PCCalibrationBox_Callback(hObject, eventdata, handles)
% hObject    handle to PCCalibrationBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PCCalibrationBox
handles.Settings.DoPCStrainMin = get(hObject,'Value');
guidata(hObject, handles);



% --- Executes on button press in DisplayShiftsBox.
function DisplayShiftsBox_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayShiftsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DisplayShiftsBox
handles.Settings.DoShowPlot = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on selection change in MaterialPopup.
function MaterialPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MaterialPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MaterialPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MaterialPopup
Settings = handles.Settings;
Material = GetPopupString(hObject);
handles.Settings.Material = Material;
if handles.ScanFileLoaded
    [handles.Settings.grainID, handles.Settings.Phase] = GetGrainInfo(...
        Settings.ScanFilePath, Material, Settings.ScanParams, Settings.Angles, Settings.MisoTol);
end
guidata(hObject, handles);


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


% --- Executes on selection change in ScanTypePopup.
function ScanTypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to ScanTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ScanTypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ScanTypePopup
handles.Settings.ScanType = GetPopupString(hObject);
guidata(hObject, handles);

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


% --- Executes on selection change in ProcessorsPopup.
function ProcessorsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessorsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ProcessorsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ProcessorsPopup
handles.Settings.DoParallel = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ProcessorsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProcessorsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadPrevAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPrevAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp = load('Settings.mat');
PrevSettings = temp.Settings;
clear temp
MainGUI(PrevSettings);

% --------------------------------------------------------------------
function LoadAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name,path] = uigetfile('*.mat','OpenXY Settings or Results File');
if name ~= 0
    temp = load([path name]);
    if isfield(temp,'Settings')
        NewSettings = temp.Settings;
        MainGUI(NewSettings);
    else
        warndlg('No Settings structure found in file');
    end
    clear temp;
end


% --------------------------------------------------------------------
function SaveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Settings = handles.Settings;
[name, path] = uiputfile('*.mat','Save Analysis Settings');
save(fullfile(path,name),'Settings');
disp('Analysis Saved');


% --------------------------------------------------------------------
function RestoreDefaultSettings_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreDefaultSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MainGUI;

% --------------------------------------------------------------------
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MainGUI_CloseRequestFcn(handles.MainGUI, eventdata, handles)


% --------------------------------------------------------------------
function SettingsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ROISettings_Callback(hObject, eventdata, handles)
% hObject    handle to ROISettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ScanFileLoaded && handles.ImageLoaded
    handles.Settings = ROISettingsGUI(handles.Settings,get(handles.MainGUI,'Position'));
else
    warndlg({'Cannot open ROI Settings menu'; 'Must select scan file data and first image'},'OpenXY: Invalid Operation');
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function AdvancedSettings_Callback(hObject, eventdata, handles)
% hObject    handle to AdvancedSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Settings = AdvancedSettingsGUI(handles.Settings,get(handles.MainGUI,'Position'));
guidata(hObject,handles);


% --------------------------------------------------------------------
function MicroscopeSettings_Callback(hObject, eventdata, handles)
% hObject    handle to MicroscopeSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Settings = MicroscopeSettingsGUI(handles.Settings,get(handles.MainGUI,'Position'));
guidata(hObject,handles);

function enableRunButton(handles)
if handles.ScanFileLoaded && handles.ImageLoaded && handles.OutputLoaded
    set(handles.RunButton,'Enable','on');
else
    set(handles.RunButton,'Enable','off');
end

function string = GetPopupString(Popup)
List = get(Popup,'String');
Value = get(Popup,'Value');
string = List{Value};

function SetPopupValue(Popup,String)
String = num2str(String);    
List = get(Popup,'String');
IndList = 1:length(List);
Value = IndList(strcmp(List,String));
if isempty(Value); Value =1; end;
set(Popup, 'Value', Value);

