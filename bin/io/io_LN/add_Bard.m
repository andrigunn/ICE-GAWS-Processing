%% Add Bard data 
% input is a *t.dat file from FP (some preprocessing from datalogger to dat
% file)
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
cd C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data
% time,f,HS,HS_mod,HS_nor,HS_obs,lw_out,d,sw_in,lw_in,t,sw_out,rh
%2010-04-17 21:10:00

opts = delimitedTextImportOptions("NumVariables", 13);
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "HS", "VarName10", "VarName11", "VarName12", "VarName13"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "HS", "VarName10", "VarName11", "VarName12", "VarName13"], "ThousandsSeparator", ",");

tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_bardarbunga_k06\L0\2019\bard19t.dat", opts);

a = num2str(tdata.time);
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
B = removevars(B, {'VarName10','VarName11','VarName12','VarName13'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Bard_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_bardarbunga_k06\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');
%%
opts = delimitedTextImportOptions("NumVariables", 14);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "HS", "VarName10", "VarName11", "VarName12", "VarName13"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");

tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_bardarbunga_k06\L0\2020\bard20t.dat", opts);

a = num2str(tdata.time);
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
B = removevars(B, {'VarName10','VarName11','VarName12','VarName13'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Bard_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_bardarbunga_k06\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');
%%
opts = delimitedTextImportOptions("NumVariables", 14);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = " ";
opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "rh", "sw_in", "sw_out", "HS", "VarName10", "VarName11", "VarName12", "VarName13"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";
% Specify variable properties
opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");

tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_bardarbunga_k06\L0\2022\bard22t.dat", opts);

a = num2str(tdata.time);
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
B = removevars(B, {'VarName10','VarName11','VarName12','VarName13'});

uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_Bard_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_bardarbunga_k06\L1\',sitename];
writetimetable(B,fname,'Delimiter',',');

%% 2023
datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss');
opts = delimitedTextImportOptions("NumVariables", 13);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["day", "year", "day1", "hhmm", "temp", "hum", "swin", "swout", "dist", "dist2", "tempbox", "volt", "albedo"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["day", "year", "day1", "hhmm", "temp", "hum", "swin", "swout", "dist", "dist2", "tempbox", "volt", "albedo"], "ThousandsSeparator", ",");

% Import the data
tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_bardarbunga_k06\L0\2023\bard23t.dat", opts);
clc
%%
a = num2str(tdata.hhmm);
a = strrep(string(a),'  10','0010');
a = strrep(string(a),'  20','0020');
a = strrep(string(a),'  30','0030');
a = strrep(string(a),'  40','0040');
a = strrep(string(a),'  50','0050');

a = char(a);
HH = str2num(a(:,1:2));
MM = str2num(a(:,3:4));
t = datetime(tdata.year,1,tdata.day1,(HH),(MM),0);

B = table2timetable(tdata,'RowTimes',t);
B = removevars(B, ["day","year","day1","hhmm","dist2",...
    "tempbox","volt","albedo"]);
B.Properties.VariableNames(1) = "t";
B.Properties.VariableNames(2) = "rh";
B.Properties.VariableNames(3) = "sw_in";
B.Properties.VariableNames(4) = "sw_out";
B.Properties.VariableNames(5) = "HS";
%%
uqy = unique(B.Time.Year);

sitename = ['ICE-GAWS_k06_L1_',num2str(uqy),'.csv'];
fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_bardarbunga_k06\L1\',sitename];
          
writetimetable(B,fname,'Delimiter',',');



