function data_subsurface = addNCfilesToStruct(c)

foldername = strrep(c.OutputFolder,'.','');

d = dir([c.masterDir,foldername,filesep,filesep,'*.nc'])

%%
for i = 1:length(d)
    var = d(i).name;

    c = split(var,'_');
    x = size(c);
    if x(1) ==1

        data_subsurface.T_ice = ncstruct(var);
    else
        c = split(var,{'_','.'});

        pname = string(c(2));
        data_subsurface.(string(pname)) = ncstruct(var);

    end

end
