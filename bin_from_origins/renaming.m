%% Renameing old L1 files
rootdir = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data'
filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,'\L1');
end
L1_filelist = filelist([filelist.L1_folder]==1);

%%
for i = 1:length(L1_filelist)

    if endsWith(L1_filelist(i).name,'MOD.csv') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'VST_','ICE-GAWS_')
        newStr = strrep(newStr,'_QCFin','_L1')
        newStr = strrep(newStr,'_MOD','')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])
    elseif contains(L1_filelist(i).name,'QCFin') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'VST_','ICE-GAWS_')
        newStr = strrep(newStr,'_QCFin','_L1')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])
    elseif contains(L1_filelist(i).name,'Tungnarjokull') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'Tungnarjokull','')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])
    elseif contains(L1_filelist(i).name,'Dyngjujokull') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'Dyngjujokull_','')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])
    elseif contains(L1_filelist(i).name,'Koldukvislarjokull') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'Koldukvislarjokull_','')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])
    elseif contains(L1_filelist(i).name,'Skalafellsjokull_') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'Skalafellsjokull_','')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])

    elseif contains(L1_filelist(i).name,'__') == 1
        clear fname_old newStr
        fname_old = L1_filelist(i).name
        newStr = strrep(fname_old,'__','_')
        movefile([L1_filelist(i).folder,filesep,fname_old],[L1_filelist(i).folder,filesep,newStr])
      
      
    end
end

