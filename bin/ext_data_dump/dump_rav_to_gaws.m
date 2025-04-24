clear all
% Read inn all location to extract data from
if ispc
    gaws = readtable('C:\Users\andrigun\Dropbox\04-Repos\ICE-GAWS-Processing\meta\ICE-GAWS-location-summary.csv');
elseif isunix
    gaws = readtable('/data/gaws/ICE-GAWS-location-summary.csv');
end

%%

if ispc
    data_read_dir = '\\lvthrvinnsla\data\rav\data\';
    load('\\lvthrvinnsla\data\git\rav\geoR.mat')
    df = dir([data_read_dir,'\**\*.nc4']);
elseif isunix
    data_read_dir = '/data/rav/data/';
    load('/data/git/rav/geoR.mat')
    df = dir([data_read_dir,'/**/*.nc4']);

end

disp('### rav2dm ###')
disp(['Run started at ', datestr(now)])
disp(['Making data structure for forecast data'])

for i = 1:length(df)
    df(i).year = str2num(df(i).name(end-24:end-21));
    df(i).month = str2num(df(i).name(end-19:end-18));
    df(i).day = str2num(df(i).name(end-16:end-15));
    df(i).daten = datenum([df(i).year,df(i).month,df(i).day]);
end

[~,index] = sortrows([df.daten].'); df = df(index); clear index
df = rmfield(df, {'date', 'bytes', 'isdir', 'datenum'});

%%
clear RAV ncvars
uqy = unique([df.year]);
Uqy = uqy(uqy>=1990);

for y = 1:length(Uqy)
    ix = find([df.year]==Uqy(y));
    ds = df(ix,:);
    
%%
for i = 1:lenght(ds)
    fname = [ds(i).folder,filesep,ds(i).name];
    disp(fname)

    Lat = geoR.lat;
    Lon = geoR.lon;

    ni = ncinfo(fname);
    ncvars = {ni.Variables.Name};

    time = datevec(ncread(fname,'Times')');
    time = datetime(time(:,1),time(:,2),time(:,3),time(:,4),time(:,5),time(:,5),time(:,5));

    for k = 1:length(ncvars) % Cycle variables
        ncvar = ncvars(k);
        % Read data
        data = ncread(fname,string(ncvar));
        if i == 1
         RAV.(string(ncvar)) = timetable;
        else
        end
        % Cords of stations
        xq = gaws.lat_ave;
        yq = gaws.lon_ave;
        % Cords of nc data
        x = Lat(:);
        y = Lon(:);

        for j = 1:length(time)

            v = double(data(:,:,j));
            v = v(:);
            % Points extracted
            ts = griddata(x,y,v,xq,yq)';
            timestep = time(j);
            t = timetable((ts),'RowTimes',datetime(timestep));
            t = splitvars(t);
            t.Properties.VariableNames = gaws.station;

            RAV.(string(ncvar)) = [RAV.(string(ncvar));t];

        end
    end
end


FILENAME =['RAV_GAWS_',num2str(Uqy(y)),'.mat'];
SAVE(FILENAME,'RAV')

end











