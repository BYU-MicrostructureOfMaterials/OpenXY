function NewMaterial(MaterialStruct)

fields = fieldnames(MaterialStruct);
fmt.name = '%s\t\t';
fmt.array = '%g ';
fmt.string = '%s';

fid = fopen(fullfile(pwd,'Materials',[MaterialStruct.Material '.txt']),'wt');
%fprintf(fid,'Newest Title\n\n');

for i = 1:numel(fields)
    var = MaterialStruct.(fields{i});
    varname1 = fields{i};
    fprintf(fid,fmt.name,varname1);
    if strcmp(varname1,'Material') || strcmp(varname1,'lattice')
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
