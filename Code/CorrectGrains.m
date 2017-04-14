%The Parameters of Calc F have changed, but I did not updaate this file
%script accordingly. It will need to be adjusted to work properly ZRC -
%4/14/2017
g = euler2gmat(Settings.NewAngles);
Grains = find(~cellfun(@isempty,subGrainPaths));
% F = reshape(cell2mat(Settings.data.F),3,3,Settings.ScanLength);
F = Settings.data.F;
for j = 1:length(Grains)
    gID = Grains(j);
    grainRefInd = mean(subgrainRefs(subgrainID==gID));
    subGrains = subGrainPaths{gID};
    for subgNum = 1:size(subGrains,1)
        subgID = subGrains{subgNum,1};
        path = subGrains{subgNum,2};
        subGrain = subgrainID == subgID;
        subGrainSize = sum(subGrain);
        subGrainRef = path(end);
        
        RefImage = ReadEBSDImage(Settings.ImageNamesList{Ind},Settings.ImageFilter);
        Rtot = eye(3);
        for i = 2:length(path)
            RefInd = path(i-1);
            ScanInd = path(i);
            PC = [Settings.XStar(ScanInd) Settings.YStar(ScanInd) Settings.ZStar(ScanInd)];
            ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd},Settings.ImageFilter);
            Ftemp = CalcF(RefImage,ScanImage,g(:,:,RefInd),eye(3),ScanInd,Settings,Settings.Phase{ScanInd},RefInd,PC);
            R = poldec(Ftemp);
            Rtot = Rtot*R;
            RefImage = ScanImage;
        end
        if grainRefInd ~= path(1)
            error('First index in the path should be the original reference image')
        end
        g_subRef_cor = Rtot'*g(:,:,grainRefInd);
        g_subRef_cor = repmat(g_subRef_cor,1,1,subGrainSize);
        g_subRef = repmat(g(:,:,subGrainRef),1,1,subGrainSize);
        g_subGrain = g(:,:,subGrain);
        R_subGrain = permute(MatrixMult3D(g_subGrain,permute(g_subRef,[2,1,3])),[2,1,3]);
        F_subGrain = F(:,:,subGrain);
        for i = 1:subGrainSize
            R(:,:,i) = poldec(F_subGrain(:,:,i));
        end
        g_subGrain_cor = MatrixMult3D(permute(R_subGrain,[2 1 3]),g_subRef_cor);
    end
    
end
Ind = 54;
Inds = Ind:Ind+3;

RefImage = ReadEBSDImage(Settings.ImageNamesList{Ind});
[roixc,roiyc]= GetROIs(RefImage,Settings.NumROIs,Settings.PixelSize,Settings.ROISize,...
        Settings.ROIStyle);
Settings.roixc = roixc;
Settings.roiyc = roiyc;

Rtot = eye(3);
g_new = zeros(3,3,length(Inds)-1);
g_new(:,:,1) = g(:,:,Ind);
for i = 2:length(Inds)
    RefInd = Inds(i-1);
    ScanInd = Inds(i);
    PC = [Settings.XStar(ScanInd) Settings.YStar(ScanInd) Settings.ZStar(ScanInd)];
    ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd});
    F = CalcF(RefImage,ScanImage,g(:,:,RefInd),eye(3),ScanInd,Settings,Settings.Phase{ScanInd},RefInd,PC);
    R = poldec(F);
    Rtot = Rtot*R;
    g_new(:,:,i) = R'*g_new(:,:,i-1);
    
    RefImage = ScanImage;
end
g2 = Rtot'*g(:,:,Ind);

RefInd = Ind;
ScanInd = Inds(end);
RefImage = ReadEBSDImage(Settings.ImageNamesList{RefInd});
ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd});
PC = [Settings.XStar(Inds(end)) Settings.YStar(Inds(end)) Settings.ZStar(Inds(end))];
F_test = CalcF(RefImage,ScanImage,g(:,:,Ind),eye(3),Inds(end),Settings,Settings.Phase{Inds(end)},Ind,PC);
R = poldec(F_test);
g_test = R'*g(:,:,RefInd);

% Test subgrain point
RefInd = Inds(end);
ScanInd = Inds(end)+1;
RefImage = ReadEBSDImage(Settings.ImageNamesList{RefInd});
ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd});
PC = [Settings.XStar(RefInd) Settings.YStar(RefInd) Settings.ZStar(RefInd)];
F = CalcF(RefImage,ScanImage,g(:,:,Ind),eye(3),Inds(end),Settings,Settings.Phase{Inds(end)},Ind,PC);
R = poldec(F);
g_subg = R'*g(:,:,RefInd);
R2 = (g_subg*g(:,:,RefInd)')';
g_subg_cor = R'*g_new(:,:,end);

RefInd = Inds(1);
ScanInd = Inds(end)+1;
RefImage = ReadEBSDImage(Settings.ImageNamesList{RefInd});
ScanImage = ReadEBSDImage(Settings.ImageNamesList{ScanInd});
PC = [Settings.XStar(Inds(end)) Settings.YStar(Inds(end)) Settings.ZStar(Inds(end))];
F = CalcF(RefImage,ScanImage,g(:,:,Ind),eye(3),Inds(end),Settings,Settings.Phase{Inds(end)},Ind);
R = poldec(F);
g_subg_cor_val = R'*g(:,:,RefInd);

