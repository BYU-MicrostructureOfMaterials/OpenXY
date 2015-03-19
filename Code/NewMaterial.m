function NewMaterial(MaterialStruct)

fields = fieldnames(MaterialStruct);
fmt.name = '%s\t\t';
fmt.array = '%g ';
fmt.string = '%s';

fid = fopen(fullfile(pwd,'Materials',[MaterialStruct.Material '.txt']),'wt');
%fprintf(fid,'Newest Title\n\n');
if isfield(MaterialStruct,'SplitDD')
    SplitDD = MaterialStruct.SplitDD;
    if length(SplitDD) > 1
        SplitDD(2,:) = {', '};
        SplitDD{end} = '';
        SplitDD = [SplitDD{:}];
    else
        SplitDD = SplitDD{1};
    end
    MaterialStruct.SplitDD = SplitDD;
end
for i = 1:numel(fields)
    var = MaterialStruct.(fields{i});
    varname1 = fields{i};
    fprintf(fid,fmt.name,varname1);
    if strcmp(varname1,'Material') || strcmp(varname1,'lattice') || strcmp(varname1,'SplitDD')
        format = fmt.string;
    else
        format = fmt.array;
        if strcmp(varname1,'hkl')
            var = var';
        end
    end
    fprintf(fid,format,var);
    fprintf(fid,'\n');
end

fclose(fid);
