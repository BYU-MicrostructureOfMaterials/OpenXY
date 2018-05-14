function varargout = SuperCompGUI(varargin)
% SUPERCOMPGUI MATLAB code for SuperCompGUI.fig
%      SUPERCOMPGUI, by itself, creates a new SUPERCOMPGUI or raises the existing
%      singleton*.
%
%      H = SUPERCOMPGUI returns the handle to a new SUPERCOMPGUI or the handle to
%      the existing singleton*.
%
%      SUPERCOMPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SUPERCOMPGUI.M with the given input arguments.
%
%      SUPERCOMPGUI('Property','Value',...) creates a new SUPERCOMPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SuperCompGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SuperCompGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SuperCompGUI

% Last Modified by GUIDE v2.5 14-May-2018 10:24:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SuperCompGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SuperCompGUI_OutputFcn, ...
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


% --- Executes just before SuperCompGUI is made visible.
function SuperCompGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for SuperCompGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = SuperCompGUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in submitButton.
function submitButton_Callback(hObject, eventdata, handles)
userName = handles.userNameEditText.String;
password = handles.passwordEditText.String;


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
keyboard
