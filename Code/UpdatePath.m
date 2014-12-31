function UpdatedPath=UpdatePath(OldPath,NewDir,MainPathL)

    if iscell(OldPath)
        UpdatedPath=cell(size(OldPath));
        for i=1:length(OldPath)
            UpdatedPath{i}=[NewDir,OldPath{i}(MainPathL+1:end)];
        end
    else
        UpdatedPath=[NewDir,OldPath(MainPathL+1:end)];
    end

end