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

% Last Modified by GUIDE v2.5 03-Feb-2015 12:25:53

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

% Set edit box font size to 6
edits = findobj('Style','edit');
set(edits,'FontSize',8);
set(handles.material,'FontSize',8);

latticelist = {'cubic', 'hexagonal', 'tetragonal'};
set(handles.lattice,'String',latticelist);

set(handles.units,'String',{'Angstroms'});

set(handles.NumVal,'String',num2str(8));
NumValues = 8;
LatticeNumber = 3;

%Delete previous tables if reloading GUI
delete(findobj('Tag','fhkl'));
delete(findobj('Tag','dhkl'));
delete(findobj('Tag','hkl'));

% Positioning
handles.fhkllabel.Units = 'pixels';
handles.dhkllabel.Units = 'pixels';
handles.hkllabel.Units = 'pixels';
pos.fhkllabel = handles.fhkllabel.Position;
pos.dhkllabel = handles.dhkllabel.Position;
pos.hkllabel = handles.hkllabel.Position;

left = pos.fhkllabel(1) + pos.fhkllabel(3) + 2;
height = 22;
width = 20;
fields = fieldnames(pos);
for i = 1:numel(fields)
    fieldname = fields{i}(1:strfind(fields{i},'label')-1);
    pos.(fieldname)(1) = pos.(fields{i})(1);
    pos.(fieldname)(2) = pos.(fields{i})(2) + pos.(fields{i})(4)/2 - height/2 - 20;
    pos.(fieldname)(3) = width;
    pos.(fieldname)(4) = height;
end

% Create Tables
format = cell(1,NumValues);
[format{:}] = deal('numeric');
fhkl = uitable(handles.NewMaterial,'Position',pos.fhkl,'Data',cell(NumValues,1),...
    'ColumnWidth',{35},'ColumnEditable',true(1),'ColumnFormat',format,...
    'RowName',[],'ColumnName',[],'Tag','fhkl');
dhkl = uitable(handles.NewMaterial,'Position',pos.dhkl,'Data',cell(NumValues,1),...
    'ColumnWidth',{35},'ColumnEditable',true(1),'ColumnFormat',format,...
    'RowName',[],'ColumnName',[],'Tag','dhkl');
hkl = uitable(handles.NewMaterial,'Position',pos.hkl,'Data',cell(NumValues,LatticeNumber),...
    'ColumnWidth',{35},'ColumnEditable',true(1,NumValues),'ColumnFormat',format,...
    'RowName',[],'ColumnName',[],'Tag','hkl');

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
fhkl.Position(2)=a+shift;
dhkl.Position(2)=a+shift;
hkl.Position(2)=a+shift;


% Load Variables into handles structure
handles.NewMaterial.Units = 'pixels';
handles.cancelbutton.Units = 'pixels';
handles.GUIbottom = handles.NewMaterial.Position(2);
handles.GUIwidth = handles.NewMaterial.Position(3);
handles.GUIheight = handles.NewMaterial.Position(4);
handles.Buttonheight = handles.cancelbutton.Position(2) + handles.GUIbottom;
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
invalid = false;
blank = false;

M.Material = get(handles.material,'String');
unitname = get(handles.units,'String');
if strcmp(unitname,'Angstroms')
    units = 1e-10;
end

% Validate Tables
Fhkl = cell2mat(get(handles.fhkl,'Data'));
dhkl = cell2mat(get(handles.dhkl,'Data'))*units;
hkl = cell2mat(get(handles.hkl,'Data'));
if sum(sum(isnan(Fhkl))) > 0
    invalid = true;
elseif sum(sum(isnan(dhkl))) > 0
    invalid = true;
elseif sum(sum(isnan(hkl))) > 0
    invalid = true;
end

M.Fhkl = Fhkl;
M.dhkl = dhkl;
M.hkl= hkl;

% Validate edit boxes
M.C11 = NumericInput(handles.C11,handles);
M.C12 = NumericInput(handles.C12,handles);
M.C13 = NumericInput(handles.C13,handles);
M.C33 = NumericInput(handles.C33,handles);
M.C44 = NumericInput(handles.C44,handles);
M.C66 = NumericInput(handles.C66,handles);

latticelist = get(handles.lattice,'String');
index = get(handles.lattice,'Value');
M.lattice = latticelist{index};

M.a1 = NumericInput(handles.a1,handles);
M.b1 = NumericInput(handles.b1,handles);
M.c1 = NumericInput(handles.c1,handles);
M.axs = NumericInput(handles.axs,handles);
M.Burgers = NumericInput(handles.burgers,handles)*units;
color = get(edits,'BackgroundColor');
color = cell2mat(color);
color = color(:,3)==0;
if sum(color) > 0 %There is at least one red box
    invalid = true;
end
if invalid
    warndlg('Input error: inputs must be numeric');
elseif blank
    warndlg('Input error: tables must be complete');
else
    materials = GetMaterialsList;
    addmaterial = false;
    if sum(strncmp(M.Material,materials,length(M.Material))) > 0
        %warndlg('Material with same name already exists');
        button = questdlg({'Material with same name already exists';'Would you like to overwrite it?'},'Add Material');
        if strcmp(button,'Yes')
            addmaterial = true;
        end
    else
        addmaterial = true;
    end
    if addmaterial
        NewMaterial(M);
        msgbox([M.Material ' successfully added'],'Add new material');
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

function NumVal_Callback(hObject, eventdata, handles)
% hObject    handle to NumVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumVal as text
%        str2double(get(hObject,'String')) returns contents of NumVal as a double
input = get(handles.NumVal,'String');
if isempty(str2num(input))
    set(hObject,'ForegroundColor','white');
    set(hObject,'BackgroundColor','red');
    return;
else
    edits = findobj('Style','edit');
    set(edits,'ForegroundColor','black');
    set(edits,'BackgroundColor','white');
end
NumValues = int32(str2num(get(handles.NumVal,'String')));
params{1} = handles.fhkl;
params{2} = handles.dhkl;
params{3} = handles.hkl;

% Resizes Fhkl, dhkl and hkl tables when value is changed
for i = 1:3
    data = params{i}.Data;
    [rows, cols] = size(data);
    if NumValues > rows
        data{NumValues,cols} = [];
        if i == 3
            params{i}.Data{NumValues,cols}=[];
        else
            params{i}.Data{NumValues,1}=[];
        end
    else
        data = data(1:NumValues,:);
    end
    params{i}.Data = data;
    height1 = params{i}.Position(4);
    height2 = params{i}.Extent(4);
    shift = height1 - height2;
    params{i}.Position(3)=params{i}.Extent(3);
    params{i}.Position(4)=params{i}.Extent(4);
    logical = params{i}.Position(2);
    params{i}.Position(2)=logical+shift;
end

%Resize GUI if tables grow too large
borders = 10; %pixels
handles.NewMaterial.Units = 'pixels';
guiwidth = handles.NewMaterial.Position(3);
guibottom = handles.NewMaterial.Position(2);
tableright = handles.fhkl.Position(1) + handles.fhkl.Position(3);
tablebottom = handles.hkl.Position(2);
guiwidth_original = handles.GUIwidth;
guiheight_original = handles.GUIheight;
guibottom_original = handles.GUIbottom;

if tableright > guiwidth_original - borders
    handles.NewMaterial.Position(3) = tableright + borders;
else
    handles.NewMaterial.Position(3) = guiwidth_original;
end
if tablebottom + guibottom < guibottom_original + borders
    handles.NewMaterial.Position(2) = tablebottom + guibottom - 10;
    handles.NewMaterial.Position(4) = handles.NewMaterial.Position(4) - tablebottom + borders;
    objectshift = borders - tablebottom;
else
    handles.NewMaterial.Position(2) = guibottom_original;
    handles.NewMaterial.Position(4) = guiheight_original;
    newButtonheight = handles.cancelbutton.Position(2) + handles.NewMaterial.Position(2);
    objectshift = handles.Buttonheight - newButtonheight;
end
if objectshift ~= 0
    all = findobj('Visible','on'); %All visible objects in GUI
    % Remove blank objects from list
    names = get(all,'Tag');
    logical = ~strcmp(names,'');
    all = all(logical);
    % Remove GUI figure from list
    names = get(all,'Tag');
    logical = ~strcmp(names,'NewMaterial');
    all = all(logical);
    % Set units to pixels
    set(all,'Units','pixels');
    %Shift all GUI objects up
    positions = get(all,'Position');
    for i = 1:length(positions)
        positions{i}(2) = positions{i}(2) + objectshift;
        set(all(i),'Position',positions{i});
    end
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
buttonstring = get(hObject,'String');

materials = GetMaterialsList;
%Create GUI
width = 210;
height = 80;
pos(1) = handles.NewMaterial.Position(1) + (handles.NewMaterial.Position(3)-width)/2;
pos(2) = handles.NewMaterial.Position(2) + (handles.NewMaterial.Position(4)-height)/2;
pos(3) = width;
pos(4) = height;
gui.f = figure('Visible','off','Position',pos,'MenuBar','none','Toolbar','none','name','Select Material','NumberTitle','off');

mwidth = 150;
mheight = 25;
pos = [(width - mwidth)/2 (height-mheight)*(0.75) mwidth mheight];
gui.list = uicontrol(gui.f,'Style','popup','Position',pos,'String',materials,'Tag','MaterialList');

pos(2) = (height-mheight)*(0.25);
guidata(gui.f,gui);
gui.button = uicontrol(gui.f,'Style','pushbutton','Position',pos,'String','Select','Tag',...
    'SelectionButton','Callback',{@MaterialSelection,guidata(gui.f)});
gui.f.Visible = 'on';

uiwait
if ishandle(gui.f)
    gui = guidata(gui.f);
    if isfield(gui,'material')
        material = gui.material;
        if strcmp(buttonstring,'Load Material')
            MaterialStruct = ReadMaterial(material);
            ImportMaterial(handles,eventdata,MaterialStruct);
        elseif strcmp(buttonstring,'Delete Material')
            fclose('all');            
            filename = fullfile(pwd,'Materials',[material '.txt']);
            delete(filename);
            if ~exist(filename,'file')
                msgbox([material ' successfully deleted']);
            end
            handles.loadbutton.String = 'Load Material';
        end
    end
    delete(gui.f);  
else
    handles.loadbutton.String = 'Load Material';
end



function material = MaterialSelection(hObject, eventdata,gui)
string = get(gui.list,'String');
value = get(gui.list,'Value');
gui.material = string{value};
guidata(hObject,gui);
a = 1;
gui.f.Visible = 'off';
uiresume

function ImportMaterial(handles,eventdata,MaterialStruct)
[NumVal, latticenumber] = size(handles.hkl.Data);
[m, n] = size(MaterialStruct.hkl);
if m ~= NumVal
    set(handles.NumVal,'String',num2str(m));
    NumVal_Callback(handles.NumVal, eventdata, handles);
end

n_exp =floor(log10(MaterialStruct.dhkl(1)));
if n_exp ~= -10
    warndlg('Units not in angtroms');
end
set(handles.material,'String',MaterialStruct.Material);
set(handles.NumVal,'String',num2str(m));
set(handles.fhkl,'Data',num2cell(MaterialStruct.Fhkl));
MaterialStruct.dhkl = MaterialStruct.dhkl / (1*10^n_exp); %Convert to Angtroms
set(handles.dhkl,'Data',num2cell(MaterialStruct.dhkl));
if strcmp(MaterialStruct.lattice,'hexagonal')
    set(handles.hkl,'Data',num2cell(MaterialStruct.hkl_hex));
else
    set(handles.hkl,'Data',num2cell(MaterialStruct.hkl));
end
handles.hkl.Position(3)=handles.hkl.Extent(3);
handles.hkl.Position(4)=handles.hkl.Extent(4);
if isfield(MaterialStruct,'C11')
    set(handles.C11,'String',num2str(MaterialStruct.C11));
end
if isfield(MaterialStruct,'C12')
    set(handles.C12,'String',num2str(MaterialStruct.C12));
end
if isfield(MaterialStruct,'C13')
    set(handles.C13,'String',num2str(MaterialStruct.C13));
end
if isfield(MaterialStruct,'C33')
    set(handles.C33,'String',num2str(MaterialStruct.C33));
end
if isfield(MaterialStruct,'C44')
    set(handles.C44,'String',num2str(MaterialStruct.C44));
end
if isfield(MaterialStruct,'C66')
    set(handles.C66,'String',num2str(MaterialStruct.C66));
end

latticelist = get(handles.lattice,'String');
lattice = MaterialStruct.lattice;
IndList = 1:length(latticelist);
Ind = IndList(strcmp(latticelist,lattice));
set(handles.lattice, 'Value',Ind)
if n ~= latticenumber
    lattice_Callback(handles.lattice, eventdata, handles);
end

if isfield(MaterialStruct,'a1')
    set(handles.a1,'String',num2str(MaterialStruct.a1));
end
if isfield(MaterialStruct,'b1')
    set(handles.b1,'String',num2str(MaterialStruct.b1));
end
if isfield(MaterialStruct,'c1')
    set(handles.c1,'String',num2str(MaterialStruct.c1));
end
if isfield(MaterialStruct,'axs')
    set(handles.axs,'String',num2str(MaterialStruct.axs));
end
if isfield(MaterialStruct,'Burgers')
    MaterialStruct.Burgers = MaterialStruct.Burgers / (1*10^n_exp); %Convert to Angtroms
    set(handles.burgers,'String',num2str(MaterialStruct.Burgers));
end


% --- Executes on selection change in units.
function units_Callback(hObject, eventdata, handles)
% hObject    handle to units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from units


% --- Executes during object creation, after setting all properties.
function units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on NewMaterial and none of its controls.
function NewMaterial_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to NewMaterial (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'shift'
        handles.loadbutton.String = 'Delete Material';  
end


% --- Executes on key release with focus on NewMaterial and none of its controls.
function NewMaterial_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to NewMaterial (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'shift'
        handles.loadbutton.String = 'Load Material'; 
end
