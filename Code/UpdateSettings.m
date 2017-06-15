function Settings = UpdateSettings(Settings)
Settings.data.IQ = Settings.IQ;
Settings.data.SSE = cell2mat(Settings.data.SSE)';
Settings.SSE = Settings.data.SSE;
Settings.data.F = Cell2Array(Settings.data.F);
Settings.data.g = Settings.NewAngles;
Settings.data.U = Cell2Array(Settings.data.U);
end

function A = Cell2Array(C)
A = cell2mat(C);
A = reshape(A,size(C{1},1),size(C{1},2),length(C));
end