function varargout = OutputPlotting(varargin)
% OUTPUTPLOTTING M-file for OutputPlotting.fig
%      OUTPUTPLOTTING, by itself, creates a new OUTPUTPLOTTING or raises the existing
%      singleton*.
%
%      H = OUTPUTPLOTTING returns the handle to a new OUTPUTPLOTTING or the handle to
%      the existing singleton*.
%
%      OUTPUTPLOTTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OUTPUTPLOTTING.M with the given input arguments.
%
%      OUTPUTPLOTTING('Property','Value',...) creates a new OUTPUTPLOTTING or raises the
%      existing singleton*.clc
% Starting from the left, property value pairs are
%      applied to the GUI before OutputPlotting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OutputPlotting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OutputPlotting

% Last Modified by GUIDE v2.5 15-Oct-2014 15:38:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OutputPlotting_OpeningFcn, ...
                   'gui_OutputFcn',  @OutputPlotting_OutputFcn, ...
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


% --- Executes just before OutputPlotting is made visible.
function OutputPlotting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OutputPlotting (see VARARGIN)

% Choose default command line output for OutputPlotting
handles.output = hObject;

handles.matfileloaded = 0;

if length(varargin) >= 1
    %This option allows the function to accept the settings and alpha_data
    %structs directly, but my changes broke it. If we want to keep this
    %functionality, this will need to be tweaked. ZRC 4/28/2017
    if isstruct(varargin{1})
        handles.Settings = varargin{1};
        set(handles.SettingsFileEdit,'String', [handles.Settings.AnalysisParamsPath '.mat']);
        if length(varargin) > 1
            handles.alpha_data = varargin{2};
        end
        if length(varargin) > 2
            handles.DDSettings = varargin{3};
        end
        OutputTypesList = {'Strain','Dislocation Density','Split Dislocation Density','Tetragonality','Burgers Vectors'};
        if handles.Settings.Ny == 1
            OutputTypesList = [OutputTypesList 'Line Scan Plot'];
        end
        set(handles.OptionsPopup,'String',OutputTypesList);
    %This option reads in a .mat file that OpenXY creates after finishing
    %cross corelatoin
    else
        input = varargin{1};
        try
            handles = loadSettings(input{1},handles,hObject);
        catch ME
            uiwait(errordlg([ME.message '. Please select a new file.'],...
                'File Error'))
            set(handles.SettingsFileEdit,'String','Analysis Params');
            set(handles.PlotSelectedButton,'Enabled','Off');
        end
    end
end
% handles = guidata(hObject);

smin = -0.05; % range for colormap of strain
smax = 0.05;
set(handles.StrainMinEdit,'String',num2str(smin));
set(handles.StrainMaxEdit,'String',num2str(smax));
cmin = 12.5; % range for colormap of strain
cmax = 15;
set(handles.DisloMinEdit,'String',num2str(cmin));
set(handles.DisloMaxEdit,'String',num2str(cmax));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OutputPlotting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OutputPlotting_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function SettingsFileEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SettingsFileEdit as text
%        str2double(get(hObject,'String')) returns contents of SettingsFileEdit as a double


% --- Executes during object creation, after setting all properties.
function SettingsFileEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SettingsFileEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SettingsFileBrowseButton.
function SettingsFileBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsFileBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PrevFileName = get(handles.SettingsFileEdit,'String');
[picname,picpath] = uigetfile('*.mat','Analysis parameters');
if picname == 0
    return
end
handles.CalculatedListBox.String = {};
handles.ComponentsListBox.String = {};
NewFileName = [picpath picname];
set(handles.SettingsFileEdit,'String', NewFileName);
if ~strcmp(PrevFileName,NewFileName)
    handles.matfileloaded = 0;
end
try
    handles = loadSettings(NewFileName,handles,hObject);
catch ME
    uiwait(errordlg([ME.message '. Please select a new file.'],...
        'File Error'))
    set(handles.SettingsFileEdit,'String','Analysis Params');
    set(handles.PlotSelectedButton,'Enabled','Off');
end

function handles = loadSettings(SettingsPath,handles,hObject)
% tempmat = load(SettingsPath);
% if isfield(tempmat,'Settings')
%     handles.Settings = tempmat.Settings;
%     if handles.Settings.Ny == 1
%         OutputTypesList = get(handles.OptionsPopup,'String');
%         OutputTypesList = vertcat(OutputTypesList,'Line Scan Plots');
%         set(handles.OptionsPopup,'String',OutputTypesList);
%     end
% else
%     warndlg('No Settings variable found in file')
% end
handles.DisloMinEdit.Enable = 'Off';
handles.DisloMaxEdit.Enable = 'Off';
handles.SetDislocationDefaultsButton.Enable = 'Off';

if ~exist(SettingsPath,'file')
   ME = MException('OutputPlotting:FileNotFound',...
       'Warning, the file: %s , was not found', SettingsPath);
   throw(ME);
%Loads .mat file and imports Settings and alpha_data
end

disp('Loading .mat file...');
matfile = load(SettingsPath);

if isfield(matfile,'alpha_data')
    handles.alpha_data = matfile.alpha_data;
end
if isfield(matfile,'DDSettings')
    handles.DDSettings = matfile.DDSettings;
end
if isfield(matfile,'rhos')
    handles.rhos = matfile.rhos;
end
if isfield(matfile,'Settings')
    handles.Settings = matfile.Settings;
    Settings = handles.Settings;
else
    ME = MException('OutputPlotting:NoSetttings',...
        'Warning, the file: %s, does not contain a Settings file',...
        SettingsPath);
    throw(ME);
end
handles.matfileloaded = 1;

%Updates the GUI with the appropriate options depending on the file loaded
handles.PlotSelectedButton.Enable = 'On';
plotOptions = {};
if Settings.DoStrain
    plotOptions = [plotOptions,'Strain','Tetragonality','Stress'];
end
if Settings.CalcDerivatives
    plotOptions = [plotOptions,'Dislocation Density', 'Burgers Vectors'];
    handles.DisloMinEdit.Enable = 'On';
    handles.DisloMaxEdit.Enable = 'On';
    handles.SetDislocationDefaultsButton.Enable = 'On';
end
if Settings.DoDDS
    plotOptions = [plotOptions,'Split Dislocation Density'];
    handles.DisloMinEdit.Enable = 'On';
    handles.DisloMaxEdit.Enable = 'On';
    handles.SetDislocationDefaultsButton.Enable = 'On';
end
if Settings.Ny == 1
    plotOptions = [plotOptions,'Line Scan Plots'];
end
handles.SettingsFileEdit.String = SettingsPath;
handles.OptionsPopup.String = plotOptions;
guidata(hObject, handles);



% --- Executes on selection change in CalculatedListBox.
function CalculatedListBox_Callback(hObject, eventdata, handles)
% hObject    handle to CalculatedListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CalculatedListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CalculatedListBox
SelectionType = get(handles.figure1,'SelectionType');
if strcmp(SelectionType,'open')
    OldList = get(hObject,'String');
    clickedIndex = get(hObject,'Value');
    ListIndices = 1:length(OldList);
    
    NewListIndices = ListIndices(ListIndices ~= clickedIndex);
    NewList = OldList(NewListIndices);
    if clickedIndex > 1
        set(hObject,'String',NewList,'Value', clickedIndex -1)
    else
        set(hObject,'String',NewList,'Value', clickedIndex)
    end
    
    if strcmp(OldList(clickedIndex),'Strain')
        RemoveStrainComponents(handles);
    end
    if strcmp(OldList(clickedIndex),'Dislocation Density')
        RemoveDislocationDensityComponents(handles);
    end
    if strcmp(OldList(clickedIndex),'Burgers Vectors')
        RemoveBurgersVectorComponents(handles);
    end
    if strcmp(OldList(clickedIndex), 'Stress')
       RemoveStressComponents(handles); 
    end
    
end

% --- Executes during object creation, after setting all properties.
function CalculatedListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalculatedListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OptionsPopup.
function OptionsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to OptionsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns OptionsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OptionsPopup


% --- Executes during object creation, after setting all properties.
function OptionsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OptionsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CalculateSelectedButton.
function CalculateSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in ComponentsListBox.
function ComponentsListBox_Callback(hObject, eventdata, handles)
% hObject    handle to ComponentsListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ComponentsListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ComponentsListBox
SelectionType = get(handles.figure1,'SelectionType');
if strcmp(SelectionType,'open')
    OldList = get(hObject,'String');
    clickedIndex = get(hObject,'Value');
    ListIndices = 1:length(OldList);
    
    NewListIndices = ListIndices(ListIndices ~= clickedIndex);
    NewList = OldList(NewListIndices);
    if clickedIndex > 1
        set(hObject,'String',NewList,'Value', clickedIndex -1)
    else
        set(hObject,'String',NewList,'Value', clickedIndex)
    end
    
end
    


% --- Executes during object creation, after setting all properties.
function ComponentsListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ComponentsListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotSelectedButton.
function PlotSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%Imports Settings and alpha_data, if available
FilePath = get(handles.SettingsFileEdit,'String');
%Checks if .mat file has already been imported
if ~handles.matfileloaded
    handles = loadSettings(FilePath,handles,hObject);
end

Settings = handles.Settings;
if isfield(handles,'alpha_data')
    alpha_data = handles.alpha_data;
end
if isfield(handles,'rhos')
    rhos = handles.rhos;
end
if isfield(handles,'DDSettings')
    DDSettings = handles.DDSettings;
end

%%Update File locations
UpdateFileLocations=0;
if ~strcmp(Settings.OutputPath,FilePath) && ~exist(Settings.ScanFilePath,'file') && ~exist(Settings.FirstImagePath,'file')
    UpdateFileLocations=1;
end
if ~strcmp(Settings.AnalysisParamsPath,FilePath)
    [path,name] = fileparts(FilePath);
    Settings.AnalysisParamsPath = fullfile(path,name);
end

%Update current location of the Settings .mat file
Settings.OutputPath = FilePath;
% Below assumes all files have been moved to the same folder
if UpdateFileLocations
    NewDir=FilePath(1:find(FilePath=='\',1,'last'));
    % Assumes Ang file is in the outer most path/folder
    MainPathLength=find(Settings.ScanFilePath=='\',1,'last');
    
    Settings.FirstImagePath=UpdatePath(Settings.FirstImagePath,NewDir,MainPathLength);
    newPatterns = patterns.makePatternProvider(Settings);
    newPatterns.filter = Settings.patterns.filter;
    Settings.patterns = newPatterns;
    Settings.ScanFilePath=UpdatePath(Settings.ScanFilePath,NewDir,MainPathLength);
    
    if exist('alpha_data','var') && exist('rhos','var')
        save(Settings.OutputPath ,'Settings','alpha_data','rhos','DDSettings');
    elseif exist('alpha_data','var')
        save(Settings.OutputPath ,'Settings','alpha_data'); 
    else
        save(Settings.OutputPath ,'Settings');
    end
    disp('Saving current file location');
end

%Make a call to plotting function(s) depending on what is selected
Components = get(handles.ComponentsListBox,'String');
Calculations = get(handles.CalculatedListBox,'String');
DoShowGB = get(handles.ShowGBCheckBox,'Value');

%Check for strain components
StrainComponentsList = {'e11';'e12';'e13';'e22';'e23';'e33'};
Matches = intersect(StrainComponentsList,Components);
if ~isempty(Matches)
    smin = str2double(get(handles.StrainMinEdit,'String'));
    smax = str2double(get(handles.StrainMaxEdit,'String'));
    %Check that Settings exists and has the field Settings.data. Some cases
    %may require Settings to add the loaded variable data to the Settings
    %structure.
    if ~isfield(Settings,'data')
        if exist('data','var')
            Settings.data = data;
        else
            errordlg('Loaded .mat file does not contain correct variables','Error in loaded .mat file');
        end
    end
    if isfield(Settings,'MisoTol')
        MaxMisorientation = Settings.MisoTol;
    else
        MaxMisorientation = 0;
    end
    
    StrainOutput(Settings,Matches,DoShowGB,smin,smax,MaxMisorientation);
end

%Check for Stress Components
StressComponentsList = {'VM','σ1','σ2','σ3'};
Matches = [];
Matches = intersect(StressComponentsList,Components);
if ~isempty(Matches)
    PlotStress(Settings);
end

%Check for Dislocation Density Components
DisloComponentsList = {'alpha13';'alpha23';'alpha33';'alphaTotal'};
Matches = [];
Matches = intersect(DisloComponentsList,Components);
cmin = str2double(get(handles.DisloMinEdit,'String'));
cmax = str2double(get(handles.DisloMaxEdit,'String'));

if ~isempty(Matches)
    if exist('alpha_data','var')
        DislocationDensityPlot(Settings, alpha_data, cmin, cmax, DoShowGB);
    else
        warndlg(['Warning, the file: ' FilePath ', does not contain an alpha_data file'],'Warning');
    end
end

%Check for Burgers Vectors Components
BurgVectComponentsList = {'IPF';'Dislocation_Density'; 'Crystallographic_Directions'};
Matches = [];
Matches = intersect(BurgVectComponentsList,Components);

if ~isempty(Matches)
    if exist('alpha_data','var')
        PlotBurgersVector(Settings, alpha_data);
    else
        warndlg(['Warning, the file: ' FilePath ', does not contain an alpha_data file'],'Warning');
    end
end

%Check for Split Dislocation Density
Matches = intersect('Split Dislocation Density',Calculations);
if ~isempty(Matches)
    if exist('alpha_data','var') && exist('rhos','var')
        if exist('DDSettings','var')
            avscaplots(Settings, alpha_data, rhos, DDSettings)
        else
            avscaplots(Settings, alpha_data, rhos)
        end
    else
        warndlg(['Warning, the file: ' FilePath ', does not contain alpha_data and rhos files'],'Warning');
    end
end

%check for tetragonaltity on the calculated measures list
CalcMeasuresList = get(handles.CalculatedListBox,'String');
if any(strcmp(CalcMeasuresList,'Tetragonality'))
    TetragonalityOutput(Settings,DoShowGB);
end

% If you don't want burgers vectors to have components uncomment thus and
% comment out all component related Burgers Vectors pieces of code in here
%CalcMeasuresList = get(handles.CalculatedListBox,'String');
%if any(strcmp(CalcMeasuresList,'Burgers Vectors'))
%    PlotBurgersVector(Settings, alpha_data);
%end

%Check for LineScan plots
Matches = [];
Matches = intersect('Line Scan Plots',Calculations);
if ~isempty(Matches)
    PlotLineScan(Settings);
end

%Updates Settings structure in handles struct
handles.Settings = Settings;
guidata(hObject, handles);


% --- Executes on button press in AddSelectedButton.
function AddSelectedButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddSelectedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

OptionsList = get(handles.OptionsPopup,'String');
OptionsInd = get(handles.OptionsPopup,'Value');
SelectedOption = OptionsList(OptionsInd);

ToCalculateList = get(handles.CalculatedListBox,'String');
if isempty(ToCalculateList)
    set(handles.CalculatedListBox,'String',SelectedOption)
    if strcmp(SelectedOption,'Stress')
        AddStressComponents(handles);
    end
    if strcmp(SelectedOption,'Strain')
        AddStrainComponents(handles);
    end
    if strcmp(SelectedOption,'Dislocation Density')
        AddDislocationDensityComponents(handles);
    end
    if strcmp(SelectedOption,'Burgers Vectors')
        AddBurgersVectorsComponents(handles);
    end
else
   %Add to whatever is already in there. Remove duplicates. 
   CalcList = get(handles.CalculatedListBox,'String');
   if ~any(strcmp(CalcList,SelectedOption))
        CalcList = cat(1,CalcList,SelectedOption);
        set(handles.CalculatedListBox,'String',CalcList);
        if strcmp(SelectedOption,'Strain')
            AddStrainComponents(handles);
        end
        if strcmp(SelectedOption,'Dislocation Density')
            AddDislocationDensityComponents(handles);
        end
        if strcmp(SelectedOption,'Burgers Vectors')
            AddBurgersVectorsComponents(handles);
        end
        if strcmp(SelectedOption,'Stress')
            AddStressComponents(handles);
        end
   end
end


function AddStrainComponents(handles)
    StrainComponentsList = {'e11';'e12';'e13';'e22';'e23';'e33'};
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    if isempty(CurrentComponentsList)
        set(handles.ComponentsListBox,'String',StrainComponentsList);
    else
        CurrentComponentsList = cat(1,CurrentComponentsList,StrainComponentsList);
        set(handles.ComponentsListBox,'String',CurrentComponentsList);
    end

function AddDislocationDensityComponents(handles)
    DisloComponentsList = {'alpha13';'alpha23';'alpha33';'alphaTotal'};
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    if isempty(CurrentComponentsList)
        set(handles.ComponentsListBox,'String',DisloComponentsList);
    else
        CurrentComponentsList = cat(1,CurrentComponentsList,DisloComponentsList);
        set(handles.ComponentsListBox,'String',CurrentComponentsList);
    end

function AddBurgersVectorsComponents(handles)
    BurgVectComponentsList = {'IPF';'Dislocation_Density'; 'Crystallographic_Directions'};
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    if isempty(CurrentComponentsList)
        set(handles.ComponentsListBox,'String',BurgVectComponentsList);
    else
        CurrentComponentsList = cat(1,CurrentComponentsList,BurgVectComponentsList);
        set(handles.ComponentsListBox,'String',CurrentComponentsList);
    end

function AddStressComponents(handles)
    StressComponentsList= {'VM';'σ1';'σ2';'σ3'};
    CurrentComponentsList= get(handles.ComponentsListBox,'String');
    if isempty(CurrentComponentsList)
        set(handles.ComponentsListBox,'String',StressComponentsList);
    else
        CurrentComponentsList = cat(1,CurrentComponentsList,StressComponentsList);
        set(handles.ComponentsListBox,'String',CurrentComponentsList);
    end
        
        
        
        
function RemoveStrainComponents(handles)
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    StrainComponentsList = {'e11';'e12';'e13';'e22';'e23';'e33'};
    [Matches CurrentInd] = setdiff(CurrentComponentsList,StrainComponentsList);
    CurrentComponentsList = CurrentComponentsList(CurrentInd);
    set(handles.ComponentsListBox,'String',CurrentComponentsList);
    set(handles.ComponentsListBox,'Value',1);

function RemoveDislocationDensityComponents(handles)
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    DisloComponentsList = {'alpha13';'alpha23';'alpha33';'alphaTotal'};
    [Matches CurrentInd] = setdiff(CurrentComponentsList,DisloComponentsList);
    CurrentComponentsList = CurrentComponentsList(CurrentInd);
    set(handles.ComponentsListBox,'String',CurrentComponentsList);
    set(handles.ComponentsListBox,'Value',1);

function RemoveBurgersVectorComponents(handles)
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    BurgVectComponentsList = {'IPF';'Dislocation_Density'; 'Crystallographic_Directions'};
    [Matches CurrentInd] = setdiff(CurrentComponentsList,BurgVectComponentsList);
    CurrentComponentsList = CurrentComponentsList(CurrentInd);
    set(handles.ComponentsListBox,'String',CurrentComponentsList);
    set(handles.ComponentsListBox,'Value',1);

function RemoveStressComponents(handles)
    CurrentComponentsList = get(handles.ComponentsListBox,'String');
    StressComponentsList = {'VM';'σ1';'σ2';'σ3'};
    [Matches CurrentInd] = setdiff(CurrentComponentsList,StressComponentsList);
    CurrentComponentsList = CurrentComponentsList(CurrentInd);
    set(handles.ComponentsListBox,'String',CurrentComponentsList);
    set(handles.ComponentsListBox,'Value',1);

function StrainMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StrainMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StrainMinEdit as text
%        str2double(get(hObject,'String')) returns contents of StrainMinEdit as a double


% --- Executes during object creation, after setting all properties.
function StrainMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StrainMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StrainMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StrainMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StrainMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of StrainMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function StrainMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StrainMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowGBCheckBox.
function ShowGBCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ShowGBCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowGBCheckBox



function DisloMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DisloMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DisloMinEdit as text
%        str2double(get(hObject,'String')) returns contents of DisloMinEdit as a double


% --- Executes during object creation, after setting all properties.
function DisloMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisloMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DisloMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DisloMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DisloMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of DisloMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function DisloMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisloMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SkipHelp.
function SkipHelp_Callback(hObject, eventdata, handles)
% hObject    handle to SkipHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SkipPointsHelp();


% --- Executes on button press in SetDislocationDefaultsButton.
function SetDislocationDefaultsButton_Callback(hObject, eventdata, handles)
% hObject    handle to SetDislocationDefaultsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FilePath = get(handles.SettingsFileEdit,'String');

%Loads MAT file if not already loaded
if handles.matfileloaded
    Settings = handles.Settings;
    alpha_data = handles.alpha_data;
elseif ~strcmp(FilePath, 'Analysis Params')
    disp('Loading .mat file...');
    matfile = load(FilePath);
    
    if isfield(matfile,'alpha_data')
        handles.alpha_data = matfile.alpha_data;
        alpha_data = handles.alpha_data;
        if isfield(matfile,'DDSettings')
            handles.DDSettings = matfile.DDSettings;
        end
    end
    if isfield(matfile,'Settings')
        handles.Settings = matfile.Settings;
        Settings = handles.Settings;
    else
        warndlg(['Warning, the file: ' FilePath ', does not contain a Settings file'],'Warning');
        return;
    end
    
    clear matfile;
    handles.matfileloaded = 1;
    guidata(hObject, handles);
else
    msgbox('Select an Analysis Params File');
    return;
end



%Get necessary data from Settings, if available
if isfield(Settings,'CalcDerivatives')
    if Settings.CalcDerivatives == 0
        warndlg(['Warning, the file: ' FilePath ', does not contain dislocation data'],'Warning');
        return;
    end
    
    data = Settings.data;
    stepsize_orig = abs((data.xpos(3)-data.xpos(2))/1e6); %units in meters. This is for square grid
    if strcmp(Settings.ScanType,'L')
        stepsize_orig = abs((data.xpos(5)-data.xpos(2))/1e6); %units in meters
    end
    if strcmp(Settings.NumSkipPts,'a') || strcmp(Settings.NumSkipPts,'t')
        skippts = 0;
    else
        if isnumeric(Settings.NumSkipPts)
            skippts = Settings.NumSkipPts;
        else
            skippts = str2double(Settings.NumSkipPts);
        end
    end
    stepsize = stepsize_orig*(skippts+1);

    %Calculate Default Values
    b = alpha_data.b;
    NoiseCutoff=log10((0.006*pi/180)/(stepsize*max(b))); %lower cutoff filters noise below resolution level
    LowerCutoff=log10(1/stepsize^2);
    MinCutoff=max([LowerCutoff(:),NoiseCutoff(:)]);
    UpperCutoff=log10(1/(min(b)*stepsize));
    
    set(handles.DisloMinEdit,'String',num2str(MinCutoff));
    set(handles.DisloMaxEdit,'String',num2str(UpperCutoff));
else
    warndlg(['Warning, the file: ' FilePath ', does not contain dislocation data'],'Warning');
    return;
end

% Update handles structure
guidata(hObject, handles);
    
