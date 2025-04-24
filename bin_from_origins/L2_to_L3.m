% Ice-GAWS
%% Level 2 to Level 3
% 
% Read L1 folders to structure
if ispc
    run('C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\bin\constants.m')
    Folder   = 'C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\data';
elseif ismac
	run('/Volumes/sentinel/Dropbox/01-IcelandicSnowObservatory-ISO/ICE-GAWS/bin/constants.m')
	Folder   = '/Volumes/sentinel/Dropbox/01-IcelandicSnowObservatory-ISO/ICE-GAWS/data';
end
    
FileList = dir(fullfile(Folder, '**', '*_L2_hourly*.csv'))
FileList = rmfield(FileList, {'date', 'bytes', 'isdir', 'datenum'});
%%
if ispc
    addpath('C:\Users\andrigun\Dropbox\Github_master\glacier_smb\afk')
elseif ismac
	addpath('/Volumes/sentinel/Dropbox/Github_master/glacier_smb/afk')
end
smb = make_smb;
%%
for i = 1:length(FileList)
    
    newStr = split(FileList(i).name,'_');
    x = size(newStr);
    
%     if x(1) == 5
        FileList(i).year = str2num(char(newStr(3)));
        FileList(i).siteName = newStr(2);
        
%     elseif x(1) == 6
%         %FileList(i).year = str2num(char(newStr(5)));
%         FileList(i).siteName = newStr(3);
%         
%     elseif x(1) == 4
%         %y = char(newStr(4));
%         %Yr = y(1:4);
%         %FileList(i).year = str2num(Yr);
%         
%         FileList(i).siteName = newStr(2);
%     end
    newStr = split(FileList(i).folder,filesep);
    FileList(i).mainGlacier = newStr(8);
end
% Rename variables
[FileList.name_L2] = FileList.name; FileList = rmfield(FileList,'name');
[FileList.folder_L2] = FileList.folder;  FileList = rmfield(FileList,'folder');

%% Add location information
opts = delimitedTextImportOptions("NumVariables", 5, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["year", "lat", "lon", "elevation", "site_name"];
opts.VariableTypes = ["double", "double", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "site_name", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "site_name", "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["year", "lat", "lon", "elevation"], "DecimalSeparator", ",");
opts = setvaropts(opts, ["year", "lat", "lon", "elevation"], "ThousandsSeparator", ".");

fname_location = 'C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\data\gaws_site_location_all_sites.csv';
loc = readtable(fname_location, opts);

proj = projcrs(3057);
disp('Mapping coordinates to file structure')
for i = 1:length(FileList);
   
        ix = find(FileList(i).year == loc.year & string(FileList(i).siteName) == string(loc.site_name));
    if isempty(ix);
    else
        FileList(i).lat = loc.lat(ix);
        FileList(i).lon = loc.lon(ix);
        FileList(i).ele = loc.elevation(ix);
    
        [x,y] = projfwd(proj,loc.lat(ix),-loc.lon(ix));
        FileList(i).ISN93_x = x;
        FileList(i).ISN93_y = y;
    end
end
%% Mapp observed smb data to structure
for i = 1:height(smb.A);
    newStr = split(smb.A.site(i),'_');
    smb.A.siteName(i) = newStr(1);
end

%% Renaming rules
    ix = find(string(smb.A.siteName) == 'K06')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Bard';
    end
    
    ix = find(string(smb.A.siteName) == 'hsa9')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'HNA09';
    end
    
    ix = find(string(smb.A.siteName) == 'hsa13')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'HNA13';
    end
    
        
    ix = find(string(smb.A.siteName) == 'Mved')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'MyrA';
    end
    
    ix = find(string(smb.A.siteName) == 'BR1')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Br01';
    end
    
    ix = find(string(smb.A.siteName) == 'BR1')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Br01';
    end
    
	ix = find(string(smb.A.siteName) == 'Br1')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Br01';
    end
    
	ix = find(string(smb.A.siteName) == 'Hof01')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Hoff';
    end
        
    ix = find(string(smb.A.siteName) == 'Hosp1')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Hosp';
    end
    
    ix = find(string(smb.A.siteName) == 'Hosp01')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Hosp';
    end
    
    ix = find(string(smb.A.siteName) == 'Hosp01')
    
    for i = 1:length(ix)
        smb.A.siteName{ix(i)} = 'Hosp';
    end

%%
for i = 1:length(FileList)
   
    ix = find(FileList(i).year == smb.A.year & string(FileList(i).siteName) == string(smb.A.siteName));
    
    if isempty(ix);
    else
        
        FileList(i).lat = smb.A.lat(ix);
        FileList(i).lon = smb.A.lon(ix);
        FileList(i).ele = smb.A.z(ix);
        
        FileList(i).bn = smb.A.bn(ix);
        FileList(i).bs = smb.A.bs(ix);
        FileList(i).bw = smb.A.bw(ix);
    
        [x,y] = projfwd(proj,smb.A.lat(ix),-smb.A.lon(ix));
        FileList(i).ISN93_x = x;
        FileList(i).ISN93_y = y;
    end
    
    %Special case for GF
    if FileList(i).siteName == string('Gf')
        FileList(i).lat = 64.4071297;
        FileList(i).lon = -17.2613699;
        FileList(i).ele = 1722;
        
        FileList(i).bn = NaN;
        FileList(i).bs = NaN;
        FileList(i).bw = NaN;
    
        [x,y] = projfwd(proj,smb.A.lat(ix),-smb.A.lon(ix));
        FileList(i).ISN93_x = x;
        FileList(i).ISN93_y = y;
    else
    end
    
end


%% 
for i = 1
    
    fname = [FileList(i).folder_L2,filesep,FileList(i).name_L2]
    siteName = string(FileList(i).siteName)
    %siteYear = string(FileList(i).year);
    
    disp(['Running for site: ',char(siteName)])
    clear Or M
    M = readtable(fname);
    Or = table2timetable(M);
    
    yr = Or.time.Year;
    TR = timerange([num2str(yr(1)),'-05-01 00:00:00'],[num2str(yr(1)),'-09-30 00:00:00']);
    Or = Or(TR,:);

%% Check if time is regular in table
[TF,dt] = isregular(Or);

if TF == 1
    disp('Data is regular in time')
else
    disp('Data is NOT regular in time')
    dt = unique(diff(Or.time))
end
%% Calculate surface temperature from LW - From Dirk van As and Stefan Boltzman

    if ismember('lw_in',Or.Properties.VariableNames) && ismember('lw_out',Or.Properties.VariableNames)
        disp('=> Calculate surface temperature from LW')
        Or.Tsurf_LW = SurfaceTemperature(Or.lw_out, Or.lw_in,c);
       [Or.Tsurf_SB, Or.Tsurf_0_SB, Or.ismelting_SB] = calculate_tsurf_from_lwin(Or);
        %Or = movevars(Or, 'ts', 'After', 't');
    else
    end
%% Calculate surface temperature from LW - From 

%% Calculate albedo    
	if ismember('sw_out',Or.Properties.VariableNames) && ismember('sw_in',Or.Properties.VariableNames)
        disp('=> Calculating albedo')
        dt = dt(1)
        Or.albedo_24hrSum = Albedo_sum(Or.sw_in, Or.sw_out,dt);
        Or.albedo = Or.sw_out./Or.sw_in;
    else
    end
 %%   
% Calculate energy balance
% Bæta við tjekkum á þessu

    if ismember('lw_in',Or.Properties.VariableNames)...
            && ismember('lw_out',Or.Properties.VariableNames)...
            && ismember('sw_out',Or.Properties.VariableNames)...
            && ismember('sw_in',Or.Properties.VariableNames)...
            && ismember('rh',Or.Properties.VariableNames)...
            && ismember('ps',Or.Properties.VariableNames);
        
        disp('=> Calculate Surface Energy Balance')
        [SEB] = Surface_Energy_Balance(Or,dt,c);
        yr = SEB.Time.Year;
        
        TR = timerange([num2str(yr(1)),'-05-01 00:00:00'],[num2str(yr(1)),'-09-30 00:00:00']);
        SEB_MJJAS = SEB(TR,:);
        
        %ix = find(SEB_MJJAS.melt_water<0);
        %SEB_MJJAS.melt_water(ix) = 0;
        
        ix = find(SEB_MJJAS.ts_seb<273);
        SEB_MJJAS.melt_water(ix) = 0;
        
        cs = cumsum(SEB_MJJAS.melt_water,'omitnan');
        FileList(i).aws_smb_seb = -max(cs)
        %ix = find(SEB_MJJAS.lw_out>300)
        %csf = cumsum(SEB_MJJAS.melt_water(ix),'omitnan') 
        %FileList(i).aws_smb_seb_tsurf_at_0 = -max(csf)
        
        
    else
    end
end
%% Plot SEB

close all
figure,
plot(SEB.Time, cumsum( SEB.mel,'omitnan'))

%% 

    % Write data
    folderName_L3 = [FileList(i).folder_L2(1:end-2),'L3']
    folderName_L3_original = [FileList(i).folder_L2(1:end-2),'L3',filesep,'original']
    folderName_L3_hourly = [FileList(i).folder_L2(1:end-2),'L3',filesep,'hourly']
    folderName_L3_daily = [FileList(i).folder_L2(1:end-2),'L3',filesep,'daily']
    %%
    %
    if exist(folderName_L2, 'dir')
    else
        mkdir(folderName_L2)
    end
    
    if exist(folderName_L2_original, 'dir')
    else
        mkdir(folderName_L2_original)
    end
    
    if exist(folderName_L2_hourly, 'dir')
    else
        mkdir(folderName_L2_hourly)
    end
    
    if exist(folderName_L2_daily, 'dir')
    else
        mkdir(folderName_L2_daily)
    end
    
    writetimetable(Or,...
        [folderName_L2_original,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_original.csv'],...
        'Delimiter',';')
    
    HH = retime(Or, 'hourly','mean');
    
    writetimetable(HH,...
        [folderName_L2_hourly,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_hourly.csv'],...
        'Delimiter',';')
    
    DM = retime(Or, 'daily','mean');
    
    writetimetable(DM,...
        [folderName_L2_daily,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_daily.csv'],...
        'Delimiter',';')
    
    
    

    
function Ts = SurfaceTemperature(lw_out, lw_in,c)

%((ds['ulr'] - (1 - emissivity) * ds['dlr']) / emissivity / 5.67e-8)**0.25 - T_0
A = (lw_out - (1 - c.emissivity_ice) * lw_in); 
B = (c.emissivity_ice * 5.67e-8);
C = (A./B).^0.25;
Ts = C-273,15;



%Ts = (((lw_out-(1-c.emissivity_ice)*lw_in)/(c.emissivity_ice*5.67*10^-8)).^0.25)-273.15;
    
    io = find(Ts>c.Ts_max);
    iu = find(Ts<c.TS_min);
    Ts(io) = 0;
    Ts(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.Ts_max), '°C'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.Ts_max), '°C'])

end


function albedo_sum = Albedo_sum(sw_in, sw_out,dt)
%%

D_10min = duration('00:10:00','InputFormat','hh:mm:ss');
D_1hour = duration('01:00:00','InputFormat','hh:mm:ss');

    if dt == D_10min;
        M1 = movsum(sw_in,12*6);
        M2 = movsum(sw_out,12*6);
        albedo_sum = (M2./M1);

    elseif dt == D_1hour
        M1 = movsum(sw_in,12);
        M2 = movsum(sw_out,12);
        albedo_sum = (M2./M1);

    end
    albedo_sum(albedo_sum>1)=NaN;
    albedo_sum(albedo_sum<0)=NaN;
end

function [Tsurf, Tsurf_0, ismelting] = calculate_tsurf_from_lwin(data);
%%
%data = GAWS.B10.DM;
%surf_ems = 0.97; %Surface longwave emissivity is set to 0.97. From GEUS
sig=double(5.6704E-8);% Stefan Boltzmann
ems=double(0.99);% Emissivity of snow

T4 = data.lw_out./(sig*ems);
Tsurf = nthroot(T4,4);

Tsurf_0 = Tsurf;
Tsurf_0(Tsurf_0>273.15) = 273.15;

ismelting = Tsurf;
ismelting(ismelting<273.15) = 0;
ismelting(ismelting>273.15) = 1;


Tsurf = Tsurf-273.15;
Tsurf_0 = Tsurf_0-273.15
end 






















