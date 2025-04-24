function ICE_GAWS_Processing_master(process_years_from,process_years_to,station_filter)
%% ICE-GAWS-Processing
% Master files for processing of ICE-GAWS data
% Reads L0 data and writes L1, L2 and L3 data to the correect folders
% Data is stored in "rootdir" and data is written to the rootdir
% Processing code and routines in "\04-Repos\ICE-GAWS-Processing\bin"
% MASTER SETTINGS FOR FILE
% Filter for years
process_years_from = 2024;        % year is included
process_years_to = 2024;          % year is included
station_filter = 'Gv';           % Filter for stations (use '' for all stations)

% Swithces and settings
OperationalDataUpdate = 'yes';       % Update loggernet data from live stations
Level1to2DataUpdate = 'yes';        % Run L1 to L2 data creation %% Passa þetta m.v. export úr Wiski
Level2to3DataUpdate = 'no';         % Run L2 to L3 data creation
Level2Aggregates = 'yes';            % L2 hourly, daily and monthly data
Level3Aggregates = 'no';            % L3 hourly, daily and monthly data

Level3GapFill = 'no';               % L3 hourly gap filling of data data
Level3GapFillType = 'carra';        % rav and carra for RCM and MODIS for albedo
Level3GapFillWriteDataOut ='no';   % If to write gap filled data out
Level3GapFillTypeAlbedo = 'modis';  % rav and carra for RCM and MODIS for albedo
Level3GapFilledAggregates = 'no';   % L3 hourly, daily and monthly data

Level3SEB ='no';                % use GF hourly data to calulate SEB
% NOTE: SEB needs a lot of auxilary files, density, station info etc
% General settings, paths, etc
if ispc
    % Path to ICE-GAWS-Processing repo
    dirs.git = 'C:\Users\andrigun\Dropbox\04-Repos\ICE-GAWS-Processing';
    rootdir = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data';

    addpath(genpath(dirs.git))
    cd(dirs.git)
    % Path to ICE-GAWS-Processing L0 data
    dirs.gaws = 'F:\Þróunarsvið\Rannsóknir\Jöklarannsóknir\30_GAWS\HS_MOD\Data\mod_published_GAWS_data\';

elseif ismac
    dirs.git = '/Users/andrigun/Dropbox/04-Repos/ICE-GAWS-Processing';
    rootdir = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data';

    addpath(genpath(dirs.git))
    cd(dirs.git)
    % Path to ICE-GAWS-Processing L0 data
    dirs.gaws = 'F:\Þróunarsvið\Rannsóknir\Jöklarannsóknir\30_GAWS\HS_MOD\Data\mod_published_GAWS_data\';

elseif isunix
end

diary(['GAWS_Process_logfile.txt'])
disp( '=========================================================================')
disp(['Running ICE_GAWS_Processing_master at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
disp( '=========================================================================')

% Load constants
% load the constants for filtering and processing of data
%constants;
c = constants();
%disp('Loading constants')

fOperationalDataUpdate(OperationalDataUpdate);

L1_files = fmakeL1FileStructure(rootdir,process_years_from,process_years_to,station_filter);
% L1 ==> L2 Processing
fLevel1to2DataUpdate(Level1to2DataUpdate,L1_files,c);
% L2 ==> L3 Processing
L2_files = fmakeL12FileStructure(rootdir,process_years_from,process_years_to,station_filter,L1_files);
%
fLevel2to3DataUpdate(Level2to3DataUpdate,L2_files,c);
% Make hourly, daily and monthly sums of L2 data
fLevel2Aggregates(Level2Aggregates,process_years_from,process_years_to,station_filter)
% Make hourly, daily and monthly sums of L3 data
fLevel3Aggregates(Level3Aggregates,process_years_from,process_years_to,station_filter,'L3','raw')
% Gap fill data
fLevel3GapFiller(Level3GapFill,process_years_from,process_years_to,...
    station_filter,Level3GapFillType,Level3GapFillTypeAlbedo,Level3GapFillWriteDataOut,rootdir,L1_files)

switch Level3GapFill
    case 'no'
    otherwise
        % Make hourly, daily and monthly sums of L3 gapfilled data
        switch Level3GapFillType
            case 'carra'
                fLevel3Aggregates(Level3Aggregates,process_years_from,process_years_to,station_filter,'L3GFC','hourly')
            case 'rav'
                fLevel3Aggregates(Level3Aggregates,process_years_from,process_years_to,station_filter,'L3GFR','hourly')
        end
end

%
% switch Level3SEB
%     % Calculate energy balance for GF hourly data
%     case 'yes'
%     %
%     disp(['==== Level 3 processing SEB ===='])
%     disp( '=========================================================================')
%     disp(['==== Find L3GF files to calculate SEB for'])
%     filelistL3GF = filterL3GFfiles(rootdir,process_years_from,process_years_to,station_filter);
%     disp( '=========================================================================')
%     disp( '===== Convert L3GF to SEB structure ====')
%     convertL3GFtoSEB(filelistL3GF)
%     disp( '=========================================================================')
%
% end
end
%% End of master

%%%%%% SubFunctions used %%%%%%
function fLevel3GapFiller(Level3GapFill,process_years_from,process_years_to,...
    station_filter,Level3GapFillType,Level3GapFillTypeAlbedo,Level3GapFillWriteDataOut,rootdir,L1_files)

switch Level3GapFill
    % Gap Fill hourly data
    case 'yes'
        % Búum til lista með skrám
        %%
        L3_files = fmakeL3FileStructure(rootdir,process_years_from,process_years_to,station_filter,L1_files)
%%
        for f = 1:length(L3_files)
            year_to_process = L3_files(f).year;
            station = L3_files(f).station_name;

            filename = L3_GapFiller_RCM(char(station),Level3GapFillType,Level3GapFillTypeAlbedo,...
                year_to_process,Level3GapFillWriteDataOut);
        end
    otherwise
end
%%
end
%%
function data = removeUnusedVars(data, VarRemove)
disp('===== removeUnusedVars: Running removeUnusedVars')

for i = 1:length(VarRemove);
    if ismember(VarRemove(i),data.Properties.VariableNames)
        data = removevars(data, VarRemove(i));
    end
end
end

function dout = filterRemoveMaxMin(data,c)
disp('===== filterRemoveMaxMin: Running filterRemoveMaxMin')
if ismember('f',data.Properties.VariableNames)
    io = find(data.f>c.f_max);
    iu = find(data.f<c.f_min);
    data.f(io) = NaN;
    data.f(iu) = NaN;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.f_max), 'm/s'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.f_min), 'm/s'])
else
end

if ismember('t',data.Properties.VariableNames)
    io = find(data.t>c.t_max);
    iu = find(data.t<c.t_min);
    data.t(io) = NaN;
    data.t(iu) = NaN;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.t_max), '°C'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.t_min), '°C'])
else
end

if ismember('t2',data.Properties.VariableNames)
    io = find(data.t2>c.t_max);
    iu = find(data.t2<c.t_min);
    data.t2(io) = NaN;
    data.t2(iu) = NaN;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.t_max), '°C'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.t_min), '°C'])
else
end

if ismember('d',data.Properties.VariableNames)
    io = find(data.d>c.d_max);
    iu = find(data.d<c.d_min);
    data.d(io) = 360;
    data.d(iu) = 0;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.d_max), '°'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.d_min), '°'])
else
end

if ismember('rh',data.Properties.VariableNames)
    io = find(data.rh>c.rh_max);
    iu = find(data.rh<c.rh_min);
    data.rh(io) = 100;
    data.rh(iu) = NaN;
    disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.rh_max), '%'])
    disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.rh_min), '%'])
else
end

if ismember('sw_in',data.Properties.VariableNames)
    io = find(data.sw_in>c.sw_in_max);
    iu = find(data.sw_in<c.sw_in_min);
    data.sw_in(io) = NaN;
    data.sw_in(iu) = 0;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.sw_in_max), 'w/m^2'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.sw_in_min), 'w/m^2'])
else
end

if ismember('sw_out',data.Properties.VariableNames)
    io = find(data.sw_out>c.sw_out_max);
    iu = find(data.sw_out<c.sw_out_min);
    data.sw_out(io) = NaN;
    data.sw_out(iu) = 0;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.sw_out_max), 'w/m^2'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.sw_out_min), 'w/m^2'])
else
end

if ismember('lw_in',data.Properties.VariableNames)
    io = find(data.lw_in>c.lw_in_max);
    iu = find(data.lw_in<c.lw_in_min);
    data.lw_in(io) = NaN;
    data.lw_in(iu) = NaN;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.lw_in_max), 'w/m^2'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.lw_in_min), 'w/m^2'])
else
end

if ismember('lw_out',data.Properties.VariableNames)
    io = find(data.lw_out>c.lw_out_max);
    iu = find(data.lw_out<c.lw_out_min);
    data.lw_out(io) = NaN;
    data.lw_out(iu) = NaN;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.lw_out_max), 'w/m^2'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.lw_out_min), 'w/m^2'])
else
end

if ismember('ps',data.Properties.VariableNames)
    io = find(data.ps>c.ps_max);
    iu = find(data.ps<c.ps_min);
    data.ps(io) = NaN;
    data.ps(iu) = NaN;
    %     disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.ps_max), 'w/m^2'])
    %     disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.ps_min), 'w/m^2'])
else
end


dout = data;

end

function Ts = SurfaceTemperature(lw_out, lw_in,c)
%disp('===== SurfaceTemperature: Running SurfaceTemperature')

%((ds['ulr'] - (1 - emissivity) * ds['dlr']) / emissivity / 5.67e-8)**0.25 - T_0

Ts = (((lw_out - (1 - c.emissivity_ice) * lw_in) / (c.emissivity_ice * 5.67e-8)).^0.25) - 273.15;

%Ts = (((lw_out-(1-c.emissivity_ice)*lw_in)/(c.emissivity_ice*5.67*10^-8)).^0.25)-273.15;

io = find(Ts>c.Ts_max);
iu = find(Ts<c.Ts_min);
Ts(io) = 0;
Ts(iu) = NaN;
% disp(['     ==> Found ', num2str(numel(io)),' value above ', num2str(c.Ts_max), '°C'])
% disp(['     ==> Found ', num2str(numel(iu)),' value below ', num2str(c.Ts_min), '°C'])

end

function Albedo = Albedo(sw_in, sw_out)
    %disp('===== Albedo: Running Albedo')
    Albedo = sw_in./sw_out;
    Albedo(Albedo>1)=NaN;
    Albedo(Albedo<0)=NaN;
end

function Albedo_acc = Albedo_24hr_acc(sw_in, sw_out,dt)
%disp('===== Albedo_acc: Running Albedo_acc')

    D_10min = duration('00:10:00','InputFormat','hh:mm:ss');
    D_1hour = duration('01:00:00','InputFormat','hh:mm:ss');
    D_30min = duration('00:30:00','InputFormat','hh:mm:ss');

    if dt(1) == D_10min;
        M1 = movsum(sw_in,24*6);
        M2 = movsum(sw_out,24*6);
        Albedo_acc = (M2./M1);
    
    elseif dt(1) == D_1hour
        M1 = movsum(sw_in,24);
        M2 = movsum(sw_out,24);
        Albedo_acc = (M2./M1);
    
    elseif dt(1) == D_30min
        M1 = movsum(sw_in,24*2);
        M2 = movsum(sw_out,24*2);
        Albedo_acc = (M2./M1);
    
    end

    Albedo_acc(Albedo_acc>1)=NaN;
    Albedo_acc(Albedo_acc<0)=NaN;
end

% L0 ==> L1 Processing of operational data
function fOperationalDataUpdate(OperationalDataUpdate)
switch OperationalDataUpdate
    case 'yes'
        disp( '=========================================================================')
        disp(['Running OperationalDataUpdate at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
        % update_live_data
        %   First step of L0 to L1 conversion
        %   copies raw files from the Loggernet server to the L0 directories and
        %   makes a L1 files in the L1 file directory
        %   Directories need to be manually setup
        update_live_data;
        disp(['Done OperationalDataUpdate at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
        disp( '=========================================================================')
    otherwise
        disp(['Not running OperationalDataUpdate at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
end
end

function dt = fLevel1to2DataUpdate(Level1to2DataUpdate,L1_files,c)
%%
switch Level1to2DataUpdate
    case 'yes'
        % Read L1 data
        for i = 1:length(L1_files)
            clear data
            filename = [L1_files(i).folder,filesep,L1_files(i).name];
            siteName = L1_files(i).station_name;
            clear data
            disp( '=========================================================================')
            disp(['==== Processing for file: ', L1_files(i).name])
            disp( '=========================================================================')
            data.L1 = readtable(filename,'ReadVariableNames',true );

                if ismember('time', data.L1.Properties.VariableNames) == 1
                    data.L1 = table2timetable(data.L1,'RowTimes',data.L1.time);
                    data.L1 = removevars(data.L1, 'time');
                else
                    data.L1 = table2timetable(data.L1,'RowTimes',data.L1.Time);
                    data.L1 = removevars(data.L1, 'Time');
                    data.L1.Properties.DimensionNames{1} = 'Time';
                end

            disp(['==== Level 2 processing ===='])
            data.L2 = data.L1;
            % Check if data is regular in time
            [TF,dt] = isregular(data.L2);

            if TF == 1
                disp('===== Data is regular in time')
            else

                disp('===== Data is NOT regular in time')
                dt = unique(diff(data.L2.Time));

                if ismember(duration(00,10,00),dt)==1
                    disp('===== Retiming data to 10 min timestep')
                    data.L2 = retime(data.L2,'regular','TimeStep',duration(00,10,00));
                    [TF,dt] = isregular(data.L2); % update dt info
                elseif ismember(duration(01,00,00),dt)
                    disp('===== Retiming data to 60 min timestep')
                    data.L2 = retime(data.L2,'regular','TimeStep',duration(01,00,00));
                    [TF,dt] = isregular(data.L2); % update dt info
                elseif ismember(duration(00,30,00),dt)
                    disp('===== Retiming data to 30 min timestep')
                    data.L2 = retime(data.L2,'regular','TimeStep',duration(00,30,00));
                    [TF,dt] = isregular(data.L2); % update dt info
                else

                end

            end

            [TF,dt] = isregular(data.L2);

            if TF == 1
                disp('===== Data is regular in time')
            else
                disp('===== Data is NOT regular in time')
            end
            % Check if data is sorted
            tf = issorted(data.L2);

            if tf == 1
                disp('===== Data is sorted')
            else
                disp('===== Data is NOT sorted')
            end

            % Check for missing data
            natRowTimes = ismissing(data.L2.Time);
            disp(['===== ',num2str(sum(natRowTimes)), ' values remove that are NAT'])
            data.L2 = data.L2(~natRowTimes,:);

            % Remove and replace max/min
            % remove defined periods in removePeriods
            % Removes full periods for ALL variables
            disp('===== removePeriods: Running removePeriods')
            data.L2 = removePeriods(data.L2,siteName);

            % removes periods for specific variabls and adjustments that
            % need to be made
            disp('===== BlacklistVariables: Running BlacklistVariables')
            data.L2 = BlacklistVariables(data.L2,siteName);
            %
            % filter data in accordance to filterRemoveMaxMin
            data.L2 = filterRemoveMaxMin(data.L2,c);

            % Check for missing data
            natRowTimes = ismissing(data.L2.Time);
            disp(['===== ',num2str(sum(natRowTimes)), ' values remove that are NAT'])
            data.L2 = data.L2(~natRowTimes,:);

            % Remove aux variables
            VarRemove = {'rh2', 'tcrx','f1', 'rhz','tg','tz','f2','RS','RL','d4','t4','f4','rh4'};
            data.L2 = removeUnusedVars(data.L2, VarRemove);

            % Write data to folder
            sitename = ['ICE-GAWS_',char(siteName),'_L2_',num2str(L1_files(i).year),'.csv'];
            Fname = L1_files(i).folder;
            foldername = strrep(Fname,'L1','L2');
            fname = [foldername,filesep,sitename];

            disp(['==== Writing clean file to: ', char(fname)])
            writetimetable(data.L2,fname,'Delimiter',',');
            disp(['==== Level 2 processing done ===='])

        end

    otherwise
        disp('not assigned')
        dt = [];
end

end

function fLevel2to3DataUpdate(Level2to3DataUpdate,L2_files,c)
%% L2 ==> L3 Processing
switch Level2to3DataUpdate
    case 'yes'
        disp(['==== Level 3 processing ===='])
        for i = 1:length(L2_files)
            filename = [L2_files(i).folder,filesep,L2_files(i).name];
            siteName = L2_files(i).station_name;
            clear data
            disp( '=========================================================================')
            disp(['==== Processing for file: ', L2_files(i).name])
            disp( '=========================================================================')
            data.L2 = readtable(filename,'ReadVariableNames',true );
            

            if ismember('time', data.L2.Properties.VariableNames) == 1
                data.L2 = table2timetable(data.L2,'RowTimes',data.L2.time);
                data.L2 = removevars(data.L2, 'time');
            else
                data.L2 = table2timetable(data.L2,'RowTimes',data.L2.Time);
                data.L2 = removevars(data.L2, 'Time');
                data.L2.Properties.DimensionNames{1} = 'Time';
            end

            %% In cases where L2 data is from exported Wiski we need to check for regularity
            % same step as in L1 to L2 in previous function
            [TF,dt] = isregular(data.L2);

            if TF == 1
                disp('===== Data is regular in time')
            else

                disp('===== Data is NOT regular in time')
                dt = unique(diff(data.L2.Time));

                if ismember(duration(00,10,00),dt)==1
                    disp('===== Retiming data to 10 min timestep')
                    data.L2 = retime(data.L2,'regular','TimeStep',duration(00,10,00));
                    [TF,dt] = isregular(data.L2); % update dt info
                elseif ismember(duration(01,00,00),dt)
                    disp('===== Retiming data to 60 min timestep')
                    data.L2 = retime(data.L2,'regular','TimeStep',duration(01,00,00));
                    [TF,dt] = isregular(data.L2); % update dt info
                elseif ismember(duration(00,30,00),dt)
                    disp('===== Retiming data to 30 min timestep')
                    data.L2 = retime(data.L2,'regular','TimeStep',duration(00,30,00));
                    [TF,dt] = isregular(data.L2); % update dt info
                else

                end

            end

            data.L3 = data.L2;

            if ismember('lw_out',data.L2.Properties.VariableNames)
                data.L3.Ts = SurfaceTemperature(data.L2.lw_out, data.L2.lw_in,c);
            else
            end

            if ismember('sw_in',data.L2.Properties.VariableNames) &&...
                    ismember('sw_out',data.L2.Properties.VariableNames)

                [~,dt] = isregular(data.L2);
                data.L3.Albedo_acc = Albedo_24hr_acc(data.L2.sw_in, data.L2.sw_out, dt);

            else
            end

            % Write data to folder

            foldername = strrep([L2_files(i).folder],'L2','L3');
            fname =  strrep([L2_files(i).name],'L2','L3');
            filename = [foldername,filesep,fname];

            if exist(foldername, 'dir')
            else
                mkdir(foldername)
            end

            disp(['Writing clean file to: ', char(filename)])
            writetimetable(data.L3,filename,'Delimiter',',');
            disp(['==== Level 3 processing done ===='])
            disp( '=========================================================================')
        end
    otherwise
end
end

function fLevel2Aggregates(Level2Aggregates,process_years_from,process_years_to,station_filter)
% Make hourly, daily and monthly sums of data
switch Level2Aggregates
    case 'yes'
        disp(['==== Making aggregated tables (hour, day, month) ===='])
        files = read_file_structure('L2','raw');

        % Filter L1 files with years
        ix = find( ([files.year]>=process_years_from) & ([files.year]<=process_years_to));
        files = files(ix,:);
        % Filter stations to process

        switch station_filter
            case ''

            otherwise
                ix = find([files.station_name]==station_filter);
                files = files(ix,:);
        end

        % Make hourly, daily and monthly sums of data for L2 data
        for ia = 1:length(files)

            filename = [files(ia).folder,filesep,files(ia).name];
            disp(['==== Reading file ',filename])
            tabledata = readtable(filename,'ReadVariableNames',true );

            if ismember('time', tabledata.Properties.VariableNames) == 1
                Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.time);
                Timetabledata = removevars(Timetabledata, 'time');
            else
                Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.Time);
                Timetabledata = removevars(Timetabledata, 'Time');
                Timetabledata.Properties.DimensionNames{1} = 'Time';
            end
            % Retime tables to new timesteps
            hourly_data = retime(Timetabledata,'hourly','mean');

            % Recalculate accumulative albedo is sw exist
            if ismember('sw_in',hourly_data.Properties.VariableNames) && ismember('sw_out',hourly_data.Properties.VariableNames)
                hourly_data.Albedo_acc = Albedo_24hr_acc(hourly_data.sw_in, hourly_data.sw_out,duration(00,60,00));
            else
            end

            daily_data = retime(hourly_data,'daily','mean');
            monthly_data = retime(daily_data,'monthly','mean');

            % Write data to folder
            fname = strrep(filename,'L2_','L2_hourly_');
            disp(['Writing clean file to: ', char(fname)])
            writetimetable(hourly_data,fname,'Delimiter',',');

            % Write data to folder
            fname = strrep(filename,'L2_','L2_daily_');
            disp(['Writing clean file to: ', char(fname)])
            writetimetable(daily_data,fname,'Delimiter',',');

            % Write data to folder
            fname = strrep(filename,'L2_','L2_monthly_');
            disp(['Writing clean file to: ', char(fname)])
            writetimetable(monthly_data,fname,'Delimiter',',');
            %disp(['==== Level 3 processing done ===='])
            disp( '=========================================================================')

        end
    otherwise
end
end

function fLevel3Aggregates(Level3Aggregates,process_years_from,process_years_to,station_filter,data_level,timestep)
% Make hourly, daily and monthly sums of data
switch Level3Aggregates
    case 'yes'
        disp(['==== Making aggregated tables (hour, day, month) ===='])
        files = read_file_structure(data_level,timestep);

        % Filter L1 files with years
        ix = find( ([files.year]>=process_years_from) & ([files.year]<=process_years_to));
        files = files(ix,:);
        % Filter stations to process

        switch station_filter
            case ''

            otherwise
                ix = find([files.station_name]==station_filter);
                files = files(ix,:);
        end

        % Make hourly, daily and monthly sums of data for L3 data

        for ia = 1:length(files)

            filename = [files(ia).folder,filesep,files(ia).name];
            disp(['==== Reading file ',filename])
            tabledata = readtable(filename,'ReadVariableNames',true );

            if ismember('time', tabledata.Properties.VariableNames) == 1
                Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.time);
                Timetabledata = removevars(Timetabledata, 'time');
            else
                Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.Time);
                Timetabledata = removevars(Timetabledata, 'Time');
                Timetabledata.Properties.DimensionNames{1} = 'Time';
            end
            % Retime tables to new timesteps
            hourly_data = retime(Timetabledata,'hourly','mean');

            % Recalculate accumulative albedo is sw exist
            if ismember('sw_in',hourly_data.Properties.VariableNames) && ismember('sw_out',hourly_data.Properties.VariableNames)
                hourly_data.Albedo_acc = Albedo_24hr_acc(hourly_data.sw_in, hourly_data.sw_out,duration(00,60,00));
            else
            end

            daily_data = retime(hourly_data,'daily','mean');
            monthly_data = retime(daily_data,'monthly','mean');

            % Write data to folder
            fname = strrep(filename,[data_level,'_'],[data_level,'_hourly_']);
            disp(['Writing clean file to: ', char(fname)])
            writetimetable(hourly_data,fname,'Delimiter',',');

            % Write data to folder
            fname = strrep(filename,[data_level,'_'],[data_level,'_daily_']);
            disp(['Writing clean file to: ', char(fname)])
            writetimetable(daily_data,fname,'Delimiter',',');

            % Write data to folder
            fname = strrep(filename,[data_level,'_'],[data_level,'_monthly_']);
            disp(['Writing clean file to: ', char(fname)])
            writetimetable(monthly_data,fname,'Delimiter',',');
            %disp(['==== Level 3 processing done ===='])
            disp( '=========================================================================')
%%
        end
    otherwise
end
end

function L1_files = fmakeL1FileStructure(rootdir,process_years_from,process_years_to,station_filter)
% Make the L1 file structure
disp( '=========================================================================')
disp(['Making L1 file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])

filelist = dir(fullfile(rootdir, '**',filesep,'*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
    filelist(i).L1_folder = endsWith(filelist(i).folder,[filesep','L1']);
end
L1_files = filelist([filelist.L1_folder]==1);

%% Make meta data
for i = 1:length(L1_files)
    newStr = split(L1_files(i).folder,filesep);
    newStr = split(newStr(end-1),'_');

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

    if sum(size(newStr) == 4) == 1
        newStr = split(newStr(4),'.');
        L1_files(i).year = str2num(string(newStr(1)));
    else % case for Gr_vh as the name has two letter name
        newStr = split(newStr(5),'.');
        L1_files(i).year = str2num(string(newStr(1)));
    end

end

L1_files = rmfield(L1_files, {'date', 'bytes', 'isdir', 'datenum', 'L1_folder'});

%% Filter L1 files with years
ix = find( ([L1_files.year]>=process_years_from) & ([L1_files.year]<=process_years_to));
L1_files = L1_files(ix,:);
% Filter stations to process
disp(['L1 file structure made at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])

switch station_filter
    case ''
        disp(['No filtering of L1 file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
    otherwise
        disp(['Filtering of stations from L1 file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
        ix = find([L1_files.station_name]==station_filter);
        L1_files = L1_files(ix,:);
end

end

function L2_files = fmakeL12FileStructure(rootdir,process_years_from,process_years_to,station_filter,L1_files)
% Make the L1 file structure
disp( '=========================================================================')
disp(['Making L2 file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])

%% Make L2 file structure
L2_files = L1_files;
for fi = 1:length(L2_files)
    L2_files(fi).folder = strrep([L2_files(fi).folder],'L1','L2');
    L2_files(fi).name = strrep([L2_files(fi).name],'L1','L2');
end
disp( '=========================================================================')

end

function L3_files = fmakeL3FileStructure(rootdir,process_years_from,process_years_to,station_filter,L1_files)
% Make the L1 file structure
disp( '=========================================================================')
disp(['Making L3 file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])

%% Make L2 file structure
L3_files = L1_files;
for fi = 1:length(L3_files)
    L3_files(fi).folder = strrep([L1_files(fi).folder],'L1','L3');
    L3_files(fi).name = strrep([L1_files(fi).name],'L1','L3');
end
disp( '=========================================================================')

end