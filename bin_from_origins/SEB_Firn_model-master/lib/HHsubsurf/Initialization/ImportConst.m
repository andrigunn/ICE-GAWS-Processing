function [c] = ImportConst(param)
% ImportConst: Reads physical, site-dependant, simulation-dependant and
% user-defined parameters from a set of csv files located in the ./Input
% folder. It stores all of them in the c structure that is then passed to
% all functions. Structures were found to be the fastest way of
% communicating values from one function to another.
%
% Author: Baptiste Vandecrux (bava@byg.dtu.dk)
% ========================================================================

%% Import constants for the transect-mode run ----------------------------
% originally the surface energy balance was designed to work on transects.
% This functionnality is not working anymore but might be implemented again
% later on.

filename = 'const_transect.csv';
delimiter = ';';
startRow = 2;
formatSpec = '%s%f%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
Parameter = dataArray{:, 1};
Value = dataArray{:, 2};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

for i=1:length(Parameter)
    eval(sprintf('c.%s=%f;',Parameter{i},Value(i)));
end

clear Parameter Value
c.rows = 176038;

%% Import constants regarding the station --------------------------------
filename = 'StationInfo.csv';
delimiter = ';';
startRow = 2;
formatSpec = '%s%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
StationInfo = table(dataArray{1:end-1}, 'VariableNames', {'stationname','latitude','longitude','elevationm','deepfirntemperaturedegC','slopedeg','meanaccumulationm_weq','InitialheightTm','InitialheightWSm'});
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

i_station = find(strcmp(param.station, StationInfo.stationname));
c.lat = StationInfo.latitude(i_station);
c.lon = StationInfo.longitude(i_station);
c.elev_AWS = StationInfo.elevationm(i_station);
c.ElevGrad = StationInfo.slopedeg(i_station)*pi/180; % converting slope in degrees to elevation gradient (dz/dx) in m/m positive downward
c.H_T = StationInfo.InitialheightTm(i_station);
c.H_WS = StationInfo.InitialheightWSm(i_station);
c.Tdeep_AWS = StationInfo.deepfirntemperaturedegC(i_station);
c.accum_AWS = StationInfo.meanaccumulationm_weq(i_station);

%% Import simulation constant -----------------------------------------------------------------------

filename = 'const_sim.csv';
delimiter = ';';
startRow = 1;
formatSpec = '%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
Parameter = dataArray{:, 1};
Value = dataArray{:, 2};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

for i=1:length(Parameter)
    if isempty(Parameter{i})
        continue
    end
    eval(sprintf('c.%s=%s;',Parameter{i},Value{i}));
end
clear Parameter Value

%% Import physical constants -----------------------------------------------------------------------
filename = 'const_phy.csv';
delimiter = {',',';'};
formatSpec = '%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[2,3,4]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';                result = regexp(rawData{row}, regexstr, 'names');
        
        try
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
        end
        
    end
end

rawNumericColumns = raw(:, [2,3,4]);
rawCellColumns = raw(:, [1,5]);
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric.lls
rawNumericColumns(R) = {NaN}; % Replace non-numeric.lls
Parameter = rawCellColumns(:, 1);
Value1 = cell2mat(rawNumericColumns(:, 1));
Value2 = cell2mat(rawNumericColumns(:, 2));
Value3 = cell2mat(rawNumericColumns(:, 3));
% clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;

for i=1:length(Parameter)
    switch Parameter{i}
        case {'ch1','ch2','ch3','cq1','cq2','cq3'}
            eval(sprintf('c.%s=[%f %f %f]',Parameter{i},Value1(i),Value2(i),Value3(i)));
        otherwise
            eval(sprintf('c.%s = %e;',Parameter{i},Value1(i)));
    end
end
% clear Parameter Value1 Value2 Value3

%% Import constants used by the subsurface model -----------------
filename = 'const_subsurf.csv';

delimiter = ';';
startRow = 1;
formatSpec = '%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
Parameter = dataArray{:, 1};
Value = dataArray{:, 2};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

for i=1:length(Parameter)
    if ~isempty(Parameter{i})
%         disp(sprintf('c.%s=%s;',strtrim(Parameter{i}),Value{i}))
        eval(sprintf('c.%s=%s;',strtrim(Parameter{i}),Value{i}));
    end
end
clear Parameter Value

%% Other global parameters

% Update B2017 now the thickness of a new layer is set to the fifth of the
% mean annual precipiation amount.
c.lim_new_lay = c.accum_AWS/c.new_lay_frac;


varname1 = fieldnames(c);
varname2 = fieldnames(param);
if param.verbose == 1
    fprintf('\nOverwriting default value for:\n');
end
for i = 1:length(varname1)
    for j =1:length(varname2)
        if strcmp(varname1(i),varname2(j))
            c.(char(varname1(i))) = param.(char(varname2(j)));
        end
    end
end
if c.verbose == 1
for i = 1:length(varname1)
    for j =1:length(varname2)
        if strcmp(varname1(i),varname2(j))           
            fprintf('%s %s %0.2e\n',char(varname1(i)),...
                repmat(' ',1,20-length(char(varname1(i)))),...
                param.(char(varname2(j))));
        end
    end
end
end
c.InputAWSFile = param.InputAWSFile;
c.station = param.station;

if isfield(param,'cdel') %if cdel has been defined in param
    c.cdel = param.cdel;
    c.z_ice_max     = length(c.cdel)-1;   % number of sub-surface levels
    c.jpgrnd = c.z_ice_max+1;
else
    c.z_ice_max     = c.z_max/c.dz_ice;   % number of sub-surface levels
    c.jpgrnd = c.z_ice_max+1;
%         c.cdel = ones(c.jpgrnd,1)*c.dz_ice;
    thick_cumul =  (1:c.jpgrnd).^4/c.jpgrnd^4 *c.z_max;
    c.cdel = [thick_cumul(1) thick_cumul(2:end) - thick_cumul(1:end-1)]';
    tmp = max(0,c.lim_new_lay - c.cdel);
    c.cdel = c.cdel + tmp - flipud(tmp);
end

c.rh2oice = c.rho_water/c.rho_ice;
c.cmid = zeros(c.jpgrnd,1);
c.rcdel = zeros(c.jpgrnd,1);

c.cdelsum = 0;
for jk = 1:c.jpgrnd
    c.cdelsum = c.cdelsum + c.cdel(jk);
    c.cmid(jk) = c.cdelsum - ( c.cdel(jk) / 2 );
    c.rcdel(jk) = 1/c.cdel(jk);
end
c.cdelV      =zeros(c.jpgrnd,1);
c.zdtime = c.delta_time;

% Determine local runoff time-scale  (Zuo and Oerlemans 1996). Parameters
% are set as in Lefebre et al (JGR, 2003) = MAR value (Fettweis pers comm)
c.t_runoff = (c.cro_1 + c.cro_2 * exp(- c.cro_3 * c.ElevGrad))*c.t_runoff_fact;
end

