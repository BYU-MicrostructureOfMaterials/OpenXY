function varargout = SelectPointsGUI(varargin)
% SELECTPOINTSGUI MATLAB code for SelectPointsGUI.fig
%      SELECTPOINTSGUI, by itself, creates a new SELECTPOINTSGUI or raises the existing
%      singleton*.
%
%      H = SELECTPOINTSGUI returns the handle to a new SELECTPOINTSGUI or the handle to
%      the existing singleton*.
%
%      SELECTPOINTSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTPOINTSGUI.M with the given input arguments.
%
%      SELECTPOINTSGUI('Property','Value',...) creates a new SELECTPOINTSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectPointsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectPointsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectPointsGUI

% Last Modified by GUIDE v2.5 08-May-2017 13:36:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectPointsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectPointsGUI_OutputFcn, ...
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


% --- Executes just before SelectPointsGUI is made visible.
function SelectPointsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectPointsGUI (see VARARGIN)

% Choose default command line output for SelectPointsGUI
handles.output = hObject;

% Get the Handles structure for the parent GUI
handles.ParentObj = varargin{1};
handles.Parent = guidata(handles.ParentObj);
handles.type = varargin{2};
switch handles.type
    case 'PC'
        mapPlots.plotList = {'IQ','IPF'};
        mapPlots.IQ = handles.Parent.IQ_map;
        mapPlots.IPF = handles.Parent.IPF_map;
        handles.doPatternPlot = false;
        handles.pointPlotFcn = @PCPointPlot;
        handles.leftClickFcn = @PCPointEdit;
        handles.LeftText.String = 'Edit or delete Calibration Point';
        handles.middleClickFcn = @noFcn;
        handles.MiddleText.String = 'N/A';
end

% Save the map size in the handles sructure
handles.mapSize = size(mapPlots.IQ);

handles.mapInd = 0;
handles.mapPlots = mapPlots;
% Plot the first map
handles = mapPlotUpdate(handles);

if handles.doPatternPlot
    % Plot the prompt to show a patter by right clicking, if needed
    axes(handles.PatternAxes)
    text(0.5,0.5,{'Middle click a point'; 'to display the pattern'},...
        'HorizontalAlignment','center')
    axis off
else
    hObject.Position(3) = hObject.Position(3)/2;
    axes(handles.PatternAxes)
    axis off
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectPointsGUI wait for user response (see UIRESUME)
% uiwait(handles.SelectPointsGUI);

function handles = mapPlotUpdate(handles,~)
if nargin < 2
    handles.mapInd = handles.mapInd + 1;
    if handles.mapInd > size(handles.mapPlots.plotList,2)
        handles.mapInd = 1;
    end
end
axes(handles.MapAxes)
currentMap = handles.mapPlots.plotList{handles.mapInd};
handles.MapText.String = [currentMap ' Map'];
cla;
hold on
PlotScan(handles.mapPlots.(currentMap),currentMap);
axis off
hold off
handles = handles.pointPlotFcn(handles);

% --- Outputs from this function are returned to the command line.
function varargout = SelectPointsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function SelectPointsGUI_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SelectPointsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Checks what type of click it being made
type = get(gcbf, 'SelectionType');
if handles.overMap
    switch type
        case 'normal'
            handles = handles.leftClickFcn(handles);
            handles = mapPlotUpdate(handles,1);
        case 'alt'
            handles = mapPlotUpdate(handles);
        case 'extend'
            handles = handles.middleClickFcn(handles);
            handles = mapPlotUpdate(handles,1);
        case 'open'
            %Double-Click option, does nothing
    end
end
guidata(hObject,handles);

function handles = PCPointPlot(handles)
PCData = handles.Parent.PCData;
Nx = handles.mapSize(1);
Ny = handles.mapSize(2);
scanType = FindScanType([Nx Ny],numel(handles.mapPlots.IQ));
if strcmp(scanType,'Hexagonal')
   Nx = Nx - 1; 
end
[Xind,Yind] = ind2sub2([Ny Nx],PCData.CalibrationIndices,scanType);

axes(handles.MapAxes)
hold on
plot(Xind,Yind,'kd','MarkerFaceColor','k')
hold off

handles.Parent.PCData = PCData;

function handles = PCPointEdit(handles)
Inds = handles.Parent.PCData.CalibrationIndices;
Nx = handles.mapSize(1);
Ny = handles.mapSize(2);
scanType = FindScanType([Nx Ny],numel(handles.mapPlots.IQ));

pt = handles.MapAxes.CurrentPoint;
x = ceil(pt(1,1) - 0.5);
y = ceil(pt(1,2) - 0.5);

ind = sub2ind2([Ny Nx],x,y,scanType);

[isIn,loc]=ismember(ind,Inds);
if isIn
   Inds(loc) = []; 
else
    Inds = [Inds;ind];
end
handles.Parent.PCData.CalibrationIndices = Inds;



% --- Executes on mouse motion over figure - except title and menu.
function SelectPointsGUI_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to SelectPointsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pt = handles.MapAxes.CurrentPoint;
x = pt(1,1) - 0.5;
y = pt(1,2) - 0.5;
handles.xtext.String = num2str(x);
handles.ytext.String = num2str(y);

handles.overMap = (x >= 0 && x <= handles.mapSize(2))...
    && (y >= 0 && y <= handles.mapSize(1));

if ~handles.overMap
    set(hObject,'pointer','arrow');
else
    set(hObject,'pointer','crosshair');
end
guidata(hObject,handles);


% --- Executes during object deletion, before destroying properties.
function MapAxes_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to MapAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function handles = noFcn(handles)

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(handles.ParentObj,handles.Parent)
delete(handles.SelectPointsGUI);
