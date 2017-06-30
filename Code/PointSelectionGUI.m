function varargout = PointSelectionGUI(varargin)
% POINTSELECTIONGUI Select points from the current scan
% 
% POINTSELECTIONGUI('Context',A1,...,An) opens POINTSELECTIONGUI set up to
% be used in the context specified by the value 'Context'
% 
% List of contexts:
% 'Test': Test the computation of the deformation gradient tensor
% 
% Written by Zach Clayburn, June, 2017
% 
% See also: TESTGEOMETRY
% 
% Last Modified by GUIDE v2.5 21-Jun-2017 15:41:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PointSelectionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PointSelectionGUI_OutputFcn, ...
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


% --- Executes just before PointSelectionGUI is made visible.
function PointSelectionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Accept Settings from MainGUI or Load Settings.mat
try
    handles.ParentGUI = varargin{1};
    ParentHandle = guidata(handles.ParentGUI);
    Settings = ParentHandle.Settings;
    varargin(1) = [];
catch 
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
    handles.ParentGUI = [];
end

% Verify the context of the call to PointSelectoinGUI
if ~isempty(varargin)
    if ~ischar(varargin{1})
        throw(MException('PointSelectionGUI:ArgumentError',...
            'First non-handle argument should be the context'))
    end
    
    context = varargin{1};
    
else
    throw(MException('PointSelectionGUI:ArgumentError',...
        'Please input a context argument'));
end
    
switch context
    case 'SubScan' % Select SubScan from MainGUI
        handles.PointSelectionGUI.Name = 'Select SubScan';
        handles.multiPoints = 0;
        handles.corners = [];
        handles.SaveFunc = varargin{2};
        handles.InstructionsText.String = 'Left click to view point Properties, Right click to select corner.';
    case 'Test' % The test button from MainGUI
        handles.multiPoints = 0;
        Settings.DoShowPlot = 2;
        Settings.SinglePattern = 0;
        Settings.patternAxis = handles.Pattern;
        Settings.reffAxis = handles.ReferencePattern;
        handles.SaveClose.Visible = 'Off';
        handles.InstructionsText.String = 'Left click to view point Properties, Right click to run cross corelation.';
    case 'RefPoints' % Edit reference points from Advanced Settings
        handles.PointSelectionGUI.Name = 'Edit RefInds';
        handles.multiPoints = 1;
        grainInd = varargin{2};
        handles.SaveFunc = varargin{3};
    case 'PCCalcPoints' % Select the points used in PC computations
        handles.doPoints = 2;
    otherwise
        throw(MException('PointSelectionGUI:ArgumentError',...
            'Unrecognized context'))
end
handles.context = context;


% Excecute HREBSDPrep
if ~isfield(Settings,'HREBSDPrep') || ~Settings.HREBSDPrep
    Settings = HREBSDPrep(Settings);
    if ~isempty(handles.ParentGUI) && isvalid(handles.ParentGUI)
        ParentHandles = guidata(handles.ParentGUI);
        ParentHandles.Settings = Settings;
        guidata(handles.ParentGUI,ParentHandles);
    end
end
handles.Settings = Settings;

% Set Max Blink Speed
handles.MaxSpeed = 4;

% Load previous settings
if exist('SystemSettings.mat','file')
    load SystemSettings.mat
end
if ~exist('TestGeometrySettings','var')
   TestGeometrySettings.blinkspeed = 'Medium';
   TestGeometrySettings.color = 'green';
   TestGeometrySettings.MapType = 'Image Quality';
   TestGeometrySettings.LineWidth = 0.5;
end

% Populate Color Dropdown
ColorString = {'yellow','magenta','cyan','red','green','blue','white','black','holiday'};
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
if exist('grainInd','var')
    handles.grainInd = grainInd;
    handles.inds = unique(grainInd);
end
handles.ind = 0;
handles.refInd = 0;

% Load plots into handles
g = euler2gmat(Settings.Angles);
handles.IPF = PlotIPF(g,[n m],Settings.ScanType,0);
if strcmp(Settings.ScanType,'Square')
    handles.IQ = reshape(Settings.IQ,n,m)';
    handles.CI = reshape(Settings.CI,n,m)';
elseif strcmp(Settings.ScanType,'Hexagonal')
    handles.IQ = Hex2Array(Settings.IQ,n);
    handles.CI = Hex2Array(Settings.CI,n);
end
handles.g = g;
    
% Plot Map
% handles.doPlotPoints = false;
MapSelection_SelectionChangedFcn(handles.MapSelection, eventdata, handles)

% Set Position
% if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
%     MainSize = get(handles.MainGUI,'Position');
%     set(hObject,'Units','pixels');
%     GUIsize = get(hObject,'Position');
%     set(hObject,'Position',[MainSize(1)+MainSize(3)+20 MainSize(2)-(GUIsize(4)-MainSize(4))+26 GUIsize(3) GUIsize(4)]);
%     movegui(hObject,'onscreen');
% end
gui = findall(handles.PointSelectionGUI,'KeyPressFcn','');
set(gui,'KeyPressFcn',@PointSelectionGUI_KeyPressFcn);

% Plot Pattern Prompt
axes(handles.Pattern)
text(0.5,0.5,{'Select a pattern by clicking'; 'a point on the map to the left'},'HorizontalAlignment','center')
axis off
axes(handles.ReferencePattern)
text(0.5,0.5,{'Select a pattern by clicking'; 'a point on the map to the left'},'HorizontalAlignment','center')
axis off

% Plot GBs on seperate invisible axis
axes(handles.GrainMap); axis image
h = hggroup;
PlotGBs(handles.Settings.grainID,[handles.Settings.Nx handles.Settings.Ny],handles.Settings.ScanType);
lines = findobj('Type','Line');
set(lines,'Parent',h);
h.Visible = 'Off';

% Set up Points axis
axes(handles.Points)
axis image
handles.Points.XLim = handles.Map.XLim;
handles.Points.YLim = handles.Map.YLim;
if isfield(handles,'inds')
    plotPoints(handles);
end

% Choose default command line output for PointSelectionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = PointSelectionGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when user attempts to close PointSelectionGUI.
function PointSelectionGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
PointSelectionGUI_CloseRequestFcn(handles.PointSelectionGUI, eventdata, handles)

% --- Executes on button press in SaveClose.
function SaveClose_Callback(hObject, eventdata, handles)
SaveFunc = handles.SaveFunc;
switch handles.context
    case 'SubScan'
        mainHandles = guidata(handles.ParentGUI);
        SaveFunc(mainHandles,handles.corners(:,1),handles.corners(:,2));
    case 'RefPoints'
        mainHandles = guidata(handles.ParentGUI);
        SaveFunc(mainHandles,handles.inds);
end
PointSelectionGUI_CloseRequestFcn(handles.PointSelectionGUI, eventdata, handles)

% --- Executes when selected object is changed in MapSelection.
function MapSelection_SelectionChangedFcn(hObject, eventdata, handles)
axes(handles.Map)

% Plot Map
if get(handles.IPFMap,'Value')
    PlotScan(handles.IPF,'IPF');
elseif handles.IQMap.Value
    PlotScan(handles.IQ,'IQ');
else
    PlotScan(handles.CI,'CI');
end

axis off
if ~handles.IPFMap.Value
    h = colorbar;
    h.Position(1) = 1 - h.Position(3);
    h.AxisLocation = 'in';
end
uistack(handles.GrainMap, 'top')
uistack(handles.Points, 'top')


% --- Executes on mouse motion over figure - except title and menu.
function PointSelectionGUI_WindowButtonMotionFcn(hObject, eventdata, handles)
if isfield(handles,'Settings')
    pt = get(handles.Map,'currentpoint');
    rows = handles.Settings.Nx+0.5;
    cols = handles.Settings.Ny+0.5;
    if handles.Settings.Ny == 1
        cols = round(rows/6);
    end
    handles.overicon =  (pt(1,1)>=0.5 && pt(1,1)<=rows) && (pt(1,2)>=0.5 && pt(1,2)<=cols); 
    if ~handles.overicon
        set(handles.PointSelectionGUI,'pointer','arrow');
    else
        set(handles.PointSelectionGUI,'pointer','crosshair');
    end
    guidata(hObject,handles);
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function PointSelectionGUI_WindowButtonDownFcn(hObject, eventdata, handles)
if handles.overicon
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
    if handles.multiPoints
        ind = handles.indi(y,x);
        switch handles.multiPoints
            case 1 % One point per grain
                grainID = handles.Settings.grainID;
                grain = grainID(ind);
                filledGrains = grainID(handles.inds);
                if any(ismember(filledGrains,grain))
                    handles.inds(grainID(handles.inds) == grain) = ind;
                else
                    handles.inds(end+1) = ind;
                end
                handles.ind = ind;
            case 2 % Unlimited Points
                
        end
    else
        handles.ind = handles.indi(y,x);
        handles.IndexNumEdit.String = num2str(handles.ind);
    end
    guidata(hObject,handles);
    PlotPattern(handles);handles = guidata(hObject);
    plotPoints(handles);handles = guidata(hObject);
end
        

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
set(handles.IQText,'String',Settings.IQ(ind))
set(handles.GrainText,'String',Settings.grainID(ind))
set(handles.phi1Text,'String',Settings.Angles(ind,1))
set(handles.PHIText,'String',Settings.Angles(ind,2))
set(handles.phi2Text,'String',Settings.Angles(ind,3))
[~,name,ext] = fileparts(Settings.ImageNamesList{ind});
set(handles.FileText,'FontSize',6.0)
set(handles.FileText,'String',[name ext])

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
if get(handles.Filter,'Value')
    ImageFilter = Settings.ImageFilter;
    if strcmp(Settings.ImageFilterType,'standard')
        I2=ReadEBSDImage(Settings.ImageNamesList{ind},ImageFilter);
    else
        I2=localthresh(Settings.ImageNamesList{ind});
    end
else
    I2=ReadEBSDImage(Settings.ImageNamesList{ind},[0 0 0 0]);
end
im = imagesc(I2); axis image; xlim([0 pixsize]); ylim([0 pixsize]); colormap('gray'); axis off;

if strcmp(GetPopupString(handles.SimType),'Dynamic')
    GenPat = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,phase,Av,ind);
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
    if strcmp(color,'holiday')
        colormap hot
        gui = findall(handles.PointSelectionGUI,'BackgroundColor',[0.94 0.94 0.94]);
        set(gui,'BackgroundColor','red')
        set(gui,'ForegroundColor','white','FontWeight','bold')
        set(handles.PointSelectionGUI,'Color','green')
    end
end

% Update RefrencePattern
axes(handles.ReferencePattern)
switch Settings.HROIMMethod
    case 'Simulated' % Kinematic Simulation
        RefIm = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,...
            Material.a1,Material.b1,Material.c1,Material.axs);
        if handles.Filter.Value && any(Settings.ImageFilter)
            if strcmp(Settings.ImageFilterType,'standard') 
            RefIm = custimfilt(RefIm,Settings.ImageFilter(1),...
                Settings.PixelSize,Settings.ImageFilter(3),...
                Settings.ImageFilter(4));
            else
               RefIm = localthresh(RefIm); 
            end
        end
        handles.refInd = 0;
    case 'Dynamic Simulated' % Dynamic Simulation
        if exist('GenPat','var')
            RefIm = GenPat;
        else
            RefIm = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,...
                zstar,pixsize,mperpix,elevang,phase,Av,ind);
        end
        if handles.Filter.Value && any(Settings.ImageFilter)
            if strcmp(Settings.ImageFilterType,'standard')
                RefIm = custimfilt(RefIm,Settings.ImageFilter(1),...
                    Settings.PixelSize,Settings.ImageFilter(3),...
                    Settings.ImageFilter(4));
            else
                RefIm = localthresh(RefIm);
            end
        end
        handles.refInd = 0;
    case 'Real' % Real Refernce Grain
        refInd = Settings.RefImageInd;
        if ~refInd
            refInd = Settings.RefInd(ind);
        end
        if get(handles.Filter,'Value')
            ImageFilter = Settings.ImageFilter;
            if strcmp(Settings.ImageFilterType,'standard')
                RefIm=ReadEBSDImage(Settings.ImageNamesList{refInd},ImageFilter);
            else
                RefIm=localthresh(Settings.ImageNamesList{refInd});
            end
        else
            RefIm=ReadEBSDImage(Settings.ImageNamesList{refInd},[0 0 0 0]);
        end
        handles.refInd = refInd;
end
imagesc(RefIm);
axis image;
xlim([0 pixsize]);
ylim([0 pixsize]);
colormap('gray');
axis off;
guidata(handles.PointSelectionGUI,handles);

function plotPoints(handles)
axes(handles.Points)
cla

if handles.multiPoints
    hold on
    l = length(handles.inds);
    X = zeros(1,l);
    Y = zeros(1,l);
    for ii = 1:l
        [Y(ii),X(ii)] = find(handles.indi == handles.inds(ii));
    end
    plot(X,Y,'kd','MarkerFaceColor','k','MarkerEdgeColor','w')
else 
    % Plot selected image
    [Y,X] = find(handles.indi == handles.ind);
    plot(X,Y,'kd','MarkerFaceColor','k','MarkerEdgeColor','w')
    
    if handles.refInd
        [Y2,X2] = find(handles.indi == handles.refInd);
        plot(X2,Y2,'ro','MarkerFaceColor','r','MarkerSize',4,'MarkerEdgeColor','w')
    end
    switch handles.context
        case 'SubScan'
            if strcmp(get(gcbf, 'SelectionType'),'alt')
                if size(handles.corners) == [2 2]
                    handles.corners = [];
                end
                handles.corners(end+1,:) = [X Y];
            end
            plotBox(handles)
            guidata(handles.PointSelectionGUI,handles)
        case 'Test'
            if strcmp(get(gcbf, 'SelectionType'),'alt')
                [F,g,U,SSE] = GetDefGradientTensor(handles.ind,...
                    handles.Settings,handles.Settings.Phase{handles.ind});
                F
                g
                U
                SSE
            end
    end
    hold off;
end
uistack(handles.GrainMap, 'top')
uistack(handles.Points, 'top')

function plotBox(handles)
% axes(handles.Points)
corners = handles.corners;
if isempty(corners)
    return;
end
S.XData = [min(corners(:,1)) - 0.5;...
    min(corners(:,1)) - 0.5;...
    max(corners(:,1)) + 0.5;...
    max(corners(:,1)) + 0.5];
S.YData = [min(corners(:,2)) - 0.5;...
    max(corners(:,2)) + 0.5;...
    max(corners(:,2)) + 0.5;...
    min(corners(:,2)) - 0.5];
S.FaceAlpha = 0;
plot(corners(:,1),corners(:,2),'*b')
if size(handles.corners) == [2 2]
    patch(S)
    
end

% --- Executes on selection change in BlinkSpeed.
function BlinkSpeed_Callback(hObject, eventdata, handles)
if handles.ind
    PlotPattern(handles)
end


% --- Executes during object creation, after setting all properties.
function BlinkSpeed_CreateFcn(hObject, eventdata, handles)
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LineWidth_Callback(hObject, eventdata, handles)
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function LineWidth_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Filter.
function Filter_Callback(hObject, eventdata, handles)
if handles.ind
    PlotPattern(handles)
end

% --- Executes on selection change in ColorScheme.
function ColorScheme_Callback(hObject, eventdata, handles)
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function ColorScheme_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotGB.
function PlotGB_Callback(hObject, eventdata, handles)
if hObject.Value
    handles.GrainMap.Children.Visible = 'On';
    uistack(handles.GrainMap, 'top')
else
    handles.GrainMap.Children.Visible = 'Off';
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

% --- Executes on key press with focus on PointSelectionGUI and none of its controls.
function PointSelectionGUI_KeyPressFcn(hObject, eventdata, handles)
handles = guidata(hObject);
% Close Figure with CTRL-L
if strcmp(eventdata.Key,'l') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
    SaveClose_Callback(handles.SaveClose, eventdata, handles);
end


% --- Executes on selection change in SimType.
function SimType_Callback(hObject, eventdata, handles)
if handles.ind
    PlotPattern(handles)
end

% --- Executes during object creation, after setting all properties.
function SimType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IndexNumEdit_Callback(hObject, eventdata, handles)
if ~all(isstrprop(hObject.String,'digit')) || isempty(hObject.String)
   beep
   hObject.String = num2str(handles.ind);
   return;
end
val = str2double(hObject.String);
if val <= 0
    beep
    val = 1;
elseif val > handles.Settings.ScanLength
    beep
    val = handles.Settings.ScanLength;
end
handles.ind = val;
PlotPattern(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function IndexNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
