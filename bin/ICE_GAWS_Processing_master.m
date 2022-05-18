function ICE_GAWS_Processing_master()
%% ICE-GAWS-Processing
%
%% General settings, paths, etc

if ispc
    % Path to ICE-GAWS-Processing repo
    dirs.git = 'C:\Users\andrigun\Dropbox\repos\ICE-GAWS-Processing';
    addpath(genpath(dirs.git))
    cd(dirs.git)
    % Path to ICE-GAWS-Processing L0 data
    dirs.gaws = 'F:\Þróunarsvið\Rannsóknir\Jöklarannsóknir\30_GAWS\HS_MOD\Data\mod_published_GAWS_data\';
elseif ismac

elseif isunix

end
%% Load constants
constants
disp('Loading constants')
%% constants
% load the constants for filtering and processing of data
%% L0 ==> L1 Processing
%% update_live_data 
%   First step of L0 to L1 conversion
%   copies raw files from the Loggernet server to the L0 directories and
%   makes a L1 files in the L1 file directory
%   Directories need to be manually setup
update_live_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% L1 ==> L2 Processing
rootdir = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data'
filelist = dir(fullfile(rootdir, '**\*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,'\L1');
end
L1_files = filelist([filelist.L1_folder]==1);

% Make meta data
for i = 1:length(L1_files)
    newStr = split(L1_files(i).folder,'\') 
    newStr = split(newStr(end-1),'_') 

    x = size(newStr);

    if x(1) == 3
        L1_files(i).main_glacier = string(newStr(1));
        L1_files(i).outlet_glacier = string(newStr(2));
        L1_files(i).station_name = string(newStr(3));
        
    else
        L1_files(i).main_glacier = string(newStr(1));
        L1_files(i).outlet_glacier = string(newStr(1));
        L1_files(i).station_name = string(newStr(2));
    end
    
        newStr = split(L1_files(i).name,'_'); 
        newStr = split(newStr(4),'.');
        L1_files(i).year = str2num(string(newStr(1)));
    
end

L1_files = rmfield(L1_files, {'date', 'bytes', 'isdir', 'datenum', 'L1_folder'});

%%

for i = 1:10
clear data
filename = [L1_files(i).folder,filesep,L1_files(i).name];
siteName = L1_files(i).station_name;
clear data
disp(['Processing for file: ', L1_files(i).name])
data.L1 = readtable(filename,'ReadVariableNames',true );


        if ismember('time', data.L1.Properties.VariableNames) == 1
            data.L1 = table2timetable(data.L1,'RowTimes',data.L1.time);
            data.L1 = removevars(data.L1, 'time');
        else
            data.L1 = table2timetable(data.L1,'RowTimes',data.L1.Time);
            data.L1 = removevars(data.L1, 'Time');
            data.L1.Properties.DimensionNames{1} = 'Time'; 
        end

data.L2 = data.L1;

%% Check if data is regular in time
[TF,dt] = isregular(data.L2);

if TF == 1
    disp('Data is regular in time')
else
    disp('Data is NOT regular in time')
    dt = unique(diff(data.L2.Time));
end
% Check if data is sorted
tf = issorted(data.L2);

if tf == 1
    disp('Data is sorted')
else
    disp('Data is NOT sorted')
end

%% Check for missing data
natRowTimes = ismissing(data.L2.Time);
disp([num2str(sum(natRowTimes)), ' values remove NAT'])
data.L2 = data.L2(~natRowTimes,:);

%% Remove and replace max/min
% remove defined periods in removePeriods
data.L2 = removePeriods(data.L2,siteName); 
% filter data in accordance to filterRemoveMaxMin
data.L2 = filterRemoveMaxMin(data.L2,c);

%% Check for missing data
natRowTimes = ismissing(data.L2.Time);
disp([num2str(sum(natRowTimes)), ' values remove NAT'])
data.L2 = data.L2(~natRowTimes,:);

%% Write data to folder
sitename = ['ICE-GAWS_',char(siteName),'_L2_',num2str(L1_files(i).year),'.csv'];
Fname = L1_files(i).folder;
foldername = strrep(Fname,'L1','L2');
fname = [foldername,filesep,sitename];

disp(['Writing clean file to: ', char(fname)])
writetimetable(data.L2,fname,'Delimiter',',');

%% L2 ==> L2 Processing
    data.L3 = data.L2;

     if ismember('lw_out',data.L2.Properties.VariableNames)
         data.L3.Ts = SurfaceTemperature(data.L2.lw_out, data.L2.lw_in,c);
     else
     end

     if ismember('sw_in',data.L2.Properties.VariableNames)
         data.L3.Albedo = Albedo(data.L2.sw_in, data.L2.sw_out);
         data.L3.Albedo_acc = Albedo_24hr_acc(data.L2.sw_in, data.L2.sw_out, dt);
     else
     end

% Write data to folder
sitename = ['ICE-GAWS_',char(siteName),'_L3_',num2str(L1_files(i).year),'.csv'];
Fname = L1_files(i).folder;
foldername = strrep(Fname,'L1','L3');
fname = [foldername,filesep,sitename];

    if exist(foldername, 'dir')
    else
        mkdir(foldername)
    end

disp(['Writing clean file to: ', char(fname)])
writetimetable(data.L3,fname,'Delimiter',',');

end

%%
end

% SubFunctions used
function data = removeUnusedVars(data, VarRemove)
disp(' ##   Removing additional data')
for i = 1:length(VarRemove);
    if ismember(VarRemove(i),data.Properties.VariableNames)
        data = removevars(data, VarRemove(i));
    end
end
end

function dout = filterRemoveMaxMin(data,c)
disp(' ##   Running filterRemoveMaxMin')
if ismember('f',data.Properties.VariableNames)
    io = find(data.f>c.f_max);
    iu = find(data.f<c.f_min);
    data.f(io) = NaN;
    data.f(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.f_max), 'm/s'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.f_min), 'm/s'])
else
end

if ismember('t',data.Properties.VariableNames)
    io = find(data.t>c.t_max);
    iu = find(data.t<c.t_min);
    data.t(io) = NaN;
    data.t(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.t_max), '°C'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.t_min), '°C'])
else
end

if ismember('t2',data.Properties.VariableNames)
    io = find(data.t>c.t_max);
    iu = find(data.t<c.t_min);
    data.t2(io) = NaN;
    data.t2(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.t_max), '°C'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.t_min), '°C'])
else
end

if ismember('d',data.Properties.VariableNames)
    io = find(data.d>c.d_max);
    iu = find(data.d<c.d_min);
    data.d(io) = 360;
    data.d(iu) = 0;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.d_max), '°'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.d_min), '°'])
else
end

if ismember('sw_in',data.Properties.VariableNames)
    io = find(data.sw_in>c.sw_in_max);
    iu = find(data.sw_out<c.sw_in_min);
    data.sw_in(io) = NaN;
    data.sw_in(iu) = 0;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.sw_in_max), 'w/m^2'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.sw_in_min), 'w/m^2'])
else
end


dout = data;

end

function Ts = SurfaceTemperature(lw_out, lw_in,c)

%((ds['ulr'] - (1 - emissivity) * ds['dlr']) / emissivity / 5.67e-8)**0.25 - T_0

Ts = (((lw_out - (1 - c.emissivity_ice) * lw_in) / (c.emissivity_ice * 5.67e-8)).^0.25) - 273.15


%Ts = (((lw_out-(1-c.emissivity_ice)*lw_in)/(c.emissivity_ice*5.67*10^-8)).^0.25)-273.15;

io = find(Ts>c.Ts_max);
iu = find(Ts<c.TS_min);
Ts(io) = 0;
Ts(iu) = NaN;
disp(['Found ', num2str(numel(io)),' value above ', num2str(c.Ts_max), '°C'])
disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.Ts_max), '°C'])

end

function CloudCover = CloudCover(T2,Ts,lw_in)

LR_clear = 5.31*10^-14*(T2+273.15+Ts+273.15).^6; %clear sky downward longwave radiation
LR_overcast = 5.67*10^-8*(T2+273.15+Ts+273.15).^4;

CloudCover = (lw_in-LR_clear)./(LR_overcast-LR_clear);

io = find(CloudCover>1);
%iu = find(CloudCover<0);
CloudCover(io) = 1;
%CloudCover(iu) = 0;

end

function Albedo = Albedo(sw_in, sw_out)
Albedo = sw_in./sw_out;
Albedo(Albedo>1)=NaN;
Albedo(Albedo<0)=NaN;
end


function Albedo_acc = Albedo_24hr_acc(sw_in, sw_out,dt)

D_10min = duration('00:10:00','InputFormat','hh:mm:ss');
D_1hour = duration('01:00:00','InputFormat','hh:mm:ss');

if dt(1) == D_10min;
    M1 = movsum(sw_in,24*6);
    M2 = movsum(sw_out,24*6);
    Albedo_acc = (M2./M1);

elseif dt(1) == D_1hour
    M1 = movsum(sw_in,24);
    M2 = movsum(sw_out,24);
    Albedo_acc = (M2./M1);

end
    Albedo_acc(Albedo_acc>1)=NaN;
    Albedo_acc(Albedo_acc<0)=NaN;
end



