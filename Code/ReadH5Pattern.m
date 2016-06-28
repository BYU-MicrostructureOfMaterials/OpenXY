function pattern = ReadH5Pattern(File,Location,imsize,Filter,Ind)
pattern = h5read(File,[Location 'Pattern'],[1 1 Ind],[imsize(1) imsize(2) 1]);
if size(pattern,1) ~= size(pattern,2)
    pattern = CropSquare(pattern);
end
if any(Filter)
    pattern = custimfilt(pattern,Filter(1),Filter(2),Filter(3),Filter(4));
end