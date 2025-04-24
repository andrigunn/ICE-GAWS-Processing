function filtered_files = filter_files(files, station_name, year_from,year_to)
% station_name is 'all' to select all stations in the database
%%
switch station_name
    case 'all'

        station_name = [files.station_name];
        disp('filter_files: reading data for all stations')
        disp(['filter_files: reading from ',num2str(year_from),' to ', num2str(year_to)])
    otherwise
        station_name = station_name;
        disp(['filter_files: reading data for ',station_name])
        disp(['filter_files: reading from ',num2str(year_from),' to ', num2str(year_to)])
end

ix = contains([files.station_name], station_name,'IgnoreCase',true);

ffiles = files(ix);

ix = find(([ffiles.year]>= year_from) & ([ffiles.year]<= year_to));

filtered_files = ffiles(ix);

disp(['filter_files: found ',num2str(length(filtered_files)),' files'])
