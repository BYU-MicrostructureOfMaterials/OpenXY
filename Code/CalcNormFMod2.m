function [normF U] = CalcNormFMod2(PC,I0,params2,lattice,a1,b1,c1,axs,g,X,ImageInd,Settings)

params2{1} = PC(1);
params2{2} = PC(2);
params2{3} = PC(3);
mperpix=PC(4);
PhosphorSize=mperpix*Settings.PixelSize;
standev = Settings.StandardDeviation;
ROISize = Settings.ROISize;
sampleTilt = params2{6};
pixelSize = params2{4};

normF=0;
for kk=1:length(ImageInd)
    Ind=ImageInd(kk);
    params2{1} = PC(1)-(Settings.XData(Ind)-Settings.XData(ImageInd(1)))/PhosphorSize;
params2{2} = PC(2)+(Settings.YData(Ind)-Settings.YData(ImageInd(1)))/PhosphorSize*sin(Settings.SampleTilt-Settings.CameraElevation);
params2{3} = PC(3)+(Settings.YData(Ind)-Settings.YData(ImageInd(1)))/PhosphorSize*cos(Settings.SampleTilt-Settings.CameraElevation);

F = eye(3);

clear global rs cs Gs

% I2 = genEBSDPatternHybrid(g,params2,F,lattice,a1,b1,c1,axs);
switch Settings.HROIMMethod
    
    case 'Dynamic Simulated'
        xstar=PC(1);
        ystar=PC(2);
        zstar=PC(3);
        pixsize=cell2mat(params2(4));
        Av=cell2mat(params2(5));
        elevang=cell2mat(params2(7));
        mperpix = Settings.mperpix;
        curMaterial=cell2mat(Settings.Phase(Ind)); %****may need updating for material of this point - where is that info?
        for i = 1:3
            I1 = genEBSDPatternHybrid_fromEMSoft(g,xstar,ystar,zstar,pixsize,mperpix,elevang,curMaterial,Av);
            
            clear global rs cs Gs
            %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material); % old version
            [F SSE] = CalcF(I1,I0,g,eye(3),Ind,Settings,...
                Settings.Phase{Ind},0,PC,Settings.roixc,Settings.roiyc,...
                Settings.ROIFilter,ROISize,standev,sampleTilt,pixelSize); % new DTF
            [R U] = poldec(F);
            g=R'*g;
        end
        
    otherwise
        % Remove rotational error first DTF 7/15/14
        for i = 1:3
            I1 = genEBSDPatternHybrid(g,params2,eye(3),lattice,a1,b1,c1,axs);
            I1 = custimfilt(I1,X(1),Settings.PixelSize,X(3),X(4));
            clear global rs cs Gs
            %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material); % old version
            [F SSE] = CalcF(I1,I0,g,eye(3),Ind,Settings,...
                Settings.Phase{Ind},0,PC,Settings.roixc,Settings.roiyc,...
                Settings.ROIFilter,ROISize,standev,sampleTilt,pixelSize); % new DTF
            [R U] = poldec(F);
            g=R'*g;
        end
        F=eye(3);
        % for i = 1:Settings.IterationLimit
        for i = 1:3
            I1 = genEBSDPatternHybrid(g,params2,F,lattice,a1,b1,c1,axs);
            I1 = custimfilt(I1,X(1),Settings.PixelSize,X(3),X(4));
            
            %Optical Distortion Only
            %  crpl=206; crpu=824;
            %  I1 = I1(crpl:crpu,crpl:crpu);
            clear global rs cs Gs
            %     [F SSE] = calcFnew(I1,I0,g,F,paramsF,standev,6);
            %     [F SSE] = CalcF(I1,I0,g,F,ImageInd,Settings,Settings.Material);% ** same change as above DTF 7/21/14
            [F SSE] = CalcF(I1,I0,g,F,Ind,Settings,...
                Settings.Phase{Ind},0,PC,Settings.roixc,Settings.roiyc,...
                Settings.ROIFilter,ROISize,standev,sampleTilt,pixelSize);
        end
        
        [R U] = poldec(F);
end

U=U-eye(3);
U = triu(U);
% D = F-eye(3);

% angle = GeneralMisoCalc(R,eye(3),lattice);

% if angle >= 0.5
%     normF = sum(sum((D.*D)));
% else
%normF = sum(sum((U.*U))); experimentally removed by Craig and Tim and replaced by below, Aug27 2014
normFtemp=sum(sum((U.*U)));
% end

% disp(F)
% disp(U)
% disp(PC)
% disp(SSE)
% disp(angle)

% save I2 I2
% keyboard
normF=normF+normFtemp;
end
