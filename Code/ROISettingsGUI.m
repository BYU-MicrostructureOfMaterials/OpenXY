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

% Last Modified by GUIDE v2.5 16-Aug-2017 14:05:13

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

%Fast GUI
if handles.Fast

end

%Check if H5 patterns
handles.h5 = false;
[~,~,ext] = fileparts(Settings.ScanFilePath);
if strcmp(ext,'.h5')
    handles.h5 = true;
end

%Set Position and Visuals
if ~isempty(handles.MainGUI) && isvalid(handles.MainGUI)
    MainSize = get(handles.MainGUI,'Position');
    set(hObject,'Units','pixels');
    GUIsize = get(hObject,'Position');
    height = MainSize(2)+MainSize(4)+70;
    if ismac
        GUIsize(3) = GUIsize(3)*1.2;
    end
    set(hObject,'Position',[MainSize(1)-230-20 height GUIsize(3) GUIsize(4)]);
    movegui(hObject,'onscreen')
end

%Set up Keyboard shortcuts (currently undocumented)
gui = findall(handles.ROISettingsGUI,'KeyPressFcn','');
set(gui,'KeyPressFcn',@ROISettingsGUI_KeyPressFcn);


%Set Images to Grayscale
colormap gray;

%ROI Size
handles.ROISizeEdit.String = num2str(Settings.ROISizePercent);
%NumROI Popup
MaxROINum = 50;
handles.NumROIPopup.String = num2cell(1:MaxROINum);
SetPopupValue(handles.NumROIPopup,Settings.NumROIs);
%ROI Style Popup
ROIStyleList = {'Grid','Radial','Intensity','Annular'};
handles.ROIStylePopup.String = ROIStyleList;
SetPopupValue(handles.ROIStylePopup,Settings.ROIStyle);
%ROIFilter
handles.ROIFilter1.String = num2str(Settings.ROIFilter(1));
handles.ROIFilter2.String = num2str(Settings.ROIFilter(2));
handles.ROIFilter3.String = num2str(Settings.ROIFilter(3));
handles.ROIFilter4.String = num2str(Settings.ROIFilter(4));
%Image Filter Type Popup
ImageFilterTypeList = {'standard','localthresh'};
handles.ImageFilterType.String = ImageFilterTypeList;
SetPopupValue(handles.ImageFilterType,Settings.ImageFilterType);
%ImageFilter
handles.ImageFilter1.String = num2str(Settings.ImageFilter(1));
handles.ImageFilter2.String = num2str(Settings.ImageFilter(2));
handles.ImageFilter3.String = num2str(Settings.ImageFilter(3));
handles.ImageFilter4.String = num2str(Settings.ImageFilter(4));

%Draw Original Image
axes(handles.OriginalImage);
if ~handles.h5
    handles.OrigImage = imread(Settings.FirstImagePath);
else
    handles.OrigImage = ReadH5Pattern(Settings.ScanFilePath,Settings.ImageNamesList,Settings.imsize,Settings.ImageFilter,Settings.valid,1);
end
imagesc(CropSquare(handles.OrigImage)); colormap(gca,gray);
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

%Draw Filtered Image
handles.Settings = Settings;
guidata(hObject, handles);
handles = guidata(hObject);

%Draw Simulated Pattern
DrawSimPath(handles)
guidata(hObject, handles);

%Set up Listeners
imListenProperties = {'ROISizePercent','ROIStyle','ImageFilter',...
    'ImageFilterType','NumROIs'};
handles.imListener = addlistener(Settings,imListenProperties,'PostSet',...
    @(~,event)imListenFcn(hObject,event));
simListenProperties = {'AccelVoltage','SampleTilt','ImageFilter'...
    'CameraElevation','mperpix'};
handles.simListener = addlistener(Settings,simListenProperties,'PostSet',...
    @(~,event)simListenFcn(hObject,event));


% Update handles structure
ROIStylePopup_Callback(handles.ROIStylePopup, eventdata, handles)
handles.Settings = Settings;
guidata(hObject, handles);
UpdateImage(handles);

function imListenFcn(hObject,event)
handles = guidata(hObject);
UpdateImage(handles)

function simListenFcn(hObject,event)
handles = guidata(hObject);
DrawSimPath(handles);

% --- Outputs from this function are returned to the command line.
function varargout = ROISettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;

% --- Executes when user attempts to close ROISettingsGUI.
function ROISettingsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ROISettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.imListener)
delete(handles.simListener)
delete(hObject);


% --- Executes on button press in DoneButton.
function DoneButton_Callback(hObject, eventdata, handles)
% hObject    handle to DoneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROISettingsGUI_CloseRequestFcn(handles.ROISettingsGUI, eventdata, handles);



function ImageFilter_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ind = str2double(hObject.Tag(end));
handles.Settings.ImageFilter(ind) = str2double(get(hObject,'String'));



% --- Executes on selection change in ImageFilterType.
function ImageFilterType_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
handles.Settings.ImageFilterType = contents{get(hObject,'Value')};



function ROISizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ROISizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Settings.ROISizePercent = str2double(get(hObject,'String'));



% --- Executes on selection change in NumROIPopup.
function NumROIPopup_Callback(hObject, eventdata, handles)
% hObject    handle to NumROIPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
handles.Settings.NumROIs = str2double(contents{get(hObject,'Value')});



% --- Executes on selection change in ROIStylePopup.
function ROIStylePopup_Callback(hObject, eventdata, handles)
% hObject    handle to ROIStylePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
ROIStyle = contents{get(hObject,'Value')};
handles.Settings.ROIStyle = ROIStyle;
if strcmp(ROIStyle,'Grid')
    SetPopupValue(handles.NumROIPopup,num2str(48));
    set(handles.NumROIPopup,'Enable','off')
else
    set(handles.NumROIPopup,'Enable','on')
end



function ROIFilter_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ind = str2double(hObject.Tag(end));

handles.Settings.ROIFilter(ind) = str2double(get(hObject,'String'));
guidata(hObject,handles);



% --- Executes on button press in HideROIs.
function HideROIs_Callback(hObject, eventdata, handles)
% hObject    handle to HideROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateImage(handles)

function UpdateImage(handles)
if ~get(handles.HideROIs,'Value')
    UpdateROIDisplay(handles)
else
    UpdateImageDisplay(handles)
end

function UpdateImageDisplay(handles)
% Apply updated filter to displayed image
Settings=handles.Settings;

if ~handles.h5
    if strcmp(Settings.ImageFilterType,'standard')
        Image=ReadEBSDImage(Settings.FirstImagePath,Settings.ImageFilter);
    else
        Image=localthresh(Settings.FirstImagePath);
    end
else
    Image = ReadH5Pattern(Settings.ScanFilePath,Settings.ImageNamesList,Settings.imsize,Settings.ImageFilter,Settings.valid,1);
end

axes(handles.FilteredImage);
cla
imagesc(Image); colormap(gca,'gray')
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

handles.FiltImage = Image;
guidata(handles.ROISettingsGUI,handles);

function UpdateROIDisplay(handles)
Settings = handles.Settings;
UpdateImageDisplay(handles);
handles = guidata(handles.ROISettingsGUI);
FiltImage = handles.FiltImage;

pixsize = size(FiltImage,1);
ROInum = Settings.NumROIs;
ROISize = Settings.ROISizePercent/100*pixsize;
ROIStyle = Settings.ROIStyle;

if ~strcmp(ROIStyle,'Intensity')
    [roixc,roiyc]= GetROIs(FiltImage,ROInum,pixsize,ROISize,ROIStyle);
elseif isfield(handles,'GenImage') % use intensity method
    [roixc,roiyc]= GetROIs(handles.GenImage,ROInum,pixsize,ROISize,ROIStyle);
end

if ~strcmp(ROIStyle,'Intensity') || isfield(handles,'GenImage')
    for ii = 1:length(roixc)
        hold on  
        DrawROI(roixc(ii),roiyc(ii),ROISize);
    %     rectangle('Curvature',[0 0],'Position',...
    %         [roixc(ii)-roisize/2 roiyc(ii)-roisize/2 roisize roisize],...
    %         'EdgeColor','g');   
    end
end

if isfield(handles,'GenImage')
    axes(handles.SimPat)
    cla
    imagesc(handles.GenImage); colormap(gca,gray);
    set(gca,'xcolor',get(gcf,'color'));
    set(gca,'ycolor',get(gcf,'color'));
    set(gca,'ytick',[]);
    set(gca,'xtick',[]);
    axis equal

    if strcmp(ROIStyle,'Intensity')
        for jj = 1:length(roixc)
            hold on
            DrawROI(roixc(jj),roiyc(jj),ROISize);
        %     rectangle('Curvature',[0 0],'Position',...
        %         [roixc(jj)-roisize/2 roiyc(jj)-roisize/2 roisize roisize],...
        %         'EdgeColor','g');
        end
    end
end
    
    
function DrawROI(roixc,roiyc,ROISize)
%Draw a box around the passed in region of interest in the current figure
hold on
% plot(roiyc,roixc, '*g');

TL = [roiyc - ROISize/2 roixc - ROISize/2 ];
BR = [roiyc + ROISize/2 roixc + ROISize/2];

TopLineC = TL(2):BR(2);
TopLineR(1:length(TopLineC)) = TL(1);
hold on
plot(TopLineC, TopLineR, '-g');

RightLineR = TL(1):BR(1);
RightLineC(1:length(RightLineR)) = BR(2);
hold on
plot(RightLineC, RightLineR, '-g');

BottomLineC = TL(2):BR(2);
BottomLineR(1:length(BottomLineC)) = BR(1);
hold on
plot(BottomLineC, BottomLineR, '-g');

LeftLineR = TL(1):BR(1);
LeftLineC(1:length(LeftLineR)) = TL(2);
hold on
plot(LeftLineC, LeftLineR, '-g');

function SetPopupValue(Popup,String)
String = num2str(String);    
List = get(Popup,'String');
IndList = 1:length(List);
Value = IndList(strcmp(List,String));
if isempty(Value); Value =1; end
set(Popup, 'Value', Value);
    
function string = GetPopupString(Popup)
List = get(Popup,'String');
Value = get(Popup,'Value');
string = List{Value};    



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
    SaveButton_Callback(handles.DoneButton, eventdata, handles);
end
% Close Figure with CTRL-L
if strcmp(eventdata.Key,'l') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
    CancelButton_Callback(handles.DoneButton, eventdata, handles);
end

function DrawSimPath(handles)
axes(handles.SimPat);
Settings = handles.Settings;

Image = handles.OrigImage;
if isempty(Image)
    Image = ReadEBSDImage('demo.bmp', Settings.ImageFilter);
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
    paramspat={xstar;ystar;zstar;...
        size(Image,1);Settings.AccelVoltage*1000;Settings.SampleTilt;Settings.CameraElevation;...
        Material.Fhkl;Material.dhkl;Material.hkl};
    g=euler2gmat(Settings.Angles(1,1),Settings.Angles(1,2),Settings.Angles(1,3));
    handles.GenImage = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
    handles.GenImage = custimfilt(handles.GenImage, Settings.ImageFilter(1), Settings.ImageFilter(2),Settings.ImageFilter(3),Settings.ImageFilter(4));
    imagesc(handles.GenImage); colormap(gca,gray); axis equal; axis off;
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
DrawSimPath(handles)
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

