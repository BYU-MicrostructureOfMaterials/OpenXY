function Material = CompareMats(ScanMats)
% COMPAREMATS(SCANMATS)
% Compares a material structure with the OpenXY material of the same name
% Creates an interactive GUI to select which parameters to change
% Gives to option to replace the existing material, create a new material,
%   or use the NewMaterialGUI to edit the material
% 
% Written by Brian Jackson June 2016
for i = 1:size(ScanMats,1)
    count = 1;
    if isfield(ScanMats(i),'MaterialName')
        Material = ReadMaterial(ScanMats(i).MaterialName);
    else
        Material = ReadMaterial(ScanMats(i).Material);
    end
    if ~isempty(Material)
        CompareField('a1');
        CompareField('b1');
        CompareField('c1');
        ChangeList = cell(count-1,4);
        for j = 1:count-1;
            ChangeList(j,:) = {Change{j} Material.(Change{j}) ScanMats(i).(Change{j}) false};
        end
        if size(ChangeList,1)>0
            [Sel,Action] = CreateSelectGUI(ChangeList);
            ChangeList = ChangeList(Sel,:);
            for j = 1:size(ChangeList,1)
                Material.(ChangeList{j,1}) = ChangeList{j,3};
            end
            switch Action
                case 1 %Overwrite
                    NewMaterial(Material);
                case 2 %New Material
                    input = inputdlg('Enter new material name','New Material',1,{[Material.Material '_edit']});
                    newmat = input{1};
                    materials = GetMaterialsList(2);
                    if sum(strncmp(newmat,materials,length(newmat))) > 0
                        w = warndlg('Material already exists');
                        uiwait(w,5);
                    else
                        Material.Material = newmat;
                        NewMaterial(Material);
                    end
                case 3 %Edit with GUI
                    NewMaterialGUI(Material);
            end
        end
    end
end

    function CompareField(field)
        PercTol = 1; %Percent Tolerance
        if isfield(ScanMats(i),field) && isfield(Material,field)
            scan = ScanMats(i).(field);
            data = Material.(field);
            if isnumeric(scan)
                if (scan-data)/data*100 > PercTol;
                    Change{count} = field;
                    count = count + 1;
                end
            else
                if ~strcmp(scan,data)
                    Change{count} = field;
                    count = count + 1;
                end
            end
        end
    end

    function [Selection,Action] = CreateSelectGUI(List)
        width = 400;
        height = 400;
        screen = get(groot,'ScreenSize');
        pos = [(screen(3)-width)/2 (screen(4)-height)/2 width height];
        gui.f = figure('Visible','off','Position',pos,'MenuBar','none','Toolbar','none',...
            'name','Merge Materials','NumberTitle','off');
        twidth = width*.8;
        theight = height*.8;
        tpos = [(width-twidth)/2 (height-theight)/2 twidth theight];
        gui.t = uitable(gui.f,'Position',tpos,'Data',List,'ColumnEditable',[false false false true],...
            'ColumnFormat',{'char' 'numeric' 'numeric' 'logical'},'RowName',[],'ColumnName',{'Value','OpenXY','Scan','Change?'},'Tag','t');
        guidata(gui.f,gui);
        
        bwidth = 75;
        bheight = 25;
        bpos(1,:) = [1*(width)/4-bwidth/2 10 bwidth bheight];
        bpos(2,:) = [2*(width)/4-bwidth/2 10 bwidth bheight];
        bpos(3,:) = [3*(width)/4-bwidth/2 10 bwidth bheight];
        gui.Overwrite = uicontrol(gui.f,'Style','pushbutton','Position',bpos(1,:),'String','Overwrite','Tag','Overwrite','Callback',{@OverWrite_Callback,guidata(gui.f)});
        gui.NewMaterial = uicontrol(gui.f,'Style','pushbutton','Position',bpos(2,:),'String','New Material','Tag','NewMaterial','Callback',{@NewMaterial_Callback,guidata(gui.f)});
        gui.NewMaterial = uicontrol(gui.f,'Style','pushbutton','Position',bpos(3,:),'String','Edit with GUI','Tag','EditGUI','Callback',{@EditGUI_Callback,guidata(gui.f)});
        
        gui.f.Visible = 'on';
        uiwait
        gui = guidata(gui.f);
        Selection = gui.Selection;
        Action = gui.Action;
    end

    function OverWrite_Callback(hObject,~,gui)
        data = get(gui.t,'Data');
        gui.Selection = cell2mat(data(:,end));
        gui.Action = 1;
        guidata(hObject,gui);
        gui.f.Visible = 'off';
        uiresume
    end
    function NewMaterial_Callback(hObject,~,gui)
        data = get(gui.t,'Data');
        gui.Selection = cell2mat(data(:,end));
        gui.Action = 2;
        guidata(hObject,gui);
        gui.f.Visible = 'off';
        uiresume
    end
    function EditGUI_Callback(hObject,~,gui)
        data = get(gui.t,'Data');
        gui.Selection = cell2mat(data(:,end));
        gui.Action = 3;
        guidata(hObject,gui);
        gui.f.Visible = 'off';
        uiresume
    end

end