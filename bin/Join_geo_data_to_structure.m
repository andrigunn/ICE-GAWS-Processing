function files = Join_geo_data_to_structure(files)
%% read location table
ICE_GAWS_location = readtable('C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\ICE-GAWS-location.csv')
% Join location to files

for i = 1:length(files)

    ix = find([files(i).station_name] == ICE_GAWS_location.site_name)
    ix2 = find([files(i).year] == ICE_GAWS_location.year(ix))

    files(i).year = ICE_GAWS_location.year(ix(ix2));
    files(i).site_name2 = ICE_GAWS_location.site_name(ix(ix2));
    files(i).lat = ICE_GAWS_location.lat(ix(ix2));
    files(i).lon = ICE_GAWS_location.lon(ix(ix2));
    files(i).elevation = ICE_GAWS_location.elevation(ix(ix2));

end