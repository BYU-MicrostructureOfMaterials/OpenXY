function varargout = AdvancedSettingsGUI2(varargin)
%ADVANCEDSETTINGSGUI2 MATLAB code file for AdvancedSettingsGUI2.fig
%      ADVANCEDSETTINGSGUI2, by itself, creates a new ADVANCEDSETTINGSGUI2 or raises the existing
%      singleton*.
%
%      H = ADVANCEDSETTINGSGUI2 returns the handle to a new ADVANCEDSETTINGSGUI2 or the handle to
%      the existing singleton*.
%
%      ADVANCEDSETTINGSGUI2('Property','Value',...) creates a new ADVANCEDSETTINGSGUI2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to AdvancedSettingsGUI2_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ADVANCEDSETTINGSGUI2('CALLBACK') and ADVANCEDSETTINGSGUI2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ADVANCEDSETTINGSGUI2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdvancedSettingsGUI2

% Last Modified by GUIDE v2.5 08-Jun-2017 13:27:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdvancedSettingsGUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @AdvancedSettingsGUI2_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before AdvancedSettingsGUI2 is made visible.
function AdvancedSettingsGUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for AdvancedSettingsGUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AdvancedSettingsGUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdvancedSettingsGUI2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close AdvancedSettingsGUI.
function AdvancedSettingsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to AdvancedSettingsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in HROIMMethod.
function HROIMMethod_Callback(hObject, eventdata, handles)
% hObject    handle to HROIMMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns HROIMMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HROIMMethod


% --- Executes during object creation, after setting all properties.
function HROIMMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HROIMMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HROIMedit_Callback(hObject, eventdata, handles)
% hObject    handle to HROIMedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HROIMedit as text
%        str2double(get(hObject,'String')) returns contents of HROIMedit as a double


% --- Executes during object creation, after setting all properties.
function HROIMedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HROIMedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StandardDeviation_Callback(hObject, eventdata, handles)
% hObject    handle to StandardDeviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StandardDeviation as text
%        str2double(get(hObject,'String')) returns contents of StandardDeviation as a double


% --- Executes during object creation, after setting all properties.
function StandardDeviation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StandardDeviation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MisoTol_Callback(hObject, eventdata, handles)
% hObject    handle to MisoTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MisoTol as text
%        str2double(get(hObject,'String')) returns contents of MisoTol as a double


% --- Executes during object creation, after setting all properties.
function MisoTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MisoTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GrainRefType.
function GrainRefType_Callback(hObject, eventdata, handles)
% hObject    handle to GrainRefType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GrainRefType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GrainRefType


% --- Executes during object creation, after setting all properties.
function GrainRefType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainRefType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in DoDD.
function DoDD_Callback(hObject, eventdata, handles)
% hObject    handle to DoDD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoDD



function SkipPoints_Callback(hObject, eventdata, handles)
% hObject    handle to SkipPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SkipPoints as text
%        str2double(get(hObject,'String')) returns contents of SkipPoints as a double


% --- Executes during object creation, after setting all properties.
function SkipPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SkipPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IQCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to IQCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IQCutoff as text
%        str2double(get(hObject,'String')) returns contents of IQCutoff as a double


% --- Executes during object creation, after setting all properties.
function IQCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IQCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DoSplitDD.
function DoSplitDD_Callback(hObject, eventdata, handles)
% hObject    handle to DoSplitDD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoSplitDD


% --- Executes on selection change in DDSMethod.
function DDSMethod_Callback(hObject, eventdata, handles)
% hObject    handle to DDSMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DDSMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DDSMethod

% --- Executes during object creation, after setting all properties.
function DDSMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DDSMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SelectKAM.
function SelectKAM_Callback(hObject, eventdata, handles)
% hObject    handle to SelectKAM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in EnableProfiler.
function EnableProfiler_Callback(hObject, eventdata, handles)
% hObject    handle to EnableProfiler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EnableProfiler

% --- Executes on button press in DoStrain.
function DoStrain_Callback(hObject, eventdata, handles)
% hObject    handle to DoStrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoStrain

% --- Executes on selection change in GrainMethod.
function GrainMethod_Callback(hObject, eventdata, handles)
% hObject    handle to GrainMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GrainMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GrainMethod


% --- Executes during object creation, after setting all properties.
function GrainMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinGrainSize_Callback(hObject, eventdata, handles)
% hObject    handle to MinGrainSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinGrainSize as text
%        str2double(get(hObject,'String')) returns contents of MinGrainSize as a double


% --- Executes during object creation, after setting all properties.
function MinGrainSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinGrainSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ToggleGrainMap.
function ToggleGrainMap_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleGrainMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleGrainMap


% --- Executes on button press in EditRefPoints.
function EditRefPoints_Callback(hObject, eventdata, handles)
% hObject    handle to EditRefPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on key press with focus on AdvancedSettingsGUI and none of its controls.

% --- Executes on selection change in GNDMethod.
function GNDMethod_Callback(hObject, eventdata, handles)
% hObject    handle to GNDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GNDMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GNDMethod


% --- Executes during object creation, after setting all properties.
function GNDMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GNDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AdvancedSettingsGUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to AdvancedSettingsGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
