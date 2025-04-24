function makeMergedTempeeratureProfiles(site,year,rootdir)
% Reads ts dat files and adjust for SEB input data
%rootdir = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/'

%%
d = dir([rootdir,filesep,'data_aux',filesep,'Initial States',filesep,'temperature',filesep,'**',filesep,'*ts.dat'])

for i = 1:length(d)
    c = split(d(i).name,'_');
    d(i).site = c(1);
    d(i).year = str2num(string(c(2)));
    
end

site = 'B13'
year = 0;
% Find the site and year we want
if year == 0
    disp 'Processing all available years'
    ixx = find(strcmp([d.site],site));
else
    disp 'Processing a single year'
    ixx = find(strcmp([d.site],site) & ([d.year]==year));
end

for i = 1:length(ixx)
    ix = ixx(i);
    Year = d(ix).year;

    obs_temp = readtable([d(ix).folder,filesep,d(ix).name]);
    obs_temp = removevars(obs_temp, ["Q","Tmes"]);
    % Breytum cm í metra
    obs_temp.d = obs_temp.d/100;


% Write the merged core
fname = [site,'_',num2str(Year),'_mergedTemperature.csv']
writetable(obs_temp,...
    [rootdir,filesep,'data_aux',filesep,'Initial States',filesep',fname],...
    'WriteVariableNames',0)

%
figure, hold on
plot(obs_temp.Tcorr,obs_temp.d)
set(gca, 'YDir','reverse')

end





