%% BreMyndavél 2019
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
opts = delimitedTextImportOptions("NumVariables", 10);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "f", "VarName8", "VarName9", "VarName10"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_BrMy\L0\2019\BreMy19t.dat", opts);
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
B = removevars(B, {'VarName8','VarName9','VarName10'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_BrMy_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_BrMy\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

% BreMyndavél 2020
clear tdata B
opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "f", "VarName8", "VarName9"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["decimalday", "year", "doy", "time", "t", "rh", "f", "VarName8", "VarName9"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_BrMy\L0\2020\BreMy20t.dat", opts);


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
B = removevars(B, {'VarName8','VarName9'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_BrMy_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_BrMy\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

% BreMyndavél 2019
opts = delimitedTextImportOptions("NumVariables", 10);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "f", "VarName8", "VarName9", "VarName10"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_BrMy\L0\2021\BreMy21t.dat", opts);
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
B = removevars(B, {'VarName8','VarName9','VarName10'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_BrMy_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_breidamerkurjokull_BrMy\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');
