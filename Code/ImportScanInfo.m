function Settings = ImportScanInfo(Settings,name,path)
%Read Scan File
switch nargin
    case 1
        [name,path] = uigetfile({'*.ang;*.ctf','Scan Files (*.ang,*.ctf)';'*.h5','OIM HDF5 Files (*.h5)'},'Select a Scan File');
        ScanPath = fullfile(path,name);
    case 2
        ScanPath = name;
    otherwise
        ScanPath = fullfile(path,name);
end
[~,~,ext] = fileparts(ScanPath);

%Normal Scan File
if ~strcmp(ext,'.h5')
    if ~isfield(Settings,'Angles') || ~strcmp(Settings.ScanFilePath,ScanPath)
        
        [ScanFileData,Settings.ScanParams,Settings.GrainVals] = ReadScanFile(ScanPath,Settings);
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
        Settings.ScanFilePath = ScanPath;
        
        %Unique x and y
        [X, iaX, icX] = unique(Settings.XData);
        [Y, iaY, icY] = unique(Settings.YData);

        
        %Number of steps in x and y
        Nx = iaX(end);
        Ny = length(Y);
        Settings.Nx = Nx; Settings.Ny = Ny;
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
                    else
                        Settings.ScanParams.OriginalSize = [NumColsOdd, NumRows];
                        Settings.ScanParams.NumColsOdd = Nx;
                        Settings.ScanParams.NumColsEven = Nx - 1;
                        Settings.ScanParams.NumRows = Ny;
                    end
                end
            end
            Settings.Nx = Nx; Settings.Ny = Ny;
            
            %OIM Files
            if ~strcmp(ext,'.ctf')
                %Check ScanType
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
                Settings.GrainMethod = 'Grain File'; %Default method
                
            %Oxford HKL Files
            else
                Settings.GrainMethod = 'Find Grains'; %Only method available
                
                Settings.GrainVals.grainID = CalcGrainID(Settings);
            end
        end
        
        % Hexagonal Scans
        if strcmp(Settings.ScanType, 'Hexagonal')
            if isfield(Settings.ScanParams,'NumColsOdd') && isfield(Settings.ScanParams,'NumRows')
                Settings.Nx = Settings.ScanParams.NumColsOdd;
                Settings.Ny = Settings.ScanParams.NumRows;
            else
                Settings.Nx = ceil(Nx/2); %NumRowsOdd
                Settings.Ny = Ny;
            end
        end
    end
else
    [Settings, Settings.ScanParams, Material] = ReadHDF5(Settings,ScanPath);
end
if ~exist('grainID','var')
Settings.grainID = CalcGrainID(Settings);
end
%Save GrainVals
Settings.grainID = Settings.GrainVals.grainID;
Settings.Phase = Settings.GrainVals.Phase;

%Merge Materials
if exist('Material','var')
    Material = CompareMats(Material);
    Settings.Material = Material.Material;
end

%Crop Scan
Settings = CropScan(Settings);
if length(Settings.grainID) ~= length(Settings.XData)
    error('Grain file and Scan file have a different number of points')
end

end


