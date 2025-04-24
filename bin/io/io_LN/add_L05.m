datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
cd C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data

opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "VarName14", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\langjokull\langjokull_hagafellsjokull_L05\L0\2019\LaEf19t.dat", opts);

a = num2str(tdata.time);
a = strrep(string(a),'  10','0010')
a = strrep(string(a),'  20','0020')
a = strrep(string(a),'  30','0030')
a = strrep(string(a),'  40','0040')
a = strrep(string(a),'  50','0050')

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName14','VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_L05_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\langjokull\langjokull_hagafellsjokull_L05\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%
opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "VarName14", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\langjokull\langjokull_hagafellsjokull_L05\L0\2020\LaEf20t.dat", opts);

a = num2str(tdata.time);
a = strrep(string(a),'  10','0010')
a = strrep(string(a),'  20','0020')
a = strrep(string(a),'  30','0030')
a = strrep(string(a),'  40','0040')
a = strrep(string(a),'  50','0050')

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName14','VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_L05_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\langjokull\langjokull_hagafellsjokull_L05\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%
opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "VarName14", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\langjokull\langjokull_hagafellsjokull_L05\L0\2022\LaEf22t.dat", opts);

a = num2str(tdata.time);
a = strrep(string(a),'  10','0010')
a = strrep(string(a),'  20','0020')
a = strrep(string(a),'  30','0030')
a = strrep(string(a),'  40','0040')
a = strrep(string(a),'  50','0050')

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName14','VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_L05_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\langjokull\langjokull_hagafellsjokull_L05\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%% 2023
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');

opts = delimitedTextImportOptions("NumVariables", 19);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["time", "year", "day", "hhmm", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "q1", "HS2", "q2", "tbox", "volt", "albedo"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["time", "year", "day", "hhmm", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "q1", "HS2", "q2", "tbox", "volt", "albedo"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\langjokull\langjokull_hagafellsjokull_L05\L0\2023\LaEf23t.dat", opts);

t = datetime(tdata.time + datenum('2022/12/31'),'convertFrom','datenum');
t = dateshift(t, 'start', 'minute', 'nearest');

B = table2timetable(tdata,'RowTimes',t);
B(1,:) = [];
B = removevars(B, ["time","year","day","hhmm"]);
B = removevars(B, ["q1","q2","tbox","volt","albedo"]);

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_L05_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\langjokull\langjokull_hagafellsjokull_L05\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%% 2024
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
opts = delimitedTextImportOptions("NumVariables", 19);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["time", "year", "day", "hhmm", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "q1", "HS2", "q2", "tbox", "volt", "albedo"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, ["time", "year", "day", "hhmm", "t", "rh", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "HS", "q1", "HS2", "q2", "tbox", "volt", "albedo"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\langjokull\langjokull_hagafellsjokull_L05\L0\2024\LaEf24t.dat", opts);
%
% Extract hours and minutes from hhmm
hour = floor(tdata.hhmm / 100);       % Integer division to get hours
mint = mod(tdata.hhmm, 100);        % Modulus to get minutes

% Calculate the fractional part of the day in hours and minutes
fraction_of_day = tdata.day - floor(tdata.day); % Fractional part

% Combine to create datetime
datetime_obj = datetime(tdata.year, 1, 1) + days(tdata.day - 1) + ...
               hours(hour) + minutes(mint) + ...
               seconds(fraction_of_day * 86400); % Add fractional day

B = table2timetable(tdata,'RowTimes',datetime_obj);
%B(1,:) = [];
B = removevars(B, ["time","year","day","hhmm"]);
B = removevars(B, ["q1","q2","tbox","volt","albedo"]);

uqy = unique(B.Time.Year)
% Windátt röng, löguð hér.
B.d = mod(B.d  + 180, 360);

%Hendum úr port cal timabilum
B(1:860,:) = [];
% Breytum m í cm fyrir snjóhæð
B.HS2(:) = NaN; % HS2 er ekki til hér
B.HS = B.HS.*100;
%%
sitename = ['ICE-GAWS_L05_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\langjokull\langjokull_hagafellsjokull_L05\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
