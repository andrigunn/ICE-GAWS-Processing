function filename = L3_GapFiller_RCM(station,gap_fill_rcm,albedo_for_gap_fill,year_to_process,write_data_out )
%% ICE-GAWS-GapFilling
disp('### Running ICE-GAWS-GapFilling')
% Notes
% RAV is made from RAV+IceBox and Forecast for different periods
% Station name must exist in the /data/gaws/dump_xx location
% function returns filename to gap filled data (filename)
% Testing
%for yr = 1990:2022
    
  %station = 'B16';
  %gap_fill_rcm = 'carra';
  %albedo_for_gap_fill = 'modis';
  %year_to_process = yr;
  %write_data_out = 'yes';
  %plot_output = 'yes'
%
disp(['## Running gap filling for ',station,' in year ', num2str(year_to_process)])
%
files = read_file_structure('L3','hourly');
filtered_files = filter_files(files, string(station),...
    year_to_process,year_to_process);

filename = [filtered_files.folder,filesep,filtered_files.name];

% if isempty(filtered_files)
%     continue
% else
% end

%%
% ================= Extracting weather data ==============================
% Read data from the L3 input files
tabledata = readtable(filename,'ReadVariableNames',true );
%
if ismember('time', tabledata.Properties.VariableNames) == 1
    Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.time);
    Timetabledata = removevars(Timetabledata, 'time');
else
    Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.Time);
    Timetabledata = removevars(Timetabledata, 'Time');
    Timetabledata.Properties.DimensionNames{1} = 'Time';
end

data_out = Timetabledata;
year_to_process = data_out.Time.Year(1);
%
% data_checks_for_gaws_data
% Air temperature - t
if sum(strcmp(data_out.Properties.VariableNames,'t'))==1
    % Variable exists
    if ((nanmean(data_out.t)>100) || (nanmax(data_out.t)>35) || (nanmin(data_out.t)<-35))
        error('==>> check temperature data from gaws (t)')
        
    else
        disp('Temperature data from gaws within range (t)')
    end
else
end

% Air temperature - t2
if sum(strcmp(data_out.Properties.VariableNames,'t2'))==1
    % Variable exists
    if ((nanmean(data_out.t2)>100) || (nanmax(data_out.t2)>35) || (nanmin(data_out.t2)<-35))
        error('==>> check temperature data from gaws (t2)')
    else
        disp('Temperature data from gaws within range (t2)')
    end
else
end

% Relative humidity - rh
if sum(strcmp(data_out.Properties.VariableNames,'rh'))==1
    % Variable exists
    if ((nanmean(data_out.rh)<1) || (nanmax(data_out.rh)>101) || (nanmin(data_out.rh)<0))
        error('==>> check rh data from gaws')
    else
        disp('rh data from gaws within range')
    end
else
end
%
% Albedo
if sum(strcmp(data_out.Properties.VariableNames,'Albedo_acc'))==1
    % Variable exists
    if ((nanmean(data_out.Albedo_acc)>1) || (nanmax(data_out.Albedo_acc)>1) || (nanmin(data_out.Albedo_acc)<0))
        error('==>> check Albedo_acc data from gaws')
    else
        disp('Albedo_acc data from gaws within range')
    end
else
end

% ================= Gap fill weather data ==============================

switch gap_fill_rcm
    case 'rav'
        % Everything pre 2019 is pure rav
        % 2019 is rav out through August and then Icebox
        % 2020 is icebox until 1.April, then forecast
        % Everything post 2020 is forecast

        if year_to_process < 2019 % Notum RAV pre 2019
            % RAV
            if ispc
                d = dir(['\\lvthrvinnsla.lv.is\data\gaws\rav\*',station,'*.csv']);
            elseif ismac
                d = dir(['/Volumes/data/gaws/rav/*',station,'*.csv']);
            end
            gf_data = readtimetable([d.folder,filesep,d.name]);

            % ADD RH to RAV structure
            %fix zero and negative values
            thresh=7e-5;
            gf_data.Q2( gf_data.Q2 < thresh) = thresh;
            %vapor pressure, Pa, Peixoto and Oort (1996) Eq 3, p 3445
            gf_data.ea=gf_data.Q2.*(gf_data.PSFC./1000)/0.622;

            [ vp ] = SaturationVaporPressure( gf_data.T2, 'water');
            gf_data.RH = ((gf_data.ea)./(vp)).*100;
            gf_data.RH(gf_data.RH>100) = 100;
            gf_data.T2 = gf_data.T2-273.15;
            %Convert to hPa
            gf_data.PSFC = gf_data.PSFC/100;

        elseif year_to_process == 2019 %RAV + IceBox in 2019
            % Append IceBox to RAV
            if ispc
                d = dir(['\\lvthrvinnsla.lv.is\data\gaws\rav\*',station,'*.csv']);
            elseif ismac
                d = dir(['/Volumes/data/gaws/rav/*',station,'*.csv']);
            end
            %d = dir(['\\lvthrvinnsla.lv.is\data\gaws\rav\*',station,'*.csv']);
            gf_data_rav = readtimetable([d.folder,filesep,d.name]);
            gf_data_rav = removevars(gf_data_rav,...
                ["GRAUPELNC","HFX","LH","OLR","QFX","TH2"]);

            endofrav = gf_data_rav.Time(end);
               if ispc
                    d = dir(['\\lvthrvinnsla.lv.is\data\gaws\icebox\*',...
                station,'*.csv']);
               elseif ismac
                    d = dir(['/Volumes/data/gaws/icebox/*',...
                station,'*.csv']);
               end
            gf_data_icebox = readtimetable([d.folder,filesep,d.name]);
            gf_data_icebox = removevars(gf_data_icebox, "QFX");

            ix = find(gf_data_icebox.Time > endofrav);

            gf_data = [gf_data_rav;gf_data_icebox(ix,:)];

            % ADD RH to RAV structure
            %fix zero and negative values
            thresh=7e-5;
            gf_data.Q2( gf_data.Q2 < thresh) = thresh;
            %vapor pressure, Pa, Peixoto and Oort (1996) Eq 3, p 3445
            gf_data.ea=gf_data.Q2.*(gf_data.PSFC./1000)/0.622;
            [ vp ] = SaturationVaporPressure( gf_data.T2, 'water');
            gf_data.RH = ((gf_data.ea)./(vp)).*100;
            gf_data.RH(gf_data.RH>100) = 100;
            % Convert to hPa
            gf_data.PSFC = gf_data.PSFC/100;
            gf_data.T2 = gf_data.T2-273.15;

        elseif year_to_process == 2020 % Icebox + Forecast in 2020
            %
              if ispc
                    d = dir(['\\lvthrvinnsla.lv.is\data\gaws\icebox\*',...
                station,'*.csv']);
               elseif ismac
                    d = dir(['/Volumes/data/gaws/icebox/*',...
                station,'*.csv']);
               end
            %d = dir(['\\lvthrvinnsla.lv.is\data\gaws\icebox\*',...
             %   station,'*.csv']);
            gf_data_icebox = readtimetable([d.folder,filesep,d.name]);
            gf_data_icebox = removevars(gf_data_icebox, ["QFX","RAINC"]);
            gf_data_icebox = removevars(gf_data_icebox, "SNOW");
            gf_data_icebox = retime(gf_data_icebox,'hourly');

              if ispc
                    d = dir(['\\lvthrvinnsla.lv.is\data\gaws\forecast\*',...
                station,'*.csv']);
               elseif ismac
                    d = dir(['/Volumes/data/gaws/forecast/*',...
                station,'*.csv']);
              end

            % d = dir(['\\lvthrvinnsla.lv.is\data\gaws\forecast\*',...
            %     station,'*.csv']);
            gf_data_forecast = readtimetable([d.folder,filesep,d.name]);
            gf_data_forecast.SNOWNC = ...
            gf_data_forecast.SR.*gf_data_forecast.RAINNC;
            gf_data_forecast = movevars(...
            gf_data_forecast, "SNOWNC", "Before", "SR");
            gf_data_forecast = removevars(gf_data_forecast, "RH");
            gf_data_forecast.T2 = gf_data_forecast.T2+273.15;

            endoficebox = gf_data_icebox.Time(end);

            ix = find(gf_data_forecast.Time > endoficebox);

            gf_data = [gf_data_icebox;gf_data_forecast(ix,:)];

            thresh=7e-5;
            gf_data.Q2( gf_data.Q2 < thresh) = thresh;
            %vapor pressure, Pa, Peixoto and Oort (1996) Eq 3, p 3445
            gf_data.ea=gf_data.Q2.*(gf_data.PSFC./1000)/0.622;
            [ vp ] = SaturationVaporPressure( gf_data.T2, 'water');
            gf_data.RH = ((gf_data.ea)./(vp)).*100;
            gf_data.RH(gf_data.RH>100) = 100;
            %Convert to hPa
            gf_data.PSFC = gf_data.PSFC/100;
            %
            gf_data.T2 = gf_data.T2-273.15;
            % remove a singular spike in the data
            ix = find(gf_data.T2 < -40);
            gf_data.T2(ix) = NaN;
        elseif year_to_process > 2020 %Forecast eftir 2020
            %

              if ispc
                    d = dir(['\\lvthrvinnsla.lv.is\data\gaws\forecast\*',...
                station,'*.csv']);
               elseif ismac
                    d = dir(['/Volumes/data/gaws/forecast/*',...
                station,'*.csv']);
              end
            %d = dir(['\\lvthrvinnsla.lv.is\data\gaws\forecast\*',...
               % station,'*.csv']);
            gf_data_forecast = readtimetable([d.folder,filesep,d.name]);
            gf_data_forecast.SNOWNC =...
                gf_data_forecast.SR.*gf_data_forecast.RAINNC;
            gf_data_forecast = movevars(...
                gf_data_forecast, "SNOWNC", "Before", "SR");
            gf_data_forecast = removevars(gf_data_forecast, "RH");

            gf_data = gf_data_forecast;

            thresh=7e-5;
            gf_data.Q2( gf_data.Q2 < thresh) = thresh;
            gf_data.PSFC = gf_data.PSFC*100;
            % remove a singular spike in the data
            ix = find(gf_data.PSFC < 600);
            gf_data.PSFC(ix) = NaN;
            %
            %vapor pressure, Pa, Peixoto and Oort (1996) Eq 3, p 3445
            gf_data.ea=gf_data.Q2.*(gf_data.PSFC./1000)/0.622;
            [ vp ] = SaturationVaporPressure( gf_data.T2+273.15, 'water');
            gf_data.RH = ((gf_data.ea)./(vp)).*100;
            gf_data.RH(gf_data.RH>100) = 100;
            ix = find(gf_data.T2 < -40);
            gf_data.T2(ix) = NaN;
            %convert to hPa
            gf_data.PSFC = gf_data.PSFC/100;
        end
        %
    case 'carra'
        %
        %d = dir(['\\lvthrvinnsla.lv.is\data\gaws\carra\*',char(station),'*.csv']);
        %

              if ispc
                d = dir(['\\lvthrvinnsla.lv.is\data\gaws\carra\*',char(station),'*.csv']);
               elseif ismac
                    d = dir(['/Volumes/data/gaws/carra/*',char(station),'*.csv']);
              end
        gf_data = readtimetable([d.folder,filesep,d.name]);
        % CARRA data has a shift of a few seconds in the timestamp.
        % Fixed with shift time to the nearest minute
        gf_data.Time = dateshift(gf_data.Time, 'start', 'hour', 'nearest');
        %
        % Rename some variables
        gf_data.RH = gf_data.r2;
        gf_data.T2 = gf_data.t2m-273.15;
        gf_data.SWDOWN = gf_data.ssrd;
        gf_data.PSFC = gf_data.sp;
        gf_data.TotalPrecipmweq = gf_data.tp;
        gf_data.GLW = gf_data.strd;
        
        % CARRA vars
        % '10 metre wind direction' => 'wdir10'
        % '10 metre wind speed' => 'si10'
        % 'Snow density' => 'rsn'
        % 'Snow depth water equivalent' => 'sd'
        % 'Surface pressure' => 'sp'
        % 'Surface runoff' => 'sro'
        % 'surface_downwelling_shortwave_flux_in_air' => 'ssrd'
        % 'Surface thermal radiation downwards' => 'strd'
        % 'Total Precipitation' => 'tp'
        % '2m temperature' => 't2m'

end
%
% Make a full table for the selected year
% find the timestep of the data_out
[TF,dt] = isregular(data_out);
% Make an timetable at the input data timestep
t1 = datetime(year_to_process,01,01,00,00,00);
t2 = datetime(year_to_process+1,01,01,00,00,00);

switch gap_fill_rcm
    case 'rav'
        time = t1:hours(1):t2;
    case 'carra'
        time = t1:hours(3):t2;
        % Retime GAWS data to CARRA timestep
        dt = hours(3);
        data_out = retime(data_out,'regular','mean','TimeStep',dt);
end

dummy = ones(length(time),1);

L3GF = timetable(dummy,'RowTimes',time);
% Fill table with GF data first
tr = timerange(L3GF.Time(1),L3GF.Time(end));
gf_data_f = gf_data(tr,:);

L3GF = synchronize(gf_data_f,data_out);
vn = L3GF.Properties.VariableNames;
L3GF.Properties.VariableNames = erase(vn,"_gf_data_f");
vn = L3GF.Properties.VariableNames;
L3GF.Properties.VariableNames = erase(vn,"_data_out");

% Longwave incoming
if sum(strcmp(L3GF.Properties.VariableNames,'lw_in'))==1
    % Variable exists
    ix = isnan(L3GF.lw_in);
    L3GF.lw_in(ix) = L3GF.GLW(ix);
else
    L3GF.lw_in = L3GF.GLW;
end
% Air temperature
if sum(strcmp(L3GF.Properties.VariableNames,'t'))==1
    % Variable exists
    ix = isnan(L3GF.t);
    L3GF.t(ix) = L3GF.T2(ix);
else
    L3GF.t = L3GF.T2;
end
% Relative humidity
if sum(strcmp(L3GF.Properties.VariableNames,'rh'))==1
    % Variable exists
    ix = isnan(L3GF.rh);
    L3GF.rh(ix) = L3GF.RH(ix);
else
    L3GF.rh = L3GF.RH;
end

switch gap_fill_rcm

    case 'rav'
        % Wind speed
        if sum(strcmp(L3GF.Properties.VariableNames,'f'))==1
            % Variable exists
            ix = isnan(L3GF.f);
            L3GF.f(ix) = sqrt(L3GF.V10(ix).^2+L3GF.U10(ix).^2);
        else
            L3GF.f = sqrt(L3GF.V10.^2+L3GF.U10.^2);
        end

    case 'carra'
        % Wind speed
        if sum(strcmp(L3GF.Properties.VariableNames,'f'))==1
            % Variable exists
            ix = isnan(L3GF.f);
            L3GF.f(ix) = L3GF.si10(ix);
        else
            L3GF.f = L3GF.si10;
        end
end
%
% Shortwave incoming
if sum(strcmp(L3GF.Properties.VariableNames,'sw_in'))==1
    % Variable exists
    ix = isnan(L3GF.sw_in);
    L3GF.sw_in(ix) = L3GF.SWDOWN(ix);
else
    L3GF.sw_in = L3GF.SWDOWN;
end

% Air pressure hPa
if sum(strcmp(L3GF.Properties.VariableNames,'ps'))==1
    % Variable exists
    ix = isnan(L3GF.ps);
    %L3GF.ps(ix) = L3GF.PSFC(ix)./100;
    L3GF.ps(ix) = L3GF.PSFC(ix);
else
    L3GF.ps = L3GF.PSFC;%./10;
end

% Make TotalRainfallmweq (Rain + snow)
if sum(strcmp(L3GF.Properties.VariableNames,'TotalPrecipmweq'))==1
    % Variable exists, never exists
else
    L3GF.TotalPrecipmweq = L3GF.RAINNC;
    % lag one ts to make hrly precip
    L3GF_lag = lag(L3GF);
    L3GF.TotalPrecipmweq  = (L3GF.TotalPrecipmweq-...
        L3GF_lag.TotalPrecipmweq)/1000;
    % treat HY shift
    ix = find(L3GF.TotalPrecipmweq<0);
    L3GF.TotalPrecipmweq(ix) = 0;
    % treat nans
    ix = isnan(L3GF.TotalPrecipmweq);
    L3GF.TotalPrecipmweq(ix) = 0;
end
%
switch gap_fill_rcm

    case 'rav'
        % Make Snowfallmweq (snow)
        if sum(strcmp(L3GF.Properties.VariableNames,'Snowfallmweq'))==1
            % Variable exists, never exists
        else
            L3GF.Snowfallmweq = L3GF.SNOWNC;
            % lag one ts to make hrly precip
            L3GF_lag = lag(L3GF);
            L3GF.Snowfallmweq  = (L3GF.Snowfallmweq...
                -L3GF_lag.Snowfallmweq)/1000;
            % treat HY shift
            ix = find(L3GF.Snowfallmweq<0);
            L3GF.Snowfallmweq(ix) = 0;
            % treat nans
            ix = isnan(L3GF.Snowfallmweq);
            L3GF.Snowfallmweq(ix) = 0;
        end

        % Make Rainfallmweq (rain)
        if sum(strcmp(L3GF.Properties.VariableNames,'Rainfallmweq'))==1
            % Variable exists, never exists
        else
            L3GF.Rainfallmweq = L3GF.TotalPrecipmweq-L3GF.Snowfallmweq;
            ix = find(L3GF.Rainfallmweq<0);
            L3GF.Rainfallmweq(ix) = 0;
            % treat nans
            ix = isnan(L3GF.Rainfallmweq);
            L3GF.Rainfallmweq(ix) = 0;
        end
    case 'carra'
        % Need to dwl snow and rain
end

switch string(albedo_for_gap_fill)
    case {'modis'}
        % Add albedo from MODIS
        if ispc
        d = dir(['\\lvthrvinnsla.lv.is\data\gaws\modis\*',char(station),'*.csv']);
        elseif ismac
            d = dir(['/Volumes/data/gaws/modis/*',char(station),'*.csv']);
        end
        gf_modis = readtimetable([d.folder,filesep,d.name]);
%%fixing
        switch gap_fill_rcm
            case 'rav'
                gf_modis = retime(gf_modis,'hourly','linear');
            case 'carra' 
                gf_modis = retime(gf_modis,'regular','mean','TimeStep',hours(3));
        end

        gf_modis.R_median_filter_albe_GFD=gf_modis.R_median_filter_albe_GFD./100;
        tr = timerange(L3GF.Time(1),L3GF.Time(end));
        gf_modis_f = gf_modis(tr,:);

        L3GF = synchronize(L3GF,gf_modis_f);
        %
        if sum(strcmp(...
                L3GF.Properties.VariableNames,'Albedo_acc'))==1
            % Variable exists
            ix = isnan(L3GF.Albedo_acc);
            L3GF.Albedo_acc(ix) =...
                L3GF.R_median_filter_albe_GFD(ix);

        else
            L3GF.Albedo_acc = L3GF.R_median_filter_albe_GFD;

        end

    otherwise
        disp('No gap filling for albedo')
end
%
% Calculated variables and various fiffs
%sw_out from MODIS albedo and sw_in from RCM

if sum(strcmp(L3GF.Properties.VariableNames,'sw_out'))==1
    % Variable exists
    ix = isnan(L3GF.sw_out);
    L3GF.sw_out(ix) =...
        L3GF.sw_in(ix).*(L3GF.R_median_filter_albe_GFD(ix));
else
    L3GF.sw_out =...
        L3GF.sw_in.*(L3GF.R_median_filter_albe_GFD)
end
% Estimate outgoing longwave where it does not exist
if sum(strcmp(L3GF.Properties.VariableNames,'lw_out'))==1
    % Variable exists
    ix = isnan(L3GF.lw_out);
    L3GF.lw_out(ix) =...
        0.9800 * 5.6700e-08 * (L3GF.t(ix)+273.15).^4 - (1 - 0.9800) * L3GF.lw_in(ix);
else
    L3GF.lw_out =...
        0.9800 * 5.6700e-08 * (L3GF.t+273.15).^4 - (1 - 0.9800) * L3GF.lw_in;
end
%

switch gap_fill_rcm
    case 'rav'
        datalevel = 'L3GFR'

    case'carra'
        datalevel = 'L3GFC'
end
%
% clean and remove not to write out variables
        switch gap_fill_rcm
            case 'rav'
                remvars = {'Q2';'T2';'SNOW';'RAINNC';'RAINC';'SNOWNC';'SWDOWN';...
                    'GLW';'MSLP';'PSFC';'SR';'U10';'V10';'ea';'RH';'GRAUPELNC';...
                    'HFX';'LH';'OLR';'TH2';'QFX'};

            case 'carra'
                remvars = {'r2';'rsn';'sd';'si10';'sp';'sro';'ssrd';'strd';'t2m';'tp';...
                    'wdir10';'RH';'T2';'SWDOWN';'PSFC';'GLW'};
        end
        for i = 1:length(remvars)
            if sum(strcmp(L3GF.Properties.VariableNames,remvars(i)))==1
                L3GF = removevars(L3GF, remvars(i));
            else
            end
        end

% Data checks for L3GF data
% Air temperature - t to be in C°
if sum(strcmp(L3GF.Properties.VariableNames,'t'))==1
    % Variable exists
    if ((mean(L3GF.t)>100) || (max(L3GF.t)>35) || (min(L3GF.t)<-35))
        
        %error('==>> check temperature data from L3GF (t)')
        
    else
        disp('Temperature data from L3GF within range (t)')
    end
else
end
%
% Air temperature - t2 to be in C°
if sum(strcmp(L3GF.Properties.VariableNames,'t2'))==1
    % Variable exists
    if ((mean(L3GF.t2)>100) || (max(L3GF.t2)>35) || (min(L3GF.t2)<-35))
        error('==>> check temperature data from L3GF (t2)')
    else
        disp('Temperature data from L3GF within range (t2)')
    end
else
end

% Relative humidity - rh to be in 0-100%
if sum(strcmp(L3GF.Properties.VariableNames,'rh'))==1
    % Variable exists
    if ((mean(L3GF.rh)<1) || (max(L3GF.rh)>101) || (min(L3GF.rh)<0))
        error('==>> check rh data from L3GF')
    else
        disp('rh data from L3GF within range')
    end
else
end

% Albedo to be in 0-1
if sum(strcmp(L3GF.Properties.VariableNames,'Albedo_acc'))==1
    % Variable exists
    if ((nanmean(L3GF.Albedo_acc)>1) || (nanmax(L3GF.Albedo_acc)>1) || (nanmin(L3GF.Albedo_acc)<0))
        error('==>> check Albedo_acc data from L3GF')
    else
        disp('Albedo_acc data from L3GF within range')
    end
else
end

switch write_data_out
    case 'yes'
        foldername = replace(filtered_files.folder,'L3',datalevel);
        fname = replace(filtered_files.name,'L3',datalevel);
        filename = [foldername,filesep,fname];

        if exist(foldername, 'dir')
        else
            mkdir(foldername)
        end

        disp(['==== Writing clean file to: ', char(filename)])
        writetimetable(L3GF,filename,'Delimiter',',');
        disp(['==== Level 3 GapFilling processing done ===='])
    otherwise

end

plot_output = ''
switch plot_output

    case 'yes'
        figure, 
        x0=10;
        y0=150;
        width=1200;
        height=1800;
        set(gcf,'position',[x0,y0,width,height])
        stackedplot(L3GF,["TotalPrecipmweq",...
            "f","d","t","rh","ps","lw_in",...
            "lw_out","sw_in","sw_out","Albedo_acc"])
        title([num2str(year_to_process),' for ', station])

    otherwise
end

end