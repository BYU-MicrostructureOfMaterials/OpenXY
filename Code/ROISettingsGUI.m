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

% Last Modified by GUIDE v2.5 28-Apr-2015 12:49:46

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
if isempty(varargin)
    stemp=load('Settings.mat');
    Settings = stemp.Settings;
    clear stemp
else
    Settings = varargin{1};
end

%Set Images to Grayscale
colormap gray;

%NumROI Popup
MaxROINum = 50;
set(handles.NumROIPopup,'String',num2cell(1:MaxROINum));
SetPopupValue(handles.NumROIPopup,Settings.NumROIs);
%ROI Style Popup
ROIStyleList = {'Grid','Radial','Intensity'};
set(handles.ROIStylePopup, 'String', ROIStyleList);
SetPopupValue(handles.ROIStylePopup,Settings.ROIStyle);
%Image Filter Type Popup
ImageFilterTypeList = {'standard','localthresh'};
set(handles.ImageFilterType, 'String', ImageFilterTypeList);
SetPopupValue(handles.ImageFilterType,Settings.ImageFilterType);

%Draw Original Image
axes(handles.OriginalImage);
imagesc(CropSquare(imread(Settings.FirstImagePath)));
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

if strcmp(Settings.Material,'Auto-detect')
    


% Update handles structure
handles.Settings = Settings;
guidata(hObject, handles);

% UIWAIT makes ROISettingsGUI wait for user response (see UIRESUME)
% uiwait(handles.ROISettingsGUI);


% --- Outputs from this function are returned to the command line.
function varargout = ROISettingsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ImageFilter1_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageFilter1 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilter1 as a double


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

function UpdateImageDisplay(handles,ImageFilt)
% Apply updated filter to displayed image
Settings=handles.Settings;
ImageFilterTypeList=get(handles.ImageFilterType,'String');
Ind=get(handles.ImageFilterType,'Value');

if strcmp(ImageFilterTypeList(Ind),'standard')
    Image=ReadEBSDImage(Settings.FirstImagePath,ImageFilt);
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

function SetPopupValue(Popup,String)
String = num2str(String);    
List = get(Popup,'String');
IndList = 1:length(List);
Value = IndList(strcmp(List,String));
set(Popup, 'Value', Value);
    
    
    
    
    
    
