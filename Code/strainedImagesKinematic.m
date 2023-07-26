function strainedImagesKinematic(gr, paramspat, Material, Settings, ImageInd)


F = eye(3);


% F = [1,0.004363350820702,0;0.004363350820702,1,0;0,0,1];
% F = [1,0.006894159767445,0;0.006894159767445,1,0;0,0,1];
% F = [1,0.008465049056977,0;0.008465049056977,1,0;0,0,1];
% F = [1,0.010385082368698,0;0.010385082368698,1,0;0,0,1];
% F = [1,0.011345126851333,0;0.011345126851333,1,0;0,0,1];
% F = [1,0.013090717084835,0;0.013090717084835,1,0;0,0,1];
% 
% F = [1.005930163602749,0,0;0,1,0;0,0,1];
% F = [1.009697561656260,0,0;0,1,0;0,0,1];
% F = [1.011877768863153,0,0;0,1,0;0,0,1];
% F = [1.014511459169080,0,0;0,1,0;0,0,1];
% F = [1.015749816862595,0,0;0,1,0;0,0,1];
% F = [1.018139323961349,0,0;0,1,0;0,0,1];

RefImage2 = genEBSDPatternHybrid(gr,paramspat,F,Material.lattice,Material.a1,Material.b1,Material.c1,Material.axs);

RefImage2 = custimfilt(RefImage2,Settings.ImageFilter(1), ...
            Settings.PixelSize,Settings.ImageFilter(3),Settings.ImageFilter(4));

RefImage2 = double(RefImage2)/255;
% scanNum = 6; %change this too
% scanMat = 'silicon'; %can change this
% folderName = ['Scan_', num2str(scanNum), '_', scanMat];
orientation = 'orientation_3.2'; %change this every 6 times?
file = 'B6_unstrained'; %change this every time. Should only have 2 images
folderName = ['e:/Namit/BethanySims/' orientation '/' file];
mkdir(folderName);%make a new folder for every scan
cd(folderName);%go to the folder to save for all the data
imageName = ['automation_', num2str(ImageInd), '.jpeg'];
imwrite(RefImage2(:, :), imageName);
cd('c:/Users/Bethany/Documents/GitHub/OpenXY/Code');


end