%% ICE-GAWS

if ispc
    addpath(genpath('C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS-Processing\bin'))
    dirs.gaws = 'F:\Þróunarsvið\Rannsóknir\Jöklarannsóknir\30_GAWS\HS_MOD\Data\mod_published_GAWS_data\';
    run('C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\bin\constants.m')
elseif ismac
    addpath(genpath('/Volumes/sentinel/Dropbox/01-IcelandicSnowObservatory-ISO/ICE-GAWS-Processing/bin'))
    dirs.gaws = '/Volumes/SameignLV/Þróunarsvið/Rannsóknir/Jöklarannsóknir/30_GAWS/HS_MOD/Data/mod_published_GAWS_data/';
    
elseif isunix
    
end
%% Find L0 files to process
L0_files = dir([dirs.gaws,'**',filesep,'*.csv']);
L0_files = rmfield(L0_files, {'date', 'bytes', 'isdir', 'datenum'});

% Mapp site names from file name
for i = 1:length(L0_files)
   L0_files(i).site_name = string(extractBetween(L0_files(i).name,"VST_","_QCFin"));
end
%%
disp('Loading constants')
constants;
% Read data from L0 files
i = 40
filename = [L0_files(i).folder,filesep,L0_files(i).name];
% Import data - L0 data
clear data
clc
disp(['Processing for file: ', L0_files(i).name])
data.L0 = readtable(filename,'ReadVariableNames',true ); 
data.L0 = table2timetable(data.L0,'RowTimes',data.L0.time);

% Data filters - L0 to L1
% Checks for data
% Remove unused variables
% Variables to remove
VarRemove = {'f2';'rh2';'f_QCfin';'f2_QCfin';'HS_QCfin';'lw_out_QCfin';...
    'd_QCfin';'sw_in_QCfin';'lw_in_QCfin';'t_QCfin';'t2_QCfin';...
    'sw_out_QCfin';'rh_QCfin';'rh2_QCfin'};
data.L0 = removeUnusedVars(data.L0, VarRemove);
% Check if time is regular in table
[TF,dt] = isregular(data.L0);

if TF == 1
    disp('Data is regular in time')
else
    disp('Data is NOT regular in time')
    dt = unique(diff(data.L0.Time))
end

tf = issorted(data.L0);

if tf == 1
    disp('Data is sorted')
else
    disp('Data is NOT sorted')
end
% Remove and replace max/min
data.L1 = filterRemoveMaxMin(data.L0,c);

%% L1 to L2
data.L1.Ts = SurfaceTemperature(data.L1.lw_out, data.L1.lw_in,c);
data.L1.CloudCover = CloudCover(data.L1.t,data.L1.Ts,data.L1.lw_in);
data.L1.Albedo_ori = Albedo(data.L1.sw_in, data.L1.sw_out);
data.L1.Albedo_sum = Albedo_sum(data.L1.sw_in, data.L1.sw_out, dt);

data.HH = retime(data.L1,'hourly','mean');

%% Gap filling needs to be added
%% L2 to L3
[SEB] = solveEnergyBalance(data,c);
%% Plot SEB
figure, hold on
tiledlayout(2,1)
nexttile, hold on
plot(SEB.DM.Time,SEB.DM.LHF,'DisplayName','LHF')
plot(SEB.DM.Time,SEB.DM.SHF,'DisplayName','SHF')
plot(SEB.DM.Time,SEB.DM.lw_in-SEB.DM.lw_out,'DisplayName','LWN')
plot(SEB.DM.Time,SEB.DM.sw_in-SEB.DM.sw_out,'DisplayName','SWN')
plot(SEB.DM.Time,SEB.DM.meltFlux,'DisplayName','MFLX')
%
%cumsum(SEB.DM.meltFlux,'omitnan')*.0.26
nexttile
plot(SEB.DM.Time,cumsum(SEB.DM.meltwater,'omitnan')) 


%%
legend show
grid on

title(filename)
%%

nexttile
plot(SEB.DM.Time,cumsum(SEB.DM.meltwater),'DisplayName','meltwater')


legend show
grid on






%%
function data = removeUnusedVars(data, VarRemove)
    disp(' ##   Removing additional data')
    for i = 1:length(VarRemove);
    if ismember(VarRemove(i),data.Properties.VariableNames)
        data = removevars(data, VarRemove(i));
    end
    end
end

function dout = filterRemoveMaxMin(data,c)
disp(' ##   Running filterRemoveMaxMin')

%%
if ismember('f',data.Properties.VariableNames)
    io = find(data.f>c.f_max);
    iu = find(data.f<c.f_min);
    data.f(io) = NaN;
    data.f(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.f_max), 'm/s'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.f_min), 'm/s'])
else
end
    
if ismember('t',data.Properties.VariableNames)
    io = find(data.t>c.t_max);
    iu = find(data.t<c.t_min);
    data.t(io) = NaN;
    data.t(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.t_max), '°C'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.t_min), '°C'])
else
end

if ismember('t2',data.Properties.VariableNames)
    io = find(data.t>c.t_max);
    iu = find(data.t<c.t_min);
    data.t2(io) = NaN;
    data.t2(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.t_max), '°C'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.t_min), '°C'])
else
end

if ismember('d',data.Properties.VariableNames)
    io = find(data.t>c.d_max);
    iu = find(data.t<c.d_min);
    data.d(io) = 360;
    data.d(iu) = 0;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.d_max), '°'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.d_min), '°'])
else
end

if ismember('sw_in',data.Properties.VariableNames)
    io = find(data.sw_in>c.sw_in_max);
    iu = find(data.sw_out<c.sw_in_min);
    data.sw_in(io) = NaN;
    data.sw_in(iu) = 0;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.sw_in_max), 'w/m^2'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.sw_in_min), 'w/m^2'])
else
end


dout = data;

end

function Ts = SurfaceTemperature(lw_out, lw_in,c)

%((ds['ulr'] - (1 - emissivity) * ds['dlr']) / emissivity / 5.67e-8)**0.25 - T_0

Ts = (((lw_out - (1 - c.emissivity_ice) * lw_in) / (c.emissivity_ice * 5.67e-8)).^0.25) - 273.15


%Ts = (((lw_out-(1-c.emissivity_ice)*lw_in)/(c.emissivity_ice*5.67*10^-8)).^0.25)-273.15;
    
    io = find(Ts>c.Ts_max);
    iu = find(Ts<c.TS_min);
    Ts(io) = 0;
    Ts(iu) = NaN;
    disp(['Found ', num2str(numel(io)),' value above ', num2str(c.Ts_max), '°C'])
    disp(['Found ', num2str(numel(iu)),' value below ', num2str(c.Ts_max), '°C'])

end

function CloudCover = CloudCover(T2,Ts,lw_in)

    LR_clear = 5.31*10^-14*(T2+273.15+Ts+273.15).^6; %clear sky downward longwave radiation
    LR_overcast = 5.67*10^-8*(T2+273.15+Ts+273.15).^4;

    CloudCover = (lw_in-LR_clear)./(LR_overcast-LR_clear);

    io = find(CloudCover>1);
    %iu = find(CloudCover<0);
    CloudCover(io) = 1;
    %CloudCover(iu) = 0;

end

function Albedo = Albedo(sw_in, sw_out)

    Albedo = sw_in./sw_out;
    Albedo(Albedo>1)=NaN;
    Albedo(Albedo<0)=NaN;

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



