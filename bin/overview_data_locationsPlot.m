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
        L1_filelist(i).year = str2num(string(newStr(1)));
    
end
%% Join geo data to structure
% read location table
ICE_GAWS_location = readtable('C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\ICE-GAWS-location.csv')
% Join location to files

for i = 1:length(L1_filelist)

    ix = find([L1_filelist(i).station_name] == ICE_GAWS_location.site_name)
    ix2 = find([L1_filelist(i).year] == ICE_GAWS_location.year(ix))

    L1_filelist(i).year2 = ICE_GAWS_location.year(ix(ix2));
    L1_filelist(i).site_name2 = ICE_GAWS_location.site_name(ix(ix2));
    L1_filelist(i).lat = ICE_GAWS_location.lat(ix(ix2));
    L1_filelist(i).lon = ICE_GAWS_location.lon(ix(ix2));
    L1_filelist(i).elevation = ICE_GAWS_location.elevation(ix(ix2));

end
%% Make average table 

uqst = unique([L1_filelist.site_name2]);
S = table();

for i = 1:length(uqst)

    Index = find(contains([L1_filelist.station_name],uqst(i)));

    S.station(i) = uqst(i);
    S.no_years(i) = numel(Index);
    S.lat_ave(i) = mean([L1_filelist(Index).lat]);
    S.lon_ave(i) = mean([L1_filelist(Index).lon]);
    S.ele_ave(i) = mean([L1_filelist(Index).elevation]);
    
end
S.station_cat = categorical(S.station);


%%
close all
geobubble(S,'lat_ave','lon_ave',SizeVariable='no_years',ColorVariable='station_cat')
geobasemap satellite

title(['Overview of ICE-GAWS locations - Updated: ',datestr(now,'dd.mm.yyyy')])

addpath('C:\Users\andrigun\Dropbox\repos\Water.Basics\export_fig\')
export_fig('C:\Users\andrigun\Dropbox\repos\ICE-GAWS-Processing\img\overview_data_locations.png','-m2.5')

