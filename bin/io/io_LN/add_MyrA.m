datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
cd C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data

opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2019\MyrA19t.dat", opts);

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
B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%%
opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2020\MyrA20t.dat", opts);

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
B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%%
opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2021\MyrA21t.dat", opts);

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
B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')
%%
opts = delimitedTextImportOptions("NumVariables", 20);
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "lw_in", "lw_out", "f", "f1", "d", "HS", "loggertemp", "volt", "dontknow", "VarName20"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2022\MyrA22t.dat", opts);

a = num2str(tdata.time);
a = strrep(string(a),'  10','0010');
a = strrep(string(a),'  20','0020');
a = strrep(string(a),'  30','0030');
a = strrep(string(a),'  40','0040');
a = strrep(string(a),'  50','0050');

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

B = table2timetable(tdata,'RowTimes',t);
%
B = removevars(B, {'decimalday','year','doy','time'});
B = removevars(B, ["loggertemp","volt","dontknow","VarName20"]);

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
writetimetable(B,fname,'Delimiter',',')

%% 2023
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
opts = delimitedTextImportOptions("NumVariables", 22);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["time", "year", "day", "hhmm", "t", "t2", "rh", "rh2", "sw_in", "sw_out", "lw_in", "lw_out", "f", "f2", "d", "HS", "q1", "HS2", "q2", "tbox", "volt", "albedo"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, ["time", "year", "day", "hhmm", "t", "t2", "rh", "rh2", "sw_in", "sw_out", "lw_in", "lw_out", "f", "f2", "d", "HS", "q1", "HS2", "q2", "tbox", "volt", "albedo"], "ThousandsSeparator", ",");

% Import the data
if ispc
    tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2023\MyrA23t.dat", opts);
elseif ismac
    tdata = readtable("/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/myrdalsjokull/myrdalsjokull_MyrA/L0/2023/MyrA23t.dat", opts);
end
t = datetime(tdata.time + datenum('2022/12/31'),'convertFrom','datenum');
t = dateshift(t, 'start', 'minute', 'nearest');

B = table2timetable(tdata,'RowTimes',t);
B(1,:) = [];
B = removevars(B, ["time","year","day","hhmm"]);
B = removevars(B, ["q1","q2","tbox","volt","albedo"]);

uqy = unique(B.Time.Year)

sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
if ispc
    fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
elseif ismac
    fname = ['/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/myrdalsjokull/myrdalsjokull_MyrA/L1/',sitename]
end
writetimetable(B,fname,'Delimiter',',')






