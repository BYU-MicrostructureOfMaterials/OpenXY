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

% Last Modified by GUIDE v2.5 28-Jul-2015 06:16:36

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
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    if ~isfield(Settings,'Angles') || isempty(Settings.FirstImagePath)
        warndlg('No data to load from Settings.mat');
        delete(hObject);
        return
    end
    clear stemp
else
    Settings = varargin{1};
end
handles.PrevSettings = Settings;

%Set Position
if length(varargin) > 1
    MainSize = varargin{2};
    set(hObject,'Units','pixels');
    GUIsize = get(hObject,'Position');
    ScreenSize = get(groot,'ScreenSize');
    height = MainSize(2)+MainSize(4)+70;
    if ismac
        GUIsize(3) = GUIsize(3)*1.2;
    end
    set(hObject,'Position',[MainSize(1) height GUIsize(3) GUIsize(4)]);
    movegui(hObject,'onscreen')
end

%Set Images to Grayscale
colormap gray;

%ROI Size
set(handles.ROISizeEdit,'String',num2str(Settings.ROISizePercent));
%NumROI Popup
MaxROINum = 50;
set(handles.NumROIPopup,'String',num2cell(1:MaxROINum));
SetPopupValue(handles.NumROIPopup,Settings.NumROIs);
%ROI Style Popup
ROIStyleList = {'Grid','Radial','Intensity'};
set(handles.ROIStylePopup, 'String', ROIStyleList);
SetPopupValue(handles.ROIStylePopup,Settings.ROIStyle);
%ROIFilter
set(handles.ROIFilter1,'String',num2str(Settings.ROIFilter(1)));
set(handles.ROIFilter2,'String',num2str(Settings.ROIFilter(2)));
set(handles.ROIFilter3,'String',num2str(Settings.ROIFilter(3)));
set(handles.ROIFilter4,'String',num2str(Settings.ROIFilter(4)));
%Image Filter Type Popup
ImageFilterTypeList = {'standard','localthresh'};
set(handles.ImageFilterType, 'String', ImageFilterTypeList);
SetPopupValue(handles.ImageFilterType,Settings.ImageFilterType);
%ImageFilter
set(handles.ImageFilter1,'String',num2str(Settings.ImageFilter(1)));
set(handles.ImageFilter2,'String',num2str(Settings.ImageFilter(2)));
set(handles.ImageFilter3,'String',num2str(Settings.ImageFilter(3)));
set(handles.ImageFilter4,'String',num2str(Settings.ImageFilter(4)));

%Draw Original Image
axes(handles.OriginalImage);
handles.OrigImage = imread(Settings.FirstImagePath);
imagesc(CropSquare(handles.OrigImage));
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

%Draw Filtered Image
handles.Settings = Settings;
guidata(hObject, handles);
UpdateImageDisplay(handles);
handles = guidata(hObject);

%Draw Simulated Pattern
Image = ReadEBSDImage(Settings.FirstImagePath, Settings.ImageFilter);
if isempty(Image)
    Image = ReadEBSDImage('demo.bmp', Settings.ImageFilter);
end
Material = ReadMaterial(Settings.Phase{1});
paramspat={Settings.ScanParams.xstar;Settings.ScanParams.ystar;Settings.ScanParams.zstar;...
    size(Image,1);Settings.AccelVoltage*1000;Settings.SampleTilt;Settings.CameraElevation;...
    Material.Fhkl;Material.dhkl;Material.hkl};
g=euler2gmat(Settings.Angles(1,1),Settings.Angles(1,2),Settings.Angles(1,3));
handles.GenImage = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
handles.GenImage = custimfilt(handles.GenImage, Settings.ImageFilter(1), Settings.ImageFilter(2),Settings.ImageFilter(3),Settings.ImageFilter(4));
axes(handles.SimPat);
imagesc(handles.GenImage)
drawnow
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

% Update handles structure
handles.Settings = Settings;
guidata(hObject, handles);

% UIWAIT makes ROISettingsGUI wait for user response (see UIRESUME)
uiwait(handles.ROISettingsGUI);


% --- Outputs from this function are returned to the command line.
function varargout = ROISettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles,'Settings')
    varargout{1} = handles.Settings;
end
delete(hObject);

% --- Executes when user attempts to close ROISettingsGUI.
function ROISettingsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ROISettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

% --- Executes on button press in SaveCloseButton.
function SaveCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROISettingsGUI_CloseRequestFcn(handles.ROISettingsGUI, eventdata, handles);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Settings = handles.PrevSettings;
guidata(hObject,handles);
ROISettingsGUI_CloseRequestFcn(handles.ROISettingsGUI, eventdata, handles);


function ImageFilter1_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageFilter1 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilter1 as a double
handles.Settings.ImageFilter(1) = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ImageFilter1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageFilter2_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageFilter2 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilter2 as a double
handles.Settings.ImageFilter(2) = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ImageFilter2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageFilter3_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageFilter3 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilter3 as a double
handles.Settings.ImageFilter(3) = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ImageFilter3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageFilter4_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilter4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageFilter4 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilter4 as a double
handles.Settings.ImageFilter(4) = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ImageFilter4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilter4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ImageFilterType.
function ImageFilterType_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageFilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageFilterType
contents = cellstr(get(hObject,'String'));
handles.Settings.ImageFilterType = contents{get(hObject,'Value')};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ImageFilterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROISizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ROISizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROISizeEdit as text
%        str2double(get(hObject,'String')) returns contents of ROISizeEdit as a double
handles.Settings.ROISizePercent = str2double(get(hObject,'String'));
handles.Settings.ROISize = round((handles.Settings.ROISizePercent * .01)*handles.Settings.PixelSize);
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
handles.Settings.NumROIs = str2double(contents{get(hObject,'Value')});
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
if strcmp(ROIStyle,'Grid')
    SetPopupValue(handles.NumROIPopup,num2str(48));
    handles.Settings.NumROIs = 48;
end
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



function ROIFilter1_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilter1 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilter1 as a double
handles.Settings.ROIFilter(1) = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ROIFilter1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIFilter2_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilter2 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilter2 as a double
handles.Settings.ROIFilter(2) = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ROIFilter2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIFilter3_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilter3 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilter3 as a double
handles.Settings.ROIFilter(3) = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ROIFilter3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilter3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ROIFilter4_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilter4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilter4 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilter4 as a double
handles.Settings.ROIFilter(4) = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ROIFilter4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilter4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RefreshButton.
function RefreshButton_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateImageDisplay(handles);

% --- Executes on button press in UpdateROIButton.
function UpdateROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateROIDisplay(handles);


function UpdateImageDisplay(handles)
% Apply updated filter to displayed image
Settings=handles.Settings;

if strcmp(Settings.ImageFilterType,'standard')
    Image=ReadEBSDImage(Settings.FirstImagePath,Settings.ImageFilter);
else
    Image=localthresh(Settings.FirstImagePath);
end
axes(handles.FilteredImage);
cla
imagesc(Image);
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
GenImage=handles.GenImage;

if ~strcmp(ROIStyle,'Intensity')
    [roixc,roiyc]= GetROIs(FiltImage,ROInum,pixsize,ROISize,ROIStyle);
else % use intensity method
    [roixc,roiyc]= GetROIs(GenImage,ROInum,pixsize,ROISize,ROIStyle);
end


for ii = 1:length(roixc)
    hold on  
    DrawROI(roixc(ii),roiyc(ii),ROISize);
%     rectangle('Curvature',[0 0],'Position',...
%         [roixc(ii)-roisize/2 roiyc(ii)-roisize/2 roisize roisize],...
%         'EdgeColor','g');   
end
axes(handles.SimPat)
cla
imagesc(GenImage);
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
if isempty(Value); Value =1; end;
set(Popup, 'Value', Value);
    
function string = GetPopupString(Popup)
List = get(Popup,'String');
Value = get(Popup,'Value');
string = List{Value};    

