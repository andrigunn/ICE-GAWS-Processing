% Update_GAWS with live data
% Copy loggernet files to L01 directories

disp('Updating GAWS data: Copy loggernet files to L01 directories')
clear dirs
% Raw data file location
dirs.raw.HNA09 = '\\lvvmlognet01\Maelingar\Vedur\Hofsjokull\HNA09';
dirs.L0.HNA09 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\hofsjokull\hofsjokull_þjorsarjokull_HNA09\L0\2022';

dirs.raw.B10 ='\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B10';
dirs.L0.B10 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Bruarjokull_B10\L0\2022';

dirs.raw.B13 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B13';
dirs.L0.B13 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Bruarjokull_B13\L0\2022';

dirs.raw.B16 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\B16'
dirs.L0.B16 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Bruarjokull_B16\L0\2022';

dirs.raw.T01 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T01';
dirs.L0.T01 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Tungnaarjokull_T01\L0\2022';

dirs.raw.T03 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T03';
dirs.L0.T03 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Tungnaarjokull_T03\L0\2022';

dirs.raw.T06 = '\\lvvmlognet01\Maelingar\Vedur\Vatnajokull\T06';
dirs.L0.T06 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Tungnaarjokull_T06\L0\2022';

site_name = fieldnames(dirs.raw);

for i = 1:length(site_name)

    fileList = dir([dirs.raw.(string(site_name(i))),'\*.dat']);

    for ii = 1:length(fileList)
        copyfile([fileList(ii).folder,filesep,fileList(ii).name], dirs.L0.(string(site_name(i))));
    end

end
%% Used to process older years
% clear dirs
% clc
% dirs.L0.B13 = 'C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Bruarjokull_B13\L0\2021';
% %C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\data\vatnajokull\vatnajokull_Bruarjokull_B10\L0\2018
% Make L1 data from L0 data
site_name = fieldnames(dirs.L0);

for i = 1:length(site_name)

    filename = dirs.L0.(string(site_name(i)))
    
    filename = dir([filename,filesep,'*_MET.dat']);
    T = readtable([filename.folder,filesep,(filename.name)]);

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
    
    fname = [foldername,filesep,sitename]
    writetimetable(TT,fname,'Delimiter',',')

end













