%
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
opts = delimitedTextImportOptions("NumVariables", 25);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
% Specify column names and types
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh2", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "VarName16", "VarName17", "HS", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L0\2019\BreNe19t.dat", opts);
tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens

a = num2str(tdata.time);
a = strrep(string(a),'   0','2400');
a = strrep(string(a),'  10','0010');
a = strrep(string(a),'  20','0020');
a = strrep(string(a),'  30','0030');
a = strrep(string(a),'  40','0040');
a = strrep(string(a),'  50','0050');

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0);

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName16','VarName17'});
B = removevars(B, {'VarName19','VarName20','VarName21','VarName22','VarName23','VarName24','VarName25'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Br01_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

opts = delimitedTextImportOptions("NumVariables", 24);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
%opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];

opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "VarName16", "VarName17", "HS", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
%opts = setvaropts(opts, ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L0\2020\BreNe20t.dat", opts);
tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens

%tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
%tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens

a = num2str(tdata.time);
a = strrep(string(a),'   0','2400');
a = strrep(string(a),'  10','0010');
a = strrep(string(a),'  20','0020');
a = strrep(string(a),'  30','0030');
a = strrep(string(a),'  40','0040');
a = strrep(string(a),'  50','0050');

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0);

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName16','VarName17','VarName19','VarName20','VarName21','VarName22','VarName23','VarName24'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Br01_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 25);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "VarName16", "VarName17", "HS", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L0\2021\BreNe21t.dat", opts);

tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
%tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
%tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens

a = num2str(tdata.time);
a = strrep(string(a),'   0','2400');
a = strrep(string(a),'  10','0010');
a = strrep(string(a),'  20','0020');
a = strrep(string(a),'  30','0030');
a = strrep(string(a),'  40','0040');
a = strrep(string(a),'  50','0050');

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0);

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName16','VarName17','VarName19','VarName20','VarName21','VarName22','VarName23','VarName24'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Br01_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

%% 2022

% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 25);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "VarName16", "VarName17", "HS", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");

% Import the data

tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L0\2022\BreNe22t.dat", opts);

tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
%tdata(1,:) = []; % fjarlægjum fyrsta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens
%tdata(end,:) = []; % fjarlægjum síðasta tímastimpilinn þar sem hann þarf að vera á árinu 2018 til að meika sens

a = num2str(tdata.time);
a = strrep(string(a),'   0','2400');
a = strrep(string(a),'  10','0010');
a = strrep(string(a),'  20','0020');
a = strrep(string(a),'  30','0030');
a = strrep(string(a),'  40','0040');
a = strrep(string(a),'  50','0050');

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0);

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, {'VarName16','VarName17','VarName19','VarName20','VarName21','VarName22','VarName23','VarName24'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Br01_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

%% 2023
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');

opts = delimitedTextImportOptions("NumVariables", 24);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["day", "year", "day1", "hhmm", "t", "t2", "rh", "h4m", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "notused", "notused1", "HS", "q", "HS2", "q2", "tboxx", "volt", "albedo"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["day", "year", "day1", "hhmm", "t", "t2", "rh", "h4m", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "notused", "notused1", "HS", "q", "HS2", "q2", "tboxx", "volt", "albedo"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L0\2023\BreNe23t.dat", opts);
tdata(1,:) = [];
% 
% a = num2str(tdata.hhmm);
% a = strrep(string(a),'   0','2400');
% a = strrep(string(a),'  10','0010');
% a = strrep(string(a),'  20','0020');
% a = strrep(string(a),'  30','0030');
% a = strrep(string(a),'  40','0040');
% a = strrep(string(a),'  50','0050');
% 
% a = char(a);
% HH = str2double(a(:,1:2)) % þarf að athuga með format
% MM = str2double(a(:,3:4));

t = datetime(tdata.day + datenum('2022/12/31'),'convertFrom','datenum');

t = dateshift(t, 'start', 'minute', 'nearest');

B = table2timetable(tdata,'RowTimes',t);

B = removevars(B, ["day","year","day1","hhmm"]);
B = removevars(B, ["h4m","notused","notused1","q"]);
B = removevars(B, ["tboxx","volt","albedo"]);
B = removevars(B, "q2");
B(end,:) = [];

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Br01_L1_',num2str(uqy),'.csv']
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');
%% 2024
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');

opts = delimitedTextImportOptions("NumVariables", 24);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["day", "year", "day1", "hhmm", "t", "t2", "rh", "h4m", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "notused", "notused1", "HS", "q", "HS2", "q2", "tboxx", "volt", "albedo"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["day", "year", "day1", "hhmm", "t", "t2", "rh", "h4m", "sw_in", "sw_out", "lw_in", "lw_out", "f", "d", "ps", "notused", "notused1", "HS", "q", "HS2", "q2", "tboxx", "volt", "albedo"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L0\2024\BreNe24t.dat", opts);
tdata(1,:) = [];
%% 
% a = num2str(tdata.hhmm);
% a = strrep(string(a),'   0','2400');
% a = strrep(string(a),'  10','0010');
% a = strrep(string(a),'  20','0020');
% a = strrep(string(a),'  30','0030');
% a = strrep(string(a),'  40','0040');
% a = strrep(string(a),'  50','0050');
% 
% a = char(a);
% HH = str2double(a(:,1:2)) % þarf að athuga með format
% MM = str2double(a(:,3:4));

t = datetime(tdata.day + datenum('2023/12/31'),'convertFrom','datenum');

t = dateshift(t, 'start', 'minute', 'nearest');

B = table2timetable(tdata,'RowTimes',t);

B = removevars(B, ["day","year","day1","hhmm"]);
B = removevars(B, ["h4m","notused","notused1","q"]);
B = removevars(B, ["tboxx","volt","albedo"]);
B = removevars(B, "q2");
B(end,:) = [];

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Br01_L1_',num2str(uqy),'.csv']
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_breidamerkurjokull_Br01\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');
