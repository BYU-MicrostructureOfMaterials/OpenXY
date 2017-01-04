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

% Last Modified by GUIDE v2.5 02-Jan-2017 16:36:58

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

% Accept Settings from MainGUI or Load Settings.mat
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
else
    Settings = varargin{1};
end
Settings = HREBSDPrep(Settings);
handles.Settings = Settings;

% Set Max Blink Speed
handles.MaxSpeed = 2;

% Load previous settings
if exist('SystemSettings.mat','file')
    load SystemSettings.mat
end
if ~exist('TestGeometrySettings','var')
   TestGeometrySettings.blinkspeed = 0.5;
   TestGeometrySettings.color = 'green';
   TestGeometrySettings.MapType = 'Image Quality';
   TestGeometrySettings.LineWidth = 0.5;
end

% Populate Color Dropdown
ColorString = {'yellow','magenta','cyan','red','green','blue','white','black'};
set(handles.ColorScheme,'String',ColorString);
SetPopupValue(handles.ColorScheme,TestGeometrySettings.color);

% Set Blink Speed
set(handles.BlinkSpeedSlider,'Value',TestGeometrySettings.blinkspeed);

% Set Map Type
if strcmp(TestGeometrySettings.MapType,'Image Quality')
    set(handles.IQMap,'Value',1)
else
    set(handles.IPFMap,'Value',1)
end

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
g = euler2rmat(Settings.Angles);
handles.IPF = PlotIPF(g,[n m],Settings.ScanType,0);
if strcmp(Settings.ScanType,'Square')
    handles.IQ = reshape(Settings.IQ,n,m)';
elseif strcmp(Settings.ScanType,'Hexagonal')
    handles.IQ = Hex2Array(Settings.IQ,n);
end
handles.g = g;
    
% Plot Map
MapSelection_SelectionChangedFcn(handles.MapSelection, eventdata, handles)

% Plot Pattern Prompt
axes(handles.Pattern)
text(0.5,0.5,{'Select a pattern by double-clicking'; 'a point on the map to the left'},'HorizontalAlignment','center')
axis off

% Choose default command line output for TestGeometryGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TestGeometryGUI wait for user response (see UIRESUME)
uiwait(handles.TestGeometryGUI);


% --- Outputs from this function are returned to the command line.
function varargout = TestGeometry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
delete(handles.TestGeometryGUI);

% --- Executes when user attempts to close TestGeometryGUI.
function TestGeometryGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to TestGeometryGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

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
TestGeometrySettings.blinkspeed = get(handles.BlinkSpeedSlider,'Value');
TestGeometrySettings.color = GetPopupString(handles.ColorScheme);
TestGeometrySettings.LineWidth = get(handles.LineWidth,'Value');
if get(handles.IPFMap,'Value')
    TestGeometrySettings.MapType = 'IPF';
else
    TestGeometrySettings.MapType = 'Image Quality';
end
save('SystemSettings.mat','TestGeometrySettings','-append')
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

function SelectPoint(im,~)
disp('pressed map')

handles = get(im,'UserData');
Settings = handles.Settings;
n = Settings.Nx; m = Settings.Ny;

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

% Get variables for the point
xstar = Settings.XStar(ind);
ystar = Settings.YStar(ind);
zstar = Settings.ZStar(ind);
Av = Settings.AccelVoltage*1000; %put it in eV from KeV
sampletilt = Settings.SampleTilt;
elevang = Settings.CameraElevation;
pixsize = Settings.PixelSize;
Material = ReadMaterial(Settings.Phase{ind});
if strcmp(Material.lattice,'cubic') %Decide how many bands to overlay
    numfam = 4;
else
    numfam = 5;
end
paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl(1:numfam);Material.dhkl(1:numfam);Material.hkl(1:numfam,:)};
g = handles.g(:,:,ind);

% Get params from GUI
color = GetPopupString(handles.ColorScheme);
speed = get(handles.BlinkSpeedSlider,'Value');
width = get(handles.LineWidth,'Value');

% Read Pattern and plot with overlay
axes(handles.Pattern)
if get(handles.Filter,'Value')
    ImageFilter = Settings.ImageFilter;
else
    ImageFilter = [0 0 0 0];
end
I2 = ReadEBSDImage(Settings.ImageNamesList{ind},ImageFilter);
imagesc(I2); axis image; xlim([0 pixsize]); ylim([0 pixsize]); colormap('gray'); axis off;
genEBSDPatternHybridLineOverlay(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs,...
    'BlinkSpeed',speed,'Color',GetPopupString(handles.ColorScheme),'MaxSpeed',handles.MaxSpeed,...
    'LineWidth',width);


% --- Executes on slider movement.
function BlinkSpeedSlider_Callback(hObject, eventdata, handles)
% hObject    handle to BlinkSpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function BlinkSpeedSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlinkSpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
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
