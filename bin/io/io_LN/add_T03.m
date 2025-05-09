% add_T03
%% T03
clear all

filename = '\\lvvmlognet01\maelingar\Vedur\Vatnajokull\T03\2019\VST_Tungnaarjokull_T03_MET'
T03_19 = importfile_from_LoggerNetMEtFiles(filename);

filename = '\\lvvmlognet01\maelingar\Vedur\Vatnajokull\T03\2020\VST_Tungnaarjokull_T03_MET.dat.backup'
T03_20 = importfile_from_LoggerNetMEtFiles(filename);

filename = '\\lvvmlognet01\maelingar\Vedur\Vatnajokull\T03\VST_Tungnaarjokull_T03_MET'
T03_21= importfile_from_LoggerNetMEtFiles(filename);

% Merge to one
T03_19_21 = [T03_19;T03_20;T03_21];

T03_19_21 = removevars(T03_19_21, {'RECORD','volt'});
T03_19_21 = removevars(T03_19_21, 'f_v');
T03_19_21 = removevars(T03_19_21, {'dsdev','fsdev'});
T03_19_21 = removevars(T03_19_21, {'RS','RL','RN'});

T03_19_21 = rmmissing(T03_19_21,'DataVariables','TIMESTAMP'); 

%
T03CSV = table();
T03CSV.time = T03_19_21.TIMESTAMP;
T03CSV.HS = T03_19_21.HS;
T03CSV.HS_mod = nan(length(T03_19_21.HS),1);
T03CSV.HS_nor = nan(length(T03_19_21.HS),1);
T03CSV.HS_dif = nan(length(T03_19_21.HS),1);
T03CSV.HS_obs = nan(length(T03_19_21.HS),1);
T03CSV.lw_out = T03_19_21.lw_out;

T03CSV.lw_out = T03_19_21.lw_out;
T03CSV.d = T03_19_21.d;
T03CSV.sw_in = T03_19_21.sw_in;
T03CSV.lw_in = T03_19_21.lw_in;

T03CSV.lw_out = T03_19_21.lw_out;
T03CSV.f = T03_19_21.f;
T03CSV.sw_in = T03_19_21.sw_in;
T03CSV.lw_in = T03_19_21.lw_in;

T03CSV.t = T03_19_21.t;
T03CSV.sw_out = T03_19_21.sw_out;
T03CSV.rh = T03_19_21.rh;
T03CSV.ps = T03_19_21.ps;


%
B = table2timetable(T03CSV,'RowTimes',T03CSV.time);

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
    
    sitename = ['VST_Tungnarjokull_T03_QCFin_',num2str(uqy(i)),'_MOD.csv'];
    fname = ['C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\data\vatnajokull\vatnajokull_Tungnaarjokull_T03\L1\',sitename]
    writetimetable(Bs,fname,'Delimiter',',')

end
%%
function data = importfile_B10_2019(filename, dataLines)
%IMPORTFILE Import data from a text file
%  VSTBRUARJOKULLB10MET = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a table.
%
%  VSTBRUARJOKULLB10MET = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  VSTBruarjokullB10MET = importfile("\\lvvmlogneT03\maelingar\Vedur\Vatnajokull\B10\2019-2021\VST_Bruarjokull_B10_MET.dat.backup", [5, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 01-Oct-2021 10:44:03

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [5, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 23);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "ts", "tb"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts = setvaropts(opts, ["RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "ts", "tb"], "ThousandsSeparator", ",");

% Import the data
data = readtable(filename, opts);

end










