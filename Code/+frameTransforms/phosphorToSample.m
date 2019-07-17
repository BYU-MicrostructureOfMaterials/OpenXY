function Qps = phosphorToSample(Settings)
%PHOSPHORTOSAMPLE The tranformation from the phosphor sensor to the sample
%   Compute the transformation matrix that corresponds to the
%   transformation from the phosphor sensor's refference frame to the
%   sample's refference frame. The reverse transformation is just the
%   transpose of this matrix.
%
%   If the camera euler angles have been read from the scan metadat, then
%   it is used to compute the transformation; otherwise, the camera
%   elevation angle is used.

if isfield(Settings,'camphi1')
    Qmp = euler2gmat(Settings.camphi1,Settings.camPHI,Settings.camphi2);
    Qmi = [0 -1 0;1 0 0;0 0 1];
    sampletilt = Settings.SampleTilt;
    Qio = [
        cos(sampletilt) 0 -sin(sampletilt)
        0 1 0;sin(sampletilt) 0 cos(sampletilt)
        ];
    Qpo = Qio*Qmi*Qmp'*[-1 0 0;0 1 0;0 0 -1];
    
    Qps = Qpo;
else
    alphaRotation=pi/2-Settings.SampleTilt+Settings.CameraElevation;
    Qps=[0 -cos(alphaRotation) -sin(alphaRotation);...
        -1     0            0;...
        0   sin(alphaRotation) -cos(alphaRotation)];
end

