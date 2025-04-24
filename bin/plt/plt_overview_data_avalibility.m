%% Read all files from the file structure.
% Filter flag can be changed from L1 to L0,L2 or L3. 

rootdir = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data'
filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,'\L2');
end


%

L1_filelist = filelist([filelist.L1_folder]==1);
L1_filelist = rmfield(L1_filelist, {'date', 'bytes', 'isdir', 'datenum', 'L1_folder'});

toRemove = contains({L1_filelist.name}, 'hourly') | contains({L1_filelist.name}, 'monthly') | contains({L1_filelist.name}, 'daily');
L1_filelist = L1_filelist(~toRemove);

%% Make meta data for 1/0 table
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
%
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
%% Add data that show the percent of the year of data - tekur smá tíma að rúlla
for i = 1:length(L1_filelist)

    filename = [L1_filelist(i).folder,filesep,L1_filelist(i).name];
    percent = calculateDailyCoverage(filename);
    
    L1_filelist(i).data_cover = percent;

end
%%
%
L1prc = struct2table(L1_filelist);
L1prc.station_name_cat = categorical(L1.station_name);
%
sites = categories(L1prc.station_name_cat);
year = [min(L1prc.year):1:max(L1prc.year)];
%
tbl = zeros(length(sites),length(year));

for i = 1:length(sites) % fyrir hverja stöð
    site = string(sites(i));
    yrs = L1prc.year(L1prc.station_name_cat ==string(sites(i)));
    prc = L1prc.data_cover(L1prc.station_name_cat ==string(sites(i)));

    for ii = 1:length(yrs) % fyrir hvert ár fyrir stöð
        ix = find(year == yrs(ii))
        tbl(i,ix) = prc(ii);
    end 
end

%% Teiknum 1/0 framsetningu
close all
figure( 'Position', [10 10 1200 800])
h = heatmap(year,sites,tbl);
%h.ColorbarVisible = 'off';
title(['Overview of data avalability from the ICE-GAWS network - Updated: ',datestr(now,'dd.mm.yyyy')])
set(gcf,'Color','white')
addpath('C:\Users\andrigun\Dropbox\04-Repos\Water.Basics\export_fig\')
export_fig('C:\Users\andrigun\Dropbox\04-Repos\ICE-GAWS-Processing\img\overview_data_avalibility.png','-m2.5')
%% for paper
export_fig('C:\Users\andrigun\Dropbox\Apps\Overleaf\ICE-GAWS-JGR-Atmos\figures\overview_data_avalibility.pdf','-m2.5')

%
function percent = calculateDailyCoverage(filename)
    %% Read the CSV file into a timetable
    data = readtimetable(filename);

    % Ensure the timetable is sorted and has datetime row times
    data = sortrows(data);

    % Retime to daily mean
    dailyData = retime(data, 'daily', 'mean');

    % Count how many unique days have data (ignoring all-NaN rows)
    hasData = any(~ismissing(dailyData), 2);
    numDaysWithData = sum(hasData);
%%
    % Determine the total number of days in the year
    if isempty(dailyData)
        percent = 0;
        return;
    end

    yearVal = dailyData.Time.Year(1);
    startOfYear = datetime(yearVal, 1, 1);
    endOfYear = datetime(yearVal, 12, 31);
    totalDaysInYear = daysact(startOfYear, endOfYear) + 1;

    % Calculate percentage
    percent = 100 * numDaysWithData / totalDaysInYear;
end








