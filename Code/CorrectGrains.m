clear Ftot Utot Rtot Rtot2 Utot2 g_GrainRef
subgrainPaths = Settings.subgrainPaths;
subgrainID = Settings.subgrainID;
subRefInd = Settings.subRefInd;

% Convert angles to Rotation Matrices
g = euler2gmat(Settings.NewAngles);
g0 = euler2gmat(Settings.Angles);

% Get Grains that have been split
Grains = find(~cellfun(@isempty,subgrainPaths));

% F = reshape(cell2mat(Settings.data.F),3,3,Settings.ScanLength);
F = Settings.data.F;
U = Settings.data.U;

I1 = ReadEBSDImage(Settings.ImageNamesList{1},Settings.ImageFilter);
[roixc,roiyc]= GetROIs(I1,Settings.NumROIs,Settings.PixelSize,Settings.ROISize,...
    Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;

F_corr = F;
U_corr = U;
g_corr = g;

CorrectionMiso = ones(Settings.ScanLength,1);
time1 = 0;
time2 = 0;
for j = 1:length(Grains)
    gID = Grains(j);
    if gID == 5
        a = 1;
    end
    grainRefInd = mean(Settings.RefInd(Settings.grainID==gID));
    subGrains = subgrainPaths{gID};
    for subgNum = 1:size(subGrains,1)
        subgID = subGrains{subgNum,1};
        path = subGrains{subgNum,2};
        subGrain = subgrainID == subgID;
        subGrainSize = sum(subGrain);
        subGrainRef = path(end);
        
        if subgID == 46
            a = 1;
        end
        
        RefImage = ReadEBSDImage(Settings.ImageNamesList{grainRefInd},Settings.ImageFilter);
        
        % Get Def Gradient Tensor from grain Reference Ind to subgrain Reference Ind (g_subRef = Rtot'*g_grainRef)
        Rref = eye(3);
        Fref = eye(3);
        for i = 2:length(path)
            RefInd = path(i-1);
            ScanInd = path(i);
            ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd},Settings.ImageFilter);
            clear global rs cs Gs
            Ftemp = CalcF(RefImage,ScanImage,g(:,:,RefInd),eye(3),ScanInd,Settings,Settings.Phase{ScanInd},RefInd);
            Fref = Fref*Ftemp;
            R = poldec(Ftemp);
            Rref = Rref*R;
            RefImage = ScanImage;
        end
        if grainRefInd ~= path(1)
            error('First index in the path should be the original reference image')
        end
        
        % Option 1
        o1 = tic;
        Fref = repmat(Fref,1,1,subGrainSize);
        F_subGrain = F(:,:,subGrain);
        Ftot = MatrixMult3D(Fref,F_subGrain);
        for i = 1:subGrainSize
            R(:,:,i) = poldec(F_subGrain(:,:,i)); % Same as R_subGrain
            [Rtot2(:,:,i),Utot2(:,:,i)] = poldec(Ftot(:,:,i));
        end
        g_GrainRef = repmat(g(:,:,grainRefInd),1,1,subGrainSize);
        g_subGrain_cor  = MatrixMult3D(permute(Rtot2,[2 1 3]),g_GrainRef);
        time1 = time1 + toc(o1);
        
        
        % Option 2 - Faster
        o2 = tic;
        [Rref, Uref] = poldec(Fref(:,:,1));
        Rref = repmat(Rref,1,1,subGrainSize);
        Uref = repmat(Uref,1,1,subGrainSize);
        g_subRef = repmat(g(:,:,subGrainRef),1,1,subGrainSize);
        g_subGrain = g(:,:,subGrain);
        R_subGrain = permute(MatrixMult3D(g_subGrain,permute(g_subRef,[2,1,3])),[2,1,3]);
        Rtot = MatrixMult3D(Rref,R_subGrain);
        U_subGrain = U(:,:,subGrain) + repmat(eye(3),1,1,subGrainSize);
        Utot = MatrixMult3D(Uref,U_subGrain);
        g_subGrain_cor2 = MatrixMult3D(permute(Rtot2,[2 1 3]),g(:,:,grainRefInd));
        time2 = time2 + toc(o2);
        
        % Calculate corrected orientation for subgrain Reference Ind
        g_subRef_cor = Rref(:,:,1)'*g(:,:,grainRefInd);
        CorrectionMiso(subGrain,1) = GeneralMisoCalc(g_subRef_cor(:,:,1),g(:,:,subGrainRef),'cubic');
        g_subRef_cor = repmat(g_subRef_cor,1,1,subGrainSize);
        g_subGrain_cor_alt = MatrixMult3D(permute(R_subGrain,[2 1 3]),g_subRef_cor);
        
        F_corr(:,:,subGrain) = Ftot;
        U_corr(:,:,subGrain) = Utot2;
        g_corr(:,:,subGrain) = g_subGrain_cor;
        
        clear Ftot Utot Rtot Rtot2 Utot2 g_GrainRef
        
        
    end
    
end

q0_old = euler2quat(Settings.Angles);
q_old = euler2quat(Settings.NewAngles);
q_new = rmat2quat(g);
q_cor = rmat2quat(g_corr);
q_symops = rmat2quat(permute(gensymops,[3 2 1]));
miso_correction = real(quatMisoSym(q_old,q_cor,q_symops,'element'))*180/pi;
miso_oim = real(quatMisoSym(q0_old,q_cor,q_symops,'element'))*180/pi;
miso_old_oim = real(quatMisoSym(q_old,q0_old,q_symops,'element'))*180/pi;
miso3 = real(quatMisoSym(q_cor,q_new,q_symops,'element'))*180/pi;
miso_new = real(quatMisoSym(q0_old,q_new,q_symops,'element'))*180/pi;

SettingsNew = Settings;
SettingsNew.data.F = F_corr;
SettingsNew.data.U = U_corr;
SettingsNew.data.g = rmat2euler(g_corr);

return;
Ind = 8;
Inds = Ind:-1:Ind-3;

Rref = eye(3);
Fref = eye(3);
g_new = zeros(3,3,length(Inds)-1);
g_new(:,:,1) = g0(:,:,Ind);
RefImage = ReadEBSDImage(Settings.ImageNamesList{Inds(1)},Settings.ImageFilter);
for i = 2:length(Inds)
    RefInd = Inds(i-1);
    ScanInd = Inds(i);
    ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd},Settings.ImageFilter);
    clear global rs cs Gs
    F_temp(:,:,i) = CalcF(RefImage,ScanImage,g0(:,:,RefInd),eye(3),ScanInd,Settings,Settings.Phase{ScanInd},RefInd);
    Fref = Fref*F_temp(:,:,i);
    R = poldec(F_temp(:,:,i));
    Rref = Rref*R;
    g_new(:,:,i) = R'*g_new(:,:,i-1);
    
    RefImage = ScanImage;
end
Rtot2 = poldec(Fref);
g2 = Rref'*g(:,:,Ind); % Same as g_new(:,:,end)
g3 = Rtot2'*g(:,:,Ind); % Same as g3



RefInd = Ind;
ScanInd = Inds(end);
RefImage = ReadEBSDImage(Settings.ImageNamesList{RefInd},Settings.ImageFilter);
ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd},Settings.ImageFilter);
gr = euler2gmat(Settings.Angles(RefInd,:));
clear global rs cs Gs
F_test = CalcF(RefImage,ScanImage,gr,eye(3),ScanInd,Settings,Settings.Phase{ScanInd},RefInd);
R = poldec(F_test);
g_test = R'*g(:,:,RefInd);

Ra = poldec(F(:,:,Inds(end)));
ga = Ra'*g(:,:,Inds(1));

% Test subgrain point
RefInd = Inds(end);
ScanInd = Inds(end)+1;
RefImage = ReadEBSDImage(Settings.ImageNamesList{RefInd});
ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd});
clear global rs cs Gs
F1 = CalcF(RefImage,ScanImage,g(:,:,Ind),eye(3),Inds(end),Settings,Settings.Phase{Inds(end)},Ind);
R = poldec(F1);
g_subg = R'*g(:,:,RefInd);
R2 = (g_subg*g(:,:,RefInd)')';
g_subg_cor = R'*g_new(:,:,end);

RefInd = Inds(1);
ScanInd = Inds(end)+1;
RefImage = ReadEBSDImage(Settings.ImageNamesList{RefInd});
ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd});
clear global rs cs Gs
F1 = CalcF(RefImage,ScanImage,g(:,:,Ind),eye(3),Inds(end),Settings,Settings.Phase{Inds(end)},Ind);
R = poldec(F1);
g_subg_cor_val = R'*g(:,:,RefInd);

