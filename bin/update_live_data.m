% Update_GAWS with live data
% Copy loggernet files to L01 directories
%% Modified for 2024 data
disp('Updating GAWS data: Copy loggernet files to L01 directories')
clear dirs
% Raw data file location

if ispc
    dirs.raw.B13 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B13';
    dirs.L0.B13 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_Bruarjokull_B13\L0\2024';
    
    dirs.raw.B16 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B16';
    dirs.L0.B16 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_Bruarjokull_B16\L0\2024';
    
    dirs.raw.T03 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T03';
    dirs.L0.T03 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_Tungnaarjokull_T03\L0\2024';
    % 
    dirs.raw.T06 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T06';
    dirs.L0.T06 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_Tungnaarjokull_T06\L0\2024';
    
    dirs.raw.T01 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T01';
    dirs.L0.T01 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_Tungnaarjokull_T01\L0\2024';
    % 
    dirs.raw.HNA09 = '\\lvvmlognet01\Maelingar\Vedur\Hofsjokull\HNA09';
    dirs.L0.HNA09 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\hofsjokull\hofsjokull_þjorsarjokull_HNA09\L0\2024';
    
    dirs.raw.B10 ='\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B10';
    dirs.L0.B10 = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data\vatnajokull\vatnajokull_Bruarjokull_B10\L0\2024';

elseif ismac
    dirs.raw.B13 = '/Volumes/Maelingar/Vedur/Vatnajokull/B13';
    dirs.L0.B13 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/vatnajokull/vatnajokull_Bruarjokull_B13/L0/2024';
    
    dirs.raw.B16 = '/Volumes/Maelingar/Vedur/Vatnajokull/B16';
    dirs.L0.B16 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/vatnajokull/vatnajokull_Bruarjokull_B16/L0/2024';
    
    dirs.raw.T03 = '/Volumes/Maelingar/Vedur/Vatnajokull/T03';
    dirs.L0.T03 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/vatnajokull/vatnajokull_Tungnaarjokull_T03/L0/2024';
    % 
    dirs.raw.T06 = '/Volumes/Maelingar/Vedur/Vatnajokull/T06';
    dirs.L0.T06 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/vatnajokull/vatnajokull_Tungnaarjokull_T06/L0/2024';
    
    dirs.raw.T01 = '/Volumes/Maelingar/Vedur/Vatnajokull/T01';
    dirs.L0.T01 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/vatnajokull/vatnajokull_Tungnaarjokull_T01/L0/2024';
    % 
    dirs.raw.HNA09 = '/Volumes/Maelingar/Vedur/Hofsjokull/HNA09';
    dirs.L0.HNA09 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/hofsjokull/hofsjokull_þjorsarjokull_HNA09/L0/2024';
    
    dirs.raw.B10 ='/Volumes/Maelingar/Vedur/Vatnajokull/B10';
    dirs.L0.B10 = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data/vatnajokull/vatnajokull_Bruarjokull_B10/L0/2024';

end
%%
site_name = fieldnames(dirs.raw);

for i = 1:length(site_name)

    %fileList = dir([dirs.raw.(string(site_name(i))),'\*.dat']);
    fileList = dir([dirs.raw.(string(site_name(i))),filesep,'*.dat']);

    for ii = 1:length(fileList)
        yourFolder = dirs.L0.(string(site_name(i)));

          if ~exist(yourFolder, 'dir')
            mkdir(yourFolder)
          end

        copyfile([fileList(ii).folder,filesep,fileList(ii).name], dirs.L0.(string(site_name(i))));
        disp(['Copying ',dirs.L0.(string(site_name(i)))])
    end
end
%% Used to process older years
% Make L1 data from L0 data
site_name = fieldnames(dirs.L0);

for i = 1:length(site_name)

    siteName = site_name(i)
    filename = dirs.L0.(string(site_name(i)));
    % Find all files that contain MET
    filename = dir([filename,filesep,'*_MET*'])
    
    disp(['Found ', num2str(length(filename)), ' MET files'])
%%
    switch string(siteName)
        case 'T01'
            T = T01_merger();
        case 'B10'
            T = B10_merger();
        case 'HNA09'
            T = HNA09_merger()
        otherwise
            T = readtable([filename.folder,filesep,(filename.name)]);
    end
%%
    if ismember({'RECORD'}, T.Properties.VariableNames) == 1
        T = removevars(T, 'RECORD');
    else 
    end

    if ismember({'RN'}, T.Properties.VariableNames) == 1
        T = removevars(T, 'RN');
    else 
    end

    T = removevars(T, 'volt');
     
    if ismember({'TIMESTAMP'}, T.Properties.VariableNames) == 1
        TT = table2timetable(T,'RowTimes',T.TIMESTAMP);
        TT = removevars(TT, 'TIMESTAMP');

    elseif ismember({'TIME'}, T.Properties.VariableNames) == 1
        TT = table2timetable(T,'RowTimes',T.TIME);
        TT = removevars(TT, 'TIME');
    end

    if ismember({'f_v'}, TT.Properties.VariableNames) == 1
        TT = removevars(TT, {'f_v','dsdev','fsdev'});
    else
    end
    
    if ismember({'f_v'}, TT.Properties.VariableNames) == 1
        TT = removevars(TT, {'RS','RL','RN'});
    else
    end
  
    % Check that all data is within the same year
    uqy = unique(TT.Time.Year);

    if size(uqy(1)) > 1
        msg = 'More than one year in data. Fix *.dat input file from L0 (Loggernet)';
        error(msg)
    else
    end

    sitename = ['ICE-GAWS_',char(site_name(i)),'_L1_',num2str(uqy(1)),'.csv'];
    Fname = filename.folder;
    
    newStr = strrep(Fname,'L0','L1');
    foldername = newStr(1:end-5);%erase(newStr,"\2022");
    
    fname = [foldername,filesep,sitename];
    writetimetable(TT,fname,'Delimiter',',')

end


function T = T01_merger()

%% Set up the Import Options and import the data
clear all
opts = delimitedTextImportOptions("NumVariables", 21);
% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
% Import the data
if ismac
    T01_Jan_May = readtable("/Volumes/Maelingar/Vedur/Vatnajokull/T01/VST_Tungnaarjokull_T01_MET_Jan_May_2024.dat", opts);
elseif ispc
    T01_Jan_May = readtable("\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T01\VST_Tungnaarjokull_T01_MET_Jan_May_2024.dat", opts);
end
% Make Nans for DW data to pad the column
T01_Jan_May.DrawWire = NaN(1,height(T01_Jan_May))';
T01_Jan_May.r = NaN(1,height(T01_Jan_May))';
T01_Jan_May(16967:end,:) = [];
% Clear temporary variables
clear opts
opts = delimitedTextImportOptions("NumVariables", 23);
% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "r", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "DrawWire"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
% Import the data
if ismac
    T01_from_May = readtable("/Volumes/Maelingar/Vedur/Vatnajokull/T01/VST_Tungnaarjokull_T01_MET.dat", opts);
elseif ispc
    T01_from_May = readtable("\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T01\VST_Tungnaarjokull_T01_MET.dat", opts);
end
% Clear temporary variables
clear opts
%
T = [T01_Jan_May;T01_from_May];
%
%T = splitvars(timetable(T01.TIMESTAMP,T01))
% remove Nats
% Find Rows with NaT
rowsWithNaT = ismissing(T.TIMESTAMP);
T(rowsWithNaT, :) = [];
end

function  B = B10_merger()

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 21);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");

% Import the data
if ismac
    B10_Jan_May = readtable("/Volumes/Maelingar/Vedur/Vatnajokull/B10/VST_Bruarjokull_B10_MET_Jan-May24.dat", opts);
elseif ispc
    B10_Jan_May = readtable("\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B10\VST_Bruarjokull_B10_MET_Jan-May24.dat", opts);

end

B10_Jan_May.DrawWire = NaN(1,height(B10_Jan_May))';
B10_Jan_May.r = NaN(1,height(B10_Jan_May))';
B10_Jan_May(17510:end,:) = [];

% Clear temporary variables
clear opts

% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 23);

% Specify range and delimiter
opts.DataLines = [5, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "r", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "DrawWire"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts = setvaropts(opts, ["RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "r", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "DrawWire"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "r", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "DrawWire"], "ThousandsSeparator", ",");

% Import the data
if ismac
    B10_from_May = readtable("/Volumes/Maelingar/Vedur/Vatnajokull/B10/VST_Bruarjokull_B10_MET.dat", opts);
elseif ispc
    B10_from_May = readtable("\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B10\VST_Bruarjokull_B10_MET.dat", opts);
end


%% Clear temporary variables
clear opts

B = [B10_Jan_May;B10_from_May]
rowsWithNaT = ismissing(B.TIMESTAMP);
B(rowsWithNaT, :) = [];
end

function H = HNA09_merger()
%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 21);

% Specify range and delimiter
opts.DataLines = [4, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");

% Import the data
if ismac
    HNA09_Nov23_Mars24 = readtable("/Volumes/Maelingar/Vedur/Hofsjokull/HNA09/VST_Hofsjokull_HNA09_MET_2023_Nov_2024_Mars.dat", opts);
elseif ispc
    HNA09_Nov23_Mars24 = readtable("\\lvvmlognet01\Maelingar\Vedur\Hofsjokull\HNA09\VST_Hofsjokull_HNA09_MET_2023_Nov_2024_Mars.dat", opts);
end

HNA09_Nov23_Mars24.DrawWire = NaN(1,height(HNA09_Nov23_Mars24))';
%% Clear temporary variables
clear opts

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 22);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["TIMESTAMP", "RECORD", "volt", "f", "f_v", "d", "dsdev", "fsdev", "t", "t2", "rh", "ps", "sw_in", "sw_out", "lw_in", "lw_out", "RS", "RL", "RN", "HS", "HS2", "DrawWire"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "TIMESTAMP", "InputFormat", "yyyy-MM-dd HH:mm:ss");

% Import the data
if ismac
HNA09_from_Mars = readtable("/Volumes/Maelingar/Vedur/Hofsjokull/HNA09/VST_Hofsjokull_HNA09_MET.dat", opts);
elseif ispc
    HNA09_from_Mars = readtable("\\lvvmlognet01\Maelingar\Vedur\Hofsjokull\HNA09\VST_Hofsjokull_HNA09_MET.dat", opts);
end


%% Clear temporary variables
clear opts

H = [HNA09_Nov23_Mars24;HNA09_from_Mars];
rowsWithNaT = ismissing(H.TIMESTAMP);
H(rowsWithNaT, :) = [];
%Hendum út öllu sem er ekki 2024
ix = find(H.TIMESTAMP.Year==2023);

H(ix,:) =[];
end









