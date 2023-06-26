scanNum = 68;
fid = fopen(['badPointsScan' num2str(scanNum) '.txt'], 'r');


pts(1, :) = textscan(fid, '%d\n');
pts2 = pts{1,1};


fclose(fid);

len = length(pts2);
new = sort(pts2);