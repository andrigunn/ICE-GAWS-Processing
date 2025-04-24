function  c = findSEBinputFiles(station,yeartoprocess,gapfilledtype,rootdir) 
disp('## findSEBinputFiles')
disp(['### Finding input data for ', station, ' for ', num2str(yeartoprocess), ' using ' gapfilledtype])
% Reads in the station name, year and type of gap filled RCM. Adds the file
% locations to use to the "c" structure and returns the data in aws_data if
% needed
%%
% station = 'B16'
% yeartoprocess = 2016
% gapfilledtype = 'rav'
% Find gap filled SEB input data
switch gapfilledtype
    case 'rav'
        files = dir([rootdir,filesep,'**',filesep,'*L3GFR_SEB_input_hourly*.txt']);
    case 'carra'
        files = dir([rootdir,filesep,'**',filesep,'*L3GFC_SEB_input_hourly*.txt']);
end

for i = 1:length(files)
    C = split([files(i).name],'_');

    files(i).station = C(2);
    C2 = split(C(end),'.');
    files(i).year = str2num(char(C2(1)));

    if contains(C(3),'R')
        files(i).rcm = 'rav';
    elseif contains(C(3),'C')
        files(i).rcm = 'carra';
    end

end
files = rmfield(files, {'date', 'bytes', 'isdir', 'datenum'});

%% Filter witn input args and find met data to use
ix = find(([files.year] == yeartoprocess) &...
    (strcmp([files.station], station)==1));
    

c.InputAWSFile = [files(ix).folder,filesep,files(ix).name];
c.InputAWSFile_meta = files(ix);
%% Find density files
densityfiles = dir([rootdir,filesep,'data_aux',filesep,'Initial States',filesep,'*mergedDensity*']);
%
for i = 1:length(densityfiles)
    C = split([densityfiles(i).name],'_');

    densityfiles(i).station = C(1);
    densityfiles(i).year = str2num(char(C(2)));
end
densityfiles = rmfield(densityfiles, {'date', 'bytes', 'isdir', 'datenum'});

ix = find(([densityfiles.year] == yeartoprocess) &...
    (strcmp([densityfiles.station], station)==1));

c.InputDensityFile = [densityfiles(ix).folder,filesep,densityfiles(ix).name];
c.InputDensityFile_meta = densityfiles(ix);
%% Find temperature file
tempfiles = dir([rootdir,filesep,'data_aux',filesep,'Initial States',filesep,'*mergedTemp*']);

for i = 1:length(tempfiles)
    C = split([tempfiles(i).name],'_');

    tempfiles(i).station = C(1);
    tempfiles(i).year = str2num(char(C(2)));
end

ix = find(([tempfiles.year] == yeartoprocess) &...
    (strcmp([tempfiles.station], station)==1));

c.InputTemperatureFile = [tempfiles(ix).folder,filesep,tempfiles(ix).name];
c.InputTemperatureFile_meta = tempfiles(ix);

disp(['### Found InputAWSFile ', c.InputAWSFile])
disp(['### Found InputDensityFile ', c.InputDensityFile])
disp(['### Found InputTemperatureFile ', c.InputTemperatureFile])











