function varargout = SkipPointsHelp(varargin)
% SKIPPOINTSHELP MATLAB code for SkipPointsHelp.fig
%      SKIPPOINTSHELP, by itself, creates a new SKIPPOINTSHELP or raises the existing
%      singleton*.
%
%      H = SKIPPOINTSHELP returns the handle to a new SKIPPOINTSHELP or the handle to
%      the existing singleton*.
%
%      SKIPPOINTSHELP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SKIPPOINTSHELP.M with the given input arguments.
%
%      SKIPPOINTSHELP('Property','Value',...) creates a new SKIPPOINTSHELP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SkipPointsHelp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SkipPointsHelp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SkipPointsHelp

% Last Modified by GUIDE v2.5 07-Oct-2011 12:29:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SkipPointsHelp_OpeningFcn, ...
                   'gui_OutputFcn',  @SkipPointsHelp_OutputFcn, ...
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


% --- Executes just before SkipPointsHelp is made visible.
function SkipPointsHelp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SkipPointsHelp (see VARARGIN)
pic = imread('SkipPoints.jpg');
% pic = imread('DSCN0416.JPG');
imshow(pic)
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
% Choose default command line output for SkipPointsHelp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SkipPointsHelp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SkipPointsHelp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
