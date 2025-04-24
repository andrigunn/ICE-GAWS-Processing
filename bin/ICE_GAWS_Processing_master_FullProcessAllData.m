% Process and gap fill all sites 
% Read the list of stations dumped from CARRA/RAV
if ispc
    gaws = readtable('C:\Users\andrigun\Dropbox\04-Repos\ICE-GAWS-Processing\meta\ICE-GAWS-location-summary.csv');
elseif isunix
    
end
% All years
process_years_from = 2023;
process_years_to = 2023;

for i = 1:height(gaws)
    station_filter = string(gaws.station(i));
    ICE_GAWS_Processing_master(process_years_from,process_years_to,station_filter)
end
%%
