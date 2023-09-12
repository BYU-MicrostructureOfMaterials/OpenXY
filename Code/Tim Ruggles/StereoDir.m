%
% Calculates the IPF colors for orientations expressed as passive rotation
% matrices. Color is a  function of sample direction for cubic crystals,
% mimicking the color mapping of OIM analysis.
%
% INPUTS
% mats      - 3x3xN array. Each slice contains a passive rotation matrix
%             representing the orientation of a cubic crystal
% symops    - 3x3x24 array. Contains the 24 symmetry operations for a cubic
%             crystal
% sampledir - 1x3 or 3x1 array. The sample direction used to define the IPF
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sd = StereoDir(mats,symops,sampledir)
    
    N = length(mats(1,1,:));
    rgb = zeros(N,3);
    
    stackedMats = reshape(permute(mats, [2 1 3]), size(mats, 2), [])';
    stackedSymops = reshape(permute(symops, [2 1 3]), size(symops, 2), [])';
    
    dirs_nosymm = stackedMats*sampledir(:);
    dirs_nosymm = reshape(dirs_nosymm,3,[]);
    
    dirs = stackedSymops*dirs_nosymm;
    dirs = reshape(dirs,3,[]);
    
    %Flip directions that are in negative hemisphere
    toFlip = dirs(3,:)<0;
    dirs(:,toFlip) = dirs(:,toFlip)*-1;

    %find directions within correct azimuth angle
    xyPlaneNorms = sqrt( (dirs(1,:).^2) + (dirs(2,:).^2) );
    azcosine = dirs(1,:)./xyPlaneNorms;
    azcosine(dirs(1,:)==0 & xyPlaneNorms == 0) = 1;
    azimuth = acos(azcosine);
    negativeY = dirs(2,:)<0;
    azimuth(negativeY) = (2*pi) - azimuth(negativeY);
    inAzRange = and(azimuth>=-2e-16,azimuth<(pi/4+2e-16));

    %find directions that point to postive side of -1 0 1 plane
    dotProducts = [-1 0 1]*dirs;
    correctHemispheres = dotProducts>-2e-16;

    %Find dir that lies in standard steriographic triangle
    inRange = and(inAzRange,correctHemispheres);
    
    %Checking for duplicates
    nsymops = size(symops,3);
    for i=1:N
        checkforhit = 0;
        for j=1:nsymops
            if inRange((i-1)*nsymops+j) == 1
                if checkforhit == 0
                    checkforhit = 1;
                else
                    inRange((i-1)*nsymops+j) = 0;
                end
            end
            
        end
    end

    if sum(inRange)~=N
        rgb = zeros(N, 3);
        return;
        error('Incorrect number of directions found in standard stereographic triangle');
    else
        chosenDirs = dirs(:,inRange);
    end
        
   sd = chosenDirs';