classdef OXY < matlab.mixin.Copyable
    %OXY Handle Object that stores the Settings and data of OpenXY
    
    methods
        function obj = OXY
            %OXY Construct an instance of this class
            %   Should only be called by MainGUI at startup
            
            obj.subScanListener = addlistener(obj,'isSubScan','PostSet',...
                @(source,event) UpdateRefImageInds(obj));
            
            obj.grainRefListener = addlistener(obj,{'GrainRefImageType',...
                'MisoTol','KernelAvgMisoPath'},'PostSet',@(source,event)...
                UpdateRefImageInds(obj));
            obj.grainMethodListener = addlistener(obj,{'GrainMethod',...
                'MisoTol','MinGrainSize'},'PostSet',@(Source,event)...
                UpdateGrainID(obj));
            obj.PCListener = addlistener(obj,'PCInd','PostSet',...
                @(source,event) updatePC(obj));
        end
        
        function delete(obj)
            delete(obj.subScanListener);
            delete(obj.grainRefListener);
            delete(obj.grainMethodListener);
            delete(obj.PCListener);
        end
        
        function value = trueScanLength(obj)
            value = obj.hiddenScanLength;
        end
                
        UpdateRefImageInds(obj)
        
        UpdateGrainID(Settings)
        
        UpdatePC(Settings)
    end
    
    methods%Getters and Setters
        
        function value = get.PhosphorSize(obj)
            value = obj.mperpix * obj.PixelSize;
        end
        
        function value = get.ROISize(obj)
            value = round(obj.ROISizePercent/100 * obj.PixelSize);
        end
        
        function value = get.NumROIs(obj)
            if strcmp(obj.ROIStyle,'Grid')
                value = 48;
            else
                value = obj.hiddenNumROI;
            end
        end
        
        function set.NumROIs(obj,value)
            obj.hiddenNumROI = value;
        end
        
        function value = get.grainID(obj)
            if ~obj.isSubScan
                value = obj.hiddengrainID;
            else
                value = obj.hiddengrainID(obj.Inds);
            end
        end
        
        function set.grainID(obj,value)
            obj.hiddengrainID = value;
        end
        
        function value = get.ScanLength(obj)
            if ~obj.isSubScan
                value = obj.hiddenScanLength;
            else
                value = obj.hiddenScanLength(obj.Inds);
            end
        end
        
        function set.ScanLength(obj,value)
            obj.hiddenScanLength = value;
        end
        
        function value = get.Angles(obj)
            if ~obj.isSubScan
                value = obj.hiddenAngles;
            else
                value = obj.hiddenAngles(obj.Inds,:);
            end
        end
        
        function set.Angles(obj,value)
            obj.hiddenAngles = value;
        end
        
        function value = get.XData(obj)
            if ~obj.isSubScan
                value = obj.hiddenXData;
            else
                value = obj.hiddenXData(obj.Inds);
            end
        end
        
        function set.XData(obj,value)
            obj.hiddenXData = value;
        end
        
        function value = get.YData(obj)
            if ~obj.isSubScan
                value = obj.hiddenYData;
            else
                value = obj.hiddenYData(obj.Inds);
            end
        end
        
        function set.YData(obj,value)
            obj.hiddenYData = value;
        end
        
        function value = get.IQ(obj)
            if ~obj.isSubScan
                value = obj.hiddenIQ;
            else
                value = obj.hiddenIQ(obj.Inds);
            end
        end
        
        function set.IQ(obj,value)
            obj.hiddenIQ = value;
        end
        
        function value = get.CI(obj)
            if ~obj.isSubScan
                value = obj.hiddenCI;
            else
                value = obj.hiddenCI(obj.Inds);
            end
        end
        
        function set.CI(obj,value)
            obj.hiddenCI = value;
        end
        
        function value = get.Fit(obj)
            if ~obj.isSubScan
                value = obj.hiddenFit;
            else
                value = obj.hiddenFit(obj.Inds);
            end
        end
        
        function set.Fit(obj,value)
            obj.hiddenFit = value;
        end
        
        function value = get.Phase(obj)
            if ~obj.isSubScan
                value = obj.hiddenPhase;
            else
                value = obj.hiddenPhase(obj.Inds);
            end
        end
        
        function set.Phase(obj,value)
            obj.hiddenPhase = value;
        end
        
        function value = get.XStar(obj)
            if ~obj.isSubScan
                value = obj.hiddenXStar;
            else
                value = obj.hiddenXStar(obj.Inds);
            end
        end
        
        function set.XStar(obj,value)
            obj.hiddenXStar = value;
        end
        
        function value = get.YStar(obj)
            if ~obj.isSubScan
                value = obj.hiddenYStar;
            else
                value = obj.hiddenYStar(obj.Inds);
            end
        end
        
        function set.YStar(obj,value)
            obj.hiddenYStar = value;
        end
        
        function value = get.ZStar(obj)
            if ~obj.isSubScan
                value = obj.hiddenZStar;
            else
                value = obj.hiddenZStar(obj.Inds);
            end
        end
        
        function set.ZStar(obj,value)
            obj.hiddenZStar = value;
        end
        
        function set.ImageNamesList(obj,value)
            obj.hiddenImageNamesList = value;
        end
        
        function value = get.ImageNamesList(obj)
            if ~obj.isSubScan
                value = obj.hiddenImageNamesList;
            else
                value = obj.hiddenImageNamesList(obj.Inds);
            end
        end
        
        function set.RefInd(obj,inds)
            obj.UpdateRefImageInds
            if isrow(inds);inds = inds';end
            [Grains,GrainInds,ic] = unique(obj.grainID);
            GrainRefInds = obj.hiddenRefInd(GrainInds);
            Grain = obj.grainID(inds);
            EmptyGrains = Grains(~ismember(Grains,Grain));
            [~,sortI] = sort([Grain;EmptyGrains]);
            IndsAll = [inds; GrainRefInds(EmptyGrains)];
            IndsAll = IndsAll(sortI);
            
            obj.hiddenRefInd = IndsAll(ic);
        end
        
        function value = get.RefInd(obj)
            if obj.RefImageInd == 0
                value = obj.hiddenRefInd;
            else
                value(1:obj.ScanLength) = obj.RefImageInd;
            end
        end
                
    end
    
    events
        
        grainReffEvent
        
        grainMethodEvent
        
        PCEvent
    end
    
    properties %General Properties
        
        %The Path of the scan file 
        %   The scan file is the scan produced by either OIM or AZTEK(.ang,
        %   .ctf of .h5)
        ScanFilePath@char
        
        %The Path of the first image of the scan
        %   This should be the the file corisponding to the first image in
        %   the scan
        FirstImagePath@char
        
        %The Path where the results will be saved
        OutputPath@char
        
        %The type of scan, either 'Square' or 'Hexagonal'
        ScanType@char = 'Square'
        
        %The Material of the scan. If 'Scan File' is selected, material will be read from the scan file
        Material@char = 'Scan File'
        
        %The number of workers used for parallel processing. Defaults to one less than the available cores
        DoParallel@double scalar = feature('numCores')-1
        
        %If true, Shifts will be visualized during cross-corelation
        DoShowPlot@logical = false
        
        %If true, there is scan info saved in the .TIFF file
        ImageTag@logical = false
        
        %If true, will display GUI elements during computations
        DisplayGUI@logical = true
        
        Nx@double scalar
        Ny@double scalar
        
        
        DoStrain@logical = true
        IterationLimit@double scalar = 6
        
        StandardDeviation@double scalar = 2
                
        GNDMethod@char = 'Full'
        NumSkipPts@double scalar = 0
        IQCutoff@double scalar = 0
        
        
        DoDDS@logical = false
        DDSMethod@char = 'Nye-Kroner'
        
        EnableProfiler@logical = false
        
        %TODO make this a dependant variable
        PlaneFit@char = 'Naive'
        
        %A Cell array that contains the various PC Calibrations
        %   The cell contains the different PC calibrations stored in the
        %   rows of the cell array in the form:
        %   {Xstar,Ystar,Zstar,type,plane fit type,name,data}
        PCList@cell matrix
                
                
        HREBSDPrep@logical = false
        CalcMI@logical
                
        ScanParams@struct
        GrainVals@struct
        PixelSize@double scalar
        imsize@double vector
        Inds@double vector
                
        DoUsePCFile@logical = false
        PCFilePath@char 
        FCalcMethod@char = 'Collin Crystal'
        largefftmeth@char
        
        oldSize
        
        %For OIM H5 files in the hexGrid style, validity of each data point
        %   The way hexagonal scans are saved in H5 files, there is a dummy
        %   value saved in the 'hole' on the end of odd columns. This is a
        %   vector of logicals that tell wether or not a point is a valid
        %   point or a dummy value. This is only currently saved because it
        %   is needed to read the patterns from the H5 file. If a more
        %   elegant solution is come up with, this variable can be gotten
        %   rid of.
        valid@logical vector
        
    end
    
    properties (SetObservable = true, AbortSet = true) 
        
        %Electron acceleration voltage
        %   The acceleration voltage of the microscope scan used, in
        %   kiloelectronvolts
        AccelVoltage@double scalar = 20
        %The Tilt of the material sample
        %   The angle of the sample tilt, endited in Microscope Settings in
        %   degrees, but storted in radians. Typicaly 70 degrees.
        SampleTilt@double scalar = 70*pi/180
        SampleAzimuthal@double scalar = 0
        CameraElevation@double scalar = 10*pi/180
        CameraAzimuthal@double scalar = 0
        mperpix@double scalar = 25
        
        ROISizePercent@double scalar = 25
        ROIStyle@char = 'Grid'
        ROIFilter@double vector = [2 50 1 1]
        ImageFilterType@char = 'standard'
        ImageFilter@double vector = [9 90 0 0]
        %Index to single refference immage
        %   If zero, RefInds is used
        RefImageInd@double scalar = 0

        isSubScan@logical = false
        
        CalcDerivatives@logical = false
        %The method used to select the reference image in each grain
        %   Available methods:
        %   -Min Kernel Avg Miso
        %   -IQ > Fit > CI
        %   -Manual(this one should go away)
        GrainRefImageType@char = 'IQ > Fit > CI'
        
        GrainMethod@char = 'Grain File'
        MisoTol@double scalar = 5
        MinGrainSize@double scalar = 0
        KernelAvgMisoPath@char
        
        PCInd@double scalar = 1;
        
    end
    
    properties (SetObservable = true)
        
        %The Method used to compute the deformation gradient tenso
        %   -Simulated:
        %   -Dynamic Simulated:
        %   -Real:
        HROIMMethod@char = 'Real'
        
    end
    
    properties (Dependent = true)
        
        PhosphorSize
        ROISize
        
        grainID@double vector
        ScanLength@double scalar
        Angles@double matrix
        XData@double vector
        YData@double vector
        IQ@double vector
        CI@double vector
        Fit@double vector
        Phase@cell vector
        XStar@double vector
        YStar@double vector
        ZStar@double vector
        ImageNamesList@cell vector
        RefInd@double vector
        
    end
    
    
    properties (Dependent = true, SetObservable = true, AbortSet = true)
        
        NumROIs

    end
    
    properties (Access = protected, Hidden = true)
        
        hiddenNumROI@double scalar = 48
        
        
        hiddengrainID
        hiddenScanLength@double scalar
        hiddenAngles@double matrix
        hiddenXData@double vector
        hiddenYData@double vector
        hiddenIQ@double vector
        hiddenCI@double vector
        hiddenFit@double vector
        hiddenPhase@cell vector
        hiddenXStar@double vector
        hiddenYStar@double vector
        hiddenZStar@double vector
        hiddenImageNamesList@cell vector
        hiddenRefInd@double vector
        
        subScanListener
        grainRefListener
        grainMethodListener
        PCListener
    end
    
end

