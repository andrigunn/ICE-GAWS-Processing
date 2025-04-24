function convertL3GFtoSEB(filelistL3GF)
%%

for i = 1:length(filelistL3GF)

    filename = [filelistL3GF(i).folder,filesep,filelistL3GF(i).name];

    if contains(filelistL3GF(i).name,'L3GFC')
        datatype = 'C';
    elseif contains(filelistL3GF(i).name,'L3GFR')
        datatype = 'R';
    else 
    end


    gf_data = readtimetable(filename);

    seb_data = table;
    seb_data.Year = gf_data.Time.Year;
    seb_data.MonthOfYear = gf_data.Time.Month;
    seb_data.HourOfDayUTC = gf_data.Time.Hour;
    seb_data.DayOfYear = day(gf_data.Time,'dayofyear');
    seb_data.AirPressurehPa = gf_data.ps; %in hPa
    seb_data.AirPressurehPa_Origin = zeros(height(seb_data),1);
    seb_data.AirTemperature1C = gf_data.t;
    seb_data.AirTemperature1C_Origin = zeros(height(seb_data),1);
    seb_data.AirTemperature2C = gf_data.t;;
    seb_data.AirTemperature2C_Origin = zeros(height(seb_data),1);
    seb_data.RelativeHumidity1 = gf_data.rh;
    seb_data.RelativeHumidity1_Origin = zeros(height(seb_data),1);
    seb_data.RelativeHumidity2 = gf_data.rh;
    seb_data.RelativeHumidity2_Origin = zeros(height(seb_data),1);
    seb_data.WindSpeed1ms = gf_data.f;	
    seb_data.WindSpeed1ms_Origin = zeros(height(seb_data),1);	
    seb_data.WindSpeed2ms  = gf_data.f;		
    seb_data.WindSpeed2ms_Origin = ones(height(seb_data),1)+3;	
    seb_data.WindDirection1d = gf_data.d;	
    seb_data.WindDirection2d  = ones(height(seb_data),1)*-999;		
    seb_data.ShortwaveRadiationDownWm2 = gf_data.sw_in;	
    seb_data.ShortwaveRadiationDownWm2_Origin = zeros(height(seb_data),1);	
    seb_data.ShortwaveRadiationUpWm2 = gf_data.sw_out;	
    seb_data.ShortwaveRadiationUpWm2_Origin = zeros(height(seb_data),1);	
    seb_data.Albedo	= gf_data.Albedo_acc;
    seb_data.LongwaveRadiationDownWm2 = gf_data.lw_in;	
    seb_data.LongwaveRadiationDownWm2_Origin = zeros(height(seb_data),1);	
    seb_data.LongwaveRadiationUpWm2	= gf_data.lw_out;
    seb_data.LongwaveRadiationUpWm2_Origin = zeros(height(seb_data),1);	
    seb_data.HeightSensorBoomm = ones(height(seb_data),1)*2;
    seb_data.HeightStakesm = ones(height(seb_data),1)*1;	
    seb_data.IceTemperature1C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature2C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature3C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature4C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature5C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature6C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature7C = ones(height(seb_data),1)*-999;		
    seb_data.IceTemperature8C = ones(height(seb_data),1)*-999;		
    seb_data.time = ones(height(seb_data),1)*-999;		
    seb_data.HeightWindSpeed1m = ones(height(seb_data),1)*4;		
    seb_data.HeightWindSpeed2m = ones(height(seb_data),1)*4;		
    seb_data.HeightTemperature1m = ones(height(seb_data),1)*2;		
    seb_data.HeightTemperature2m = ones(height(seb_data),1)*2;		
    seb_data.HeightHumidity1m = ones(height(seb_data),1)*2;		
    seb_data.HeightHumidity2m = ones(height(seb_data),1)*2;		
    seb_data.SurfaceHeightm	= ones(height(seb_data),1)*0;	
    seb_data.Snowfallmweq = gf_data.Snowfallmweq;	
    seb_data.Rainfallmweq = gf_data.Rainfallmweq;	
    seb_data.DepthThermistor1m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor2m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor3m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor4m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor5m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor6m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor7m	= ones(height(seb_data),1)*-999;
    seb_data.DepthThermistor8m = ones(height(seb_data),1)*-999;
    
    % Make a new filename
    foldername = [filelistL3GF(i).folder,filesep];

    switch datatype
        case 'R'
            foldername_new = strrep(foldername,'L3GFR','L3GFR_SEB_input');
        case 'C'
            foldername_new = strrep(foldername,'L3GFC','L3GFC_SEB_input');
    end

    fname = [filelistL3GF(i).name];
    fname_new = strrep(fname,'csv','txt');

        switch datatype
        case 'R'
            fname_new = strrep(fname_new,'L3GFR','L3GFR_SEB_input');
        case 'C'
            fname_new = strrep(fname_new,'L3GFC','L3GFC_SEB_input');
        end
    
    
        if ~exist(foldername_new, 'dir')
         mkdir(foldername_new);
        end

     if i ==1
        disp(['Writing SEB input data files to: ', char([foldername_new])])
     else
     end

    disp(['Writing SEB input data file to: ', char([fname_new])])
    writetable(seb_data, [foldername_new,fname_new],'Delimiter','\t');

end

    disp(['Done writing SEB input data files'])
