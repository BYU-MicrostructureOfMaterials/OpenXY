function varargout = NewMaterialGUI(varargin)
% NEWMATERIALGUI MATLAB code for NewMaterialGUI.fig
%      NEWMATERIALGUI, by itself, creates a new NEWMATERIALGUI or raises the existing
%      singleton*.
%
%      H = NEWMATERIALGUI returns the handle to a new NEWMATERIALGUI or the handle to
%      the existing singleton*.
%
%      NEWMATERIALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWMATERIALGUI.M with the given input arguments.
%
%      NEWMATERIALGUI('Property','Value',...) creates a new NEWMATERIALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewMaterialGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewMaterialGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewMaterialGUI

% Last Modified by GUIDE v2.5 21-Jan-2015 14:42:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NewMaterialGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @NewMaterialGUI_OutputFcn, ...
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


% --- Executes just before NewMaterialGUI is made visible.
function NewMaterialGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewMaterialGUI (see VARARGIN)

% Choose default command line output for NewMaterialGUI
handles.output = hObject;

edits = findobj('Style','edit');
set(edits,'FontSize',6);
set(handles.material,'FontSize',8);

latticelist = {'cubic', 'hexagonal', 'tetragonal'};
set(handles.lattice,'String',latticelist);

NumValues = 8;
LatticeNumber = 3;

% Positioning
handles.fhkllabel.Units = 'pixels';
handles.dhkllabel.Units = 'pixels';
handles.hkllabel.Units = 'pixels';
pos.fhkllabel = handles.fhkllabel.Position;
pos.dhkllabel = handles.dhkllabel.Position;
pos.hkllabel = handles.hkllabel.Position;

left = pos.fhkllabel(1) + pos.fhkllabel(3);
height = 22;
fields = fieldnames(pos);
for i = 1:numel(fields)
    fieldname = fields{i}(1:strfind(fields{i},'label')-1);
    pos.(fieldname)(1) = left;
    pos.(fieldname)(2) = pos.(fields{i})(2) + pos.(fields{i})(4)/2 - height/2;
    pos.(fieldname)(3) = 100;
    pos.(fieldname)(4) = height;
end

% Create Tables
fhkl = uitable(handles.NewMaterial,'Position',pos.fhkl,'Data',cell(1,NumValues),...
    'ColumnWidth',{25},'ColumnEditable',true(1,NumValues),...
    'RowName',[],'ColumnName',[]);
dhkl = uitable(handles.NewMaterial,'Position',pos.dhkl,'Data',cell(1,NumValues),...
    'ColumnWidth',{25},'ColumnEditable',true(1,NumValues),...
    'RowName',[],'ColumnName',[]);
hkl = uitable(handles.NewMaterial,'Position',pos.hkl,'Data',cell(NumValues,LatticeNumber),...
    'ColumnWidth',{25},'ColumnEditable',true(1,NumValues),...
    'RowName',[],'ColumnName',[]);

fhkl.Position(3)=fhkl.Extent(3);
fhkl.Position(4)=fhkl.Extent(4);
dhkl.Position(3)=dhkl.Extent(3);
dhkl.Position(4)=dhkl.Extent(4);

height1 = hkl.Position(4);
height2 = hkl.Extent(4);
shift = height1 - height2;
hkl.Position(3)=hkl.Extent(3);
hkl.Position(4)=hkl.Extent(4);
a = hkl.Position(2);
hkl.Position(2)=a+shift;


% Load Variables into handles structure
handles.fhkl = fhkl;
handles.dhkl = dhkl;
handles.hkl = hkl;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NewMaterialGUI wait for user response (see UIRESUME)
% uiwait(handles.NewMaterial);


% --- Outputs from this function are returned to the command line.
function varargout = NewMaterialGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fhkl1_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl1 as text
%        str2double(get(hObject,'String')) returns contents of fhkl1 as a double


% --- Executes during object creation, after setting all properties.
function fhkl1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl2_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl2 as text
%        str2double(get(hObject,'String')) returns contents of fhkl2 as a double


% --- Executes during object creation, after setting all properties.
function fhkl2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl3_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl3 as text
%        str2double(get(hObject,'String')) returns contents of fhkl3 as a double


% --- Executes during object creation, after setting all properties.
function fhkl3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl4_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl4 as text
%        str2double(get(hObject,'String')) returns contents of fhkl4 as a double


% --- Executes during object creation, after setting all properties.
function fhkl4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl5_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl5 as text
%        str2double(get(hObject,'String')) returns contents of fhkl5 as a double


% --- Executes during object creation, after setting all properties.
function fhkl5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl6_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl6 as text
%        str2double(get(hObject,'String')) returns contents of fhkl6 as a double


% --- Executes during object creation, after setting all properties.
function fhkl6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl7_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl7 as text
%        str2double(get(hObject,'String')) returns contents of fhkl7 as a double


% --- Executes during object creation, after setting all properties.
function fhkl7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fhkl8_Callback(hObject, eventdata, handles)
% hObject    handle to fhkl8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fhkl8 as text
%        str2double(get(hObject,'String')) returns contents of fhkl8 as a double


% --- Executes during object creation, after setting all properties.
function fhkl8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fhkl8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl1_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl1 as text
%        str2double(get(hObject,'String')) returns contents of dhkl1 as a double


% --- Executes during object creation, after setting all properties.
function dhkl1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl2_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl2 as text
%        str2double(get(hObject,'String')) returns contents of dhkl2 as a double


% --- Executes during object creation, after setting all properties.
function dhkl2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl3_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl3 as text
%        str2double(get(hObject,'String')) returns contents of dhkl3 as a double


% --- Executes during object creation, after setting all properties.
function dhkl3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl4_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl4 as text
%        str2double(get(hObject,'String')) returns contents of dhkl4 as a double


% --- Executes during object creation, after setting all properties.
function dhkl4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl5_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl5 as text
%        str2double(get(hObject,'String')) returns contents of dhkl5 as a double


% --- Executes during object creation, after setting all properties.
function dhkl5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl6_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl6 as text
%        str2double(get(hObject,'String')) returns contents of dhkl6 as a double


% --- Executes during object creation, after setting all properties.
function dhkl6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl7_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl7 as text
%        str2double(get(hObject,'String')) returns contents of dhkl7 as a double


% --- Executes during object creation, after setting all properties.
function dhkl7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dhkl8_Callback(hObject, eventdata, handles)
% hObject    handle to dhkl8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhkl8 as text
%        str2double(get(hObject,'String')) returns contents of dhkl8 as a double


% --- Executes during object creation, after setting all properties.
function dhkl8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhkl8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl11_Callback(hObject, eventdata, handles)
% hObject    handle to hkl11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl11 as text
%        str2double(get(hObject,'String')) returns contents of hkl11 as a double


% --- Executes during object creation, after setting all properties.
function hkl11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl12_Callback(hObject, eventdata, handles)
% hObject    handle to hkl12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl12 as text
%        str2double(get(hObject,'String')) returns contents of hkl12 as a double


% --- Executes during object creation, after setting all properties.
function hkl12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl13_Callback(hObject, eventdata, handles)
% hObject    handle to hkl13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl13 as text
%        str2double(get(hObject,'String')) returns contents of hkl13 as a double


% --- Executes during object creation, after setting all properties.
function hkl13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl21_Callback(hObject, eventdata, handles)
% hObject    handle to hkl21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl21 as text
%        str2double(get(hObject,'String')) returns contents of hkl21 as a double


% --- Executes during object creation, after setting all properties.
function hkl21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl22_Callback(hObject, eventdata, handles)
% hObject    handle to hkl22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl22 as text
%        str2double(get(hObject,'String')) returns contents of hkl22 as a double


% --- Executes during object creation, after setting all properties.
function hkl22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl23_Callback(hObject, eventdata, handles)
% hObject    handle to hkl23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl23 as text
%        str2double(get(hObject,'String')) returns contents of hkl23 as a double


% --- Executes during object creation, after setting all properties.
function hkl23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl31_Callback(hObject, eventdata, handles)
% hObject    handle to hkl31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl31 as text
%        str2double(get(hObject,'String')) returns contents of hkl31 as a double


% --- Executes during object creation, after setting all properties.
function hkl31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl32_Callback(hObject, eventdata, handles)
% hObject    handle to hkl32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl32 as text
%        str2double(get(hObject,'String')) returns contents of hkl32 as a double


% --- Executes during object creation, after setting all properties.
function hkl32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl33_Callback(hObject, eventdata, handles)
% hObject    handle to hkl33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl33 as text
%        str2double(get(hObject,'String')) returns contents of hkl33 as a double


% --- Executes during object creation, after setting all properties.
function hkl33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl41_Callback(hObject, eventdata, handles)
% hObject    handle to hkl41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl41 as text
%        str2double(get(hObject,'String')) returns contents of hkl41 as a double


% --- Executes during object creation, after setting all properties.
function hkl41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl42_Callback(hObject, eventdata, handles)
% hObject    handle to hkl42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl42 as text
%        str2double(get(hObject,'String')) returns contents of hkl42 as a double


% --- Executes during object creation, after setting all properties.
function hkl42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl43_Callback(hObject, eventdata, handles)
% hObject    handle to hkl43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl43 as text
%        str2double(get(hObject,'String')) returns contents of hkl43 as a double


% --- Executes during object creation, after setting all properties.
function hkl43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl51_Callback(hObject, eventdata, handles)
% hObject    handle to hkl51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl51 as text
%        str2double(get(hObject,'String')) returns contents of hkl51 as a double


% --- Executes during object creation, after setting all properties.
function hkl51_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl52_Callback(hObject, eventdata, handles)
% hObject    handle to hkl52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl52 as text
%        str2double(get(hObject,'String')) returns contents of hkl52 as a double


% --- Executes during object creation, after setting all properties.
function hkl52_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl53_Callback(hObject, eventdata, handles)
% hObject    handle to hkl53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl53 as text
%        str2double(get(hObject,'String')) returns contents of hkl53 as a double


% --- Executes during object creation, after setting all properties.
function hkl53_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl61_Callback(hObject, eventdata, handles)
% hObject    handle to hkl61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl61 as text
%        str2double(get(hObject,'String')) returns contents of hkl61 as a double


% --- Executes during object creation, after setting all properties.
function hkl61_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl62_Callback(hObject, eventdata, handles)
% hObject    handle to hkl62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl62 as text
%        str2double(get(hObject,'String')) returns contents of hkl62 as a double


% --- Executes during object creation, after setting all properties.
function hkl62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl63_Callback(hObject, eventdata, handles)
% hObject    handle to hkl63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl63 as text
%        str2double(get(hObject,'String')) returns contents of hkl63 as a double


% --- Executes during object creation, after setting all properties.
function hkl63_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl71_Callback(hObject, eventdata, handles)
% hObject    handle to hkl71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl71 as text
%        str2double(get(hObject,'String')) returns contents of hkl71 as a double


% --- Executes during object creation, after setting all properties.
function hkl71_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl72_Callback(hObject, eventdata, handles)
% hObject    handle to hkl72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl72 as text
%        str2double(get(hObject,'String')) returns contents of hkl72 as a double


% --- Executes during object creation, after setting all properties.
function hkl72_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl73_Callback(hObject, eventdata, handles)
% hObject    handle to hkl73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl73 as text
%        str2double(get(hObject,'String')) returns contents of hkl73 as a double


% --- Executes during object creation, after setting all properties.
function hkl73_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl81_Callback(hObject, eventdata, handles)
% hObject    handle to hkl81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl81 as text
%        str2double(get(hObject,'String')) returns contents of hkl81 as a double


% --- Executes during object creation, after setting all properties.
function hkl81_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl82_Callback(hObject, eventdata, handles)
% hObject    handle to hkl82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl82 as text
%        str2double(get(hObject,'String')) returns contents of hkl82 as a double


% --- Executes during object creation, after setting all properties.
function hkl82_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hkl83_Callback(hObject, eventdata, handles)
% hObject    handle to hkl83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hkl83 as text
%        str2double(get(hObject,'String')) returns contents of hkl83 as a double


% --- Executes during object creation, after setting all properties.
function hkl83_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hkl83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C11_Callback(hObject, eventdata, handles)
% hObject    handle to C11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C11 as text
%        str2double(get(hObject,'String')) returns contents of C11 as a double


% --- Executes during object creation, after setting all properties.
function C11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C13_Callback(hObject, eventdata, handles)
% hObject    handle to C13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C13 as text
%        str2double(get(hObject,'String')) returns contents of C13 as a double


% --- Executes during object creation, after setting all properties.
function C13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C12_Callback(hObject, eventdata, handles)
% hObject    handle to C12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C12 as text
%        str2double(get(hObject,'String')) returns contents of C12 as a double


% --- Executes during object creation, after setting all properties.
function C12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C33_Callback(hObject, eventdata, handles)
% hObject    handle to C33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C33 as text
%        str2double(get(hObject,'String')) returns contents of C33 as a double


% --- Executes during object creation, after setting all properties.
function C33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C44_Callback(hObject, eventdata, handles)
% hObject    handle to C44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C44 as text
%        str2double(get(hObject,'String')) returns contents of C44 as a double


% --- Executes during object creation, after setting all properties.
function C44_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C66_Callback(hObject, eventdata, handles)
% hObject    handle to C66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C66 as text
%        str2double(get(hObject,'String')) returns contents of C66 as a double


% --- Executes during object creation, after setting all properties.
function C66_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lattice.
function lattice_Callback(hObject, eventdata, handles)
% hObject    handle to lattice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lattice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lattice
latticelist = get(handles.lattice,'String');
index = get(handles.lattice,'Value');
lattice = latticelist(index);
if strcmp(lattice,'hexagonal')
    LatticeNumber = 4;
else
    LatticeNumber = 3;
end

hkl = handles.hkl;
[row cols] = size(hkl.Data);
if LatticeNumber > cols
    hkl.Data{row,LatticeNumber}=[];
elseif LatticeNumber < cols
    data =hkl.Data;
    data = data(:,1:LatticeNumber);
    hkl.Data = data;
end

hkl.Position(3)=hkl.Extent(3);
hkl.Position(4)=hkl.Extent(4);
    

% --- Executes during object creation, after setting all properties.
function lattice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lattice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function a1_Callback(hObject, eventdata, handles)
% hObject    handle to a1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a1 as text
%        str2double(get(hObject,'String')) returns contents of a1 as a double


% --- Executes during object creation, after setting all properties.
function a1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b1_Callback(hObject, eventdata, handles)
% hObject    handle to b1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b1 as text
%        str2double(get(hObject,'String')) returns contents of b1 as a double


% --- Executes during object creation, after setting all properties.
function b1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function c1_Callback(hObject, eventdata, handles)
% hObject    handle to c1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c1 as text
%        str2double(get(hObject,'String')) returns contents of c1 as a double


% --- Executes during object creation, after setting all properties.
function c1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axs_Callback(hObject, eventdata, handles)
% hObject    handle to axs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axs as text
%        str2double(get(hObject,'String')) returns contents of axs as a double


% --- Executes during object creation, after setting all properties.
function axs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function burgers_Callback(hObject, eventdata, handles)
% hObject    handle to burgers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of burgers as text
%        str2double(get(hObject,'String')) returns contents of burgers as a double


% --- Executes during object creation, after setting all properties.
function burgers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to burgers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function material_Callback(hObject, eventdata, handles)
% hObject    handle to material (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of material as text
%        str2double(get(hObject,'String')) returns contents of material as a double


% --- Executes during object creation, after setting all properties.
function material_CreateFcn(hObject, eventdata, handles)
% hObject    handle to material (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addbutton.
function addbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edits = findobj('Style','edit');
set(edits,'ForegroundColor','black');
set(edits,'BackgroundColor','white');

M.material = get(handles.material,'String');

k = 0;
fail = 0;
for i = 1:8
    
    % fhkl
    edit = findobj('Tag',['fhkl' num2str(i)]);
    temp = NumericInput(edit,handles);
    M.Fhkl(i) = temp;

    % dhkl
    edit = findobj('Tag',['dhkl' num2str(i)]);
    M.dhkl(i) = NumericInput(edit,handles);

    % hkl
    for j = 1:3
        edit = findobj('Tag',['hkl' num2str(i) num2str(j)]);
        M.hkl(i) = NumericInput(edit,handles);
    end
end

M.C11 = NumericInput(handles.C11,handles);
M.C12 = NumericInput(handles.C12,handles);
M.C13 = NumericInput(handles.C13,handles);
M.C33 = NumericInput(handles.C33,handles);
M.C44 = NumericInput(handles.C44,handles);
M.C66 = NumericInput(handles.C66,handles);

latticelist = get(handles.lattice,'String');
index = get(handles.lattice,'Value');
M.lattice = latticelist(index);

M.a1 = NumericInput(handles.a1,handles);
M.b1 = NumericInput(handles.b1,handles);
M.c1 = NumericInput(handles.c1,handles);
M.axs = NumericInput(handles.axs,handles);
M.Burgers = NumericInput(handles.burgers,handles);

color = get(edits,'BackgroundColor');
color = cell2mat(color);
color = color(:,3)==0;
if sum(color) > 0 %There is at least one red box
    warndlg('Input error: inputs must be numeric');
else
    %NewMaterial(M);
    str = {'nickel','silicon','iron-alpha','titanium(alpha)','magnesium','aluminum',...
    'germanium','martensite','copper','tantalum','iron-gamma','boronzirconium_0060610','siliconcarbide6h','siliconcarbon_0020013', 'titaniumaluminum', 'cigs', 'grainfile','titanium(beta)'};
    for i = 1:length(str)
        Material = str{i};
        [ Fhkl hkl C11 C12 C44 lattice a1 b1 c1 dhkl axs str C13 C33 C66 Burgers] = SelectMaterial(Material);
        MaterialStruct.Material = Material;
        MaterialStruct.Fhkl= Fhkl;
        MaterialStruct.dhkl= dhkl;
        MaterialStruct.hkl= hkl;
        MaterialStruct.C11= C11;
        MaterialStruct.C12= C12;
        MaterialStruct.C44= C44;
        MaterialStruct.lattice = lattice;
        MaterialStruct.a1 = a1;
        MaterialStruct.b1 = b1;
        MaterialStruct.c1 = c1;
        MaterialStruct.axs = axs;
        MaterialStruct.Burgers = Burgers;
        NewMaterial(MaterialStruct);
    end
    
end


function output = NumericInput(edit, handles)
% Takes string from edit box and returns the number.
% If it is not a number, it returns 0 and changes the formatting of the box
temp = get(edit,'String');
if ~isempty(temp) %Nothing in box
    if isempty(str2num(temp)) %Input is not a number
        output = 0;
        set(edit,'ForegroundColor','white');
        set(edit,'BackgroundColor','red');
    else
        output = str2double(temp);
    end
else
    output = 0;
end

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.NewMaterial);


% --- Executes when user attempts to close NewMaterial.
function NewMaterial_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to NewMaterial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


function NumVal_Callback(hObject, eventdata, handles)
% hObject    handle to NumVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumVal as text
%        str2double(get(hObject,'String')) returns contents of NumVal as a double
NumValues = str2double(get(hObject,'String'));
NumValues = int32(NumValues);
params{1} = handles.fhkl;
params{2} = handles.dhkl;
params{3} = handles.hkl;

% Resizes Fhkl, dhkl and hkl tables when value is changed
[~, col] = size(params{3});
for i = 1:3
    if NumValues > length(params{i}.Data)
        if i == 3
            params{i}.Data{NumValues,col}=[];
        else
            params{i}.Data{1,NumValues}=[];
        end
    else
        data = params{i}.Data;
        if i == 3
            data = data(1:NumValues,:);
        else    
            data = data(1:NumValues);
        end
        params{i}.Data = data;
    end
    height1 = params{i}.Position(4);
    height2 = params{i}.Extent(4);
    shift = height1 - height2;
    params{i}.Position(3)=params{i}.Extent(3);
    params{i}.Position(4)=params{i}.Extent(4);
    if i == 3
        a = params{i}.Position(2);
        params{i}.Position(2)=a+shift;
    end
end
handles.NewMaterial.Units = 'pixels';
guiwidth = handles.NewMaterial.Position(3);
tableright = handles.fhkl.Position(1) + handles.fhkl.Position(3);
tablebottom = handles.hkl.Position(2);

if tableright > guiwidth
    handles.NewMaterial.Position(3) = handles.NewMaterial.Position(3) + tableright - guiwidth + 10;
end
if tablebottom < 10
    handles.NewMaterial.Position(4) = handles.NewMaterial.Position(4) - tablebottom + 10;
    handles.NewMaterial.Position(2) = handles.NewMaterial.Position(2) + tablebottom - 10;
end





% --- Executes during object creation, after setting all properties.
function NumVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[picname picpath] = uigetfile('*.ang','.ang file');
if picname == 0
    picpath = 'No file selected';
    picname = '';
else
    handles.FileDir = picpath;
    % Update handles structure
    guidata(hObject, handles);
end
