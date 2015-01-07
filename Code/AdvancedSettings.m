function varargout = AdvancedSettings(varargin)
% ADVANCEDSETTINGS M-file for AdvancedSettings.fig
%      ADVANCEDSETTINGS, by itself, creates a new ADVANCEDSETTINGS or raises the existing
%      singleton*.
%
%      H = ADVANCEDSETTINGS returns the handle to a new ADVANCEDSETTINGS or the handle to
%      the existing singleton*.
%
%      ADVANCEDSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCEDSETTINGS.M with the given input arguments.
%
%      ADVANCEDSETTINGS('Property','Value',...) creates a new ADVANCEDSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AdvancedSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AdvancedSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdvancedSettings

% Last Modified by GUIDE v2.5 27-Dec-2014 10:48:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdvancedSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @AdvancedSettings_OutputFcn, ...
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


% --- Executes just before AdvancedSettings is made visible.
function AdvancedSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdvancedSettings (see VARARGIN)

%get Settings sent in if this was opened before and is being reopened.
stemp=load('Settings.mat');
Settings=stemp.Settings;
clear stemp

%Initialize NumROIs popup
MaxROINum = 50;
set(handles.NumberROIsPopUp,'String',num2cell(1:MaxROINum));

%Initialize ROIStyle popup
ROIStyleList = {'Grid','Radial','Intensity'};
set(handles.ROIStylePopUp, 'String', ROIStyleList);

%Initialize ROIStyle popup
ImageFilterTypeList = {'standard','localthresh'};
set(handles.ImageFilterType, 'String', ImageFilterTypeList);

%Initialize HROIMMEthod popup
HROIMMethodList = {'Simulated','Real-Grain Ref','Real-Single Ref'};
set(handles.HROIMMethodPopUp, 'String', HROIMMethodList);

%Initialize FCalcMethod popup
FCalcMethodList = {'Wilkinson Sample','Wilkinson Crystal','Collin Sample','Collin Crystal'};
set(handles.FCalcMethodPopUp, 'String', FCalcMethodList);

%Initialze Real Ref Image Method
GrainRefImageTypeList = {'Min Kernel Avg Miso','IQ > Fit > CI'};
set(handles.GrainRefTypePopUp, 'String', GrainRefImageTypeList);

if ~isempty(Settings.ROISizePercent)
    if ~isnumeric(Settings.ROISizePercent) || Settings.ROISizePercent <= 0
        warndlg('Input ROISizePercent is not a number or is negative','Warning');
    else
        set(handles.ROISizeEdit, 'String', num2str(Settings.ROISizePercent) );
    end
end

if ~isempty(Settings.NumROIs)
    if Settings.NumROIs > MaxROINum
       warndlg('Too many ROI''s attempted','Warning');
    else
        NumROIs = Settings.NumROIs;
        set(handles.NumberROIsPopUp, 'Value', NumROIs);
    end    
end

if ~isempty(Settings.ROIStyle)
    
    ROIStyle = Settings.ROIStyle;
    IndList = 1:length(ROIStyleList);
    SelectedROIStyleInd = IndList(strcmp(ROIStyleList,ROIStyle));
    set(handles.ROIStylePopUp, 'Value', SelectedROIStyleInd);
    
    if strcmp(Settings.ROIStyle,'Grid')
        
       set(handles.NumberROIsPopUp,'Enable','off');
%        set(handles.ROISizeEdit,'Enable','off');
        
    end
    
end

if strcmp(Settings.ROIStyle,'Intensity')

   set(handles.ROIFilterEdit1,'Enable','off');
   set(handles.ROIFilterEdit2,'Enable','off');
   set(handles.ROIFilterEdit3,'Enable','off');
   set(handles.ROIFilterEdit4,'Enable','off');
%        set(handles.ROISizeEdit,'Enable','off');
elseif ~isempty(Settings.ROIFilter)

   set(handles.ROIFilterEdit1,'String',num2str(Settings.ROIFilter(1)));
   set(handles.ROIFilterEdit2,'String',num2str(Settings.ROIFilter(2)));
   set(handles.ROIFilterEdit3,'String',num2str(Settings.ROIFilter(3)));
   set(handles.ROIFilterEdit4,'String',num2str(Settings.ROIFilter(4)));
    
end

if ~isempty(Settings.ImageFilterType)
    ImageFilterType = Settings.ImageFilterType;
    IndList = 1:length(ImageFilterTypeList);
    Ind = IndList(strcmp(ImageFilterTypeList,ImageFilterType));
    set(handles.ImageFilterType,'Value',Ind);
    if strcmp(Settings.ImageFilterType,'localthresh')

        set(handles.ImageFilterEdit1,'Enable','off');
        set(handles.ImageFilterEdit2,'Enable','off');
        set(handles.ImageFilterEdit3,'Enable','off');
        set(handles.ImageFilterEdit4,'Enable','off');
    %        set(handles.ROISizeEdit,'Enable','off');
    end
end
if ~isempty(Settings.ImageFilter)

   set(handles.ImageFilterEdit1,'String',num2str(Settings.ImageFilter(1)));
   set(handles.ImageFilterEdit2,'String',num2str(Settings.ImageFilter(2)));
   set(handles.ImageFilterEdit3,'String',num2str(Settings.ImageFilter(3)));
   set(handles.ImageFilterEdit4,'String',num2str(Settings.ImageFilter(4)));

end
if ~isempty(Settings.ROIFilter)
    
   set(handles.ROIFilterEdit1,'String',num2str(Settings.ROIFilter(1)));
   set(handles.ROIFilterEdit2,'String',num2str(Settings.ROIFilter(2)));
   set(handles.ROIFilterEdit3,'String',num2str(Settings.ROIFilter(3)));
   set(handles.ROIFilterEdit4,'String',num2str(Settings.ROIFilter(4)));
    
end
if ~isempty(Settings.HROIMMethod)
    
    HROIMMethod = Settings.HROIMMethod;
    if strcmp(HROIMMethod,'Wilkinson')
        if Settings.RefImageInd > 0
            HROIMMethod = 'Real-Single Ref';
            set(handles.RefImageIndEdit,'String',num2str(Settings.RefImageInd));
        else
            HROIMMethod = 'Real-Grain Ref';
        end
    end
            
    IndList = 1:length(HROIMMethodList);
    SelectedHROIMMethodInd = IndList(strcmp(HROIMMethodList,HROIMMethod));
    if isempty(SelectedHROIMMethodInd)
        set(handles.HROIMMethodPopUp,'Value',1);
    else
        set(handles.HROIMMethodPopUp, 'Value', SelectedHROIMMethodInd);
    end
    
    if ~strcmp(HROIMMethod,'Simulated')
        set(handles.GrainRefTypePopUp,'Enable','on');
        set(handles.KernelAvgFilePathEdit,'Enable','on');
        set(handles.KernelAvgBrowseButton,'Enable','on');
        set(handles.IterationLabel,'Visible','off');
        set(handles.IterationLimitEdit,'Enable','off');
        set(handles.IterationLimitEdit,'Visible','off');
        set(handles.RefImageIndLabel,'Visible','on');
        if strcmp(HROIMMethod,'Real-Grain Ref')
            set(handles.RefImageIndEdit,'Enable','off');
        else
            set(handles.RefImageIndEdit,'Enable','on');
        end
        set(handles.RefImageIndEdit,'Visible','on');      
    else
        set(handles.GrainRefTypePopUp,'Enable','off');
        set(handles.KernelAvgFilePathEdit,'Enable','off');
        set(handles.KernelAvgBrowseButton,'Enable','off');
        set(handles.IterationLabel,'Visible','on');
        set(handles.IterationLimitEdit,'Enable','on');
        set(handles.IterationLimitEdit,'Visible','on');
        set(handles.RefImageIndLabel,'Visible','off');
        set(handles.RefImageIndEdit,'Enable','off');
        set(handles.RefImageIndEdit,'Visible','off');
    end
    
end
if ~isempty(Settings.CalcDerivatives)
    
    set(handles.CalcDerivativesCheckBox, 'Value', Settings.CalcDerivatives)
    CalcDerivativesCheckBox_Callback(handles.CalcDerivativesCheckBox, eventdata, handles)
    
end
if ~isempty(Settings.NumSkipPts)
    
    set(handles.NumSkipPtsBox, 'String', Settings.NumSkipPts);
    
end
if ~isempty(Settings.MisoTol)
    
    set(handles.MisoTolBox, 'String', Settings.MisoTol)
    
end
if ~isempty(Settings.IQCutoff)
    
    set(handles.IQCutoffBox, 'String', Settings.IQCutoff)
    
end
if ~isempty(Settings.FCalcMethod)
    
    FCalcMethod = Settings.FCalcMethod;
    IndList = 1:length(FCalcMethodList);
    SelectedFCalcMethodInd = IndList(strcmp(FCalcMethodList,FCalcMethod));
    set(handles.FCalcMethodPopUp, 'Value', SelectedFCalcMethodInd);
    
end

if ~isempty(Settings.IterationLimit)
   set(handles.IterationLimitEdit,'String',num2str(Settings.IterationLimit));    
end

if ~isempty(Settings.StandardDeviation)
    set(handles.StdDevEdit,'String',num2str(Settings.StandardDeviation))
end

if ~isempty(Settings.RefImageInd)
    set(handles.RefImageIndEdit,'String',num2str(Settings.RefImageInd));
end

if ~isempty(Settings.GrainRefImageType)
    
    GrainRefImageType = Settings.GrainRefImageType;
    IndList = 1:length(GrainRefImageTypeList);
    SelectedGrainRefImageTypeInd = IndList(strcmp(GrainRefImageTypeList,GrainRefImageType));
    set(handles.GrainRefTypePopUp, 'Value', SelectedGrainRefImageTypeInd);
    
end

if ~isempty(Settings.KernelAvgMisoPath)
   set(handles.KernelAvgFilePathEdit, 'String', Settings.KernelAvgMisoPath);
end


%Read in first image, if that does not work, read in demo image
Image = ReadEBSDImage(Settings.FirstImagePath, Settings.ImageFilter);
if isempty(Image)
    Image = ReadEBSDImage('demo.bmp', Settings.ImageFilter);
end

GrainFileVals = ReadGrainFile(Settings.GrainFilePath);
curMaterial=lower(GrainFileVals{11}(1));

[ Fhkl hkl C11 C12 C44 lattice a1 b1 c1 dhkl axs str C13 C33 C66 Burgers]=SelectMaterial(curMaterial);
Av = Settings.AccelVoltage*1000; %put it in eV from KeV
sampletilt = Settings.SampleTilt;
elevang = Settings.CameraElevation;
pixsize = size(Image,1);
disp(Settings.AngFilePath)
[SquareFileVals ScanParams] = ReadAngFile(Settings.AngFilePath);
paramspat={ScanParams.xstar;ScanParams.ystar;ScanParams.zstar;pixsize;Av;sampletilt;elevang;Fhkl;dhkl;hkl};
Angles(:,1) = SquareFileVals{1};
Angles(:,2) = SquareFileVals{2};
Angles(:,3) = SquareFileVals{3};
g=euler2gmat(Angles(1,1),Angles(1,2),Angles(1,3));

GenImage = genEBSDPatternHybrid(g,paramspat,eye(3),lattice,a1,b1,c1,axs);
GenImage = custimfilt(GenImage, Settings.ImageFilter(1), Settings.ImageFilter(2),Settings.ImageFilter(3),Settings.ImageFilter(4));
handles.GenImage=GenImage;
handles.Image = Image;
handles.Settings = Settings;
UpdateImageDisplay(handles,Settings.ImageFilter);
% UpdateROIDisplay(handles,Settings.ImageFilter);
axes(handles.OriginalImage);
imagesc(imread(Settings.FirstImagePath))
drawnow
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal

axes(handles.SimPat);
imagesc(GenImage)
drawnow
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
axis equal
% Choose default command line output for AdvancedSettings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% keyboard
% UIWAIT makes AdvancedSettings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdvancedSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in NumberROIsPopUp.
function NumberROIsPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to NumberROIsPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns NumberROIsPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumberROIsPopUp
% Update handles structure
guidata(hObject, handles);
% UpdateROIDisplay(handles);

% --- Executes during object creation, after setting all properties.
function NumberROIsPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberROIsPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ROISizePopUp.
function ROISizePopUp_Callback(hObject, eventdata, handles)
% hObject    handle to ROISizePopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ROISizePopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROISizePopUp
% Update handles structure
guidata(hObject, handles);
% UpdateROIDisplay(handles);

% --- Executes during object creation, after setting all properties.
function ROISizePopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROISizePopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in HROIMMethodPopUp.
function HROIMMethodPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to HROIMMethodPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns HROIMMethodPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HROIMMethodPopUp
HROIMMethodList = get(hObject,'String');
Ind = get(hObject,'Value');
HROIMMethod = HROIMMethodList(Ind);

if ~strcmp(HROIMMethod,'Simulated') %Either type of Real
    
    GrainRefTypeList = get(handles.GrainRefTypePopUp,'String');
    GrainRefType = GrainRefTypeList(get(handles.GrainRefTypePopUp,'Value'));
    if strcmp(GrainRefType, 'Min Kernel Avg Miso')
        set(handles.KernelAvgFilePathEdit,'Enable','on');
        set(handles.KernelAvgBrowseButton,'Enable','on');
    end
    set(handles.GrainRefTypePopUp,'Enable','on');
    set(handles.IterationLimitEdit,'Enable','off');
    set(handles.IterationLimitEdit,'Visible','off');
    set(handles.IterationLabel,'Visible','off');
    set(handles.RefImageIndLabel,'Visible','on');
    if strcmp(HROIMMethod,'Real-Single Ref')
        set(handles.RefImageIndEdit,'Enable','on');
        set(handles.RefImageIndEdit,'Visible','on');
    else
        set(handles.RefImageIndEdit,'Enable','off');
        set(handles.RefImageIndEdit,'Visible','on');
    end
else %Simulated
    set(handles.GrainRefTypePopUp,'Enable','off');
    set(handles.KernelAvgFilePathEdit,'Enable','off');
    set(handles.KernelAvgBrowseButton,'Enable','off');
    set(handles.RefImageIndLabel,'Visible','off')
    set(handles.IterationLimitEdit,'Enable','on');
    set(handles.IterationLimitEdit,'Visible','on');
    set(handles.IterationLabel,'Visible','on');
    set(handles.RefImageIndEdit,'Enable','off');
    set(handles.RefImageIndEdit,'Visible','off');
end

% --- Executes during object creation, after setting all properties.
function HROIMMethodPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HROIMMethodPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ROIStylePopUp.
function ROIStylePopUp_Callback(hObject, eventdata, handles)
% hObject    handle to ROIStylePopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ROIStylePopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROIStylePopUp
guidata(hObject, handles);
% UpdateROIDisplay(handles);
StyleList = get(hObject,'String');
Ind = get(hObject,'Value');
ROIStyle = StyleList{Ind};
if strcmp(ROIStyle,'Grid')
        
       set(handles.NumberROIsPopUp,'Enable','off');
%        set(handles.ROISizeEdit,'Enable','off');
else
        set(handles.NumberROIsPopUp,'Enable','on');
%        set(handles.ROISizeEdit,'Enable','off');
end
if strcmp(ROIStyle,'Intensity')
   set(handles.ROIFilterEdit1,'Enable','off');
   set(handles.ROIFilterEdit2,'Enable','off');
   set(handles.ROIFilterEdit3,'Enable','off');
   set(handles.ROIFilterEdit4,'Enable','off');
else    
   set(handles.ROIFilterEdit1,'Enable','on');
   set(handles.ROIFilterEdit2,'Enable','on');
   set(handles.ROIFilterEdit3,'Enable','on');
   set(handles.ROIFilterEdit4,'Enable','on');
end


% --- Executes during object creation, after setting all properties.
function ROIStylePopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIStylePopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IterationLimitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to IterationLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IterationLimitEdit as text
%        str2double(get(hObject,'String')) returns contents of IterationLimitEdit as a double


% --- Executes during object creation, after setting all properties.
function IterationLimitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IterationLimitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FCalcMethodPopUp.
function FCalcMethodPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to FCalcMethodPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FCalcMethodPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FCalcMethodPopUp


% --- Executes during object creation, after setting all properties.
function FCalcMethodPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FCalcMethodPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function KernelAvgFilePathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to KernelAvgFilePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of KernelAvgFilePathEdit as text
%        str2double(get(hObject,'String')) returns contents of KernelAvgFilePathEdit as a double


% --- Executes during object creation, after setting all properties.
function KernelAvgFilePathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KernelAvgFilePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KernelAvgBrowseButton.
function KernelAvgBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to KernelAvgBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[picname picpath] = uigetfile('*.txt','OIM Map Data');
set(handles.KernelAvgFilePathEdit,'String', [picpath picname]);



% --- Executes on button press in SaveAndCloseButton.
function SaveAndCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAndCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read in all items relevant to Settings and save them to a .mat file
Settings = handles.Settings;

Settings.ROISizePercent = str2double(get(handles.ROISizeEdit,'String'));

Settings.NumROIs = get(handles.NumberROIsPopUp,'Value');

ROIStyleList = get(handles.ROIStylePopUp,'String');
StyleInd = get(handles.ROIStylePopUp,'Value');
Settings.ROIStyle = ROIStyleList{StyleInd};

ImageFilterTypeList = get(handles.ImageFilterType,'String');
TypeInd = get(handles.ImageFilterType,'Value');
Settings.ImageFilterType = ImageFilterTypeList{TypeInd};

ROIFilt(1) = str2double(get(handles.ROIFilterEdit1,'String'));
ROIFilt(2) = str2double(get(handles.ROIFilterEdit2,'String'));
ROIFilt(3) = str2double(get(handles.ROIFilterEdit3,'String'));
ROIFilt(4) = str2double(get(handles.ROIFilterEdit4,'String'));
Settings.ROIFilter = ROIFilt;

ImageFilt(1) = str2double(get(handles.ImageFilterEdit1,'String'));
ImageFilt(2) = str2double(get(handles.ImageFilterEdit2,'String'));
ImageFilt(3) = str2double(get(handles.ImageFilterEdit3,'String'));
ImageFilt(4) = str2double(get(handles.ImageFilterEdit4,'String'));
Settings.ImageFilter = ImageFilt;

HROIMMethodList = get(handles.HROIMMethodPopUp,'String');
MethodInd = get(handles.HROIMMethodPopUp,'Value');
switch HROIMMethodList{MethodInd}
    case 'Simulated'
        Settings.HROIMMethod = HROIMMethodList{MethodInd};
        Settings.RefImageInd = 0;
    case 'Real-Grain Ref'
        Settings.HROIMMethod = 'Wilkinson'; %Wilkison is the original name used for 'Real' pattern method
        Settings.RefImageInd = 0;
    case 'Real-Single Ref'
        Settings.HROIMMethod = 'Wilkinson';
        Settings.RefImageInd = str2double(get(handles.RefImageIndEdit,'String'));
end

%Derivatives Settings
Settings.CalcDerivatives = get(handles.CalcDerivativesCheckBox, 'Value');
Settings.NumSkipPts = get(handles.NumSkipPtsBox, 'String');
Settings.MisoTol = str2double(get(handles.MisoTolBox, 'String'));
Settings.IQCutoff = str2double(get(handles.IQCutoffBox, 'String'));

Limit = uint8(str2num(get(handles.IterationLimitEdit,'String')));
if isinteger(Limit) && Limit > 0
    Settings.IterationLimit = Limit;
else
    errordlg('Iteration limit can only be a positive integer','Doy');
    return;
end

StdDev = double(str2num(get(handles.StdDevEdit,'String')));
if StdDev > 0
    Settings.StandardDeviation = StdDev;
else
    errordlg('Standard deviation can only be a positive number','Warning');
    return;
end


FCalcList = get(handles.FCalcMethodPopUp,'String');
FCalcInd = get(handles.FCalcMethodPopUp,'Value');
Settings.FCalcMethod = FCalcList{FCalcInd};

GrainRefTypeList = get(handles.GrainRefTypePopUp,'String');
GrRefId = get(handles.GrainRefTypePopUp,'Value');
Settings.GrainRefImageType = GrainRefTypeList{GrRefId};

Settings.KernelAvgMisoPath = get(handles.KernelAvgFilePathEdit,'String');

save('Settings.mat','Settings');
% keyboard
delete(handles.figure1);

function ImageFilterEdit1_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of ImageFilterEdit1 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilterEdit1 as a double


% --- Executes during object creation, after setting all properties.
function ImageFilterEdit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageFilterEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of ImageFilterEdit2 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilterEdit2 as a double


% --- Executes during object creation, after setting all properties.
function ImageFilterEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageFilterEdit3_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of ImageFilterEdit3 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilterEdit3 as a double


% --- Executes during object creation, after setting all properties.
function ImageFilterEdit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImageFilterEdit4_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of ImageFilterEdit4 as text
%        str2double(get(hObject,'String')) returns contents of ImageFilterEdit4 as a double


% --- Executes during object creation, after setting all properties.
function ImageFilterEdit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageFilterEdit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in GrainRefTypePopUp.
function GrainRefTypePopUp_Callback(hObject, eventdata, handles)
% hObject    handle to GrainRefTypePopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GrainRefTypePopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GrainRefTypePopUp
HROIMMethodList = get(handles.HROIMMethodPopUp,'String');
HROIMMethod = HROIMMethodList(get(handles.HROIMMethodPopUp,'Value'));
GrainRefTypeList = get(hObject,'String');
GrainRefType = GrainRefTypeList(get(hObject,'Value'));
if and(~strcmp(HROIMMethod,'Simulated'), (strcmp(GrainRefType,'Min Kernel Avg Miso')))
    set(handles.KernelAvgFilePathEdit,'Enable','on');
    set(handles.KernelAvgBrowseButton,'Enable','on');
else
    set(handles.KernelAvgFilePathEdit,'Enable','off');
    set(handles.KernelAvgBrowseButton,'Enable','off');
end

% --- Executes during object creation, after setting all properties.
function GrainRefTypePopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrainRefTypePopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIFilterEdit1_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilterEdit1 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilterEdit1 as a double


% --- Executes during object creation, after setting all properties.
function ROIFilterEdit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIFilterEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilterEdit2 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilterEdit2 as a double


% --- Executes during object creation, after setting all properties.
function ROIFilterEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIFilterEdit3_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilterEdit3 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilterEdit3 as a double


% --- Executes during object creation, after setting all properties.
function ROIFilterEdit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIFilterEdit4_Callback(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIFilterEdit4 as text
%        str2double(get(hObject,'String')) returns contents of ROIFilterEdit4 as a double


% --- Executes during object creation, after setting all properties.
function ROIFilterEdit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFilterEdit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
guidata(hObject, handles);
% UpdateROIDisplay(handles);


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



function StdDevEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StdDevEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StdDevEdit as text
%        str2double(get(hObject,'String')) returns contents of StdDevEdit as a double


% --- Executes during object creation, after setting all properties.
function StdDevEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StdDevEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RefreshImage.
function RefreshImage_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
ImageFilt(1) = str2double(get(handles.ImageFilterEdit1,'String'));
ImageFilt(2) = str2double(get(handles.ImageFilterEdit2,'String'));
ImageFilt(3) = str2double(get(handles.ImageFilterEdit3,'String'));
ImageFilt(4) = str2double(get(handles.ImageFilterEdit4,'String'));
UpdateImageDisplay(handles,ImageFilt)

% --- Executes on button press in Help.
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in ImageFilterType.
function ImageFilterType_Callback(hObject, eventdata, handles)
% hObject    handle to ImageFilterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageFilterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageFilterType
ImageFilterTypeList = get(hObject,'String');
Ind = get(hObject,'Value');
handles.ImageFilterType=ImageFilterTypeList(Ind);
disp(ImageFilterTypeList(Ind))
if strcmp(ImageFilterTypeList(Ind),'localthresh')

    set(handles.ImageFilterEdit1,'Enable','off');
    set(handles.ImageFilterEdit2,'Enable','off');
    set(handles.ImageFilterEdit3,'Enable','off');
    set(handles.ImageFilterEdit4,'Enable','off');
else
   
    set(handles.ImageFilterEdit1,'Enable','on');
    set(handles.ImageFilterEdit2,'Enable','on');
    set(handles.ImageFilterEdit3,'Enable','on');
    set(handles.ImageFilterEdit4,'Enable','on');
end

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


% --- Executes on button press in RefreshROIs.
function RefreshROIs_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
ImageFilt(1) = str2double(get(handles.ImageFilterEdit1,'String'));
ImageFilt(2) = str2double(get(handles.ImageFilterEdit2,'String'));
ImageFilt(3) = str2double(get(handles.ImageFilterEdit3,'String'));
ImageFilt(4) = str2double(get(handles.ImageFilterEdit4,'String'));
UpdateROIDisplay(handles,ImageFilt)


% --- Executes during object creation, after setting all properties.
function OriginalImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OriginalImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate OriginalImage


% --- Executes during object creation, after setting all properties.
function SimPat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SimPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate SimPat


% --- Executes during object creation, after setting all properties.
function FilteredImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FilteredImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate FilteredImage


% --- Executes on button press in CalcDerivativesCheckBox.
function CalcDerivativesCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to CalcDerivativesCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CalcDerivativesCheckBox
value = get(hObject, 'Value');
if value == 0
    set(handles.NumSkipPtsBox, 'Enable', 'off');
    set(handles.MisoTolBox, 'Enable', 'off');
    set(handles.IQCutoffBox, 'Enable', 'off');
elseif value == 1
    set(handles.NumSkipPtsBox, 'Enable', 'on');
    set(handles.MisoTolBox, 'Enable', 'on');
    set(handles.IQCutoffBox, 'Enable', 'on');
end
    



function NumSkipPtsBox_Callback(hObject, eventdata, handles)
% hObject    handle to NumSkipPtsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumSkipPtsBox as text
%        str2double(get(hObject,'String')) returns contents of NumSkipPtsBox as a double

%Input validation
Settings = handles.Settings;
UserInput = get(hObject,'String');
if isempty(str2num(UserInput))
    if ~strcmp(UserInput, 'a') && ~strcmp(UserInput, 't')
        set(hObject, 'String', Settings.NumSkipPts);
        warndlg('Input must be numerical, "a" or "t"');
    end
elseif str2double(UserInput) < 0
    set(hObject, 'String', Settings.NumSkipPts);
    warndlg('Input must be positive');
else
    set(hObject, 'String', round(str2double(UserInput)));
end
    
%Updates handles object
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NumSkipPtsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumSkipPtsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MisoTolBox_Callback(hObject, eventdata, handles)
% hObject    handle to MisoTolBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MisoTolBox as text
%        str2double(get(hObject,'String')) returns contents of MisoTolBox as a double


% --- Executes during object creation, after setting all properties.
function MisoTolBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MisoTolBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function IQCutoffBox_Callback(hObject, eventdata, handles)
% hObject    handle to IQCutoffBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IQCutoffBox as text
%        str2double(get(hObject,'String')) returns contents of IQCutoffBox as a double


% --- Executes during object creation, after setting all properties.
function IQCutoffBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IQCutoffBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RefImageIndEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RefImageIndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RefImageIndEdit as text
%        str2double(get(hObject,'String')) returns contents of RefImageIndEdit as a double


% --- Executes during object creation, after setting all properties.
function RefImageIndEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefImageIndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in skippointshelp.
function skippointshelp_Callback(hObject, eventdata, handles)
% hObject    handle to skippointshelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SkipPointsHelp();