function Sections = AnalyzeSections(Strain,Sec,ExpTet)
leftWin = 5;
rightWin = 2;
NN = length(Strain);
ind = 1:NN;
ExpTet = ExpTet*1;

u11 = Strain(:,1)*100;
u22 = Strain(:,2)*100;
u33 = Strain(:,3)*100;

for i = 1:length(Sec)-1
    Sections(i).Ind = ind(Sec(i)+leftWin:Sec(i+1)-rightWin);
end

%Create struct with info for each section
for i = 1:length(Sec)-1
    Len = length(Sections(i).Ind);
    Sections(i).u11 = u11(Sections(i).Ind);
    Sections(i).u22 = u22(Sections(i).Ind);
    Sections(i).u33 = u33(Sections(i).Ind);
    Sections(i).Std = [std(Sections(i).u11), std(Sections(i).u22), std(Sections(i).u33)];
    Sections(i).Mean = [mean(Sections(i).u11),mean(Sections(i).u22),mean(Sections(i).u33)];
    Sections(i).Tet = Sections(i).u33 - (Sections(i).u11 + Sections(i).u22)/2;
    Sections(i).TetMean = mean(Sections(i).Tet);
    Sections(i).TetStd = std(Sections(i).Tet);
    
    if ~mod(i,2) %even
        zerobegin = Sections(i).TetMean > Sections(i-1).TetMean;
        Len0 = length(Sections(i-1).Ind);
        Sections(i-1).SSE = sum((ones(Len0,1)*(~zerobegin)*ExpTet-Sections(i-1).Tet).^2)/Len0;
        Sections(i).SSE = sum((ones(Len,1)*zerobegin*ExpTet-Sections(i).Tet).^2)/Len;
        Sections(i-1).ExpTet = (~zerobegin)*ExpTet;
        Sections(i).ExpTet = zerobegin*ExpTet;
    end
    if i == length(Sec)-1 && mod(i,2) %odd number of sections
        Sections(i).SSE = sum((ones(Len,1)*(~zerobegin)*ExpTet-Sections(i).Tet).^2)/Len;
        Sections(i).ExpTet = (~zerobegin)*ExpTet;
    end
end
%disp(['Average Std Dev: ' num2str(mean([Sections(:).Std])*100) '%'])
