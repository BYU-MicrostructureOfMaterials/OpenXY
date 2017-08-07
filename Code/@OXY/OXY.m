classdef OXY < handle
    %OXY Handle Object behind OpenXY
    
    properties
        ScanFilePath@char
        FirstImagePath@char 
        OutputPath@char
        ScanType@char = 'Square'
        Material@char = 'Scan File'
        DoParallel@double scalar = feature('numCores')-1
        DoShowPlot@logical
        ImageTag@logical
        DisplayGUI@logical
        ROISizePercent@double scalar
        NumROIs@double scalar
        ROIStyle@char
        ROIFilter@double vector
        ImageFilterType@char
        ImageFilter@double vector
        DoStrain@logical
        HROIMMethod@char
        IterationLimit@double scalar
        RefImageInd@double scalar
        StandardDeviation@double scalar
        MisoTol@double scalar
        GrainRefImageType@char
        GrainMethod@char
        MinGrainSize@double scalar
        CalcDerivatives@logical
        GNDMethod@char
        NumSkipPts@double scalar
        IQCutoff@double scalar
        DoDDS@logical
        DDSMethod@char
        KernelAvgMisoPath@char
        EnableProfiler@logical
        PlaneFit@char
        AccelVoltage@double scalar
        SampleTilt@double scalar
        SampleAzimuthal@double scalar
        CameraElevation@double scalar
        CameraAzimuthal@double scalar
        mperpix@double scalar
        HREBSDPrep@logical
        DoUsePCFile@logical
        PCFilePath@char
        FCalcMethod@char
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
        ROISize@double scalar
        PhosphorSize@double scalar
        imsize@double vector
        ImageNamesList@cell vector
        PCList@cell matrix
        XStar@double vector
        YStar@double vector
        ZStar@double vector
        largefftmeth@char
        Inds@double vector
        RefInd@double vector
    end
    
    methods
        function obj = OXY
            %OXY Construct an instance of this class
            %   Should only be called by MainGUI at startup
        end
        
        function obj2 = createCopy(obj)
            
        end
        
    end
end

