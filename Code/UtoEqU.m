%%%%%%%% TO CONVERT U to Equivalent Von Mises U %%%%%%%%%%%%%

% allU = fopen('Uvalues.txt', 'r');
% 
% formSpec = '%f';
% 
% rawU = fscanf(allU, formSpec);
% 
% fclose(allU);

len = length(Settings.data.U)*9;

rawU = zeros(len, 1);
l = 1;

for i = 1:(len/9)
    for j = 1:3
        for k = 1:3
            rawU(l) = Settings.data.U(j,k,i);
            l = l+1;
        end
    end
end

numMatrix = length(rawU) / 9; %9 because 9 values in a 3x3 matrix
b=1;
E=zeros(numMatrix,1);

for a = 1:numMatrix %number of matrices
    u(1:9) = rawU(b:b+8);
    b = b + 9;

    exx = (2/3)*u(1) + (-1/3)*u(5) + (-1/3)*u(9);
    eyy = (-1/3)*u(1) + (2/3)*u(5) + (-1/3)*u(9);
    ezz = (-1/3)*u(1) + (-1/3)*u(5) + (2/3)*u(9);

    yxy = 2*u(2);
    yyz = 2*u(6);
    yzx = 2*u(7);

    E(a) = (2/3)*sqrt((3*(exx^2 + eyy^2 + ezz^2)/2)+(3*(yxy^2 + yyz^2 + yzx^2)/4));

end

E = E';

eqU = fopen('eqUVals.txt', 'w');
fprintf(eqU, '%g\n', E(1:end));
fclose(eqU);