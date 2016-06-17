function varargout = PCGUI(varargin)
% PCGUI MATLAB code for PCGUI.fig
%      PCGUI, by itself, creates a new PCGUI or raises the existing
%      singleton*.
%
%      H = PCGUI returns the handle to a new PCGUI or the handle to
%      the existing singleton*.
%
%      PCGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCGUI.M with the given input arguments.
%
%      PCGUI('Property','Value',...) creates a new PCGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PCGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PCGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PCGUI

% Last Modified by GUIDE v2.5 17-Jun-2016 12:45:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PCGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PCGUI_OutputFcn, ...
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


% --- Executes just before PCGUI is made visible.
function PCGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PCGUI (see VARARGIN)

%Accept Settings from MainGUI or Load Settings.mat
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
else
    Settings = varargin{1};
end

%Populate PCMethod Box
TypeString = {'Strain Minimization','Grid','Tiff','Manual'};
if ~Settings.ImageTag; TypeString(3) = []; end;
set(handles.NewPCType,'String',TypeString);

%Populate List Box
if ~isfield(Settings,'PCList')
    Settings.PCList = {Settings.ScanParams.xstar,Settings.ScanParams.ystar,Settings.ScanParams.zstar,...
        'Scan File','Naive','Default',{''}};
end
set(handles.PCList,'String',Settings.PCList(:,6));

%Create IPF map and save it
if ~isfield(handles,'IPF_map')
    g = zeros(3,3,Settings.ScanLength);
    for i = 1:Settings.ScanLength
        g(:,:,i) = euler2gmat(Settings.Angles(i,:));
    end
    handles.IPF_map = PlotIPF(g,[Settings.Nx Settings.Ny],Settings.ScanType,0);
end

%Create IQ map and save it
if ~isfield(handles,'IQ_map')
    handles.IQ_map = vec2map(Settings.IQ,Settings.Nx,Settings.ScanType);
end

%Get VHRatio
if isfield(Settings.ScanParams,'VHRatio')
    handles.V = Settings.ScanParams.VHRatio;
else
    im = imread(Settings.FirstImagePath);
    [Y,X,~] = size(im);
    handles.V = Y/X;
end

%Select Current PC
if size(Settings.PCList,2) == 8
    IndCol = [Settings.PCList{:,8}];
    Settings.PCList(:,8) = []; %Remove column
    ListInds = 1:length(IndCol);
    index = ListInds(logical(IndCol)    );
else
    index = 1;
end
set(handles.PCList,'Value',index);

% Update handles structure
handles.Settings = Settings;
guidata(hObject, handles);

%Update PC 
PCList_Callback(hObject, eventdata, handles);

% UIWAIT makes PCGUI wait for user response (see UIRESUME)
uiwait(handles.PCGUI);


% --- Outputs from this function are returned to the command line.
function varargout = PCGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
index = GetListIndex(handles);
IndCol = zeros(size(handles.Settings.PCList,1),1);
IndCol(index) = 1;
handles.Settings.PCList(:,8) = num2cell(IndCol);
varargout{1} = handles.Settings;
delete(handles.PCGUI);

% --- Executes when user attempts to close PCGUI.
function PCGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PCGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

% --- Executes on button press in CloseButton.
function CloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PCGUI_CloseRequestFcn(handles.PCGUI, eventdata, handles);

% --- Executes on selection change in PCList.
function PCList_Callback(hObject, eventdata, handles)
% hObject    handle to PCList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PCList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PCList
index = GetListIndex(handles);
xstar = handles.Settings.PCList{index,1};
ystar = handles.Settings.PCList{index,2};
zstar = handles.Settings.PCList{index,3};
set(handles.XStarLabel,'String',xstar);
set(handles.YStarLabel,'String',ystar);
set(handles.ZStarLabel,'String',zstar);

if strcmp(handles.Settings.PCList{index,5},'Naive')
    handles.Settings.XStar = xstar - handles.Settings.XData/handles.Settings.PhosphorSize;
    detector_angle = handles.Settings.SampleTilt-handles.Settings.CameraElevation;
    handles.Settings.YStar = ystar + handles.Settings.YData/handles.Settings.PhosphorSize*sin(detector_angle);
    handles.Settings.ZStar = zstar + handles.Settings.YData/handles.Settings.PhosphorSize*cos(detector_angle);
else
    handles.Settings.XStar(:) = xstar;
    handles.Settings.YStar(:) = ystar;
    handles.Settings.ZStar(:) = zstar;
end
UpdatePlot(handles)

%Edit on Double-click
SelectionType = get(handles.PCGUI,'SelectionType');
if strcmp(SelectionType,'open')
    set(handles.PCGUI,'SelectionType','normal');
    EditPC_Callback(handles.EditPC, eventdata, handles);
    handles = guidata(handles.PCGUI);
end
guidata(handles.PCGUI,handles)



% --- Executes during object creation, after setting all properties.
function PCList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NewPC.
function NewPC_Callback(hObject, eventdata, handles)
% hObject    handle to NewPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
type = GetPopupString(handles.NewPCType);
index = GetListIndex(handles);
Settings = handles.Settings;
Sel = Settings.PCList(index,:);

if strcmp(type,'Strain Minimization')
    %Setup Initial Params
    def_name = 'StrainMin';
    count = sum(cell2mat(strfind(handles.Settings.PCList(:,6),def_name))>0);
    if count
        def_name = [def_name num2str(count)];
    end
    PCSettings = PCEdit([Sel(1:3) 'Strain Minimization' Sel(5) def_name {''}],handles.V);
    if ~isempty([PCSettings{1:3}])
        
        %Perform Strain Minimization
        PCData = PCStrainMinimization(Settings,PCSettings{5});

        %Add New PC to List
        Settings.PCList(end+1,:) = {PCData.MeanXStar PCData.MeanYStar PCData.MeanZStar  PCSettings{4:6} PCData};
        set(handles.PCList,'String',Settings.PCList(:,6));
        handles.Settings = Settings;
        guidata(handles.PCGUI,handles);
    end
elseif strcmp(type,'Manual')
     %Setup Initial Params
    def_name = 'Manual';
    count = sum(cell2mat(strfind(handles.Settings.PCList(:,6),def_name))>0);
    if count
        def_name = [def_name num2str(count)];
    end
    PCSettings = PCEdit([Sel(1:3) 'Manual' Sel(5) def_name {''}],handles.V);
    if ~isempty([PCSettings{1:3}])
        count = sum(cell2mat(strfind(handles.Settings.PCList(:,6),PCSettings{6}))>0);
        if count
            PCSettings{6} = [PCSettings{6} num2str(count)];
        end

        %Add to PC List
        Settings.PCList(end+1,:) = PCSettings;
        set(handles.PCList,'String',Settings.PCList(:,6));
        handles.Settings = Settings;
        guidata(handles.PCGUI,handles);
    end
elseif strcmp(type,'Grid')
    def_name = 'Grid';
    count = sum(cell2mat(strfind(handles.Settings.PCList(:,6),def_name))>0);
    if count
        def_name = [def_name num2str(count)];
    end
    plots.IQ_map = handles.IQ_map; plots.IPF_map = handles.IPF_map;
    PCSettings = PCEdit([Sel(1:3) 'Grid' Sel(5) def_name {''}],handles.V,plots);
    
    if ~isempty([PCSettings{1:3}])
        PCData = PCSettings{7};
        if isempty(PCData.CalibrationIndices)
            warndlg('No Calibration Indices Selected. Calibration Aborted')
        else
            PCData = PCGrid(Settings,PCSettings{7});
        
            %Add to PC List
            Settings.PCList(end+1,:) = {PCData.xstar PCData.ystar PCData.zstar...
                'Grid' 'Naive' def_name PCData};
            set(handles.PCList,'String',Settings.PCList(:,6));
            handles.Settings = Settings;
            guidata(handles.PCGUI,handles);
        end
    end
end


% --- Executes on selection change in NewPCType.
function NewPCType_Callback(hObject, eventdata, handles)
% hObject    handle to NewPCType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NewPCType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NewPCType


% --- Executes during object creation, after setting all properties.
function NewPCType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewPCType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EditPC.
function EditPC_Callback(hObject, eventdata, handles)
% hObject    handle to EditPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = GetListIndex(handles);
plots.IQ_map = handles.IQ_map; plots.IPF_map = handles.IPF_map;
EditedPC = PCEdit(handles.Settings.PCList(index,:),handles.V,plots);
if ~isempty([EditedPC{1:3}])
    XStars = abs([handles.Settings.PCList{:,1}] - EditedPC{1}) < 1e-6;
    YStars = abs([handles.Settings.PCList{:,2}] - EditedPC{2}) < 1e-6;
    ZStars = abs([handles.Settings.PCList{:,3}] - EditedPC{3}) < 1e-6;
    planefit = handles.Settings.PCList{index,5};
    name = handles.Settings.PCList{index,6};
    
    %Check for rename
    rename = [name '_Edit'];
    if ~strcmp(name,EditedPC{6})
        rename = EditedPC{6};
    end
    count = sum(cell2mat(strfind(handles.Settings.PCList(:,6),rename))>0);
    if count > 0
        rename = [rename num2str(count)];
    end
    
    %Edit or Add
    GridEdit = false;
    SREdit = false;
    if ~any(XStars&YStars&ZStars) %Manually Edited PC
        EditedPC{4} = 'Manual';
        handles.Settings.PCList(end+1,:) = [EditedPC(1:5) rename {''}];
        set(handles.PCList,'String',handles.Settings.PCList(:,6));
    elseif ~strcmp(name,EditedPC{6}) %Rename only
        if any(strcmp(handles.Settings.PCList(:,6),EditedPC{6}))
            handles.Settings.PCList{index,6} = rename;
        else
            handles.Settings.PCList{index,6} = EditedPC{6};
        end
        set(handles.PCList,'String',handles.Settings.PCList(:,6));
    end
    if ~strcmp(planefit,EditedPC{5}) %PlaneFit changed
        handles.Settings.PCList{index,5} = EditedPC{5};
    end
    
    %Check for changes requiring recalibration
    if strcmp(EditedPC{4},'Strain Minimization')
        if isfield(EditedPC{7},'CalibrationIndices')
            if length(EditedPC{7}.CalibrationIndices) ~= length(handles.Settings.PCList{index,7}.CalibrationIndices)
                SREdit = true;
            elseif ~all(EditedPC{7}.CalibrationIndices == handles.Settings.PCList{index,7}.CalibrationIndices) %Calibration Points changed
                SREdit = true;
            end
        end
    end
    if strcmp(EditedPC{4},'Grid')
        if EditedPC{7}.numpc ~= handles.Settings.PCList{index,7}.numpc || ...
                EditedPC{7}.numpats ~= handles.Settings.PCList{index,7}.numpats || ...
                EditedPC{7}.deltapc ~= handles.Settings.PCList{index,7}.deltapc
            GridEdit = true;
        end
        if isfield(EditedPC{7},'CalibrationIndices') && EditedPC{7}.numpats == handles.Settings.PCList{index,7}.numpats && ~all(EditedPC{7}.CalibrationIndices == handles.Settings.PCList{index,7}.CalibrationIndices)
            GridEdit = true;
        end
    end
    
    %Re-perform Calibrations, if necessary
    if SREdit
        sel = questdlg('Edits require a new calibration. Continue?','PC Edit','Yes','No','Yes');
        if strcmp(sel,'Yes')
            PCData = PCStrainMinimization(handles.Settings,EditedPC{5},EditedPC{7}.CalibrationIndices);
            handles.Settings.PCList(end+1,:) = {PCData.MeanXStar PCData.MeanYStar PCData.MeanZStar  EditedPC{4:5} rename PCData};
            set(handles.PCList,'String',handles.Settings.PCList(:,6));
        end
    end
    if GridEdit
        sel = questdlg('Edits require a new calibration. Continue?','Yes','No','Yes');
        if strcmp(sel,'Yes')
            PCData = PCGrid(handles.Settings,EditedPC{7});
            handles.Settings.PCList(end+1,:) = {PCData.xstar PCData.ystar PCData.zstar...
                'Grid' 'Naive' rename PCData};
            set(handles.PCList,'String',handles.Settings.PCList(:,6));
        end
    end
    guidata(handles.PCGUI,handles);
    PCList_Callback(handles.PCList, eventdata, handles);
    handles = guidata(handles.PCGUI);
    guidata(handles.PCGUI,handles);
end


% --- Executes on button press in RemovePC.
function RemovePC_Callback(hObject, eventdata, handles)
% hObject    handle to RemovePC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = GetListIndex(handles);
handles.Settings.PCList(index,:) = [];
len = size(handles.Settings.PCList(:,1),1);
if get(handles.PCList,'Value') > len
    set(handles.PCList,'Value',len)
end
set(handles.PCList,'String',handles.Settings.PCList(:,6));
guidata(handles.PCGUI,handles);


function index = GetListIndex(handles)
Names = get(handles.PCList,'String');
Selection = Names{get(handles.PCList,'Value')};
index = strcmp(handles.Settings.PCList(:,6),Selection);

function SetPopupValue(Popup,String)
String = num2str(String);    
List = get(Popup,'String');
IndList = 1:length(List);
Value = IndList(strcmp(List,String));
if isempty(Value); Value =1; end;
set(Popup, 'Value', Value);

function string = GetPopupString(Popup)
List = get(Popup,'String');
Value = get(Popup,'Value');
string = List{Value};


% --- Executes when selected object is changed in PlotOptions.
function PlotOptions_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in PlotOptions 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdatePlot(handles)

function UpdatePlot(handles)
cur = GetListIndex(handles);
Nx = handles.Settings.Nx;
Ny = handles.Settings.Ny;

%Reset Plot
axes(handles.PCaxes)
cla(handles.PCaxes,'reset')

%Plot Selected graph
if get(handles.PCPlot,'Value')
    ind = strcmp('Scan File',handles.Settings.PCList(:,4));
    ScanPC = [handles.Settings.PCList{ind,1:3}];
    CurrPC = [handles.Settings.PCList{cur,1:3}];
    scatter3(handles.PCaxes,ScanPC(1),ScanPC(2),ScanPC(3),'bo')
    hold on
    scatter3(handles.PCaxes,CurrPC(1),CurrPC(2),CurrPC(3),'go')
    XStar = vec2map(handles.Settings.XStar,handles.Settings.Nx,handles.Settings.ScanType);
    YStar = vec2map(handles.Settings.YStar,handles.Settings.Nx,handles.Settings.ScanType);
    ZStar = vec2map(handles.Settings.ZStar,handles.Settings.Nx,handles.Settings.ScanType);
    if Ny == 1
        plot3(handles.PCaxes,XStar,YStar,ZStar,'g')
    else
        surf(XStar,YStar,ZStar,zeros(size(ZStar)))
    end
    colormap jet
    shading flat
elseif get(handles.IPFPlot,'Value')
    PlotScan(handles.IPF_map,'IPF')
    
    %Plot Calibration Points
    if ismember(handles.Settings.PCList{cur,4},{'Strain Minimization','Grid'})
        hold on
        [Xinds,Yinds] = ind2sub([Nx Ny],handles.Settings.PCList{cur,7}.CalibrationIndices);
        plot(Xinds,Yinds,'kd','MarkerFaceColor','k')
    end
    guidata(handles.PCGUI,handles);
elseif get(handles.IQPlot,'Value')
    PlotScan(handles.IQ_map,'Image Quality')
    
    %Plot Calibration Points
    if ismember(handles.Settings.PCList{cur,4},{'Strain Minimization','Grid'})
        hold on
        [Xinds,Yinds] = ind2sub([Nx Ny],handles.Settings.PCList{cur,7}.CalibrationIndices);
        plot(Xinds,Yinds,'kd','MarkerFaceColor','k')
    end
end
PlotGB_Callback(handles.PlotGB, [], handles);



% --- Executes on button press in PlotGB.
function PlotGB_Callback(hObject, eventdata, handles)
% hObject    handle to PlotGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotGB
if ~get(handles.PCPlot,'Value')
    if get(handles.PlotGB,'Value')
        axes(handles.PCaxes)
        GrainMap = vec2map(handles.Settings.grainID,handles.Settings.Nx,handles.Settings.ScanType);
        PlotGBs(GrainMap);
    end
end