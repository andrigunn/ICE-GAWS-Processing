%% clean variables out of files
rootdir = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data'
filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,'\L1');
end
L1_filelist = filelist([filelist.L1_folder]==1);

%%
clc
vars_to_remove = [...
    {'lw_in_r'};{'lw_out_r'};{'fg'};{'tx'};{'tn'};...
    {'HS_q'};{'albedo'};{'snd'};{'t_rad_C'};{'t_rad_K'};...
    {'HS_dif'};];


for i = 1:length(L1_filelist)

    fname = [L1_filelist(i).folder,filesep,L1_filelist(i).name];
    % Read table
    T = readtable(fname);

    vnames = T.Properties.VariableNames;
    ix = contains(vnames,'QCfin');
    vars_to_remove = [vars_to_remove;vnames(ix)'];

    disp(['File: ', char(L1_filelist(i).name)])
        
    for ii = 1:length(vars_to_remove)
        
        vars_to_check = vars_to_remove(ii);
        
        if ismember(vars_to_check, T.Properties.VariableNames) == 1
            disp(['     Removing => ', char(vars_to_check)])
            T = removevars(T, vars_to_check);
        else
       
        end
        

    end
    
    disp(['Writing clean file to: ', char(L1_filelist(i).name)])
    writetable(T,fname)
end

