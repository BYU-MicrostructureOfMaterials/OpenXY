classdef OXY < matlab.mixin.Copyable
    %OXY Handle Object that stores the Settings and data of OpenXY
        
    properties
        
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
        DoParallel@double scalar =feature('numCores')-1
        
        %If true, Shifts will be visualized during cross-corelation
        DoShowPlot@logical = false
        
        %If true, there is scan info saved in the .TIFF file
        ImageTag@logical = false
        
        %If true, will display GUI elements during computations
        DisplayGUI@logical = true
              
        DoStrain@logical = true
        HROIMMethod@char = 'Real'
        IterationLimit@double scalar = 6
        RefImageInd@double scalar = 0
        StandardDeviation@double scalar = 2
        MisoTol@double scalar = 5
        GrainRefImageType@char = 'IQ > Fit > CI'
        GrainMethod@char = 'Grain File'
        MinGrainSize@double scalar = 0
                
        CalcDerivatives@logical = false
        GNDMethod@char = 'Full'
        NumSkipPts@double scalar = 0
        IQCutoff@double scalar = 0
        
        
        DoDDS@logical = false
        DDSMethod@char = 'Nye-Kroner'
        
        
        KernelAvgMisoPath@char
        
        
        EnableProfiler@logical = false
                
        PlaneFit@char = 'Naive'
        PCList@cell matrix
        XStar@double vector
        YStar@double vector
        ZStar@double vector
                
                
        HREBSDPrep@logical = false
        CalcMI@logical
                
        ScanParams@struct
        GrainVals@struct
        ScanLength@double scalar
        Angles@double matrix
        XData@double vector
        YData@double vector
        IQ@double vector
        CI@double vector
        Fit@double vector
        Nx@double scalar
        Ny@double scalar
        grainID@double vector
        Phase@cell vector
        PixelSize@double scalar
        imsize@double vector
        ImageNamesList@cell vector
        Inds@double vector
        RefInd@double vector
                
        DoUsePCFile@logical = false
        PCFilePath@char 
        FCalcMethod@char = 'Collin Crystal'
        largefftmeth@char
        
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
        
    end
    
    properties (Dependent = true)
        
        PhosphorSize
        ROISize
        
    end
    
    properties (Dependent = true, SetObservable = true)
        
        NumROIs

    end
    
    properties (Access = protected, Hidden = true)
        hiddenNumROI@double scalar = 48
    end
    
    events
        
        
    end
    
    
    methods
        function obj = OXY
            %OXY Construct an instance of this class
            %   Should only be called by MainGUI at startup
        end
        
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
        
    end
end

