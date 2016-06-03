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

% Last Modified by GUIDE v2.5 02-Jun-2016 10:05:05

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
guidata(handles.PCEdit,handles);
SetPopupValue(handles.PCType,input{4});
SetPopupValue(handles.PlaneFit,input{5});
handles = guidata(handles.PCEdit);
set(handles.NameEdit,'String',input{6});
handles.PCData = input{7};

%Read in VHRatio
if ~isempty(varargin{2})
    handles.V = varargin{2};
end

%Read in image maps
if length(varargin) > 2
    handles.IQ_map = varargin{3}.IQ_map;
    handles.IPF_map = varargin{3}.IPF_map;
    set(handles.IPFPlot,'Value',1);
    UpdatePlot(handles); 
end
UpdatePC(handles);

pos = get(handles.PCEdit,'Position');
Type = input{4};
switch Type
    case 'Strain Minimization'
        set(handles.PCEdit,'Position',[pos(1) pos(2) 88 pos(4)]);
        set(handles.StrainMinPanel,'Visible','on');
        set(handles.PCGridPanel,'Visible','off');
    case 'Grid'
        set(handles.PCEdit,'Position',[pos(1) pos(2) 128 pos(4)]);
        set(handles.StrainMinPanel,'Visible','on','Position',[85 0.5 40 17]);
        set(handles.PCGridPanel,'Visible','on','Position',[44 0.5 40 17]);
        if length(input)>6 && ~isempty(input{7})
            set(handles.numpats,'String',input{7}.numpats,'Enable','off');
            set(handles.numpc,'String',input{7}.numpc);
            set(handles.deltapc,'String',input{7}.deltapc);
            set(handles.XStarFit,'Enable','on')
            set(handles.YStarFit,'Enable','on')
            set(handles.ZStarFit,'Enable','on')
            set(handles.NoGridPlot,'Enable','on')
        else
            set(handles.numpats,'String',100); handles.PCData.numpats = 100;
            set(handles.numpc,'String',40); handles.PCData.numpc = 40;
            set(handles.deltapc,'String',0.06/40); handles.PCData.deltapc = 0.06/handles.PCData.numpc;
            set(handles.XStarFit,'Enable','off')
            set(handles.YStarFit,'Enable','off')
            set(handles.ZStarFit,'Enable','off')
            set(handles.NoGridPlot,'Enable','off')
        end
    otherwise
        set(handles.PCEdit,'Position',[pos(1) pos(2) 45 pos(4)]);
        set(handles.StrainMinPanel,'Visible','off');
        set(handles.PCGridPanel,'Visible','off');
end

% Update handles structure
handles.fig = {};
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
if ishandle(handles.fig)
    close(handles.fig)
end
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
UpdatePC(handles);


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
UpdatePC(handles);

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
UpdatePC(handles);

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



function PCX_Callback(hObject, eventdata, handles)
% hObject    handle to PCX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PCX as text
%        str2double(get(hObject,'String')) returns contents of PCX as a double
V = handles.V;
handles.xstar = str2double(get(handles.PCX,'String'))/V-1/(2*V)+1/2;
guidata(handles.PCEdit,handles);
UpdatePC(handles);



% --- Executes during object creation, after setting all properties.
function PCX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PCY_Callback(hObject, eventdata, handles)
% hObject    handle to PCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PCY as text
%        str2double(get(hObject,'String')) returns contents of PCY as a double
V = handles.V;
handles.ystar = str2double(get(handles.PCX,'String'))/V;
guidata(handles.PCEdit,handles);
UpdatePC(handles);

% --- Executes during object creation, after setting all properties.
function PCY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PCY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DD_Callback(hObject, eventdata, handles)
% hObject    handle to DD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DD as text
%        str2double(get(hObject,'String')) returns contents of DD as a double
V = handles.V;
handles.zstar = str2double(get(handles.PCX,'String'))/V;
guidata(handles.PCEdit,handles);
UpdatePC(handles);


% --- Executes during object creation, after setting all properties.
function DD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DD (see GCBO)
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
V = handles.V;
set(handles.XStarEdit,'String',num2str(handles.xstar));
set(handles.YStarEdit,'String',num2str(handles.ystar));
set(handles.ZStarEdit,'String',num2str(handles.zstar));
set(handles.PCX,'String',num2str(handles.xstar*V+(1-V)/2));
set(handles.PCY,'String',num2str(handles.ystar*V));
set(handles.DD,'String',num2str(handles.zstar*V));


% --- Executes when selected object is changed in StrainMinPanel.
function StrainMinPanel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in StrainMinPanel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdatePlot(handles)

function UpdatePlot(handles)
%Reset Plot
cla(handles.StrainMinaxes,'reset');
[Ny,Nx] = size(handles.IQ_map);

%Plot Selected graph
if get(handles.IPFPlot,'Value')
    image(handles.StrainMinaxes,handles.IPF_map)
    
    %Plot Calibration Points
    if ismember(GetPopupString(handles.PCType),{'Strain Minimization','Grid'})
        hold on
        [Yinds,Xinds] = ind2sub([Nx Ny],handles.PCData.CalibrationIndices);
        plot(Xinds,Yinds,'kd','MarkerFaceColor','k')
    end
elseif get(handles.IQPlot,'Value')
    image(handles.StrainMinaxes,handles.IQ_map)
    
    %Plot Calibration Points
    if ismember(GetPopupString(handles.PCType),{'Strain Minimization','Grid'})
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
   handles.PCData.CalibrationIndices = SelectCalibrationPoints(handles.IQ_map,handles.IPF_map,handles.PCData.CalibrationIndices(:,1));
   numpats = length(handles.PCData.CalibrationIndices);
   set(handles.numpats,'String',numpats);
   handles.PCData.numpats = numpats;
   UpdatePlot(handles);
end
guidata(handles.PCEdit,handles);



function numpats_Callback(hObject, eventdata, handles)
% hObject    handle to numpats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numpats as text
%        str2double(get(hObject,'String')) returns contents of numpats as a double
handles.PCData.numpats = str2double(get(handles.numpats,'String'));
guidata(handles.PCEdit,handles);

% --- Executes during object creation, after setting all properties.
function numpats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numpats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function numpc_Callback(hObject, eventdata, handles)
% hObject    handle to numpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numpc as text
%        str2double(get(hObject,'String')) returns contents of numpc as a double
handles.PCData.numpc = str2double(get(handles.numpc,'String'));
guidata(handles.PCEdit,handles);


% --- Executes during object creation, after setting all properties.
function numpc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function deltapc_Callback(hObject, eventdata, handles)
% hObject    handle to deltapc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deltapc as text
%        str2double(get(hObject,'String')) returns contents of deltapc as a double
handles.PCData.deltapc = str2double(get(handles.deltapc,'String'));
guidata(handles.PCEdit,handles);

% --- Executes during object creation, after setting all properties.
function deltapc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deltapc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in GridPlotPanel.
function GridPlotPanel_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in GridPlotPanel 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'PCData')
    if ~get(handles.NoGridPlot,'Value')
        handles.fig = figure(1);
        set(handles.PCEdit,'Units','Pixels');
        pos = get(handles.PCEdit,'Position');
        set(handles.fig,'Units','Pixels','Position',[pos(1)+pos(3) pos(2)+pos(4)-350 500 350])
        cla
    end
    if get(handles.XStarFit,'Value')
        EvalPCGrid(handles.PCData.StrainPoints(:,:,1),handles.PCData.PCPoints(:,:,1));
    elseif get(handles.YStarFit,'Value')
        EvalPCGrid(handles.PCData.StrainPoints(:,:,2),handles.PCData.PCPoints(:,:,2));
    elseif get(handles.ZStarFit,'Value')
        EvalPCGrid(handles.PCData.StrainPoints(:,:,3),handles.PCData.PCPoints(:,:,3));
    else
        if ishandle(handles.fig)
            close(handles.fig)
        end
    end
    guidata(handles.PCEdit,handles);
end
