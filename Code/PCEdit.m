function varargout = PCEdit(varargin)
% PCEDIT MATLAB code for PCEdit.fig
%      PCEDIT, by itself, creates a new PCEDIT or raises the existing
%      singleton*.
%
%      H = PCEDIT returns the handle to a new PCEDIT or the handle to
%      the existing singleton*.
%
%      PCEDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCEDIT.M with the given input arguments.
%
%      PCEDIT('Property','Value',...) creates a new PCEDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PCEdit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PCEdit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PCEdit

% Last Modified by GUIDE v2.5 01-Jun-2016 14:07:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PCEdit_OpeningFcn, ...
                   'gui_OutputFcn',  @PCEdit_OutputFcn, ...
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


% --- Executes just before PCEdit is made visible.
function PCEdit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PCEdit (see VARARGIN)

%Populate PCMethod Box
set(handles.PCType,'String',{'Strain Minimization','Grid','Tiff','Scan File','Manual'});
set(handles.PCType,'Enable','off');

%Populate PlaneFit box
set(handles.PlaneFit,'String',{'Naive','None'});

%Read Input
input = varargin{1};
handles.xstar = input{1};
handles.ystar = input{2};
handles.zstar = input{3};
UpdatePC(handles);
guidata(handles.PCEdit,handles);
SetPopupValue(handles.PCType,input{4});
SetPopupValue(handles.PlaneFit,input{5});
handles = guidata(handles.PCEdit);
set(handles.NameEdit,'String',input{6});
handles.PCData = input{7};

if ~isempty(varargin{2})
    handles.IQ_map = varargin{2}.IQ_map;
    handles.IPF_map = varargin{2}.IPF_map;
end
set(handles.IPFPlot,'Value',1);
UpdatePlot(handles); 


pos = get(handles.PCEdit,'Position');
Type = input{4};
switch Type
    case 'Strain Minimization'
        set(handles.PCEdit,'Position',[pos(1) pos(2) 88 pos(4)]);
        set(handles.StrainMinPanel,'Visible','on');
    otherwise
        set(handles.StrainMinPanel,'Visible','off');
        set(handles.PCEdit,'Position',[pos(1) pos(2) 45 pos(4)]);
end
        


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PCEdit wait for user response (see UIRESUME)
uiwait(handles.PCEdit);


% --- Outputs from this function are returned to the command line.
function varargout = PCEdit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = {handles.xstar,...
                handles.ystar,...
                handles.zstar,...
                GetPopupString(handles.PCType),GetPopupString(handles.PlaneFit)...
                get(handles.NameEdit,'String'),handles.PCData};
delete(handles.PCEdit);


% --- Executes when user attempts to close PCEdit.
function PCEdit_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PCEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if strcmp(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

% --- Executes on button press in DoneButton.
function DoneButton_Callback(hObject, eventdata, handles)
% hObject    handle to DoneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PCEdit_CloseRequestFcn(handles.PCEdit, eventdata, handles);


function XStarEdit_Callback(hObject, eventdata, handles)
% hObject    handle to XStarEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XStarEdit as text
%        str2double(get(hObject,'String')) returns contents of XStarEdit as a double
handles.xstar = str2double(get(handles.XStarEdit,'String'));
guidata(handles.PCEdit,handles);


% --- Executes during object creation, after setting all properties.
function XStarEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XStarEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YStarEdit_Callback(hObject, eventdata, handles)
% hObject    handle to YStarEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YStarEdit as text
%        str2double(get(hObject,'String')) returns contents of YStarEdit as a double
handles.ystar = str2double(get(handles.YStarEdit,'String'));
guidata(handles.PCEdit,handles);

% --- Executes during object creation, after setting all properties.
function YStarEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YStarEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZStarEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ZStarEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZStarEdit as text
%        str2double(get(hObject,'String')) returns contents of ZStarEdit as a double
handles.zstar = str2double(get(handles.ZStarEdit,'String'));
guidata(handles.PCEdit,handles);

% --- Executes during object creation, after setting all properties.
function ZStarEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZStarEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PCType.
function PCType_Callback(hObject, eventdata, handles)
% hObject    handle to PCType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PCType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PCType


% --- Executes during object creation, after setting all properties.
function PCType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlaneFit.
function PlaneFit_Callback(hObject, eventdata, handles)
% hObject    handle to PlaneFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlaneFit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlaneFit


% --- Executes during object creation, after setting all properties.
function PlaneFit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlaneFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XStarEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to XStarEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XStarEdit2 as text
%        str2double(get(hObject,'String')) returns contents of XStarEdit2 as a double


% --- Executes during object creation, after setting all properties.
function XStarEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XStarEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YStarEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to YStarEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YStarEdit2 as text
%        str2double(get(hObject,'String')) returns contents of YStarEdit2 as a double


% --- Executes during object creation, after setting all properties.
function YStarEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YStarEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZStarEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to ZStarEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZStarEdit2 as text
%        str2double(get(hObject,'String')) returns contents of ZStarEdit2 as a double


% --- Executes during object creation, after setting all properties.
function ZStarEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZStarEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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

function UpdatePC(handles)
set(handles.XStarEdit,'String',num2str(handles.xstar));
set(handles.YStarEdit,'String',num2str(handles.ystar));
set(handles.ZStarEdit,'String',num2str(handles.zstar));


% --- Executes when selected object is changed in StrainMinPanel.
function StrainMinPanel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in StrainMinPanel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdatePlot(handles)

function UpdatePlot(handles)
%Reset Plot
cla(handles.StrainMinaxes,'reset');
[Nx, Ny] = size(handles.IQ_map);

%Plot Selected graph
if get(handles.IPFPlot,'Value')
    image(handles.StrainMinaxes,handles.IPF_map)
    
    %Plot Calibration Points
    if strcmp('Strain Minimization',GetPopupString(handles.PCType))
        hold on
        [Yinds,Xinds] = ind2sub([Nx Ny],handles.PCData.CalibrationIndices);
        plot(Xinds,Yinds,'kd','MarkerFaceColor','k')
    end
elseif get(handles.IQPlot,'Value')
    image(handles.StrainMinaxes,handles.IQ_map)
    
    %Plot Calibration Points
    if strcmp('Strain Minimization',GetPopupString(handles.PCType))
        hold on
        [Yinds,Xinds] = ind2sub([Nx Ny],handles.PCData.CalibrationIndices);
        plot(Xinds,Yinds,'kd','MarkerFaceColor','k')
    end
end
set(handles.StrainMinaxes,'XTick',[],'YTick',[]);



function NameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NameEdit as text
%        str2double(get(hObject,'String')) returns contents of NameEdit as a double


% --- Executes during object creation, after setting all properties.
function NameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectPoints.
function SelectPoints_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel = questdlg({'This will create a new pattern center calibration.';'Continue?'},'Point Selection','Yes','No','Yes');
if strcmp(sel,'Yes')
   handles.PCData.CalibrationIndices = SelectCalibrationPoints(handles.IQ_map,handles.IPF_map);
end
guidata(handles.PCEdit,handles);

