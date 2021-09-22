function varargout = ROISettingsGUI(varargin)
% ROISETTINGSGUI MATLAB code for ROISettingsGUI.fig
%      ROISETTINGSGUI, by itself, creates a new ROISETTINGSGUI or raises the existing
%      singleton*.
%
%      H = ROISETTINGSGUI returns the handle to a new ROISETTINGSGUI or the handle to
%      the existing singleton*.
%
%      ROISETTINGSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROISETTINGSGUI.M with the given input arguments.
%
%      ROISETTINGSGUI('Property','Value',...) creates a new ROISETTINGSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROISettingsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROISettingsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROISettingsGUI

% Last Modified by GUIDE v2.5 11-Jun-2019 10:12:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROISettingsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ROISettingsGUI_OutputFcn, ...
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

% --- Executes during object creation, after setting all properties.
function ROISettingsGUI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROISettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes just before ROISettingsGUI is made visible.
function ROISettingsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROISettingsGUI (see VARARGIN)

% Choose default command line output for ROISettingsGUI
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
    MainHandles = guidata(handles.MainGUI);
    Settings = MainHandles.Settings;
end
handles.Settings = Settings;
handles.PrevSettings = Settings;

%Fast GUI
if handles.Fast

end

%Set Position and Visuals
if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
    MainSize = get(handles.MainGUI,'Position');
    set(hObject,'Units','pixels');
    GUIsize = get(hObject,'Position');
    ScreenSize = get(groot,'ScreenSize');
    height = MainSize(2)+MainSize(4)+70;
    if ismac
        GUIsize(3) = GUIsize(3)*1.2;
    end
    set(hObject,'Position',[MainSize(1)-230-20 height GUIsize(3) GUIsize(4)]);
    movegui(hObject,'onscreen')
end
handles.ColorSave = get(handles.SaveButton,'BackgroundColor');
handles.ColorEdit = [1 1 0]; % Yellow
gui = findall(handles.ROISettingsGUI,'KeyPressFcn','');
set(gui,'KeyPressFcn',@ROISettingsGUI_KeyPressFcn);
guidata(hObject, handles)


% --- Outputs from this function are returned to the command line.
function varargout = ROISettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

Settings = handles.Settings;

%Set Images to Grayscale
colormap gray;

%ROI Size
set(handles.ROISizeEdit,'String',num2str(Settings.ROISizePercent));

%NumROI Popup
set(handles.NumROIPopup,'String',num2str(Settings.NumROIs));

%ROI Style Popup
ROIStyleList = {'Grid','Radial','Intensity','Annular'};
set(handles.ROIStylePopup, 'String', ROIStyleList);
SetPopupValue(handles.ROIStylePopup,Settings.ROIStyle);

%ROIFilter
%TODO Make this use the patterns.ImageFilter in stead
set(handles.ROIFilter1,'String',num2str(Settings.ROIFilter(1))); 
set(handles.ROIFilter2,'String',num2str(Settings.ROIFilter(2)));
set(handles.ROIFilter3,'String',num2str(Settings.ROIFilter(3)));
set(handles.ROIFilter4,'String',num2str(Settings.ROIFilter(4)));

%Image Filter Type Popup
handles.ImageFilterType.String = patterns.ImageFilterType.getNames;
filterType = char(Settings.patterns.filter.filterType);
SetPopupValue(handles.ImageFilterType, filterType);

%ImageFilter
handles.ImageFilter1.String =...
    num2str(Settings.patterns.filter.lowerRadius);
handles.ImageFilter2.String =...
    num2str(Settings.patterns.filter.upperRadius);
handles.ImageFilter3.String =...
    num2str(Settings.patterns.filter.lowerSmoothing);
handles.ImageFilter4.String =...
    num2str(Settings.patterns.filter.lowerSmoothing);

%Draw Original Image
handles.originalImage = Settings.patterns.getUnfilteredPattern(1);
ax = handles.originalImageAxes;
imagesc(ax, handles.originalImage);
colormap(ax,gray);
axis(ax, 'image');
axis(ax, 'off');

%Draw Filtered Image
handles.filteredImage = Settings.patterns.getPattern(Settings,1);
ax = handles.filteredImageAxes;
imagesc(ax, handles.filteredImage);
colormap(ax, gray);
axis(ax, 'image');
axis(ax, 'off');
handles.filteredImageObject = findall(ax, 'Type', 'image');
handles.roiLines = plotROIs(handles);


%Draw Simulated Pattern
handles = DrawSimPath(handles);
guidata(hObject, handles);

% Update handles structure
handles.edited = false;
handles.Settings = Settings;
guidata(hObject, handles);

SaveColor(handles)


% --- Executes when user attempts to close ROISettingsGUI.
function ROISettingsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ROISettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
    MainHandles = guidata(handles.MainGUI);
    MainHandles.Settings = handles.Settings;
    guidata(handles.MainGUI,MainHandles);
    UpdateMainGUIs = getappdata(handles.MainGUI,'UpdateGUIs');
    UpdateMainGUIs(MainHandles);
end
UpdateTestGeom(handles)
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
ROISettingsGUI_CloseRequestFcn(handles.ROISettingsGUI, eventdata, handles);


% --- Executes on selection change in ImageFilterType.
function ImageFilterType_Callback(hObject, eventdata, handles) 
% hObject    handle to ImageFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageFilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageFilterType
contents = cellstr(get(hObject,'String'));
handles.Settings.ImageFilterType = contents{get(hObject,'Value')};
UpdateImage(handles)
if ValChanged(handles,'ImageFilterType')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


function ROISizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ROISizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROISizeEdit as text
%        str2double(get(hObject,'String')) returns contents of ROISizeEdit as a double
handles.Settings.ROISizePercent = str2double(get(hObject,'String'));
handles.Settings.ROISize = round((handles.Settings.ROISizePercent * .01)*handles.Settings.PixelSize);

handles = UpdateROIs(handles);

if ValChanged(handles,'ROISizePercent')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ROISizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROISizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumROIPopup.
function NumROIPopup_Callback(hObject, eventdata, handles)
% hObject    handle to NumROIPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NumROIPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumROIPopup
contents = cellstr(get(hObject,'String'));
handles.Settings.NumROIs = str2double(contents);

handles = UpdateROIs(handles);

if ValChanged(handles,'NumROIs')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NumROIPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumROIPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ROIStylePopup.
function ROIStylePopup_Callback(hObject, eventdata, handles)
% hObject    handle to ROIStylePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROIStylePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROIStylePopup
contents = cellstr(get(hObject,'String'));
ROIStyle = contents{get(hObject,'Value')};
handles.Settings.ROIStyle = ROIStyle;

handles = UpdateROIs(handles);

if ValChanged(handles,'ROIStyle')
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ROIStylePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIStylePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FilterEdit_Callback(hObject, eventdata, handles)
newValue = str2double(hObject.String);

switch hObject
    case handles.ROIFilter1
        handles.Settings.ROIFilter(1) = newValue;
        editValue = {'ROIFilter'};
        
    case handles.ROIFilter2
        handles.Settings.ROIFilter(2) = newValue;
        editValue = {'ROIFilter'};
        
    case handles.ROIFilter3
        handles.Settings.ROIFilter(3) = newValue;
        editValue = {'ROIFilter'};
        
    case handles.ROIFilter4
        handles.Settings.ROIFilter(4) = newValue;
        editValue = {'ROIFilter'};
        
    case handles.ImageFilter1
        handles.Settings.patterns.filter.lowerRadius = newValue;
        editValue = {'patterns', 'filter'};
        
    case handles.ImageFilter2
        handles.Settings.patterns.filter.upperRadius = newValue;
        editValue = {'patterns', 'filter'};
        
    case handles.ImageFilter3
        handles.Settings.patterns.filter.lowerSmoothing = logical(newValue);
        editValue = {'patterns', 'filter'};
        
    case handles.ImageFilter4
        handles.Settings.patterns.filter.upperSmoothing = logical(newValue);
        editValue = {'patterns', 'filter'};
        
    otherwise
        error('OpenXY:ROISettingsGUI', ...
            ['ROISettingsGUI.FilterEdit_Callback has been called '...
            'on object %s.\nThis is an internal error, please open an '...
            'issue on the OpenXY Github page'], hObject.Tag)
end

UpdateImage(handles)
if ValChanged(handles, editValue{:})
    handles.edited = true;
end
SaveColor(handles)
guidata(hObject,handles);


% --- Executes on button press in HideROIs.
function HideROIs_Callback(hObject, eventdata, handles)
% hObject    handle to HideROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HideROIs
handles.roiLines.Visible = ~hObject.Value;

function UpdateImage(handles)
handles.filteredImage = handles.Settings.patterns.getPattern(1);
handles.filteredImageObject.CData = handles.filteredImage;

function handles = UpdateROIs(handles)
delete(handles.roiLines);
handles.roiLines = plotROIs(handles);
handles.roiLines.Visible = ~handles.HideROIs.Value;


    
function roiLines = plotROIs(handles)
Settings = handles.Settings;
filteredImage = handles.filteredImage;

pixsize = size(filteredImage,1);
ROInum = Settings.NumROIs;
ROISize = Settings.ROISizePercent/100*pixsize;
ROIStyle = Settings.ROIStyle;

if ~strcmp(ROIStyle,'Intensity')
    [roixc,roiyc]= GetROIs(filteredImage,ROInum,pixsize,ROISize,ROIStyle);
elseif isfield(handles,'GenImage') % use intensity method
    [roixc,roiyc]= GetROIs(handles.GenImage,ROInum,pixsize,ROISize,ROIStyle);
end

ax = handles.filteredImageAxes;
roiLines = hggroup(ax);

hold(ax, 'on');
for ii = 1:length(roixc)
    box = DrawROI(ax, roixc(ii), roiyc(ii), ROISize);
    for line = box
        line.Parent = roiLines;
    end
    
end
hold(ax, 'off');


function box = DrawROI(ax, roixc, roiyc, ROISize)
%Draw a box around the passed in region of interest in the current figure

% plot(roiyc,roixc, '*g');

TL = [roiyc - ROISize/2 roixc - ROISize/2 ];
BR = [roiyc + ROISize/2 roixc + ROISize/2];

TopLineC = TL(2):BR(2);
TopLineR(1:length(TopLineC)) = TL(1);

top = plot(ax, TopLineC, TopLineR, '-g');

RightLineR = TL(1):BR(1);
RightLineC(1:length(RightLineR)) = BR(2);

right = plot(ax, RightLineC, RightLineR, '-g');

BottomLineC = TL(2):BR(2);
BottomLineR(1:length(BottomLineC)) = BR(1);

bottom = plot(ax, BottomLineC, BottomLineR, '-g');

LeftLineR = TL(1):BR(1);
LeftLineC(1:length(LeftLineR)) = TL(2);

left = plot(ax, LeftLineC, LeftLineR, '-g');
box = [top, left, bottom, right];

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

function SaveColor(handles)
if handles.edited
    set(handles.SaveButton,'BackgroundColor',handles.ColorEdit);
else
    set(handles.SaveButton,'BackgroundColor',handles.ColorSave);
end

function changed = ValChanged(handles,varargin)
[oldValue, newValue] = recrusiveValueFind(...
    handles.PrevSettings, handles.Settings, varargin);
if ischar(oldValue)
    changed = ~strcmp(oldValue, newValue);
else
    changed = any(oldValue ~= newValue);
end


function [oldValue, newValue] = recrusiveValueFind(old, new, fields)
oldValue = old.(fields{1});
newValue = new.(fields{1});

if length(fields) > 1
    [oldValue, newValue] = recrusiveValueFind(...
        oldValue, newValue, fields(2:end));
end


% --- Executes on key press with focus on ROISettingsGUI and none of its controls.
function ROISettingsGUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ROISettingsGUI (see GCBO)
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

function handles = DrawSimPath(handles)
ax = handles.simPatAxes;
Settings = handles.Settings;

simImage = handles.originalImage;
if isempty(simImage)
    simImage = ReadEBSDImage('demo.bmp', Settings.ImageFilter);
end

if handles.Fast
    Mat = Settings.Material;
else
    Mat = Settings.Phase{1};
end
if strcmp(Mat,'Scan File')
    text(0.5,0.5,{'Select a valid Material','from Main GUI'},'HorizontalAlignment','center');
    axis off
elseif ~handles.Fast
    Material = ReadMaterial(Mat);
    if isfield(Settings,'XStar')
        xstar = Settings.XStar(1);
        ystar = Settings.YStar(1);
        zstar = Settings.ZStar(1);
    else
        xstar = Settings.ScanParams.xstar;
        ystar = Settings.ScanParams.ystar;
        zstar = Settings.ScanParams.zstar;
    end
    paramspat={
        xstar
        ystar
        zstar
        size(simImage,1)
        Settings.AccelVoltage*1000
        Settings.SampleTilt
        Settings.CameraElevation
        Material.Fhkl
        Material.dhkl
        Material.hkl}';
    g=euler2gmat(Settings.Angles(1,1),Settings.Angles(1,2),Settings.Angles(1,3));
    
    handles.GenImage = genEBSDPatternHybrid(...
        g,...
        paramspat,...
        eye(3),...
        Material.lattice,...
        Material.a1,...
        Material.b1,...
        Material.c1,...
        Material.axs);
    handles.GenImage =...
        Settings.patterns.filter.filterImage(handles.GenImage);
    
    imagesc(ax, handles.GenImage); 
    colormap(ax, gray); 
    axis(ax, 'equal');
    axis(ax, 'off');
    drawnow
else
    text(0.5,0.5,{'Cannot create','Simulated Pattern','in Fast mode'},'HorizontalAlignment','center')
    axis off
end


% --------------------------------------------------------------------
function SimPatFrame_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SimPatFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function updates the simulated pattern when you click on the frame
% This is primarily used to give a callback function to re-generate the
% simulated pattern from other GUIs
handles = DrawSimPath(handles);
guidata(hObject, handles);

function UpdateTestGeom(handles)
if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
    MainHandles = guidata(handles.MainGUI);
    if ~isempty(MainHandles.TestGeomGUI) && isvalid(MainHandles.TestGeomGUI)
        TestGeomHandles = guidata(MainHandles.TestGeomGUI);
        % Update Settings
        TestGeomHandles.Settings = handles.Settings;
        guidata(TestGeomHandles.TestGeometryGUI,TestGeomHandles);
        if get(TestGeomHandles.Filter,'Value')
            % Update Graphs
            PlotPatternFcn = get(TestGeomHandles.NumFam,'Callback');
            PlotPatternFcn(TestGeomHandles.NumFam,[]);
        end
    end
end


% --- Executes on mouse press over axes background.
function simPatAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to simPatAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) poop
