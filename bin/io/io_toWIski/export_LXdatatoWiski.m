%
clc
close all
% Til að Wiski lesi skrárnar þarf að setja þær í \\lvvmwiski\input\LV_Campbell8\
% Keyra þarf út bæði L1 og L2 skrár í sitthvora möppuna til að O og P raðir
% uppfærist. L1 fer í O raðir og L2 í P raðir
% Dateformat: "2021-05-02 11:40:00"
addpath C:\Users\andrigun\Dropbox\04-Repos\ICE-GAWS-Processing\bin\io

load('C:\Users\andrigun\Dropbox\04-Repos\ICE-GAWS-Processing\bin\io\io_toWIski\metheader.mat')
hinfo = METheader.Properties.VariableNames;

level_to_export = 'L1';
cd F:\Þróunarsvið\Rannsóknir\Jöklarannsóknir\08_Gögn\02_Veðurgögn\aws_to_wiski\
cd(level_to_export)

files = read_file_structure(level_to_export,'raw');

% Veljum ár sem við viljum keyra út. Passa að yfirkeyra ekki það sem er
% búið að hreinsa og laga í Wiski
filter_year = 2023;
ix = find([files.year]==filter_year);
files = files(ix,:);

%%
for i = 1:length(files)
    
    filename = [files(i).folder,filesep,files(i).name];
    disp(['==== Reading file ',filename])
    tabledata = readtable(filename,'ReadVariableNames',true );

glacier = char(files(i).main_glacier);

switch glacier
    case'vatnajokull'
        glacier = char(files(i).outlet_glacier);
        glacier = strcat(upper(glacier(1)),lower(glacier(2:end))); %catital first letter
        Glacier = [upper(glacier(1)),glacier(2:end)]%catital first letter
    otherwise
        glacier = char(files(i).main_glacier);
        glacier = strcat(upper(glacier(1)),lower(glacier(2:end))); %catital first letter
        Glacier = [upper(glacier(1)),glacier(2:end)]; %catital first letter
end

    station = char(files(i).station_name); 
        
    fileName = ['VST_',Glacier,'_',station,'_MET_',num2str(files(i).year),'.dat'];
    fileHeader = METheader;
    fileHeader.RECORD(1) = ['VST_',glacier,'_',station];
    
    switch level_to_export
        case 'L1'
            fileHeader.fsdev(1) = ['MET'];
        otherwise   
            fileHeader.fsdev(1) = ['MET_',level_to_export];
    end
% Map variables to header

    wiskitalble = table();

    if ismember('time', tabledata.Properties.VariableNames) == 1
        wiskitalble.TIMESTAMP = tabledata.time;
    else
        wiskitalble.TIMESTAMP = tabledata.Time;
    end

    wiskitalble.RECORD = linspace(1,height(tabledata), height(tabledata))';
    wiskitalble.volt = repelem([{''}], [height(tabledata)])'; % pad with NaNs

    if ismember('f', tabledata.Properties.VariableNames) == 1
        wiskitalble.f = tabledata.f;
    else
        wiskitalble.f =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('f_v', tabledata.Properties.VariableNames) == 1
        wiskitalble.f_v = tabledata.f_v;
    else
        wiskitalble.f_v = repelem([{''}], [height(tabledata)])';%nan(1,height(tabledata))';
    end

    if ismember('d', tabledata.Properties.VariableNames) == 1
        wiskitalble.d = tabledata.d;
    else
        wiskitalble.d =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('dsdev', tabledata.Properties.VariableNames) == 1
        wiskitalble.dsdev = tabledata.dsdev;
    else
        wiskitalble.dsdev =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('fsdev', tabledata.Properties.VariableNames) == 1
        wiskitalble.fsdev = tabledata.fsdev;
    else
        wiskitalble.fsdev =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('t', tabledata.Properties.VariableNames) == 1
         wiskitalble.t = tabledata.t;
    else
        wiskitalble.t =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('t2', tabledata.Properties.VariableNames) == 1
        wiskitalble.t2 = tabledata.t2;
    else
        wiskitalble.t2 =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('rh', tabledata.Properties.VariableNames) == 1
        wiskitalble.rh = tabledata.rh;
    else
        wiskitalble.rh =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('ps', tabledata.Properties.VariableNames) == 1
        wiskitalble.ps = tabledata.ps;
    else
        wiskitalble.ps =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('sw_in', tabledata.Properties.VariableNames) == 1
        wiskitalble.sw_in = tabledata.sw_in;
    else
        wiskitalble.sw_in =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('sw_out', tabledata.Properties.VariableNames) == 1
        wiskitalble.sw_out = tabledata.sw_out;
    else
        wiskitalble.sw_out =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('lw_in', tabledata.Properties.VariableNames) == 1
        wiskitalble.lw_in = tabledata.lw_in;
    else
        wiskitalble.lw_in =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('lw_out', tabledata.Properties.VariableNames) == 1
        wiskitalble.lw_out = tabledata.lw_out;
    else
        wiskitalble.lw_out =  repelem([{''}], [height(tabledata)])';
    end

    wiskitalble.RS =  repelem([{''}], [height(tabledata)])';
    wiskitalble.RL=  repelem([{''}], [height(tabledata)])';
    wiskitalble.RN =  repelem([{''}], [height(tabledata)])';

    if ismember('HS', tabledata.Properties.VariableNames) == 1
        wiskitalble.HS = tabledata.HS;
    else
        wiskitalble.HS =  repelem([{''}], [height(tabledata)])';
    end

    if ismember('HS2', tabledata.Properties.VariableNames) == 1
        wiskitalble.HS2 = tabledata.HS2;
    else
        wiskitalble.HS2 =  repelem([{''}], [height(tabledata)])';
    end

    writetable(fileHeader, fileName, 'WriteVariableNames', false)
    writetable(wiskitalble,fileName,'WriteMode','append')

end



