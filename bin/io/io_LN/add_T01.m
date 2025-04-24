% add_T01
%% T01
clear all
%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 20);
% Specify range and delimiter
opts.DataLines = [11, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "BattVolt", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts = setvaropts(opts, ["RECORD", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "BattVolt", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS"], "ThousandsSeparator", ",");
% Import the data
T01_19 = readtable("\\lvvmlognet01\maelingar\Vedur\Vatnajokull\T01\2019\VST_Tungnaarjokull_T01_MET.dat", opts);
T01_19 = removevars(T01_19, ["RECORD","f_v","dsdev","fsdev","BattVolt","RS","RL","RN"]);
T01_19.HS2 = nan(length(T01_19.HS),1);

%%
opts = delimitedTextImportOptions("NumVariables", 20);

% Specify range and delimiter
opts.DataLines = [11, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "BattVolt", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts = setvaropts(opts, ["RECORD", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "BattVolt", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS"], "ThousandsSeparator", ",");

T01_20 = readtable("\\lvvmlognet01\maelingar\Vedur\Vatnajokull\T01\2020\VST_Tungnaarjokull_T01_MET.dat", opts);
T01_20 = removevars(T01_20, ["RECORD","f_v","dsdev","fsdev","BattVolt","RS","RL","RN"]);
T01_20.HS2 = nan(length(T01_20.HS),1);
%%
%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 21);

% Specify range and delimiter
opts.DataLines = [5, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts = setvaropts(opts, ["RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2"], "ThousandsSeparator", ",");

T01_21 = readtable("\\lvvmlognet01\maelingar\Vedur\Vatnajokull\T01\2021\VST_Tungnaarjokull_T01_MET.dat", opts);
T01_21 = removevars(T01_21, ["RECORD","volt","dsdev","fsdev","RS","RL","RN","f_v"]);
%%
% Merge to one
T01_19_21 = [T01_19;T01_20;T01_21];

% T01_19_21 = removevars(T01_19_21, {'RECORD','BattVolt'});
% T01_19_21 = removevars(T01_19_21, 'f_v');
% T01_19_21 = removevars(T01_19_21, {'dsdev','fsdev'});
% T01_19_21 = removevars(T01_19_21, {'RS','RL','RN'});

T01_19_21 = rmmissing(T01_19_21,'DataVariables','TIMESTAMP'); 

%%
T01CSV = table();
T01CSV.time = T01_19_21.TIMESTAMP;
T01CSV.HS = T01_19_21.HS;
T01CSV.HS_mod = nan(length(T01_19_21.HS),1);
T01CSV.HS_nor = nan(length(T01_19_21.HS),1);
T01CSV.HS_dif = nan(length(T01_19_21.HS),1);
T01CSV.HS_obs = nan(length(T01_19_21.HS),1);
T01CSV.lw_out = T01_19_21.lw_out;

T01CSV.lw_out = T01_19_21.lw_out;
T01CSV.d = T01_19_21.d;
T01CSV.sw_in = T01_19_21.sw_in;
T01CSV.lw_in = T01_19_21.lw_in;

T01CSV.lw_out = T01_19_21.lw_out;
T01CSV.f = T01_19_21.f;
T01CSV.sw_in = T01_19_21.sw_in;
T01CSV.lw_in = T01_19_21.lw_in;

T01CSV.t = T01_19_21.t;
T01CSV.sw_out = T01_19_21.sw_out;
T01CSV.rh = T01_19_21.rh;
T01CSV.ps = T01_19_21.ps;

T01CSV(1:2,:) = [];
%
B = table2timetable(T01CSV,'RowTimes',T01CSV.time);

B = removevars(B, 'time');
B.Properties.DimensionNames{1} = 'time'; 
clear uqy
%remove 2017 timestamps

ix = find([B.time.Year]==2017)
B(ix,:) = [];

uqy = unique(B.time.Year)
%
for i =1:length(uqy)
    
    ix = find([B.time.Year]==uqy(i));
    Bs = B(ix,:);
    
    sitename = ['ICE-GAWS_T01_L1_',num2str(uqy(i)),'.csv'];
    fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Tungnaarjokull_T01\L1\',sitename]
    writetimetable(Bs,fname,'Delimiter',',')

end
%%
