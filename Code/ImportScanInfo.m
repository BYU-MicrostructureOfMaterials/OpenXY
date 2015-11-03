function Settings = ImportScanInfo(Settings,name,path)

%Read Scan File
if ~isfield(Settings,'Angles')

    [ScanFileData,Settings.ScanParams] = ReadScanFile(fullfile(path,name));

    %Initialize Variables
    Settings.ScanLength = size(ScanFileData{1},1);
    Settings.Angles = zeros(Settings.ScanLength,3);
    Settings.XData = zeros(Settings.ScanLength,1);
    Settings.YData = zeros(Settings.ScanLength,1);
    Settings.IQ = zeros(Settings.ScanLength,1);
    Settings.CI = zeros(Settings.ScanLength,1);
    Settings.Fit = zeros(Settings.ScanLength,1);

    %Read ScanFile Data into Settings
    Settings.Angles(:,1) = ScanFileData{1};
    Settings.Angles(:,2) = ScanFileData{2};
    Settings.Angles(:,3) = ScanFileData{3};
    Settings.XData = ScanFileData{4};
    Settings.YData = ScanFileData{5};
    Settings.IQ = ScanFileData{6};
    Settings.CI = ScanFileData{7};
    Settings.Fit = ScanFileData{10};
    Settings.ScanFilePath = fullfile(path,name);
end

%Check ScanType
[~,~,ext] = fileparts(fullfile(path,name));
if strcmp(ext,'.ang')
check = true;
if ~isempty(strfind(Settings.ScanParams.GridType,'Hex'))
    AutoType = 'Hexagonal';
elseif ~isempty(strfind(Settings.ScanParams.GridType,'Sqr'))
    AutoType = 'Square';
else
    check = false;
end
    if check && ~strcmp(Settings.ScanType,AutoType)
        button = questdlg({'Scan type might be incorrect.';['Would you like to change it to ' AutoType '?']},'OpenXY');
        switch button
            case 'Yes'
                Settings.ScanType = AutoType;
            case 'Cancel'
                return;
        end
    end
end

%Unique x and y
X = unique(Settings.XData);
Y = unique(Settings.YData);

%Number of steps in x and y
Nx = length(X);
Ny = length(Y);

%Validate Scan Size
if ~strcmp(Settings.ScanType,'Hexagonal')
    if isfield(Settings.ScanParams,'NumColsOdd') && isfield(Settings.ScanParams,'NumRows')
        if Nx ~= Settings.ScanParams.NumColsOdd || Ny ~= Settings.ScanParams.NumRows
            
            NumColsOdd = Settings.ScanParams.NumColsOdd;
            NumRows = Settings.ScanParams.NumRows;
            ScanP = [num2str(NumColsOdd) 'x' num2str(NumRows)];
            Auto =  [num2str(Nx) 'x' num2str(Ny)];
            choice = questdlg({'Scan dimensions do not agree:';
                ['Scan File Header: ' ScanP];
                ['Unique values: ' Auto];
                'Select correct values'},'Scan Dimension Differ',ScanP,Auto,Auto);

            if strcmp(choice,ScanP)
                Nx = NumColsOdd;
                Ny = NumRows;
                set(ScanSizeText,'String',ScanP);
            else
                Settings.ScanParams.OriginalSize = [NumColsOdd, NumRows];
                Settings.ScanParams.NumColsOdd = Nx;
                Settings.ScanParams.NumColsEven = Nx - 1;
                Settings.ScanParams.NumRows = Ny;
            end
        end   
    end
    Settings.Nx = Nx; Settings.Ny = Ny;
else   
    if isfield(Settings.ScanParams,'NumColsOdd') && isfield(Settings.ScanParams,'NumRows')
        Settings.Nx = Settings.ScanParams.NumColsOdd;
        Settings.Ny = Settings.ScanParams.NumRows;
    else
        Settings.Nx = ceil(Nx/2); %NumRowsOdd
        Settings.Ny = Ny;
    end
end

%Crop Scan
Settings = CropScan(Settings);
