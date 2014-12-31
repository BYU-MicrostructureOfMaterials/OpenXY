function varargout = HowToList(varargin)
% HOWTOLIST M-file for HowToList.fig
%      HOWTOLIST, by itself, creates a new HOWTOLIST or raises the existing
%      singleton*.
%
%      H = HOWTOLIST returns the handle to a new HOWTOLIST or the handle to
%      the existing singleton*.
%
%      HOWTOLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOWTOLIST.M with the given input arguments.
%
%      HOWTOLIST('Property','Value',...) creates a new HOWTOLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HowToList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HowToList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HowToList

% Last Modified by GUIDE v2.5 23-Aug-2011 15:06:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HowToList_OpeningFcn, ...
                   'gui_OutputFcn',  @HowToList_OutputFcn, ...
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


% --- Executes just before HowToList is made visible.
function HowToList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HowToList (see VARARGIN)

% Choose default command line output for HowToList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HowToList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HowToList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in HowTo.
function HowTo_Callback(hObject, eventdata, handles)
% hObject    handle to HowTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns HowTo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HowTo


% --- Executes during object creation, after setting all properties.
function HowTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HowTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
