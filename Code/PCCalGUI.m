function varargout = PCCalGUI(varargin)
% PCCALGUI MATLAB code for PCCalGUI.fig
%      PCCALGUI, by itself, creates a new PCCALGUI or raises the existing
%      singleton*.
%
%      H = PCCALGUI returns the handle to a new PCCALGUI or the handle to
%      the existing singleton*.
%
%      PCCALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PCCALGUI.M with the given input arguments.
%
%      PCCALGUI('Property','Value',...) creates a new PCCALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PCCalGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PCCalGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PCCalGUI

% Last Modified by GUIDE v2.5 17-Sep-2015 10:19:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PCCalGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PCCalGUI_OutputFcn, ...
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

% --- Executes just before PCCalGUI is made visible.
function PCCalGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PCCalGUI (see VARARGIN)
% Choose default command line output for PCCalGUI


%Get Settings sent in if this was opened before and is being reopened.
if length(varargin) == 1
   Settings = varargin{1}; 

else
    %otherwise load the Settings(should be default)
    load Settings
end

%[SquareFileVals, ScanParams] = ReadScanFile(Settings.ScanFilePath);

%Set defaults
handles.xstar_file = Settings.ScanParams.xstar;
handles.ystar_file = Settings.ScanParams.ystar;
handles.zstar_file = Settings.ScanParams.zstar;
set(handles.xstar,'String',num2str(handles.xstar_file));
set(handles.ystar,'String',num2str(handles.ystar_file));
set(handles.zstar,'String',num2str(handles.zstar_file));
set(handles.manualpc,'Value',0);
set(handles.naivebutton,'Value',1);
set(handles.scanfilepc,'Value',1);

handles.xstar_m = handles.xstar_file;
handles.ystar_m = handles.ystar_file;
handles.zstar_m = handles.zstar_file;

%Set up variables for plotting
IQ = Settings.IQ;
Nx = Settings.Nx;
Ny = Settings.Ny;
ScanType = Settings.ScanType;

%Create Plots
switch ScanType

    case 'Square'
        IQPlot = reshape(IQ, Nx,Ny)';
        if Ny == 1 %Lines Scans
            IQPlot = repmat(IQPlot,floor(Settings.ScanLength/4),1);
        end

        axes(handles.axes1)
        imagesc(IQPlot)
        axis image %scales to natural width and height
        
    case 'Hexagonal'
        NumColsEven = Nx-1;
        NumColsOdd = Nx;
        x = Settings.XData;
        y = Settings.YData;
        x = Hex2Array(x,NumColsOdd,NumColsEven);
        y = Hex2Array(y,NumColsOdd,NumColsEven);
        iq = Hex2Array(IQ,NumColsOdd,NumColsEven);
        
        StdDev = std(iq(:));
        Mean = mean(iq(:));
        Limits(1) = Mean - 3*StdDev;
        Limits(2) = Mean + 3*StdDev;
        
        axes(handles.axes1)
        surf(x,y,iq, 'EdgeColor','none');
        view(2);
        caxis(Limits);
        IQPlot.x = x;
        IQPlot.y = y;
        IQPlot.iq = iq;
        IQPlot.Limits = Limits;
        
end
axes(handles.axes2)
plot3(Settings.ScanParams.xstar,Settings.ScanParams.ystar,Settings.ScanParams.zstar,'bo')
colormap jet

if Settings.ImageTag
    set(handles.tiffpc,'Enable','on');
else   
    set(handles.tiffpc,'Enable','off');
end
set(handles.fromtiff,'Enable','off');

set(handles.SavePCCal,'Value',1);
handles.SaveAllPC = 1;

% Update handles structure
handles.Algorithm = 'fminsearch';
handles.Settings = Settings;
handles.ScanParams = Settings.ScanParams;
handles.VanPont = 0;
handles.calibrated = 0;
handles.tiffread = 0;
handles.IQPlot = IQPlot;
handles.isset = false;
guidata(hObject, handles);
%uiwait(handles.PCCalGUI)
pcmethod_SelectionChangedFcn(handles.pcmethod, eventdata, handles)


% --- Outputs from this function are returned to the command line.
function varargout = PCCalGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = 1;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in savenclose.
function savenclose_Callback(hObject, eventdata, handles)
% hObject    handle to savenclose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);
handles = guidata(hObject);
YesNo = 'Yes';
if ~handles.isset
    YesNo = questdlg({'No pattern center calibration has been performed.'; 'Are you sure you want to continue?'},'No Calibration');
end
if ~strcmp(YesNo,'No')
    Settings = handles.Settings;
    SaveAllPC = handles.SaveAllPC;
    
    if SaveAllPC
        PCCal.PCMethod = handles.pcmethod;
        PCCal.PlaneFit = handles.planefit;
        if handles.calibrated
            PCCal.MeanXstar = handles.MeanXstar;
            PCCal.MeanYstar = handles.MeanYstar;
            PCCal.MeanZstar = handles.MeanZstar;
            PCCal.FitXstar = handles.FitXstar;
            PCCal.FitYstar = handles.FitYstar;
            PCCal.FitZstar = handles.FitZstar;
            PCCal.NaiveXstar = handles.NaiveXstar;
            PCCal.NaiveYstar = handles.NaiveYstar;
            PCCal.NaiveZstar = handles.NaiveZstar;
        end
        if handles.tiffread
            PCCal.TiffXstar = handles.TiffXstar;
            PCCal.TiffYstar = handles.TiffYstar;
            PCCal.TiffZstar = handles.TiffZstar;
        end
        Settings.PCCal = PCCal;
    else
        Settings.DoPCStrainMin = 0;
        
    end
    if strcmp(YesNo,'Cancel')
        Settings.Exit = 1;
    end
    save('Settings.mat','Settings');
    delete(handles.PCCalGUI);
end

% --- Executes when user attempts to close PCCalGUI.
function PCCalGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PCCalGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
try
    dlg = 'Continue';
    if handles.calibrated
        dlg = questdlg('Please select an option:', 'Continue','Cancel','Continue');
    end
    switch dlg
        case 'Continue'
            savenclose_Callback(handles.savenclose,eventdata,handles);
        case 'Cancel'
            Settings = handles.Settings;
            Settings.Exit = 1;
            save('Settings.mat','Settings');
            delete(handles.PCCalGUI);
    end
catch
    delete(hObject)
end

% --- Executes on button press in calibratebutton.
function calibratebutton_Callback(hObject, eventdata, handles)
% hObject    handle to calibratebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.strainmin,'Value')
    strainmin_calibration(handles.calibratebutton,eventdata,handles);
elseif get(handles.tiffpc,'Value')
    tiff_calibration(handles.calibratebutton,eventdata,handles);
end

function strainmin_calibration(hObject,eventdata,handles)
if handles.VanPont
    
    Settings = handles.Settings;
    ScanParams = handles.ScanParams;

    npoints = length(Settings.CalibrationPointIndecies);

    CalibrationPointsPC = zeros(npoints,3);
    
    NumCores = Settings.DoParallel;
    try
        ppool = gcp('nocreate');
        if isempty(ppool)
            parpool(NumCores);
        end
    catch
        ppool = matlabpool('size');
        if ~ppool
            matlabpool('local',NumCores); 
        end
    end
    M = NumCores;
    
    pctRunOnAll javaaddpath('java')
    ppm = ParforProgMon( 'Point Calibration ', npoints,1,400,50 );
%     profile on
    Algorithm = handles.Algorithm;
    ScanParams.xstar = Settings.XStar(1);
    ScanParams.ystar = Settings.YStar(2);
    ScanParams.zstar = Settings.ZStar(3);
    parfor (i=1:npoints,M)
        PCref = PCMinSinglePattern(Settings, ScanParams, Settings.CalibrationPointIndecies(i),Algorithm);
        disp(['Point: ' num2str(i)])
        CalibrationPointsPC(i,:) = PCref';
        ppm.increment();
    end
%     profile off
%     profile viewer
    ppm.delete();
    Settings.CalibrationPointsPC = CalibrationPointsPC;

    psize = Settings.PhosphorSize;
    
    handles.MeanXstar = mean(Settings.CalibrationPointsPC(:,1)+(Settings.XData(Settings.CalibrationPointIndecies))/psize);
    handles.MeanYstar = mean(Settings.CalibrationPointsPC(:,2)-(Settings.YData(Settings.CalibrationPointIndecies))/psize*sin(Settings.SampleTilt));
    handles.MeanZstar = mean(Settings.CalibrationPointsPC(:,3)-(Settings.YData(Settings.CalibrationPointIndecies))/psize*cos(Settings.SampleTilt));
%     disp(['xstar: ' num2str(handles.MeanXstar(1))]);
%     disp(['ystar: ' num2str(handles.MeanYstar(1))]);
%     disp(['zstar: ' num2str(handles.MeanZstar(1))]);

    handles.NaiveXstar = handles.MeanXstar-(Settings.XData)/psize;
    handles.NaiveYstar = handles.MeanYstar+(Settings.YData)/psize*sin(Settings.SampleTilt);
    handles.NaiveZstar = handles.MeanZstar+(Settings.YData)/psize*cos(Settings.SampleTilt);

    % PC Plane Fit
    [n,V,p] = affine_fit(Settings.CalibrationPointsPC);

    line = zeros(npoints,6);
    for i=1:npoints
        line(i,:)=[Settings.CalibrationPointsPC(i,:) n'];
    end

    plane = [p V(:,1)' V(:,2)'];

    X=intersectLinePlane(line,plane);

    C = zeros(npoints,2);
    for i=1:npoints
        C(i,1)=Settings.XData(Settings.CalibrationPointIndecies(i));
        C(i,2)=Settings.YData(Settings.CalibrationPointIndecies(i));
    end

    A=zeros(3*npoints,9);
    PC=zeros(3*npoints,1);

    for i=1:npoints
        x=C(i,1);
        y=C(i,2);
        for k=1:3
            A(k+(i-1)*3,(1+3*(k-1)))=x;
            A(k+(i-1)*3,(2+3*(k-1)))=y;
            A(k+(i-1)*3,(3+3*(k-1)))=1;
            PC((i-1)*3+k)=X(i,k);
        end
    end

    coeffs=pinv(A)*PC;

    handles.FitXstar = coeffs(1)*Settings.XData+coeffs(2)*Settings.YData+coeffs(3);
    handles.FitYstar = coeffs(4)*Settings.XData+coeffs(5)*Settings.YData+coeffs(6);
    handles.FitZstar = coeffs(7)*Settings.XData+coeffs(8)*Settings.YData+coeffs(9);
    
    set(handles.pcplanefit,'Enable','on');

    
    handles.Settings = Settings;
    guidata(hObject, handles);
    
    cla(handles.axes2)
    handles.calibrated = 1;
    
    planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);
    
    handles = guidata(hObject);
    if get(handles.autorunbox,'Value')
        savenclose_Callback(handles.savenclose,eventdata,handles);
    end
    
else
    mboxhandle = msgbox('You need to select points to calibrate first');
    pause(1)
    close(mboxhandle)
    
end


% --- Executes on button press in selectpointsbutton.
function selectpointsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectpointsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Right-click last point or use RETURN key to exit.

Settings = handles.Settings;
Nx = Settings.Nx;
Ny = Settings.Ny;
IQ = Settings.IQ;
XData = Settings.XData;
YData = Settings.YData;
NumColsEven = Nx-1;
NumColsOdd = Nx;
IQPlot = handles.IQPlot;
XStep = XData(2)-XData(1);
YStep = YData(YData > 0);
if isempty(YStep) %Lines Scans
    YStep = 0;
else
    YStep = YStep(1);
end
Title = 'Press RETURN key or right-click last point to exit';
if Settings.Ny > 1
    MinPoints = 3;
elseif Settings.Ny == 1
    MinPoints = 1;
end

%Create Correct Indice Matrix
switch Settings.ScanType
    case 'Square'
        indi = 1:1:Settings.Nx*Settings.Ny;
        indi = reshape(indi, Settings.Nx,Settings.Ny)';
        
        %Create the Figure
        selectfig = figure;
        imagesc(IQPlot)
        axis image
        title(Title);
        
        npoints = 1;
        morepoints = 1;
        while morepoints   
            %Gets X,Y data from user
            [x,y, button] = ginput(1);
            if x > Nx
                x = Nx;
            elseif x < 1
                x = 1;
            end
            if y > Ny
                y = Ny;
            elseif y < 1
                y = 1;
            end
            
            if ~isempty(x)
                CalibrationPointIndecies(npoints) = indi(round(y), round(x));
                Xind(npoints) = round(x);
                Yind(npoints) = round(y);
                
                if button ~= 1 && npoints >= MinPoints
                    morepoints = 0;
                end
                npoints = npoints + 1;
            elseif npoints > MinPoints %When RETURN key is pressed
                morepoints = 0;
            end
            
            hold on
            plot(round(x),round(y),'kd','MarkerFaceColor','k');
        end
        close (selectfig);
        hold off
        axes(handles.axes1)
        imagesc(IQPlot)
        axis image
        hold on
        plot(Xind,Yind,'kd','MarkerFaceColor','k');
        %CalibrationPointIndecies
        
    case 'Hexagonal'
        indi = 1:length(XData);
        indi = Hex2Array(indi, NumColsOdd, NumColsEven);
        color = IQPlot.iq;
        
        selectfig = figure;
                
        npoints = 1;
        morepoints = 1;
        while morepoints
            %Create the Figure
            surf(IQPlot.x,IQPlot.y,IQPlot.iq,color,'EdgeColor','none');
            view(2);
            caxis(IQPlot.Limits);
            title(Title);
            colormap jet
            
            %Gets X,Y data from user
            [x,y, button] = ginput(1);
            Xind = round(x/XStep);
            Yind = round(y/YStep);
            if Xind > NumColsEven
                Xind = NumColsEven;
            elseif Xind < 1
                Xind = 1;
            end
            if Yind > Ny
                Yind = Ny;
            elseif Yind < 1
                Yind = 1;
            end
            
            if ~isempty(x)
            
                CalibrationPointIndecies(npoints) = indi(Yind, Xind);

                hold on
                scatter3(XData(CalibrationPointIndecies(npoints)),YData(CalibrationPointIndecies(npoints)),max(IQ));
                color(Yind,Xind) = max(IQ)*1000;

                if button ~= 1 && npoints > 2
                    morepoints = 0;
                end
                npoints = npoints + 1;
            elseif npoints > 3 %When RETRUN key is pressed
                morepoints = 0;
            end    
        end
        close (selectfig);
        hold off
        axes(handles.axes1)
        surf(IQPlot.x,IQPlot.y,IQPlot.iq,'EdgeColor','none');
        view(2);
        caxis(IQPlot.Limits);
        hold on
        height(1:length(CalibrationPointIndecies)) = max(IQ);
        scatter3(XData(CalibrationPointIndecies),YData(CalibrationPointIndecies),height);
                
end
Settings.CalibrationPointIndecies = CalibrationPointIndecies;
handles.Settings = Settings;
handles.VanPont = 1;
guidata(hObject, handles);

% --- Executes on button press in autorunbox.
function autorunbox_Callback(hObject, eventdata, handles)
% hObject    handle to autorunbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of autorunbox

% --------------------------------------------------------------------
function planefitpanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to planefitpanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Settings = handles.Settings;
Nx = Settings.Nx;
NumColsEven = Nx-1;
NumColsOdd = Nx;
ScanType = Settings.ScanType;

cla(handles.axes2)
    
%Get PC Data
psize = Settings.PhosphorSize;
ismanual = get(handles.manualpc,'Value');
iscalibrated = handles.calibrated;
isset = false;
if ismanual
    xstar = handles.xstar_m;
    ystar = handles.ystar_m;
    zstar = handles.zstar_m;
    isset = true;
elseif get(handles.strainmin,'Value') && iscalibrated
    xstar = handles.MeanXstar;
    ystar = handles.MeanYstar;
    zstar = handles.MeanZstar;
    isset = true;
elseif get(handles.tiffpc,'Value') && handles.tiffread
    isset = true;
elseif get(handles.scanfilepc,'Value')
    xstar = handles.xstar_file;
    ystar = handles.ystar_file;
    zstar = handles.zstar_file;
    isset = true;
end

if isset
    % Naive Plane Fit
    if get(handles.naivebutton,'Value')
        handles.planefit = 'Naive';
        
        %Calculate Naive Plane Fit
        Settings.XStar = xstar-(Settings.XData)/psize;
        Settings.YStar = ystar+(Settings.YData)/psize*sin(Settings.SampleTilt);
        Settings.ZStar = zstar+(Settings.YData)/psize*cos(Settings.SampleTilt);

    end

    % PC Data Fit
    if get(handles.pcplanefit,'Value') && iscalibrated
        handles.planefit = 'PCPlaneFit';
        
        %Assign pc matrices
        Settings.XStar = handles.FitXstar;
        Settings.YStar = handles.FitYstar;
        Settings.ZStar = handles.FitZstar;

    end
    
    % No Fit
    if get(handles.nofit,'Value')
        handles.planefit = 'No Fit';
        
        %Assign pc matrices
        Settings.XStar = xstar*ones(size(Settings.XStar));
        Settings.YStar = ystar*ones(size(Settings.XStar));
        Settings.ZStar = zstar*ones(size(Settings.XStar));
        
    end

    %Get PC Data from TIFF
    if handles.tiffread && get(handles.fromtiff,'Value')
        handles.planefit = 'From Tiff Images';
        
        Settings.Xstar = handles.TiffXstar;
        Settings.Ystar = handles.TiffYstar;
        Settings.Zstar = handles.TiffZstar;
 
    end
end

%Update Plot
cla(handles.axes2)
axes(handles.axes2)
%Plot PC from file
plot3(handles.xstar_file,handles.ystar_file,handles.zstar_file,'bo')
xlabel('XStar')
ylabel('YStar')
zlabel('ZStar')
hold on


%Set PC boxes on GUI
if isset
    set(handles.xstar,'String',num2str(Settings.XStar(1)));
    set(handles.ystar,'String',num2str(Settings.YStar(1)));
    set(handles.zstar,'String',num2str(Settings.ZStar(1)));
    setmanualpc(handles);
    handles = guidata(hObject);
    
    %Plot new PC 1st point
    plot3(Settings.XStar(1),Settings.YStar(1),Settings.ZStar(1),'go');
    
    switch ScanType
        case 'Square'
            XStar = reshape(Settings.XStar,Settings.Nx,Settings.Ny)';
            YStar = reshape(Settings.YStar,Settings.Nx,Settings.Ny)';
            ZStar = reshape(Settings.ZStar,Settings.Nx,Settings.Ny)';
        case 'Hexagonal'
            XStar = Hex2Array(Settings.XStar(1:end-1), NumColsOdd, NumColsEven);
            YStar = Hex2Array(Settings.YStar(1:end-1), NumColsOdd, NumColsEven);
            ZStar = Hex2Array(Settings.ZStar(1:end-1), NumColsOdd, NumColsEven);
    end
    if Settings.Ny > 1
        surf(XStar,YStar,ZStar,zeros(size(ZStar)))
    else
        plot3(XStar,YStar,ZStar)
    end
    shading flat
else
    set(handles.xstar,'String','No PC Data');
    set(handles.ystar,'String','No PC Data');
    set(handles.zstar,'String','No PC Data');
end


handles.isset = isset;
handles.Settings = Settings;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes on button press in LoadPCCalc.
function LoadPCCalc_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPCCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
w = cd;
Settings = handles.Settings;
cd(fileparts(Settings.ScanFilePath));
[filename, filepath] = uigetfile('*mat','Select an Analysis_Params file');
cd(w);
matfile = load(fullfile(filepath,filename));
if isfield(matfile,'Settings')
    loadedSettings = matfile.Settings;
    valid = 1;
    % Validation
    if (Settings.AccelVoltage ~= loadedSettings.AccelVoltage)...
        ||(Settings.SampleTilt ~= loadedSettings.SampleTilt)...
        ||(Settings.SampleAzimuthal ~= loadedSettings.SampleAzimuthal)...
        ||(Settings.CameraElevation ~= loadedSettings.CameraElevation)...
        ||(Settings.CameraAzimuthal ~= loadedSettings.CameraAzimuthal)...
        ||(~strcmp(Settings.ScanFilePath,loadedSettings.ScanFilePath))...
        ||(~strcmp(Settings.ScanType,loadedSettings.ScanType))...
        ||(sum(Settings.IQ ~= loadedSettings.IQ)>0)
        valid = 0;
    end
    if valid == 0
        warndlg('Selected Scan not compatible with current scan');
    end
    
    if isfield(loadedSettings,'PCCal') && valid
        PCCal = loadedSettings.PCCal;
        handles.MeanXstar = PCCal.MeanXstar;
        handles.MeanYstar = PCCal.MeanYstar;
        handles.MeanZstar = PCCal.MeanZstar;
        handles.FitXstar = PCCal.FitXstar;
        handles.FitYstar = PCCal.FitYstar;
        handles.FitZstar = PCCal.FitZstar;
        handles.NaiveXstar = PCCal.NaiveXstar;
        handles.NaiveYstar = PCCal.NaiveYstar;
        handles.NaiveZstar = PCCal.NaiveZstar;
        handles.calibrated = 1;
        handles.VanPont = 1;
        handles.Settings.CalibrationPointIndecies = loadedSettings.CalibrationPointIndecies;
        handles.Settings.CalibrationPointsPC = loadedSettings.CalibrationPointsPC;
        handles.Settings.PhosphorSize = loadedSettings.PhosphorSize;
        if isfield(PCCal,'TiffXStar')
            handles.TiffXStar = PCCal.TiffXStar;
            handles.TiffYStar = PCCal.TiffYStar;
            handles.TiffZStar = PCCal.TiffZStar;
            handles.tiffread = 1;
        end
        if isfield(PCCal,'PCMethod')
            switch PCCal.PCMethod
                case 'StrainMin'
                    set(handles.strainmin,'Value',1);
                case 'FromTiff'
                    set(handles.tiffpc,'Value',1);
                case 'FromFile'
                    set(handles.scanfilepc,'Value',1);
                case 'Manual'
                    set(handles.manualpc,'Value',1);
            end
        end
        if isfield(PCCal,'PlaneFit')
            switch PCCal.PlaneFit
                case 'Naive'
                    set(handles.naivebutton,'Value',1);
                case 'PCPlaneFit'
                    set(handles.pcplanefit,'Value',1);
                case 'From Tiff Images'
                    set(handles.fromtiff,'Value',1);
                case 'No Fit'
                    set(handles.nofit,'Value',1);
            end
        end
        handles.xstar_file = loadedSettings.ScanParams.xstar;
        handles.ystar_file = loadedSettings.ScanParams.ystar;
        handles.zstar_file = loadedSettings.ScanParams.zstar;
        handles.xstar_m = loadedSettings.XStar(1);
        handles.ystar_m = loadedSettings.YStar(1);
        handles.zstar_m = loadedSettings.ZStar(1);
        
        IQPlot = handles.IQPlot;
        CalibrationPointIndecies = loadedSettings.CalibrationPointIndecies;
        Nx = Settings.Nx;
        Ny = Settings.Ny;
        IQ = Settings.IQ;
        XData = Settings.XData;
        YData = Settings.YData;
        NumColsEven = Nx-1;
        NumColsOdd = Nx;
        switch Settings.ScanType
            case 'Square'
                indi = 1:1:Nx*Ny;
                indi = reshape(indi,Nx,Ny)';
                for i = 1:length(CalibrationPointIndecies)
                    Xind(i) = mod(CalibrationPointIndecies(i),Nx);
                    Yind(i) = ceil(CalibrationPointIndecies(i)/Nx);
                end
                axes(handles.axes1)
                imagesc(IQPlot)
                axis image
                hold on
                plot(Xind,Yind,'kd','MarkerFaceColor','k');
            case 'Hexagonal'
                indi = 1:length(XData);
                indi = Hex2Array(indi, NumColsOdd, NumColsEven);
                axes(handles.axes1)
                surf(IQPlot.x,IQPlot.y,IQPlot.iq,'EdgeColor','none');
                view(2);
                caxis(IQPlot.Limits);
                hold on
                height(1:length(CalibrationPointIndecies)) = max(IQ);
                scatter3(XData(CalibrationPointIndecies),YData(CalibrationPointIndecies),height);
        end
        guidata(hObject,handles);
    end
end
pcmethod_SelectionChangedFcn(handles.pcmethod, eventdata, handles);
clear matfile;


% --- Executes on button press in SavePCCalc.
function SavePCCalc_Callback(hObject, eventdata, handles)
% hObject    handle to SavePCCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[path, name] = fileparts(handles.Settings.OutputPath);
Settings = handles.Settings;
Settings.PCCal.MeanXstar = handles.MeanXstar;
Settings.PCCal.MeanYstar = handles.MeanYstar;
Settings.PCCal.MeanZstar = handles.MeanZstar;
Settings.PCCal.FitXstar = handles.FitXstar;
Settings.PCCal.FitYstar = handles.FitYstar;
Settings.PCCal.FitZstar = handles.FitZstar;
Settings.PCCal.NaiveXstar = handles.NaiveXstar;
Settings.PCCal.NaiveYstar = handles.NaiveYstar;
Settings.PCCal.NaiveZstar = handles.NaiveZstar;

save(fullfile(path,name),'Settings');


% --- Executes on button press in SavePCCal.
function SavePCCal_Callback(hObject, eventdata, handles)
% hObject    handle to SavePCCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SavePCCal
handles.SaveAllPC = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in fromtiffbutton.
function fromtiffbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fromtiffbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function tiff_calibration(hObject,eventdata,handles)
handles = guidata(hObject);
Settings = handles.Settings;
info = imfinfo(Settings.ImageNamesList{1});

if Settings.ImageTag %See MainGUI.m SetImageFields

    handles.TiffXstar = zeros(size(Settings.XData));
    handles.TiffYstar = handles.TiffXstar;
    handles.TiffZstar = handles.TiffXstar;
    
    VHRatio = Settings.VHRatio;
    lscan = Settings.ScanLength;

    h = waitbar(0,'Reading Tiff Files');
    for i=1:lscan
        try
            info = imfinfo(Settings.ImageNamesList{i});

            xistart = strfind(info.UnknownTags.Value,'<pattern-center-x-pu>');
            xifinish = strfind(info.UnknownTags.Value,'</pattern-center-x-pu>');

            thisx = str2double(info.UnknownTags.Value(xistart+length('<pattern-center-x-pu>'):xifinish-1));
            handles.TiffXstar(i) = (thisx - (1-VHRatio)/2)/VHRatio;

            yistart = strfind(info.UnknownTags.Value,'<pattern-center-y-pu>');
            yifinish = strfind(info.UnknownTags.Value,'</pattern-center-y-pu>');

            handles.TiffYstar(i) = str2double(info.UnknownTags.Value(yistart+length('<pattern-center-y-pu>'):yifinish-1));

            zistart = strfind(info.UnknownTags.Value,'<detector-distance-pu>');
            zifinish = strfind(info.UnknownTags.Value,'</detector-distance-pu>');

            handles.TiffZstar(i) = str2double(info.UnknownTags.Value(zistart+length('<detector-distance-pu>'):zifinish-1))/VHRatio;
        catch
            handles.TiffXstar(i) = handles.ScanParams.xstar;
            handles.TiffYstar(i) = handles.ScanParams.ystar;
            handles.TiffZstar(i) = handles.ScanParams.zstar;
        end
        waitbar(i/lscan,h)
    end
    close(h)

    handles.tiffread = 1;
    set(handles.fromtiff,'Enable','on');

    if ~handles.calibrated
        Settings.Xstar = handles.TiffXstar;
        Settings.Ystar = handles.TiffYstar;
        Settings.Zstar = handles.TiffZstar;
        
        handles.Settings = Settings;
    end
    
    guidata(hObject, handles);
    if get(handles.autorunbox,'Value')
        set(handles.fromtiff,'Value',1)
    end
    planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);
    
    if get(handles.autorunbox,'Value')
        savenclose_Callback(handles.savenclose,eventdata,handles);
    end

else
    msgbox('No PC data found in image files','Read PC from TIFF')
end




function xstar_Callback(hObject, eventdata, handles)
% hObject    handle to xstar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xstar as text
%        str2double(get(hObject,'String')) returns contents of xstar as a double
handles.xstar_m = str2double(get(hObject,'String'));
guidata(hObject,handles);
planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function xstar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ystar_Callback(hObject, eventdata, handles)
% hObject    handle to ystar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ystar as text
%        str2double(get(hObject,'String')) returns contents of ystar as a double
handles.ystar_m = str2double(get(hObject,'String'));
guidata(hObject,handles);
planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function ystar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ystar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstar_Callback(hObject, eventdata, handles)
% hObject    handle to zstar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zstar as text
%        str2double(get(hObject,'String')) returns contents of zstar as a double
handles.zstar_m = str2double(get(hObject,'String'));
guidata(hObject,handles);
planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function zstar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when selected object is changed in pcmethod.
function pcmethod_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pcmethod 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.strainmin,'Value')
    set(handles.selectpointsbutton,'Enable','on');
    set(handles.calibratebutton,'Enable','on');
    set(handles.naivebutton,'Enable','on');
    set(handles.pcplanefit,'Enable','on');
    set(handles.fromtiff,'Enable','off');
    set(handles.nofit,'Enable','on');
    if get(handles.fromtiff,'Value')
        set(handles.naivebutton,'Value',1)
    end
    handles.pcmethod = 'StrainMin';
elseif get(handles.tiffpc,'Value')
    set(handles.selectpointsbutton,'Enable','off')
    set(handles.calibratebutton,'Enable','on')
    set(handles.naivebutton,'Enable','off');
    set(handles.pcplanefit,'Enable','off');
    set(handles.fromtiff,'Enable','on');
    set(handles.fromtiff,'Value',1);
    set(handles.nofit,'Enable','off');
    handles.pcmethod = 'FromTiff';
else % Manual or from Scan file
    set(handles.selectpointsbutton,'Enable','off')
    set(handles.calibratebutton,'Enable','off')
    set(handles.naivebutton,'Enable','on');
    set(handles.pcplanefit,'Enable','off');
    set(handles.fromtiff,'Enable','off');
    set(handles.nofit,'Enable','on');
    if get(handles.pcplanefit,'Value') || get(handles.fromtiff,'Value')
        set(handles.naivebutton,'Value',1)
    end
end
if get(handles.scanfilepc,'Value')
    handles.pcmethod = 'FromFile';
end
if get(handles.manualpc,'Value')
    set(handles.xstar,'Enable','on');
    set(handles.ystar,'Enable','on');
    set(handles.zstar,'Enable','on');
    set(handles.xstar,'String',num2str(handles.xstar_m));
    set(handles.ystar,'String',num2str(handles.ystar_m));
    set(handles.zstar,'String',num2str(handles.zstar_m));
    handles.pcmethod = 'Manual';
else
    set(handles.xstar,'Enable','off');
    set(handles.ystar,'Enable','off');
    set(handles.zstar,'Enable','off');
end
planefitpanel_SelectionChangeFcn(handles.planefitpanel, eventdata, handles);

function setmanualpc(handles)
handles.xstar_m = str2double(get(handles.xstar,'String'));
handles.ystar_m = str2double(get(handles.ystar,'String'));
handles.zstar_m = str2double(get(handles.zstar,'String'));
guidata(handles.planefitpanel,handles);


% --------------------------------------------------------------------
function SettingsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SettingsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OptimizationMenu_Callback(hObject, eventdata, handles)
% hObject    handle to OptimizationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Create GUI
width = 280;
height = 80;
set(handles.PCCalGUI,'Units','pixels');
guipos = get(handles.PCCalGUI,'Position');
pos(1) = guipos(1) + (guipos(3)-width)/2;
pos(2) = guipos(2) + (guipos(4)-height)/2;
pos(3) = width;
pos(4) = height;
gui.f = figure('Visible','off','Position',pos,'MenuBar','none','Toolbar','none','name','Select Optimization Routine','NumberTitle','off');

mwidth = 150;
mheight = 25;
pos = [(width - mwidth)/2 (height-mheight)*(0.75) mwidth mheight];
gui.list = uicontrol(gui.f,'Style','popup','Position',pos,'String',{'fminsearch','pso'},'Tag','Optimization Routine');

pos(2) = (height-mheight)*(0.25);
guidata(gui.f,gui);
gui.button = uicontrol(gui.f,'Style','pushbutton','Position',pos,'String','Select','Tag',...
    'SelectionButton','Callback',{@OptSelect,guidata(gui.f)});
gui.f.Visible = 'on';

uiwait
if ishandle(gui.f)
    gui = guidata(gui.f);
    if isfield(gui,'Algorithm')
        handles.Algorithm = gui.Algorithm;
    end
    delete(gui.f);  
else
    handles.loadbutton.String = 'Load Material';
end
guidata(hObject,handles);

function OptSelect(hObject,eventdata,gui)
string = get(gui.list,'String');
value = get(gui.list,'Value');
gui.Algorithm = string{value};
guidata(hObject,gui);
gui.f.Visible = 'off';
uiresume
