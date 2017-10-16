function pattern = ReadH5Pattern(File,Location,imsize,Filter,valid,Ind)
% Not a verry elegant solution to HexGrid, but it works for now... Zach C.
if ~isempty(valid)
    ii = 1;
    while ii <= Ind
        if ~valid(ii); Ind = Ind + 1; end
        ii = ii + 1;
    end
end
pattern = h5read(File,[Location 'Pattern'],[1 1 Ind],[imsize(1) imsize(2) 1]);
if size(pattern,1) ~= size(pattern,2)
    pattern = CropSquare(pattern);
end
if any(Filter)
    pattern = custimfilt(pattern,Filter(1),Filter(2),Filter(3),Filter(4));
end
