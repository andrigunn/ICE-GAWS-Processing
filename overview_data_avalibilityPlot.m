%% clean variables out of files
rootdir = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data'
filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,'\L1');
end
L1_filelist = filelist([filelist.L1_folder]==1);

L1_filelist = rmfield(L1_filelist, {'date', 'bytes', 'isdir', 'datenum', 'L1_folder'});

%% Make meta data
for i = 1:length(L1_filelist)
    newStr = split(L1_filelist(i).folder,'\') 
    newStr = split(newStr(end-1),'_') 

    x = size(newStr);

    if x(1) == 3
        L1_filelist(i).main_glacier = string(newStr(1));
        L1_filelist(i).outlet_glacier = string(newStr(2));
        L1_filelist(i).station_name = string(newStr(3));
        
    else
        L1_filelist(i).main_glacier = string(newStr(1));
        L1_filelist(i).outlet_glacier = string(newStr(1));
        L1_filelist(i).station_name = string(newStr(2));
    end
    
        newStr = split(L1_filelist(i).name,'_'); 
        newStr = split(newStr(4),'.');
        L1_filelist(i).year = str2double(cell2mat(newStr(1)));
    
end

%%
L1 = struct2table(L1_filelist);
L1.station_name_cat = categorical(L1.station_name);
%
sites = categories(L1.station_name_cat);
year = [min(L1.year):1:max(L1.year)];
%
tbl = zeros(length(sites),length(year));

for i = 1:length(sites)
    site = string(sites(i));
    yrs = L1.year(L1.station_name_cat ==string(sites(i)));

    for ii = 1:length(yrs)
        ix = find(year == yrs(ii))
        tbl(i,ix) = 1;
    end 
end
%%
close all
figure
h = heatmap(year,sites,tbl);
h.ColorbarVisible = 'off';
title(['Overview of data avalability from the ICE-GAWS network - Updated: ',datestr(now,'dd.mm.yyyy')])

addpath('C:\Users\andrigun\Dropbox\repos\Water.Basics\export_fig\')
export_fig('C:\Users\andrigun\Dropbox\repos\ICE-GAWS-Processing\img\overview_data_avalibility.png','-m2.5')






