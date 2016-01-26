function [F, g, U, SSE, XX] = GetDefGradientTensor(ImageInd,Settings,curMaterial)
%GETDEFGRADIENTTENSOR
%[F g U SSE] = GetDefGradientTensor(ImageInd,Settings)
%Takes in the HREBSD Settings structure and the image index
%Calculates deformation gradient tensor F between the image and the chosen
%reference image, returns F, orientation (g), strain (U), and the error
%measure SSE.
%Jay Basinger, March 24 2011

%ImageInd is the index of the image(s) to use for comparison.
%% Read in the scan point's image. If L grid, read in legs as well.
DoLGrid = strcmp(Settings.ScanType,'L');
% fftw('wisdom',Settings.largefftmeth);
% disp(curMaterial)

XX = zeros(Settings.NumROIs,3);

if DoLGrid
    
    %the LImageNamesList field is a cell of length three containing the
    %L-grid image paths.
    ImagePaths = Settings.LImageNamesList(ImageInd,:);
    ImagePath = ImagePaths{2};
    LegAPath = ImagePaths{1};
    LegCPath = ImagePaths{3};
    if strcmp(Settings.ImageFilterType,'standard')
        ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
        LegAImage = ReadEBSDImage(LegAPath,Settings.ImageFilter);
        LegCImage = ReadEBSDImage(LegCPath,Settings.ImageFilter);
    else
        ScanImage = localthresh(ImagePath);
        LegAImage = localthresh(LegAPath);
        LegCImage = localthresh(LegCPath);
    end
    
    if isempty(ScanImage) || isempty(LegAImage) || isempty(LegCImage)
        
        F.a =  -eye(3); F.b = -eye(3); F.c = -eye(3); SSE.a = 101; SSE.b = 101;
        SSE.b = 101; U = -eye(3);
        g = euler2gmat(Angles(ImageInd,1),Angles(ImageInd,2),Angles(ImageInd,3));
        
        return;
    end
    
else
    
    ImagePath = Settings.ImageNamesList{ImageInd};
    if strcmp(Settings.ImageFilterType,'standard')
        ScanImage = ReadEBSDImage(ImagePath,Settings.ImageFilter);
    else
        ScanImage = localthresh(ImagePath);
    end
    g = euler2gmat(Settings.Angles(ImageInd,1) ...
        ,Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));
    if isempty(ScanImage)
        F = -eye(3); SSE = 101; U = -eye(3);
        return;
    end
    
end

%Initialize variables for params settings for calcFnew and genEBSDpattern

xstar = Settings.XStar(ImageInd);
ystar = Settings.YStar(ImageInd);
zstar = Settings.ZStar(ImageInd);

Av = Settings.AccelVoltage*1000; %put it in eV from KeV

sampletilt = Settings.SampleTilt;

elevang = Settings.CameraElevation;

pixsize = Settings.PixelSize;
Material = ReadMaterial(curMaterial);  % this should depend on the crystal structure maybe not here
paramspat={xstar;ystar;zstar;pixsize;Av;sampletilt;elevang;Material.Fhkl;Material.dhkl;Material.hkl};
% for new Dr. Fullwood condition

if strcmp(Settings.ROIStyle,'Intensity')
    %     Settings.NumROIs=25;% originally 36; if you comment this line out it reverts****
    %     Settings.ROISizePercent=15; % was 25% - seems way too big
    %     Settings.ROISize=round(Settings.ROISizePercent*pixsize/100);
    %     Settings.ROIStyle='Intensity'; % was 'Grid'; comment out to revert - but beware that grid always chooses 48 ROIs
    I1 = genEBSDPatternHybrid(g,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs); %use high intensity points in simulated image rather than real image to pick ROI points
    
    [roixc,roiyc]= GetROIs(I1,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
    
else
    [roixc,roiyc]= GetROIs(ScanImage,Settings.NumROIs,pixsize,Settings.ROISize,...
        Settings.ROIStyle);
    Settings.roixc = roixc;
    Settings.roiyc = roiyc;
%     if exist('Optimize.mat','file') > 0
%         load Optimize.mat
%         Settings.NumROIs
%         Settings.ROISizePercent
%         ROIXC = [ROIXC; roixc];
%         ROIYC = [ROIYC; roiyc];
%     else
%         ROIXC = roixc;
%         ROIYC = roiyc;
%     end
%     save('Optimize.mat', 'ROIXC', 'ROIYC');
end



%use only for optical distortion correction
% paramspat={xstar;ystar;zstar;round(pixsize*1.6613);Av;sampletilt;elevang;Fhkl;dhkl;hkl};
% crpl=206; crpu=824;


%Josh tended to use a reference orientation for all points within a grain
%for materials with low deformation. If it has a great deal of deformation
%this needs to be reconsidered.
% gr = euler2gmat(Settings.Phi1Ref(ImageInd),Settings.PHIRef(ImageInd),Settings.Phi2Ref(ImageInd));%% the most recent version - but gets messed up due to wrong ref orientation!!!!! hence changed to next line 7/24/14
gr=g;
% gr = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3));


%Get Reference Image depending on the chosen HROIM Method (so far these are
%either Simulated or Real. Plan on adding Sim/Real Hybrid
switch Settings.HROIMMethod
    
    case 'Dynamic Simulated'
        mperpix = Settings.mperpix;
        
        if Settings.SinglePattern
            RefImage = Settings.RefImage;
            clear global rs cs Gs
            [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,Settings.RefImageInd);
        else
            RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);

            clear global rs cs Gs
            [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial);

            for iq=1:3
                [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
                gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
                RefImage = genEBSDPatternHybrid_fromEMSoft(gr,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);

                clear global rs cs Gs
                [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial);
            end
            %%%%%
        end
        
    case 'Simulated'
        
        %         RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),lattice,al,bl,cl,axs); % testing next line instead *****
        RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
        %          RefImage = genEBSDPatternHybridMexHat(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
        
        %use following line only for optical distortion correction
        %    RefImage = RefImage(crpl:crpu,crpl:crpu);
        %         RefImage = genEBSDPattern(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
        
        RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
            Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));

        %Initialize
        clear global rs cs Gs
        [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial);
        
        %%%%New stuff to remove rotation error from strain measurement DTF  7/14/14
        for iq=1:2
            [rr,uu]=poldec(F1); % extract the rotation part of the deformation, rr
            gr=rr'*gr; % correct the rotation component of the deformation so that it doesn't affect strain calc
            RefImage = genEBSDPatternHybrid(gr,paramspat,eye(3),Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);
            RefImage = custimfilt(RefImage,Settings.ImageFilter(1), ...
                Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));
            
            clear global rs cs Gs
            [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial);
        end
        %%%%%
        
        %Improved convergence routine should replace this loop:
        
        for ii = 1:Settings.IterationLimit
            if SSE1 > 25 % need to make this a variable in the AdvancedSettings GUI
                if ii == 1
                    display(['Didn''t make it in to the iteration loop for:' Settings.ImageNamesList{ImageInd}])
                end
                g = euler2gmat(Settings.Angles(ImageInd,1),Settings.Angles(ImageInd,2),Settings.Angles(ImageInd,3)); 
                F = -eye(3); SSE = 101; U = -eye(3);
                return;
            end
            [r1,u1]=poldec(F1);
            U1=u1;
            R1=r1;
            FTemp=R1*U1; %**** isn't this just F1 - why did we bother doing this????
            
            
            NewRefImage = genEBSDPatternHybrid(gr,paramspat,FTemp,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);% correct method ******DTF changed to test new profiles             pattern *****
            %  NewRefImage = genEBSDPatternHybridmult(gr,paramspat,FTemp,lattice,al,bl,cl,axs);  % multiplied simulated approach
            %   NewRefImage = genEBSDPatternHybridMexHat(gr,paramspat,eye(3),lattice,al,bl,cl,axs);
            %             NewRefImage = genEBSDPatternProfileFnew(gr,paramspat,FTemp,lattice,al,bl,cl,axs,ScanImage);
            %              NewRefImage = genEBSDPatternHybridOwnWave(gr,paramspat,FTemp,lattice,al,bl,cl,axs);
            %             keyboard
            %Comment in this line only for optical distortion test: NewRefImage = NewRefImage(crpl:crpu,crpl:crpu);
            
            NewRefImage = custimfilt(NewRefImage, Settings.ImageFilter(1), Settings.PixelSize, ...
                Settings.ImageFilter(3), Settings.ImageFilter(4));
            %         keyboard
            clear global rs cs Gs
            [F1,SSE1,XX] = CalcF(NewRefImage,ScanImage,gr,FTemp,ImageInd,Settings,curMaterial);
            
        end
        
        
        
    case 'Real'
        %Find the grain of scan image and get the reference image for that
        %grain
        RefImagePath = Settings.RefImageNames{ImageInd}; % original line
        RefInd=Settings.RefInd(ImageInd);
        if strcmp(Settings.ImageFilterType,'standard')
            RefImage = ReadEBSDImage(RefImagePath,Settings.ImageFilter);
        else
            RefImage = localthresh(RefImagePath);
        end
        
        clear global rs cs Gs
%         disp(RefImagePath);
        [F1,SSE1,XX] = CalcF(RefImage,ScanImage,gr,eye(3),ImageInd,Settings,curMaterial,RefInd);
        
    case 'Hybrid'
        %Use simulated pattern method on one reference image then use
        %Real for all others in that grain.
        
        
end

%Calculate Mutual Information over entire Image
%XX.MI_total = CalcMutualInformation(RefImage,ScanImage);

if DoLGrid
    
    %For the leg points just set it to Real Sample all the
    %time
    KeepFCalcMethod = Settings.FCalcMethod;
    Settings.FCalcMethod = 'Real Sample';
    
    
    % evaluate point a using b as the reference
    clear global rs cs Gs
    [F.a SSE.a] = CalcF(ScanImage,LegAImage,gr,eye(3),ImageInd,Settings,curMaterial,ImageInd); %note - sending in index of scan point for now - no PC correction!!!
    
    % evaluate point c using b as the refrerence
    clear global rs cs Gs
    [F.c SSE.c] = CalcF(ScanImage,LegCImage,gr,eye(3),ImageInd,Settings,curMaterial,ImageInd);%note - sending in index of scan point for now - no PC correction!!!
    
    Settings.FCalcMethod = KeepFCalcMethod;
    
    F.b = F1;
    SSE.b = SSE1;
    
    [r.a u.a] = poldec(F.a);
    [r.b u.b] = poldec(F.b);
    [r.c u.c] = poldec(F.c);
    
    g.a = r.a'*gr;
    g.b = r.b'*gr;
    g.c = r.c'*gr;
    
    U.a = u.a;
    U.b = u.b;
    U.c = u.c;
else
    SSE = SSE1;
    [r u]=poldec(F1);
    U=u;
    R=r;
    F=r*u;
    g = R'*gr;
    U=U-eye(3); %*****used to send it back before subtracting I - is this a problem????
%     sum(sum(U.*U))
%     U(1,1)
%     U(3,3)
end

end

