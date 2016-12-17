function valid = CheckSplitDDMaterials(allMaterials)
j = 1;
invalidInd = [];
for i = 1:length(allMaterials)
    if ~strcmp(allMaterials{1},'Scan File')
        M = ReadMaterial(allMaterials{i});
        if ~isfield(M,'SplitDD')
            invalidInd(j) = i;
            j = j + 1;
        end
    else
        invalidInd = 1;
    end
end

if ~isempty(invalidInd)
    valid = false;
    matlist = strjoin(allMaterials(invalidInd),', ');
    warndlg(['Split Dislocation data not available for ' matlist],'OpenXY');
else
    valid = true;
end