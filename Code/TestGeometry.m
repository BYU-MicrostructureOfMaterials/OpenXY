function varargout = TestGeometry(varargin)
% TESTGEOMETRYGUI MATLAB code for TestGeometryGUI.fig
%      TESTGEOMETRYGUI, by itself, creates a new TESTGEOMETRYGUI or raises the existing
%      singleton*.
%
%      H = TESTGEOMETRYGUI returns the handle to a new TESTGEOMETRYGUI or the handle to
%      the existing singleton*.
%
%      TESTGEOMETRYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGEOMETRYGUI.M with the given input arguments.
%
%      TESTGEOMETRYGUI('Property','Value',...) creates a new TESTGEOMETRYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TestGeometry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TestGeometry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TestGeometryGUI

% Last Modified by GUIDE v2.5 12-Jan-2017 15:34:34

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TestGeometry_OpeningFcn, ...
                   'gui_OutputFcn',  @TestGeometry_OutputFcn, ...
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


% --- Executes just before TestGeometryGUI is made visible.
function TestGeometry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TestGeometryGUI (see VARARGIN)

handles.outout = hObject;

% Accept Settings from MainGUI or Load Settings.mat
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
    handles.MainGUI = [];
else
    if length(varargin) == 2
        handles.Fast = varargin{2};
    end
    handles.MainGUI = varargin{1};
    MainHandle = guidata(handles.MainGUI);
    Settings = MainHandle.Settings;
end

% Excecute HREBSDPrep
if ~isfield(Settings,'HREBSDPrep') || ~Settings.HREBSDPrep
    Settings = HREBSDPrep(Settings);
    if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
        MainHandles = guidata(handles.MainGUI);
        MainHandles.Settings = Settings;
        guidata(MainHandles.MainGUI,MainHandles);
    end
end
handles.Settings = Settings;

% Set Max Blink Speed
handles.MaxSpeed = 4;

% Load previous settings
sysSettings = matfile('SystemSettings.mat', 'Writable', true);
if ~isprop(sysSettings,'TestGeometrySettings')
   TestGeometrySettings.blinkspeed = 'Medium';
   TestGeometrySettings.color = 'green';
   TestGeometrySettings.MapType = 'Image Quality';
   TestGeometrySettings.LineWidth = 0.5;
   sysSettings.TestGeometrySettings = TestGeometrySettings;
else
    TestGeometrySettings = sysSettings.TestGeometrySettings;
end

% Populate Color Dropdown
ColorString = {'yellow','magenta','cyan','red','green','blue','white','black'};
set(handles.ColorScheme,'String',ColorString);
SetPopupValue(handles.ColorScheme,TestGeometrySettings.color);

% Set Blink Speed
SpeedOptions = {'No Blink','Slow','Medium','Fast','Hide Bands'};
set(handles.BlinkSpeed,'String',SpeedOptions);
SetPopupValue(handles.BlinkSpeed,TestGeometrySettings.blinkspeed);

% Set Line Width
LineOptions = {'Thin','Medium','Thick'};
set(handles.LineWidth,'String',LineOptions);
SetPopupValue(handles.LineWidth,TestGeometrySettings.LineWidth);

% Set Number of Families (off until a point is selected)
set(handles.NumFam,'Enable','off');
set(handles.NumFam,'String','4');

% Set Map Type
if strcmp(TestGeometrySettings.MapType,'Image Quality')
    set(handles.IQMap,'Value',1)
else
    set(handles.IPFMap,'Value',1)
end

% Simulated Pattern Type
set(handles.SimType,'String',{'Simulated','Dynamic'})
if strcmp(Settings.HROIMMethod,'Dynamic Simulated')
    SimType = 'Dynamic';
else
    SimType = 'Kinematic';
end
SetPopupValue(handles.SimType,SimType);

% Turn off GB's by default
set(handles.PlotGB,'Value',0)

% Filter by default
set(handles.Filter,'Value',1)

% Generate Index arrays
n = Settings.Nx; m = Settings.Ny;
if strcmp(Settings.ScanType,'Square')
    indi = 1:1:m*n;
    indi = reshape(indi,n,m)';
elseif strcmp(Settings.ScanType,'Hexagonal')
    NumColsOdd = n;
    indi = 1:length(Settings.Inds);
    indi = Hex2Array(indi,NumColsOdd);
end
handles.indi = indi;
handles.ind = 0;

% Load plots into handles
g = euler2gmat(Settings.Angles);
handles.IPF = PlotIPF(g,[n m],Settings.ScanType,0);
if strcmp(Settings.ScanType,'Square')
    handles.IQ = reshape(Settings.IQ,n,m)';
elseif strcmp(Settings.ScanType,'Hexagonal')
    handles.IQ = Hex2Array(Settings.IQ,n);
end
handles.g = g;
    
% Plot Map
MapSelection_SelectionChangedFcn(handles.MapSelection, eventdata, handles)

% Set Position
if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
    MainSize = get(handles.MainGUI,'Position');
    set(hObject,'Units','pixels');
    GUIsize = get(hObject,'Position');
    set(hObject,'Position',[MainSize(1)+MainSize(3)+20 MainSize(2)-(GUIsize(4)-MainSize(4))+26 GUIsize(3) GUIsize(4)]);
    movegui(hObject,'onscreen');
end
gui = findall(handles.TestGeometryGUI,'KeyPressFcn','');
set(gui,'KeyPressFcn',@TestGeometryGUI_KeyPressFcn);

% Plot Pattern Prompt
axes(handles.Pattern)
text(0.5,0.5,{'Select a pattern by clicking'; 'a point on the map to the left'},'HorizontalAlignment','center')
axis off

% Choose default command line output for TestGeometryGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TestGeometryGUI wait for user response (see UIRESUME)
%uiwait(handles.TestGeometryGUI);


% --- Outputs from this function are returned to the command line.
function varargout = TestGeometry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close TestGeometryGUI.
function TestGeometryGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to TestGeometryGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);

% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TestGeometryGUI_CloseRequestFcn(handles.TestGeometryGUI, eventdata, handles)

% --- Executes on button press in SaveClose.
function SaveClose_Callback(hObject, eventdata, handles)
% hObject    handle to SaveClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TestGeometrySettings.blinkspeed = GetPopupString(handles.BlinkSpeed);
TestGeometrySettings.color = GetPopupString(handles.ColorScheme);
TestGeometrySettings.LineWidth = GetPopupString(handles.LineWidth);
if get(handles.IPFMap,'Value')
    TestGeometrySettings.MapType = 'IPF';
else
    TestGeometrySettings.MapType = 'Image Quality';
end
sysSettings = matfile('SystemSettings.mat', 'Writable', true);
sysSettings.TestGeometrySettings = TestGeometrySettings;
TestGeometryGUI_CloseRequestFcn(handles.TestGeometryGUI, eventdata, handles)


% --- Executes when selected object is changed in MapSelection.
function MapSelection_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in MapSelection 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.Map)

% Plot Map
if get(handles.IPFMap,'Value')
    im = PlotScan(handles.IPF,'IPF');
else
    im = PlotScan(handles.IQ,'Image Quality');
end

% Set Callback for button-press
set(im,'ButtonDownFcn',@SelectPoint)
set(im,'UserData',handles)

% Plot Grain Boundaries
if get(handles.PlotGB,'Value')
    PlotGBs(handles.Settings.grainID,[handles.Settings.Nx handles.Settings.Ny],handles.Settings.ScanType)
end
axis off

% --- Executes on mouse press over axes background.
function Map_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse motion over figure - except title and menu.
function TestGeometryGUI_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to TestGeometryGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'Settings')
    pt = get(handles.Map,'currentpoint');
    rows = handles.Settings.Nx+0.5;
    cols = handles.Settings.Ny+0.5;
    if handles.Settings.Ny == 1
        cols = round(rows/6);
    end
    handles.overicon =  (pt(1,1)>=0.5 && pt(1,1)<=rows) && (pt(1,2)>=0.5 && pt(1,2)<=cols); 
    if ~handles.overicon
        set(handles.TestGeometryGUI,'pointer','arrow');
    else
        set(handles.TestGeometryGUI,'pointer','crosshair');
    end
    guidata(hObject,handles);
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function TestGeometryGUI_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to TestGeometryGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.overicon
    switch hObject.SelectionType
        case 'normal'
            if handles.ind == 0
                set(handles.NumFam,'UserData',true);
            end
            Settings = handles.Settings;
            n = Settings.Nx; m = Settings.Ny;
            
            % Get Selected Location
            pt = get(handles.Map,'currentpoint');
            x = round(pt(1,1));
            if m == 1
                y = 1;
            else
                y = round(pt(1,2));
            end
            handles.ind = handles.indi(y,x);
        case {'extend','alt'}
            input = inputdlg('Enter an Index Number:');
            handles.ind = str2double(input{1});
    end
    guidata(hObject,handles);
    PlotPattern(handles);
end
    

function SelectPoint(im,~)
return
handles = get(im,'UserData');
Settings = handles.Settings;
n = Settings.Nx; m = Settings.Ny;
if handles.ind == 0
    set(handles.NumFam,'UserData',true);
end

% Get selected location
[x,y, button] = ginput(1);
x = round(x); y = round(y);
if x < 0; x = 1; end;
if y < 0; y = 1; end;
if x > n; x = n; end;
if y > m; y = m; end;
handles.ind = handles.indi(y,x);
guidata(handles.Map,handles)
PlotPattern(handles)
    

function PlotPattern(handles)
ind = handles.ind;
Settings = handles.Settings;

% Update NumFam Popup
Material = ReadMaterial(Settings.Phase{ind});
Options = strsplit(num2str(1:length(Material.Fhkl)));
set(handles.NumFam,'String',Options);
if strcmp(Material.lattice,'cubic') %Decide how many bands to overlay
    numfamdef = 4;
else
    numfamdef = 5;
end
% Initialization
if get(handles.NumFam,'UserData')
    set(handles.NumFam,'Value',numfamdef);
    set(handles.NumFam,'UserData',false);
    set(handles.NumFam,'Enable','on');
end
% For difference phases
if get(handles.NumFam,'Value') > length(Options)
    set(handles.NumFam,'Value',numfam);
end

% Get variables for the point
xstar = Settings.XStar(ind);
ystar = Settings.YStar(ind);
zstar = Settings.ZStar(ind);
Av = Settings.AccelVoltage*1000; %put it in eV from KeV
sampletilt = Settings.SampleTilt;
elevang = Settings.CameraElevation;
pixsize = Settings.PixelSize;
numfam = get(handles.NumFam,'Value');
mperpix = Settings.mperpix;
paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl(1:numfam);Material.dhkl(1:numfam);Material.hkl(1:numfam,:)};
g = handles.g(:,:,ind);
phase = Settings.Phase{ind};

% Update GUI Info Box
set(handles.PhaseText,'String',phase)
set(handles.IndexText,'String',num2str(ind))
set(handles.LatticeText,'String',Material.lattice)
set(handles.CIText,'String',Settings.CI(ind))
set(handles.FitText,'String',Settings.Fit(ind))

% Get params from GUI
color = GetPopupString(handles.ColorScheme);
val = get(handles.BlinkSpeed,'Value');
SpeedOptions = [0 1.5 .75 .25 handles.MaxSpeed];
speed = SpeedOptions(val);
val = get(handles.LineWidth,'Value');
WidthOptions = [0.01 1 3];
width = WidthOptions(val);

% Read Pattern and plot with overlay
axes(handles.Pattern)
I2 = Settings.patterns.getPattern(Settings,ind);
im = imagesc(I2); axis image; xlim([0 pixsize]); ylim([0 pixsize]); colormap('gray'); axis off;

if strcmp(GetPopupString(handles.SimType),'Dynamic')
    GenPat = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,sampletilt,phase,Av,ind);
    cla(handles.DynamicPattern)
    h = imagesc(handles.DynamicPattern,GenPat); colormap(handles.DynamicPattern,gray);
    uistack(handles.DynamicPattern,'top')
    axis(handles.DynamicPattern,'image','off')
    if speed == handles.MaxSpeed
        set(h,'Visible','off')
    elseif speed > 0
        blinkline(h,speed)
    else
        blinkline(h);blinkline(h);
    end
else
    if isfield(Settings,'camphi1')
        paramspat{11} = Settings.camphi1;
        paramspat{12} = Settings.camPHI;
        paramspat{13} = Settings.camphi2;
    end
    genEBSDPatternHybridLineOverlay(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,...
        'BlinkSpeed',speed,'Color',color,'MaxSpeed',handles.MaxSpeed,...
        'LineWidth',width);
end

% --- Executes on selection change in BlinkSpeed.
function BlinkSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to BlinkSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BlinkSpeed contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BlinkSpeed
if handles.ind
    PlotPattern(handles)
end


% --- Executes during object creation, after setting all properties.
function BlinkSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlinkSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumFam.
function NumFam_Callback(hObject, eventdata, handles)
% hObject    handle to NumFam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NumFam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumFam
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function NumFam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumFam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LineWidth_Callback(hObject, eventdata, handles)
% hObject    handle to LineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function LineWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Filter.
function Filter_Callback(hObject, eventdata, handles)
% hObject    handle to Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Filter
if handles.ind
    PlotPattern(handles)
end

% --- Executes on selection change in ColorScheme.
function ColorScheme_Callback(hObject, eventdata, handles)
% hObject    handle to ColorScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ColorScheme contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ColorScheme
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function ColorScheme_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotGB.
function PlotGB_Callback(hObject, eventdata, handles)
% hObject    handle to PlotGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotGB
MapSelection_SelectionChangedFcn(handles.MapSelection, eventdata, handles)

   

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


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over BlinkText.
function BlinkText_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to BlinkText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on TestGeometryGUI and none of its controls.
function TestGeometryGUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to TestGeometryGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
% Close Figure with CTRL-L
if strcmp(eventdata.Key,'l') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
    SaveClose_Callback(handles.SaveClose, eventdata, handles);
end


% --- Executes on selection change in SimType.
function SimType_Callback(hObject, eventdata, handles)
% hObject    handle to SimType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SimType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SimType
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function SimType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SimType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
