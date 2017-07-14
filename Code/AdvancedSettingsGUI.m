function varargout = AdvancedSettingsGUI(varargin)
% ADVANCEDSETTINGSGUI MATLAB code for AdvancedSettingsGUI.fig
%      ADVANCEDSETTINGSGUI, by itself, creates a new ADVANCEDSETTINGSGUI or raises the existing
%      singleton*.
%
%      H = ADVANCEDSETTINGSGUI returns the handle to a new ADVANCEDSETTINGSGUI or the handle to
%      the existing singleton*.
%
%      ADVANCEDSETTINGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCEDSETTINGSGUI.M with the given input arguments.
%
%      ADVANCEDSETTINGSGUI('Property','Value',...) creates a new ADVANCEDSETTINGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AdvancedSettingsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AdvancedSettingsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdvancedSettingsGUI

% Last Modified by GUIDE v2.5 04-Jan-2017 14:23:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdvancedSettingsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AdvancedSettingsGUI_OutputFcn, ...
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


% --- Executes just before AdvancedSettingsGUI is made visible.
function AdvancedSettingsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdvancedSettingsGUI (see VARARGIN)

% Choose default command line output for AdvancedSettingsGUI
handles.output = hObject;

%Accept Settings from MainGUI or Load Settings.mat
handles.Fast = false;
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
else
    if length(varargin) == 2
        handles.Fast = varargin{2};
    end
    handles.MainGUI = varargin{1};
    MainHandle = guidata(handles.MainGUI);
    Settings = MainHandle.Settings;
end
handles.PrevSettings = Settings;

%Fast GUI
if handles.Fast
    set(handles.EditRefPoints,'Enable','off')
    set(handles.ToggleGrainMap,'Enable','off')
end

%HROIM Method
if ~isfield(Settings,'DoStrain')
    Settings.DoStrain = 1;
end
set(handles.DoStrain,'Value',Settings.DoStrain);

HROIMMethodList = {'Simulated-Kinematic','Simulated-Dynamic','Real-Grain Ref','Real-Single Ref'};
set(handles.HROIMMethod, 'String', HROIMMethodList);
if strcmp(Settings.HROIMMethod,'Simulated')
    SetPopupValue(handles.HROIMMethod,'Simulated-Kinematic');
elseif strcmp(Settings.HROIMMethod,'Dynamic Simulated')
    SetPopupValue(handles.HROIMMethod,'Simulated-Dynamic');
else
    if Settings.RefImageInd == 0
        SetPopupValue(handles.HROIMMethod,'Real-Grain Ref');
    else
        SetPopupValue(handles.HROIMMethod,'Real-Single Ref');
    end
end

%Standard Deviation
set(handles.StandardDeviation,'String',num2str(Settings.StandardDeviation));
%Misorientation Tolerance
set(handles.MisoTol,'String',num2str(Settings.MisoTol));
%Grain Ref Type
GrainRefImageTypeList = {'Min Kernel Avg Miso','IQ > Fit > CI','Manual'};
set(handles.GrainRefType, 'String', GrainRefImageTypeList);
SetPopupValue(handles.GrainRefType,Settings.GrainRefImageType);
%Grain ID Method
set(handles.GrainMethod,'String',{'Grain File','Find Grains'});
[~,~,ext] = fileparts(Settings.ScanFilePath);

    
if strcmp(ext,'.ctf')
    SetPopupValue(handles.GrainMethod,'Find Grains');
    set(handles.GrainMethod,'Enable','off')
elseif strcmp(Settings.ScanType,'Hexagonal') % Find Grains not yet compatibile with hexagonal scan
    SetPopupValue(handles.GrainMethod,'Grain File')
    set(handles.GrainMethod,'Enable','off')
else
    SetPopupValue(handles.GrainMethod,Settings.GrainMethod);
    set(handles.GrainMethod,'Enable','on');
end

%Min Grain Size
set(handles.MinGrainSize,'String',num2str(Settings.MinGrainSize))

%Dislocation Density Method
GNDMethods = {'Full Cross-Correlation','Partial Cross-Correlation','Orientation-based'};
set(handles.GNDMethod,'String',GNDMethods);
val = find(~cellfun('isempty',strfind(GNDMethods,Settings.GNDMethod)));
set(handles.GNDMethod,'Value',val);

%Calculate Dislocation Density
set(handles.DoDD,'Value', Settings.CalcDerivatives);
%Number of Skip Points
set(handles.SkipPoints,'String',Settings.NumSkipPts);
%IQ Cutoff
set(handles.IQCutoff,'String',num2str(Settings.IQCutoff));

%SplitDD
%Do SplitDD
set(handles.DoSplitDD,'Value',Settings.DoDDS);
DDSMethods = {'Nye-Kroner','Nye-Kroner (Pantleon)','Distortion Matching'};
set(handles.DDSMethod,'String',DDSMethods);
index = find(strcmp(DDSMethods,Settings.DDSMethod));
set(handles.DDSMethod,'Value',index)

%Kernel Avg Miso
if iscell(Settings.KernelAvgMisoPath)
    Settings.KernelAvgMisoPath = Settings.KernelAvgMisoPath{1};
end
if exist(Settings.KernelAvgMisoPath,'file')
    [path,name,ext] = fileparts(Settings.KernelAvgMisoPath);
    set(handles.KAMname,'String',[name ext]);
    set(handles.KAMpath,'String',path);
else
    set(handles.KAMname,'String','No File Selected');
    set(handles.KAMpath,'String','No File Selected');
end

%Calculation Options
set(handles.EnableProfiler,'Value',Settings.EnableProfiler);

%Set Position and Visuals
if ~isempty(handles.MainGUI)
    MainSize = get(handles.MainGUI,'Position');
    set(hObject,'Units','pixels');
    GUIsize = get(hObject,'Position');
    set(hObject,'Position',[MainSize(1)-GUIsize(3)-20 MainSize(2)-(GUIsize(4)-MainSize(4))+26 GUIsize(3) GUIsize(4)]);
    movegui(hObject,'onscreen');
end
handles.ColorSave = get(handles.SaveButton,'BackgroundColor');
handles.ColorEdit = [1 1 0]; % Yellow
gui = findall(handles.AdvancedSettingsGUI,'KeyPressFcn','');
set(gui,'KeyPressFcn',@AdvancedSettingsGUI_KeyPressFcn);

% Update handles structure
handles.Settings = Settings;
handles.GrainMap = [];
handles.edited = false;

%Update Components
GNDMethod_Callback(handles.GNDMethod, eventdata, handles);
handles = guidata(hObject);
if ~strcmp(handles.GNDMethod.String{handles.GNDMethod.Value},'Partial Cross-Correlation')
    DoStrain_Callback(handles.DoStrain, eventdata, handles,1);
    handles = guidata(hObject);
end
HROIMMethod_Callback(handles.HROIMMethod, eventdata, handles,1);
handles = guidata(hObject);
DoDD_Callback(handles.DoDD, eventdata, handles);
handles = guidata(hObject);
GrainMethod_Callback(handles.GrainMethod, eventdata, handles,true)
handles = guidata(hObject);
guidata(hObject, handles);


% UIWAIT makes AdvancedSettingsGUI wait for user response (see UIRESUME)
%uiwait(handles.AdvancedSettingsGUI);


% --- Outputs from this function are returned to the command line.
function varargout = AdvancedSettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close AdvancedSettingsGUI.
function AdvancedSettingsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to AdvancedSettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if ishandle(handles.GrainMap)
    close(handles.GrainMap)
end
delete(hObject);

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
    MainHandles = guidata(handles.MainGUI);
    MainHandles.Settings = handles.Settings;
    
    % Orientation-based GND
    if strcmp(handles.Settings.GNDMethod,'Orientation') && ~handles.Settings.DoStrain
        MainHandles.SkipImageLoad = true;
    end
    
    % Call enableRunButton
    enableRunButton = getappdata(handles.MainGUI,'enableRunButton');
    enableRunButton(MainHandles);
    guidata(handles.MainGUI,MainHandles);
    
    UpdateMainGUIs = getappdata(handles.MainGUI,'UpdateGUIs');
    UpdateMainGUIs(MainHandles);
end
handles.PrevSettings = handles.Settings;
handles.edited = false;
guidata(hObject,handles);
SaveColor(handles)

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Settings = handles.PrevSettings;
guidata(hObject,handles);
AdvancedSettingsGUI_CloseRequestFcn(handles.AdvancedSettingsGUI, eventdata, handles);


% --- Executes on selection change in HROIMMethod.
function HROIMMethod_Callback(hObject, eventdata, handles,~)
% hObject    handle to HROIMMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns HROIMMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HROIMMethod
contents = cellstr(get(hObject,'String'));
HROIMMethod = contents{get(hObject,'Value')};
switch HROIMMethod
    case 'Simulated-Kinematic'
        set(handles.HROIMlabel,'String','Iteration Limit');
        set(handles.HROIMedit,'String',num2str(handles.Settings.IterationLimit));
        set(handles.GrainRefType,'Enable','off');
        set(handles.SelectKAM,'Enable','off');
        set(handles.EditRefPoints,'Enable','off')
        handles.Settings.HROIMMethod = 'Simulated';
        if get(handles.DoStrain,'Value')
            set(handles.HROIMedit,'Enable','on');
        else
            set(handles.HROIMedit,'Enable','off');
        end
        handles.Settings.RefInd = [];
        ToggleGrainMap_Callback(handles.ToggleGrainMap,eventdata,handles);
    case 'Simulated-Dynamic'
        %Check for EMsoft
        EMsoftPath = GetEMsoftPath;
        if isempty(EMsoftPath)
            HROIMMethod = 'Simulated';
            SetPopupValue(hObject,'Simulated-Kinematic');
            handles.Settings.HROIMMethod = HROIMMethod;
        end
        
        %Validate EMsoft setup
        if ~isempty(EMsoftPath)  && strcmp(HROIMMethod,'Simulated-Dynamic')
            %Check if Monte-Carlo Simulation data has been generated
            valid = 1;
            if isfield(handles.Settings,'Phase')
                mats = unique(handles.Settings.Phase);
            elseif strcmp(handles.Settings.Material,'Scan File')
                valid = 0;
                warndlgpause({'Material must be specified before selecting Simulation-Dynamic','Resetting to kinematic simulation'},'Select Material');
                SetPopupValue(hObject,'Simulated-Kinematic');
                handles.Settings.HROIMMethod = 'Simulated';
                mats = {};
            else
                mats = handles.Settings.Material;
            end
            EMdataPath = fullfile(fileparts(EMsoftPath),'EMdata');
            EMsoftMats = dir(EMdataPath);
            EMsoftMats = {EMsoftMats(~cellfun(@isempty,strfind({EMsoftMats.name},'EBSDmaster'))).name}';
            EMsoftMats = cellfun(@(x) x(1:strfind(x,'_EBSDmaster')-1),EMsoftMats,'UniformOutput',false);
            inlist = ismember(mats,EMsoftMats);
            if ~all(inlist)
                valid = 0;
                msg = {['No master EBSD files for: ' strjoin(mats(~inlist),', ')], ['Search path: ' EMdataPath],'Resetting to kinematic simulation'};
                warndlgpause(msg,'No EMsoft data found');
                SetPopupValue(hObject,'Simulated-Kinematic');
                handles.Settings.HROIMMethod = 'Simulated';
            end
            
            %Set method to simualated dynamic
            if valid
                set(handles.HROIMlabel,'String','Iteration Limit');
                set(handles.HROIMedit,'String',num2str(handles.Settings.IterationLimit));
                set(handles.GrainRefType,'Enable','off');
                set(handles.SelectKAM,'Enable','off');
                set(handles.EditRefPoints,'Enable','off')
                handles.Settings.HROIMMethod = 'Dynamic Simulated';
                if get(handles.DoStrain,'Value')
                    set(handles.HROIMedit,'Enable','on');
                else
                    set(handles.HROIMedit,'Enable','off');
                end
                handles.Settings.RefInd = [];
                ToggleGrainMap_Callback(handles.ToggleGrainMap,eventdata,handles);
            end
        end
    case 'Real-Grain Ref'
        set(handles.HROIMlabel,'String','Ref Image Index');
        handles.Settings.RefImageInd = 0;
        set(handles.HROIMedit,'String',num2str(handles.Settings.RefImageInd));
        set(handles.HROIMedit,'Enable','off');
        set(handles.GrainRefType,'Enable','on');
        if ~handles.Fast, set(handles.EditRefPoints,'Enable','on'), end
        handles.Settings.HROIMMethod = 'Real';
        if nargin == 3
            GrainRefType_Callback(handles.GrainRefType, eventdata, handles);
        end
        set(handles.GrainRefType,'Enable','on');
        handles = guidata(hObject);
    case 'Real-Single Ref'
        set(handles.HROIMlabel,'String','Ref Image Index');
        if handles.Settings.RefImageInd == 0
            handles.Settings.RefImageInd = 1;
            if ~handles.Fast
                handles.Settings.RefInd(1:handles.Settings.ScanLength) = 1;
            end
        end
        set(handles.HROIMedit,'String',num2str(handles.Settings.RefImageInd));
        set(handles.HROIMedit,'Enable','on');
        set(handles.GrainRefType,'Enable','on');
        set(handles.EditRefPoints,'Enable','off')
        GrainRefType_Callback(handles.GrainRefType, eventdata, handles);
        handles = guidata(hObject);
        handles.Settings.HROIMMethod = 'Real';
        handles.Settings.GrainRefImageType = 'Manual';
        SetPopupValue(handles.GrainRefType,'Manual');
        set(handles.GrainRefType,'Enable','off');
end
if ValChanged(handles,'HROIMMethod')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

function warndlgpause(msg,title)
h = warndlg(msg,title);
uiwait(h,7);
if isvalid(h); close(h); end;


% --- Executes during object creation, after setting all properties.
function HROIMMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HROIMMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HROIMedit_Callback(hObject, eventdata, handles)
% hObject    handle to HROIMedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HROIMedit as text
%        str2double(get(hObject,'String')) returns contents of HROIMedit as a double
contents = cellstr(get(handles.HROIMMethod,'String'));
HROIMMethod = contents{get(handles.HROIMMethod,'Value')};
switch HROIMMethod
    case 'Simulated-Kinematic'
        handles.Settings.IterationLimit = str2double(get(hObject,'String'));
    case 'Simulated-Dynamic'
        handles.Settings.IterationLimit = str2double(get(hObject,'String'));
    case 'Real-Grain Ref'
        handles.Settings.RefImageInd = 0;
    case 'Real-Single Ref'
        input = str2double(get(hObject,'String'));
        if isfield(handles.Settings,'ScanLength') && ...
                input > 0 && input <= handles.Settings.ScanLength
            handles.Settings.RefImageInd = round(input);
            handles.Settings.RefInd(1:handles.Settings.ScanLength) = round(input);
            set(hObject,'String',num2str(round(input)));
            ToggleGrainMap_Callback(handles.ToggleGrainMap,eventdata,handles);
        else
            msgbox(['Invalid input. Must be between 1 and ' num2str(handles.Settings.ScanLength) '.'],'Invalid Image Index');
            set(hObject,'String',num2str(handles.Settings.RefImageInd));
        end
end
if ValChanged(handles,'IterationLimit') || ValChanged(handles,'RefImageInd')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function HROIMedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HROIMedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StandardDeviation_Callback(hObject, eventdata, handles)
% hObject    handle to StandardDeviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StandardDeviation as text
%        str2double(get(hObject,'String')) returns contents of StandardDeviation as a double
handles.Settings.StandardDeviation = str2double(get(hObject,'String'));
if ValChanged(handles,'StandardDeviation')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function StandardDeviation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StandardDeviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MisoTol_Callback(hObject, eventdata, handles)
% hObject    handle to MisoTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MisoTol as text
%        str2double(get(hObject,'String')) returns contents of MisoTol as a double
handles.Settings.MisoTol = str2double(get(hObject,'String'));
handles.Settings.grainID = CalcGrainID(handles.Settings);

GrainRefType_Callback(handles.GrainRefType, eventdata, handles);
if ValChanged(handles,'MisoTol')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MisoTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MisoTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GrainRefType.
function GrainRefType_Callback(hObject, eventdata, handles)
% hObject    handle to GrainRefType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GrainRefType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GrainRefType
contents = cellstr(get(hObject,'String'));
GrainRefType = contents{get(hObject,'Value')};
if strcmp(GrainRefType,'Min Kernel Avg Miso')
    set(handles.SelectKAM,'Enable','on');
else
    set(handles.SelectKAM,'Enable','off');
end
if ~handles.Fast
    switch GrainRefType
        case 'Min Kernel Avg Miso'
            if ~isfield(handles.Settings,'KernelAvgMisoPath') || ~exist(handles.Settings.KernelAvgMisoPath,'file')
                SelectKAM_Callback(handles.SelectKAM,eventdata,handles);
                handles = guidata(hObject);
                handles.Settings.RefInd = handles.AutoRefInds;
            end
        case 'IQ > Fit > CI'
            handles.AutoRefInds = UpdateAutoInds(handles,handles.Settings.GrainRefImageType);
            handles.Settings.RefInd = handles.AutoRefInds;
            ToggleGrainMap_Callback(handles.ToggleGrainMap,eventdata,handles);
        case 'Manual'
            grainIDs = unique(handles.Settings.grainID);
            if ~isfield(handles.Settings,'RefInd') || isempty(handles.Settings.RefInd)
                handles.AutoRefInds = UpdateAutoInds(handles,handles.Settings.GrainRefImageType);
                handles.Settings.RefInd = handles.AutoRefInds;
            end
            RefGrainIDs = handles.Settings.grainID(unique(handles.Settings.RefInd));
            if length(grainIDs) ~= length(RefGrainIDs) || ~all(sort(grainIDs)==sort(RefGrainIDs))
                w = warndlg('Grains have changed. New reference indices must be selected.');
                uiwait(w,3)
                EditRefPoints_Callback(handles.EditRefPoints, eventdata, handles);
                handles = guidata(hObject);
            end
            ToggleGrainMap_Callback(handles.ToggleGrainMap,eventdata,handles);
    end
end
handles.Settings.GrainRefImageType = GrainRefType;
if ValChanged(handles,'GrainRefImageType')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function GrainRefType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainRefType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DoDD.
function DoDD_Callback(hObject, eventdata, handles)
% hObject    handle to DoDD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoDD
handles.Settings.CalcDerivatives = get(hObject,'Value');
if get(hObject,'Value')
    set(handles.DoSplitDD,'Enable','on');
    set(handles.SkipPoints,'Enable','on');
    set(handles.IQCutoff,'Enable','on');
    set(handles.GNDMethod,'Enable','on');
    GNDMethod_Callback(handles.GNDMethod, eventdata, handles);
    DoSplitDD_Callback(handles.DoSplitDD, eventdata, handles);
    handles = guidata(hObject);
else
    set(handles.DoStrain,'Enable','on');
    set(handles.DoSplitDD,'Enable','off');
    set(handles.SkipPoints,'Enable','off');
    set(handles.IQCutoff,'Enable','off');
    set(handles.GNDMethod,'Enable','off');
    DoSplitDD_Callback(handles.DoSplitDD, eventdata, handles);
    handles = guidata(hObject);
end
if ValChanged(handles,'CalcDerivatives')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);



function SkipPoints_Callback(hObject, eventdata, handles)
% hObject    handle to SkipPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SkipPoints as text
%        str2double(get(hObject,'String')) returns contents of SkipPoints as a double
%Input validation
Settings = handles.Settings;
UserInput = get(hObject,'String');
if isempty(str2num(UserInput))
    if ~strcmp(UserInput, 'a') && ~strcmp(UserInput, 't')
        set(hObject, 'String', Settings.NumSkipPts);
        warndlg('Input must be numerical, "a" or "t"');
    end
elseif str2double(UserInput) < 0
    set(hObject, 'String', Settings.NumSkipPts);
    warndlg('Input must be positive');
else
    if strcmp(Settings.ScanType,'Hexagonal')
        set(hObject, 'String', round(str2double(UserInput)*2)/2);
    else
        set(hObject, 'String', round(str2double(UserInput)));
    end
end
handles.Settings.NumSkipPts = str2double(get(hObject,'String'));

%Updates handles object
if ValChanged(handles,'NumSkipPts')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function SkipPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SkipPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IQCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to IQCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IQCutoff as text
%        str2double(get(hObject,'String')) returns contents of IQCutoff as a double
handles.Settings.IQCutoff = str2double(get(hObject,'String'));
if ValChanged(handles,'IQCutoff')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function IQCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IQCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in DoSplitDD.
function DoSplitDD_Callback(hObject, eventdata, handles)
% hObject    handle to DoSplitDD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoSplitDD
Settings = handles.Settings;
if isfield(Settings,'Phase')
    allMaterials = unique(Settings.Phase);
else
    allMaterials = {Settings.Material};
end

if get(hObject,'Value')
    valid = CheckSplitDDMaterials(allMaterials);
    if valid
        enable = 'on';
    else
        set(hObject,'Value',0);
        enable = 'off';
    end
else
    set(hObject,'Value',0);
    enable = 'off';
end
if strcmp(get(hObject,'Enable'),'off')
    enable = 'off';
end
set(handles.DDSMethod,'Enable',enable);
handles.Settings.DoDDS = get(hObject,'Value');
if ValChanged(handles,'DoDDS')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes on selection change in SplitDDMethod.
function SplitDDMethod_Callback(hObject, eventdata, handles)
% hObject    handle to SplitDDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SplitDDMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SplitDDMethod
contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
switch val
    case 'No weighting'
        minscheme = 1;
    case 'Energy'
        minscheme = 2;
    case 'CRSS'
        minscheme = 3;
    case 'CRSS + Schmid'
        minscheme = 4;
end
handles.Settings.rdoptions.minscheme = minscheme;
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function SplitDDMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SplitDDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in SplitDDOpt.
function SplitDDOpt_Callback(hObject, eventdata, handles)
% hObject    handle to SplitDDOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SplitDDOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SplitDDOpt
contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
switch val
    case 'L1'
        L1 = 1; x0type = 0;
    case 'L2'
        L1 = 0; x0type = 1;
    case 'L1 from L2'
        L1 = 1; x0type = 1;
end
handles.Settings.rdoptions.L1 = L1;
handles.Settings.rdoptions.x0type = x0type;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SplitDDOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SplitDDOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DDSMethod.
function DDSMethod_Callback(hObject, eventdata, handles)
% hObject    handle to DDSMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DDSMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DDSMethod
contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
handles.Settings.DDSMethod = val;
handles.Settings.rdoptions.Pantleon = strcmp(val,'Pantleon');

if ValChanged(handles,'DDSMethod')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function DDSMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DDSMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectKAM.
function SelectKAM_Callback(hObject, eventdata, handles)
% hObject    handle to SelectKAM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = pwd;
if exist(handles.Settings.ScanFilePath,'file')
    path = fileparts(handles.Settings.ScanFilePath);
else
    path = pwd;
end
cd(path);
[name, path] = uigetfile('*.txt','OIM Map Data');
if name ~= 0 %Nothing selected
    set(handles.KAMname,'String',name);
    set(handles.KAMname,'TooltipString',name);
    set(handles.KAMpath,'String',path);
    set(handles.KAMpath,'TooltipString',path);
    handles.Settings.KernelAvgMisoPath = fullfile(path,name);
    
    %Get RefImageInds
    handles.AutoRefInds = UpdateAutoInds(handles,handles.Settings.GrainRefImageType);
    guidata(hObject,handles);
end
cd(w);
if ValChanged(handles,'KernelAvgMisoPath')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);



function SetPopupValue(Popup,String)
String = num2str(String);    
List = get(Popup,'String');
IndList = 1:length(List);
Value = IndList(strcmp(List,String));
if isempty(Value); Value =1; end;
set(Popup, 'Value', Value);



% --- Executes on button press in EnableProfiler.
function EnableProfiler_Callback(hObject, eventdata, handles)
% hObject    handle to EnableProfiler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnableProfiler
handles.Settings.EnableProfiler = get(hObject,'Value');

if ValChanged(handles,'EnableProfiler')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes on button press in DoStrain.
function DoStrain_Callback(hObject, eventdata, handles,~)
% hObject    handle to DoStrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoStrain
if get(hObject,'Value')
    set(handles.HROIMMethod,'Enable','on');
    set(handles.HROIMedit,'Enable','on');
    set(handles.StandardDeviation,'Enable','on');
    set(handles.MisoTol,'Enable','on');
    set(handles.GrainRefType,'Enable','on');
    if ~handles.Fast, set(handles.EditRefPoints,'Enable','on'), end
else
    set(handles.HROIMMethod,'Enable','off');
    set(handles.HROIMedit,'Enable','off');
    %set(handles.StandardDeviation,'Enable','off');
    %set(handles.MisoTol,'Enable','off');
    %set(handles.GrainRefType,'Enable','off');
    set(handles.EditRefPoints,'Enable','off');
end
if nargin == 3
HROIMMethod_Callback(handles.HROIMMethod,eventdata,handles);
end
handles.Settings.DoStrain = get(hObject,'Value');

if ValChanged(handles,'DoStrain')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


% --- Executes on selection change in GrainMethod.
function GrainMethod_Callback(hObject, eventdata, handles, init)
% hObject    handle to GrainMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GrainMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GrainMethod
if nargin < 4
    init = false;
end
contents = get(hObject,'String');
Method = contents{get(hObject,'Value')};
if ~strcmp(handles.Settings.GrainMethod,Method) || init
    handles.Settings.GrainMethod = Method;
    if ~handles.Fast
        if strcmp(Method,'Find Grains')
            set(handles.MinGrainSize,'Enable','on')
            handles.Settings.grainID = CalcGrainID(handles.Settings);
        else
            set(handles.MinGrainSize,'Enable','off')
            handles.Settings.grainID = handles.Settings.GrainVals.grainID;
        end
    end
end
GrainRefType_Callback(handles.GrainRefType, eventdata, handles);
if ValChanged(handles,'GrainMethod')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

    


% --- Executes during object creation, after setting all properties.
function GrainMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinGrainSize_Callback(hObject, eventdata, handles)
% hObject    handle to MinGrainSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinGrainSize as text
%        str2double(get(hObject,'String')) returns contents of MinGrainSize as a double
handles.Settings.MinGrainSize = str2double(get(hObject,'String'));
if ~handles.Fast
    handles.Settings.grainID = CalcGrainID(handles.Settings);
end
GrainRefType_Callback(handles.GrainRefType, eventdata, handles);
if ValChanged(handles,'MinGrainSize')
    handles.edited = true;
end
SaveColor(handles)
% guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function MinGrainSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinGrainSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ToggleGrainMap.
function ToggleGrainMap_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleGrainMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleGrainMap
if get(hObject,'Value') && ~handles.Fast
    handles.GrainMap = OpenGrainMap(handles);
    cla
    GrainMap = vec2map(handles.Settings.grainID,handles.Settings.Nx,handles.Settings.ScanType);
    if size(GrainMap,1) == 1 %Line Scans
        GrainMap = repmat(GrainMap,round(size(GrainMap,2)/6),1);
    end
    imagesc(GrainMap)
    axis image
    
    if strcmp(handles.Settings.HROIMMethod,'Real')
        if handles.Settings.RefImageInd == 0
            if isfield(handles.Settings,'RefInd')
                [X,Y] = ind2sub2([handles.Settings.Nx,handles.Settings.Ny],handles.Settings.RefInd,handles.Settings.ScanType);
            end
        else
            [X,Y] = ind2sub2([handles.Settings.Nx,handles.Settings.Ny],handles.Settings.RefImageInd,handles.Settings.ScanType);
        end
        hold on
        plot(X,Y,'kd','MarkerFaceColor','k')
    end
    guidata(hObject,handles);
elseif ishandle(handles.GrainMap)
    close(handles.GrainMap)
    set(hObject,'BackgroundColor',[1 1 1]*0.94)
else
    set(hObject,'BackgroundColor',[1 1 1]*0.94)
end


% --- Executes on button press in EditRefPoints.
function EditRefPoints_Callback(hObject, eventdata, handles)
% hObject    handle to EditRefPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.GrainMap) || ~isvalid(handles.GrainMap)
    %Get List of Available options
    list = get(handles.GrainRefType,'String');
    GrainRefType = list(get(handles.GrainRefType,'Value'));
    
    options = list(~strcmp(list,'Manual'));
    if ~isfield(handles.Settings,'KernelAvgMisoPath') || ~exist(handles.Settings.KernelAvgMisoPath,'dir')
        options = options(~strcmp(options,'Min Kernel Avg Miso'));
    end
    
    %Query User for selection
    if length(options)>1
        %Check if current selection is in the list of possible options
        if ~ismember(GrainRefType,options)
            def = options{1};
        else
            def = GrainRefType;
        end
        sel = questdlg('Select Method for Automatic selection (for leftover grains)','Manual Reference Selection',...
            options,def);
    else
        sel = options;
    end
    
    %Generate New Ref Inds, if the selected method is different than the previously used method
    if ~strcmp(sel,GrainRefType) || ~isfield(handles,'AutoRefInds')
        handles.AutoRefInds = UpdateAutoInds(handles,sel);
    end
    
    %Get Previously Inds or Start New
    Inds = [];
    if isfield(handles.Settings,'RefInd')
        sel2 = questdlg({'Existing Manual Inds detected';'Edit map or clear?'},'Manual Reference Selection','Edit','Clear','Edit');
        if strcmp(sel2,'Edit')
            Inds = handles.Settings.RefInd;
        end
    end
    
    %Manually Edit Inds
    % handles.GrainMap = OpenGrainMap(handles);
    handles.GrainMap = PointSelectionGUI(handles.AdvancedSettingsGUI,'RefPoints',Inds,@saveRefPoints);
    guidata(hObject,handles);
end

function saveRefPoints(handles,inds)
% Add the Auto inds that were not put in manually, then  generates the
% refference inds.
inds = inds';
grainID = handles.Settings.grainID;
AutoRefInds = handles.AutoRefInds;
[Grains,GrainInds,ic] = unique(grainID);
GrainRefInds = AutoRefInds(GrainInds);
Grain = grainID(inds);
EmptyGrains = Grains(~ismember(Grains,Grain));
[~,sortI] = sort([Grain;EmptyGrains]);
IndsAll = [inds; GrainRefInds(EmptyGrains)];
IndsAll = IndsAll(sortI);

RefInd = IndsAll(ic);

handles.Settings.RefInd = RefInd;
if ValChanged(handles,'RefInd')
    handles.edited = true;
end
SaveColor(handles)

guidata(handles.AdvancedSettingsGUI,handles);

function AutoRefInds = UpdateAutoInds(handles,GrainRefType)
if strcmp(GrainRefType,'Min Kernel Avg Miso')
    AutoRefInds = GetRefImageInds(...
        {handles.Settings.Angles;handles.Settings.IQ;handles.Settings.CI;handles.Settings.Fit},...
        handles.Settings.grainID, handles.Settings.KernelAvgMisoPath);
else 
    AutoRefInds = GetRefImageInds(...
        {handles.Settings.Angles;handles.Settings.IQ;handles.Settings.CI;handles.Settings.Fit}, handles.Settings.grainID);
end

function GrainMap = OpenGrainMap(handles)
if ~ishandle(handles.GrainMap)
    pos = get(handles.AdvancedSettingsGUI,'Position');
    GrainMap = figure('Position',[pos(1)+pos(3)+15 pos(2) 500 500]);
else
    figure(handles.GrainMap)
    GrainMap = handles.GrainMap;
end
func = @(~,~) set(handles.ToggleGrainMap,'Value',0,'BackgroundColor',[1 1 1]*0.94);
GrainMap.Name = 'Grain Map';
GrainMap.MenuBar = 'None';
GrainMap.IntegerHandle = 'off';
GrainMap.DeleteFcn = func;
set(handles.ToggleGrainMap,'Value',1,'BackgroundColor',[1 1 0])



% --- Executes on selection change in GNDMethod.
function GNDMethod_Callback(hObject, eventdata, handles)
% hObject    handle to GNDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GNDMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GNDMethod
contents = get(hObject,'String');
set(handles.DoStrain,'Enable','on');
sel = contents{get(hObject,'Value')};
switch sel
    case 'Full Cross-Correlation'
        handles.Settings.GNDMethod = 'Full';
    case 'Partial Cross-Correlation'
        handles.Settings.GNDMethod = 'Partial';
        handles.Settings.DoStrain = 1;
        set(handles.DoStrain,'Value',1);
        DoStrain_Callback(handles.DoStrain, eventdata, handles);
        if ~isfield(handles.Settings,'data')
            set(handles.DoStrain,'Enable','off');
        else
            set(handles.DoStrain,'Enable','on');
        end
    case 'Orientation-based'
        handles.Settings.GNDMethod = 'Orientation';
        
end
if ValChanged(handles,'GNDMethod')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function GNDMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GNDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SaveColor(handles)
if handles.edited
    set(handles.SaveButton,'BackgroundColor',handles.ColorEdit);
else
    set(handles.SaveButton,'BackgroundColor',handles.ColorSave);
end

function changed = ValChanged(handles,value)
if isfield(handles.PrevSettings,value)
    if ischar(handles.Settings.(value))
        changed = ~strcmp(handles.Settings.(value),handles.PrevSettings.(value));
    else
        changed =  ~isequal(handles.Settings.(value),handles.PrevSettings.(value));
    end
else
    changed = true;
end


% --- Executes on key press with focus on AdvancedSettingsGUI and none of its controls.
function AdvancedSettingsGUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to AdvancedSettingsGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
% Save Figure with CTRL-S
if strcmp(eventdata.Key,'s') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
    SaveButton_Callback(handles.SaveButton, eventdata, handles);
end
% Close Figure with CTRL-L
if strcmp(eventdata.Key,'l') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
    CancelButton_Callback(handles.SaveButton, eventdata, handles);
end

