function filelist = filterL3GFfiles(rootdir,process_years_from,process_years_to,station_filter,filltype)
% Search in structure for all L3GFR_hourly files
switch filltype
    case 'rav'
        filelist = dir(fullfile(rootdir, '**',filesep,'*L3GFR_hourly*'));  %get list of files and folders in any subfolder
    case 'carra'
        filelist = dir(fullfile(rootdir, '**',filesep,'*L3GFC_hourly*'));  %get list of files and folders in any subfolder
end
filelist = filelist(~[filelist.isdir]);  %r
%%
% Add meta data to the structure
for i = 1:length(filelist)
    newStr = split(filelist(i).folder,filesep);
    newStr = split(newStr(end-1),'_');

    x = size(newStr);

    if x(1) == 3
        filelist(i).main_glacier = string(newStr(1));
        filelist(i).outlet_glacier = string(newStr(2));
        filelist(i).station_name = string(newStr(3));

    else
        filelist(i).main_glacier = string(newStr(1));
        filelist(i).outlet_glacier = string(newStr(1));
        filelist(i).station_name = string(newStr(2));
    end

    newStr = split(filelist(i).name,'_');

    if sum(size(newStr) == 4) == 1
        newStr = split(newStr(4),'.');
        filelist(i).year = str2num(string(newStr(1)));
    else % case for Gr_vh as the name has two letter name
        newStr = split(newStr(5),'.');
        filelist(i).year = str2num(string(newStr(1)));
    end

end

filelist = rmfield(filelist, {'date', 'bytes', 'isdir', 'datenum'});
%%
% Filter L3GF files with years
ix = find( ([filelist.year]>=process_years_from) & ([filelist.year]<=process_years_to));
filelist = filelist(ix,:);
% Filter stations to process
disp(['L3GF file structure made at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])

switch station_filter
    case ''
        disp(['No filtering of L3GF file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
    otherwise
        disp(['Filtering of stations from L3GF file structure at ', datestr(now,'dd.mm.yyyy HH:MM:SS')])
        ix = find([filelist.station_name]==station_filter);
        filelist = filelist(ix,:);
end