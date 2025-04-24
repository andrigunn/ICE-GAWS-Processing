function GAWS_L2_WData = readDataFromWiskiToTimetable(stationName,getDataFrom,getDataTo,savedata,saveStationName)
%% Station to get data from. Full name not needed but needs to be unique

% stationName = 'B13';
% Period to get data from. Wiski has limitations on extent. If empty the
% full period will be attempted. Not likely to work.
% getDataFrom = datetime(2000,01,01,00,00,00,00);
% getDataTo = datetime(2000,12,31,00,00,00,00);
% Parameters to get. By default, only P series are fetched (L2 data). If
% left empty, all P parameters are fetched and setup in a GAWS L2 file.
getParameters = '';
disp('GAWS_L2_WData: Reading GAWS data from Wiski')
disp([' Station: ',stationName])
disp([' Period req. from: ',datestr(getDataFrom),' to ',datestr(getDataTo)])
save_name = ['ICE-GAWS_',saveStationName,'_L2_',num2str(year(getDataFrom)),'.csv'];
save_location = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\';

d = dir(([save_location,'**\ICE-GAWS_',saveStationName,'_L2_*']));
SaveName = [d(1).folder,filesep,save_name];

%% getGAWSfromWiski
% Get all meta data for Glacier weather station in Wiski. Returns names and
% station_id that is used for futher data extraction
disp('GAWS_L2_WData: getStationListURL')
getStationListURL = 'http://lvvmwiski:8080/KiWIS/KiWIS?service=kisters&type=queryServices&request=getStationList&datasource=0&format=objson&object_type=Glacier%20weather%20station&returnfields=station_name,station_no,site_name,object_type';
GawsStationsInWiski = webread(getStationListURL);

switch stationName
    case 'Breiða'
        station_ind = matches({GawsStationsInWiski.station_name},stationName);

    otherwise
        station_ind = contains({GawsStationsInWiski.station_name},stationName);

end

x = (sum(station_ind));

if x > 1
    GawsStationsInWiski(station_ind).station_name;
    error('ERROR: More than one station found')
elseif x == 0
    error('ERROR: No station found')
end
%
station_no = GawsStationsInWiski(station_ind).station_no;

disp(['GAWS_L2_WData: Found ',...
    GawsStationsInWiski(station_ind).station_name,...
    ' with id ',GawsStationsInWiski(station_ind).station_no])
%%
% Get timeseries list from station_id

getTimeseriesListURL = ['http://lvvmwiski:8080//KiWIS/KiWIS?service=',...
    'kisters&type=queryServices&request=getTimeseriesList&',...
    'datasource=0&format=objson&',...
    'station_no=',station_no,...
    '&returnfields=',...
    'station_name,station_no,ts_id,ts_name,parametertype_name,coverage,' ,...
    'stationparameter_longname,ts_type_name,ts_type_id,stationparameter_name'];

GAWSgetTimeseriesList = webread(getTimeseriesListURL);

%
switch getParameters
    case ''
        disp('  Getting all P parameters')
    otherwise
end

ts_ids_P = contains({GAWSgetTimeseriesList.ts_name},'P');
GetParameters = GAWSgetTimeseriesList(ts_ids_P);

% Remove battvolt
ts_ids_battvolt = contains({GetParameters.stationparameter_name},'Bat');
GetParameters(ts_ids_battvolt) = [];
% Add O-series for HS and HS2
ts_ids_HS_original = contains({GAWSgetTimeseriesList.ts_name},'O') &...
    contains({GAWSgetTimeseriesList.parametertype_name},'HS');

GetParameters = [GetParameters;GAWSgetTimeseriesList(ts_ids_HS_original)];
% Sort so AT is at top, has the longest timerange
[~,index] = sortrows({GetParameters.parametertype_name}.');
GetParameters = GetParameters(index); clear index

%% Check if data exist within the range asked for
dateMin = min(datetime({GetParameters.from},...
    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSX',...
    'Format', 'yyyy-MM-dd HH:mm:ss.SSS','TimeZone','local'));

dateMax = max(datetime({GetParameters.to},...
    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSX',...
    'Format', 'yyyy-MM-dd HH:mm:ss.SSS','TimeZone','local'));


% yearMin = year(dateMin)
% yearMax = year(dateMax)

if year(dateMin)> year(getDataFrom)
    GAWS_L2_WData = [];
    disp 'No times exists'
    return
else
    disp 'Times exist with data'
end


%% Loop throught time series id and build a table
outTables = struct();
    endrun = 0;

for i = 1:length(GetParameters)
    ts_id = GetParameters(i).ts_id;

    getTimeseriesValuesURL = ['http://lvvmwiski:8080/KiWIS/KiWIS?service=',...
        'kisters&type=queryServices&request=getTimeseriesValues&',...
        'datasource=0&format=dajson&',...
        'ts_id=',ts_id,...
        '&from=',datestr(getDataFrom,'YYYY-mm-dd'),...
        '&to=',datestr(getDataTo,'YYYY-mm-dd'),...
        '&dateformat=yyyy-MM-dd HH:mm:ss'];

    tsData = webread(getTimeseriesValuesURL);

    if isempty(tsData.data) == 1
        GAWS_L2_WData = [];
        disp(' Skipping parameter')

        continue

    else
    end

    % switch i
    %     case length(GetParameters)
    % 
    %         if isempty(fieldnames(outTables)) == 1
    %             GAWS_L2_WData = [];
    %             disp(' No data for year, returning')
    %             endrun = 1;
    %             return
    %         else
    % 
    %         end
    %     otherwise
    % 
    % end

    Ptype = string(GetParameters(i).ts_name);

    parName = string(GetParameters(i).stationparameter_name);
    switch parName
        case {'hs'}
            switch Ptype
                case 'P'
                    parName = string(GetParameters(i).stationparameter_name);
                    parName = 'HS_mod'; %clean
                case 'Pn'
                    parName = string(GetParameters(i).stationparameter_name);
                    parName = 'HS_nor'; %clean and normalize
                case 'O'
                    parName = string(GetParameters(i).stationparameter_name);
                    % original uncleaned data
                    parName = 'HS';
            end
        case 'hs2'
            switch Ptype
                case 'P'
                    parName = string(GetParameters(i).stationparameter_name);
                    parName = 'HS2_mod'; %clean
                case 'Pn'
                    parName = string(GetParameters(i).stationparameter_name);
                    parName = 'HS2_nor'; %clean and normalize
                case 'O'
                    parName = 'HS2';
            end
        otherwise
    end

    % Convert ugly json to table
    for ii = 1:length(tsData.data)
        ts = tsData.data{ii};
        time(ii) = ts(1);

        if isempty(cell2mat(ts(2)))
            value(ii) = NaN;
        else
            value(ii) = cell2mat(ts(2));
        end

    end
    % Make strucutre with timetables
    outTables.(parName) = timetable(value','RowTimes',datetime(time)');
    startTime(i) = outTables.(parName).Time(1);
    endTime(i) = outTables.(parName).Time(end);
    % Access the 'Time' variable
    timeVariable = outTables.(parName).Time;
    % Calculate time differences
    timeDifferences = diff(timeVariable);
    % Inspect the timestep
    timeStep(i) = mode(timeDifferences);
    tableSize(i) = length(outTables.(parName).Time);
end
%
switch endrun
    case 1

    otherwise
        table_timeStep = min(timeStep);
        table_start_time = min(startTime);
        table_end_time = max(endTime);

        tr = table_start_time:(table_timeStep):table_end_time; % max and min times
        %
        TT = timetable(ones(length(tr),1),'RowTimes',tr,'VariableNames',{'dummy'});
        fnames = fieldnames(outTables);
        %;
        for i = 1:length(fnames)

            TT = synchronize(TT,outTables.(string(fnames(i))));

        end
        % Fix names
        TT = removevars(TT, "dummy");
        fnames = strrep(fnames,'t_2m','t2');
        fnames = strrep(fnames,'wd','d');
        fnames = strrep(fnames,'ws','f');
        TT.Properties.VariableNames = fnames;

        GAWS_L2_WData = TT;
        %%
        switch savedata
            case 'yes'
                writetimetable(GAWS_L2_WData,SaveName,'Delimiter',',');
            otherwise
        end

end

