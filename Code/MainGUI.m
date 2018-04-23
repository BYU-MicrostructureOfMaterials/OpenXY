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

% Last Modified by GUIDE v2.5 31-Oct-2017 12:38:13

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
handles.Fast = false;
if ~isempty(varargin)
    switch length(varargin)
        case 1
            if isstruct(varargin{1})
                handles.Settings = MergeSettings(handles.Settings,varargin{1});
                SaveSettings(handles);
            elseif (ischar(varargin{1}) && strcmp(varargin{1},'Fast')) || (islogical(varargin{1}) && varargin{1})
                handles.Fast = true;
            end
        case 2
            if isstruct(varargin{1})
                handles.Settings = MergeSettings(handles.Settings,varargin{1});
                SaveSettings(handles);
            end
            if (ischar(varargin{2}) && strcmp(varargin{2},'Fast')) || (islogical(varargin{2}) && varargin{2})
                handles.Fast = true;
            end
    end
end

%Set up Fast GUI
if handles.Fast
    set(handles.SubScan,'Enable','off');
    set(handles.TestButton,'Enable','off');
end

%Load System Settings
OpenXYPath = '';
if exist('SystemSettings.mat','file')
    load SystemSettings
end
if ~exist('understand','var')
    understand = LicenseGUI;
    if ~understand
        error('Must acknowlege understanding of terms to use OpenXY')
    end
end
if ~exist(OpenXYPath,'dir')
    OpenXYPath = fileparts(which('MainGUI'));
    save('SystemSettings','OpenXYPath');
end
if exist('pos','var')
    set(hObject,'Position',pos)
end
save('SystemSettings.mat','understand','-append')
%Change working directory
XYpath = fileparts(mfilename('fullpath'));
if ~strcmp(pwd,XYpath)
    p = path;
    cd(XYpath);
    path(p);
end
addpath(genpath(XYpath));
addpath('quaternions')
addpath('DDS')

%Add sub folder(s)
if ~exist('temp','dir')
    mkdir('temp');
end


% Check for Required Matlab Toolboxes
tb = ver;
if ~any(strcmp({tb.Name},'Image Processing Toolbox'))
    w = warndlg({'Image Processing Toolbox not installed.','Mutual Information won''t be calculated'});
    uiwait(w,5);
    handles.Settings.CalcMI = 0;
else
    handles.Settings.CalcMI = 1;
end

if ~any(strcmp({tb.Name},'Parallel Computing Toolbox')) && Settings.DoParallel > 1
    w = warndlg({'Parallel Computing Toolbox not installed';'Switching to serial processing'});
    uiwait(w,5);
    handles.Settings.DoParallel = 1;
end


%Visuals
axes(handles.background);
pic = imread('OpenXYLogo.png');
imagesc(pic)
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
set(handles.SelectImageButton,'Enable','on');
BGColor = 0.94*[1 1 1];
TextColor = 'black';

%Sets default color scheme for all figures and axes
set(0,'DefaultFigureColormap',jet);

%Set Default handles values
handles.FileDir = pwd;
handles.ScanFileLoaded = false;
handles.ImageLoaded = false;
handles.OutputLoaded = false;

%ScanType
ScanTypeList = {'Square','Hexagonal'};
set(handles.ScanTypePopup,'String',ScanTypeList);
SetPopupValue(handles.ScanTypePopup,handles.Settings.ScanType);
%Material
MaterialList = GetMaterialsList;
set(handles.MaterialPopup,'String',MaterialList);
SetPopupValue(handles.MaterialPopup,handles.Settings.Material);
%Display Shifts
set(handles.DisplayShiftsBox,'Value',handles.Settings.DoShowPlot);
%Processors
NumberOfCores = feature('numCores');
set(handles.ProcessorsPopup, 'String', 1:NumberOfCores);
if NumberOfCores > 1
    DoParallel = NumberOfCores-1;
else
    DoParallel = NumberOfCores;
end
if handles.Settings.DoParallel > NumberOfCores
    set(handles.ProcessorsPopup,'Value',DoParallel);
else
    set(handles.ProcessorsPopup,'Value',handles.Settings.DoParallel);
end
ProcessorsPopup_Callback(handles.ProcessorsPopup,eventdata,handles);
handles = guidata(handles.ProcessorsPopup);

%Orientation-based GND
if strcmp(handles.Settings.GNDMethod,'Orientation') && ~handles.Settings.DoStrain
    handles.SkipImageLoad = true;
else
    handles.SkipImageLoad = false;
end

%Files
[fpath,name,ext] = fileparts(handles.Settings.ScanFilePath);
if strcmp(ext,'.h5'); filterind = 2; else filterind = 1; end;
SetScanFields(handles,[name ext],fpath,filterind);
handles = guidata(hObject);
[fpath,name,ext] = fileparts(handles.Settings.FirstImagePath);
SetImageFields(handles,[name ext],fpath);
handles = guidata(hObject);
[fpath,name,ext] = fileparts(handles.Settings.OutputPath);
SetOutputFields(handles,[name ext],fpath);
handles = guidata(hObject);

% Reset Run Button
set(handles.RunButton,'String','Run');
set(handles.RunButton,'BackgroundColor',[0 1 0]);
enableRunButton(handles);

% Store Key functions
setappdata(hObject,'enableRunButton',@enableRunButton);
setappdata(hObject,'UpdateGUIs',@UpdateGUIs);

% Instantiate holders for other GUIs
handles.MicroscopeGUI = [];
handles.AdvancedGUI = [];
handles.ROIGUI = [];
handles.TestGeomGUI = [];
handles.PCGUI = [];

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
SaveSettings(handles);
pos = get(handles.MainGUI,'Position');
save('SystemSettings.mat','pos','-append')
CloseGUIs(handles)
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
[name, path, filterind] = uigetfile({'*.ang;*.ctf','Scan Files (*.ang,*.ctf)';'*.h5','OIM HDF5 Files (*.h5)'},'Select a Scan File');
cd(wd);
SetScanFields(handles,name,path,filterind);

function SetScanFields(handles,name,path,filterind)
if name ~= 0
    handles.FileDir = path;
    prevName = get(handles.ScanNameText,'String');
    prevFolder = get(handles.ScanFolderText,'String');
    if ~strcmp(prevName,name) || ~strcmp(prevFolder,path) || ~isfield(handles.Settings,'ScanParams')
        %Truncate long strings
        if size(name,2) > 50
            nameT = [name(1:47),'...'];
        else
            nameT = name;
        end
        if size(path,2) > 50
            pathT = [path(1:47),'...'];
        else
            pathT = path;
        end
        %Update GUI labels
        set(handles.ScanNameText,'String',nameT);
        set(handles.ScanNameText,'TooltipString',name);
        set(handles.ScanFolderText,'String',pathT);
        set(handles.ScanFolderText,'TooltipString',path);
        
        if handles.Fast
            handles.Settings.ScanFilePath = fullfile(path,name);
        else
            try
                handles.Settings = ImportScanInfo(handles.Settings,name,path);
            catch ME
                if strcmp(ME.identifier,'OpenXY:MissingGrainFile')
                    set(handles.ScanNameText,'String','Select a Scan');
                    set(handles.ScanFolderText,'String','Select a Scan');
                    set(handles.ScanFolderText,'TooltipString','');
                    set(handles.ScanSizeText,'String','Select a Scan');
                    if (strcmp(ME.message,'No'))
                        errordlg('You cannot use an OIM scan without a grain file!','Grain file required!')
                    end
                    return
                elseif strcmp(ME.identifier,'OpenXY:MissingcprFile')
                    set(handles.ScanNameText,'String','Select a Scan');
                    set(handles.ScanFolderText,'String','Select a Scan');
                    set(handles.ScanFolderText,'TooltipString','');
                    set(handles.ScanSizeText,'String','Select a Scan');
                    if (strcmp(ME.message,'No'))
                        errordlg('You cannot use an AZtec scan without a .cpr file!','.cpr file required!')
                    end
                    return
                else
                    set(handles.ScanNameText,'String','Select a Scan');
                    set(handles.ScanFolderText,'String','Select a Scan');
                    set(handles.ScanFolderText,'TooltipString','');
                    set(handles.ScanSizeText,'String','Select a Scan');
                    openFiles = fopen('all');
                    for ii = openFiles
                        fclose(ii);
                    end
                    rethrow(ME);
                end
            end
            %Set ScanType
            SetPopupValue(handles.ScanTypePopup,handles.Settings.ScanType);
            
            %Validate Scan Size
            SizeStr =  [num2str(handles.Settings.Nx) 'x' num2str(handles.Settings.Ny)];
            set(handles.ScanSizeText,'String',SizeStr);
            
            %Check if Material Read worked
            handles.ScanFileLoaded = true;
            MaterialPopup_Callback(handles.MaterialPopup, [], handles);
            handles = guidata(handles.MainGUI);
            
            if filterind == 1 %Not h5
                %Get Image Names
                if handles.ImageLoaded
                    handles.Settings.ImageNamesList = ImportImageNamesList(handles.Settings);
                end
            else
                set(handles.SelectImageButton,'Enable','off');
                handles.ImageLoaded = 1;
                set(handles.FirstImageNameText,'String','N/A');
                set(handles.ImageFolderText,'String','N/A');
                set(handles.ImageSizeText,'String','N/A');
            end
        end
    end
    
    %Remove Subscan
    if all(isfield(handles.Settings,{'Inds','Resize'}))
        handles.Settings = rmfield(handles.Settings,{'Inds','Resize'});
    end
    handles.ScanFileLoaded = true;
elseif ~handles.ScanFileLoaded
    set(handles.ScanNameText,'String','Select a Scan');
    set(handles.ScanFolderText,'String','Select a Scan');
    set(handles.ScanFolderText,'TooltipString','');
    set(handles.ScanSizeText,'String','Select a Scan');
end
guidata(handles.SelectScanButton, handles);
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
        %Truncate long strings
        if size(name,2) > 37
            nameT = [name(1:34),'...'];
        else
            nameT = name;
        end
        if size(name,2) > 37
            pathT = [path(1:34),'...'];
        else
            pathT = path;
        end

        %Update GUI labels
        set(handles.FirstImageNameText,'String',nameT);
        set(handles.FirstImageNameText,'TooltipString',name);
        set(handles.ImageFolderText,'String',pathT);
        set(handles.ImageFolderText,'TooltipString',path);
        
        [x,y,~] = size(imread(fullfile(path,name)));
        improp = dir(fullfile(path,name));
        SizeStr = [num2str(x) 'x' num2str(y) ' (' num2str(round(improp.bytes/1024)) ' KB)'];
        set(handles.ImageSizeText,'String',SizeStr);
        handles.Settings.FirstImagePath = fullfile(path,name);
        handles.Settings.PixelSize = x;
        handles.Settings.ROISize = round((handles.Settings.ROISizePercent * .01)*handles.Settings.PixelSize);
        handles.Settings.PhosphorSize = handles.Settings.PixelSize * handles.Settings.mperpix;
        handles.Settings.imsize = [x,y];
        
        %Get Image Names
        if handles.ScanFileLoaded && ~handles.Fast
            handles.Settings.ImageNamesList = ImportImageNamesList(handles.Settings);
        end
        
        %Determine if the image has a custom tag in header
        info = imfinfo(handles.Settings.FirstImagePath);
        if isfield(info,'UnknownTags')
            if ~isempty(strfind(info.UnknownTags.Value,'<pattern-center-x-pu>'))
                handles.Settings.ImageTag = true;
                handles.Settings.VHRatio = info.Height/info.Width;
            end
        end
    end
    handles.ImageLoaded = true;
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
[name, path] = uiputfile({'*.ang;*.ctf','Scan Files (*.ang,*.ctf)'},'Select a Scan File',handles.Settings.OutputPath);
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
                    SelectOutputButton_Callback(handles.SelectOutputButton,[],handles);
                    return;
                case 'Cancel'
                    return;
            end
        end
        %Truncate long strings
        if size(ResultsName,2) > 45
            ResultsNameT = [ResultsName(1:42),'...'];
        else
            ResultsNameT = name;
        end
        if size(ScanName,2) > 45
            ScanNameT = [ScanName(1:42),'...'];
        else
            ScanNameT = ScanName;
        end
        if size(path,2) > 42
            pathT = [path(1:39),'...'];
        else
            pathT = path;
        end
        %Update GUI labels
        set(handles.OutputResultsText,'String',ResultsNameT);
        set(handles.OutputResultsText,'TooltipString',ResultsName);
        set(handles.OutputScanText,'String',ScanNameT);
        set(handles.OutputScanText,'TooltipString',ScanName);
        set(handles.OutputFolderText,'String',pathT);
        set(handles.OutputFolderText,'TooltipString',path);
        handles.Settings.OutputPath = fullfile(path,name);
    end     
    handles.OutputLoaded = true;
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
Settings = handles.Settings;

%Set Settings fields
Settings.Exit = false;
Settings.DisplayGUI = true;

% Disable Run Button
set(handles.RunButton,'String','Running...');
set(handles.RunButton,'Enable','off');
set(handles.RunButton,'BackgroundColor',[1 0 0]);
drawnow

% Run HREBSD Main with error catching
try
    SaveSettings(handles);
    Settings = HREBSDMain(Settings);
catch ME
    handles.ScanFileLoaded = false;
    Reset_RunButton(handles);
    enableRunButton(handles);
    save('temp/ErrorSettings.mat');
    msg = 'OpenXY encountered an error. Re-select the scan file to reset.';
    cause = MException('MATLAB:OpenXY',msg);
    ME = addCause(ME,cause);
    rethrow(ME)
    clear java
end

%Check if terminated
if Settings.Exit
    msgbox('Open XY did not finish calculation');
end

% Reset Run Button
Reset_RunButton(handles);
guidata(handles.MainGUI,handles);

function Reset_RunButton(handles)
set(handles.RunButton,'String','Run');
set(handles.RunButton,'BackgroundColor',[0 1 0]);
set(handles.RunButton,'Enable','on');

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
Material = GetPopupString(hObject);
handles.Settings.Material = Material;

if handles.ScanFileLoaded && ~handles.Fast
    if strcmp(Material,'Scan File')
        handles.Settings.Phase = handles.Settings.GrainVals.Phase;
    else
        handles.Settings.Phase(1:handles.Settings.ScanLength) = {Material};
    end
end
guidata(hObject, handles);
enableRunButton(handles);


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
DoParallel = get(hObject,'Value');
handles.Settings.DoParallel = DoParallel;
if DoParallel > 1
    set(handles.DisplayShiftsBox,'Enable','off');
    set(handles.DisplayShiftsBox,'Value',false);
else
    set(handles.DisplayShiftsBox,'Enable','on');
end
DisplayShiftsBox_Callback(handles.DisplayShiftsBox,eventdata,handles);
handles = guidata(hObject);
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
RestoreDefaultSettings_Callback(hObject, eventdata, handles);
MainGUI(PrevSettings,handles.Fast);

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
        MainGUI(NewSettings,handles.Fast);
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
if name ~= 0
    save(fullfile(path,name),'Settings');
    disp('Analysis Saved');
end

% --------------------------------------------------------------------
function RestoreDefaultSettings_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreDefaultSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CloseGUIs(handles);
MainGUI(handles.Fast);

% --------------------------------------------------------------------
function ExportSettings_Callback(hObject, eventdata, handles)
% hObject    handle to ExportSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','Settings',handles.Settings)
SaveSettings(handles)

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
    handles.ROIGUI = ROISettingsGUI(handles.MainGUI,handles.Fast);
else
    warndlg({'Cannot open ROI Settings menu'; 'Must select scan file data and first image'},'OpenXY: Invalid Operation');
end
guidata(hObject,handles);
% Relocate PCGUI
if ~isempty(handles.PCGUI) && isvalid(handles.PCGUI)
    PCCalSettings_Callback(handles.PCCalSettings, eventdata, handles); handles = guidata(hObject);
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function AdvancedSettings_Callback(hObject, eventdata, handles)
% hObject    handle to AdvancedSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ScanFileLoaded
    handles.AdvancedGUI = AdvancedSettingsGUI(handles.MainGUI,handles.Fast);
else
    warndlg({'Cannot open Advanced Settings menu'; 'Must select scan file data.'},'OpenXY: Invalid Operation');
end
enableRunButton(handles)
guidata(hObject,handles);

% --------------------------------------------------------------------
function MicroscopeSettings_Callback(hObject, eventdata, handles)
% hObject    handle to MicroscopeSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MicroscopeGUI = MicroscopeSettingsGUI(handles.MainGUI);
guidata(hObject,handles);

% --------------------------------------------------------------------
function PCCalSettings_Callback(hObject, eventdata, handles)
% hObject    handle to PCCalSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ScanFileLoaded && handles.ImageLoaded
    handles.PCGUI = PCGUI(handles.MainGUI,handles.Fast);
else
    warndlg({'Cannot open PC Calibration menu'; 'Must select scan file data and first image'},'OpenXY: Invalid Operation');
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function TestGeometry_Callback(hObject, eventdata, handles)
% hObject    handle to TestGeometry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ScanFileLoaded && handles.ImageLoaded
    TestGeomGUI = TestGeometry(handles.MainGUI);
    handles = guidata(handles.MainGUI); % To get HREBSDPrep Data
    handles.TestGeomGUI = TestGeomGUI;
else
    warndlg({'Cannot open Test Geometry menu';'Must select scan file data and first image'},'OpenXY: Invalid Operation')
end
guidata(hObject,handles);
% Relocate PCGUI
if ~isempty(handles.PCGUI) && isvalid(handles.PCGUI)
    PCCalSettings_Callback(handles.PCCalSettings, eventdata, handles); handles = guidata(hObject);
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function OpenAll_Callback(hObject, eventdata, handles)
% hObject    handle to OpenAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROISettings_Callback(handles.ROISettings, eventdata, handles); handles = guidata(hObject);
TestGeometry_Callback(handles.TestGeometry, eventdata, handles); handles = guidata(hObject);
AdvancedSettings_Callback(handles.AdvancedSettings, eventdata, handles); handles = guidata(hObject);
MicroscopeSettings_Callback(handles.MicroscopeSettings, eventdata, handles); handles = guidata(hObject);
PCCalSettings_Callback(handles.PCCalSettings, eventdata, handles); handles = guidata(hObject);


function enableRunButton(handles)
if handles.ScanFileLoaded && (handles.ImageLoaded || handles.SkipImageLoad) && handles.OutputLoaded
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

% --- Executes during object creation, after setting all properties.
function MainGUI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%Set GUI Position
ScreenSize = get(groot,'ScreenSize');
set(hObject,'Units','pixels');
movegui(hObject,'center');
GUIsize = get(hObject,'Position');
%set(handles.MainGUI,'Position',[(ScreenSize(3)-GUIsize(3))/2 (ScreenSize(4)-(500+GUIsize(4))) GUIsize(3)*1.1 GUIsize(4)]);
if ismac
    GUIsize(3) = GUIsize(3)*1.1;
    set(hObject,'Position',GUIsize);
end


% --- Executes on button press in TestButton.
function TestButton_Callback(hObject, eventdata, handles)
% hObject    handle to TestButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ScanFileLoaded && handles.ImageLoaded
    TestSettingsPntbyPnt(handles.Settings,handles.MainGUI);
else
    warndlg({'Cannot run test'; 'Must select scan file data and first image'},'OpenXY: Invalid Operation');
end
guidata(hObject,handles);


% --- Executes on button press in SubScan.
function SubScan_Callback(hObject, eventdata, handles)
% hObject    handle to SubScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ScanFileLoaded
    [im, PlotType] = ChoosePlot([handles.Settings.Nx handles.Settings.Ny],handles.Settings.IQ,handles.Settings.Angles);
    [X,Y] = SelectSubscan(im,PlotType);
    Inds = 1:handles.Settings.ScanLength;
    IndMap = vec2map(Inds',handles.Settings.Nx,handles.Settings.ScanType);
    SubInds = IndMap(Y(1):Y(2),X(1):X(2));
    handles.Settings.Inds = reshape(SubInds',[numel(SubInds) 1]);
    
    %Update Size
    newsize = fliplr(size(SubInds));
    handles.Settings.Resize = newsize;
    SizeStr =  [num2str(newsize(1)) 'x' num2str(newsize(2)) ' (Subscan)'];
    set(handles.ScanSizeText,'String',SizeStr);
    guidata(handles.MainGUI,handles);
end

function CloseGUIs(handles)
if ~isempty(handles.MicroscopeGUI) && isvalid(handles.MicroscopeGUI)
    close(handles.MicroscopeGUI)
end
if ~isempty(handles.AdvancedGUI) && isvalid(handles.AdvancedGUI)
    close(handles.AdvancedGUI)
end
if ~isempty(handles.ROIGUI) && isvalid(handles.ROIGUI)
    close(handles.ROIGUI)
end
if ~isempty(handles.PCGUI) && isvalid(handles.PCGUI)
    close(handles.PCGUI)
end
if ~isempty(handles.TestGeomGUI) && isvalid(handles.TestGeomGUI)
    close(handles.TestGeomGUI)
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text31.
function text31_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CloseGUIs(handles)

function SaveSettings(handles)
Settings = handles.Settings;
save('Settings.mat','Settings');

function UpdateGUIs(handles)
if ~isempty(handles.ROIGUI) && isvalid(handles.ROIGUI)
    h = guidata(handles.ROIGUI);
    h.Settings = handles.Settings;
    guidata(handles.ROIGUI,h);
end
if ~isempty(handles.PCGUI) && isvalid(handles.PCGUI)
    h = guidata(handles.PCGUI);
    h.Settings = handles.Settings;
    guidata(handles.PCGUI,h);
end
if ~isempty(handles.TestGeomGUI) && isvalid(handles.TestGeomGUI)
    h = guidata(handles.TestGeomGUI);
    h.Settings = handles.Settings;
    guidata(handles.TestGeomGUI,h);
end
if ~isempty(handles.MicroscopeGUI) && isvalid(handles.MicroscopeGUI)
    h = guidata(handles.MicroscopeGUI);
    h.Settings = handles.Settings;
    guidata(handles.MicroscopeGUI,h);
end
if ~isempty(handles.AdvancedGUI) && isvalid(handles.AdvancedGUI)
    h = guidata(handles.AdvancedGUI);
    h.Settings = handles.Settings;
    guidata(handles.AdvancedGUI,h);
end


% --- Executes on key press with focus on MainGUI and none of its controls.
function MainGUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MainGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if any(strcmp(eventdata.Modifier,'shift')) && strcmp(eventdata.Key,'b')
    Settings = HREBSDPrep(handles.Settings);
    if isfield(Settings,'grainsHaveBeenSplit') && Settings.grainsHaveBeenSplit
        Settings.grainID = Settings.oldGrains.grainID;
        Settings.RefInd = Settings.oldGrains.RefInd;
        Settings.oldGrains = [];
        Settings.grainsHaveBeenSplit = false;
    else
        tolerance = inputdlg('input tolerance (degrees)','Tolerance');
        tolerance = str2double(tolerance);
        if isempty(tolerance) || isnan(tolerance) || tolerance < 0
            disp('Enter a valid tolerance')
            return
        end
        Settings.grainsHaveBeenSplit = true;
        Settings.oldGrains.grainID = Settings.grainID;
        Settings.oldGrains.RefInd = Settings.RefInd;
        [Settings.grainID,Settings.RefInd] = subGrains(Settings,tolerance);
    end
    handles.Settings = Settings;
    guidata(hObject,handles);
end
    
