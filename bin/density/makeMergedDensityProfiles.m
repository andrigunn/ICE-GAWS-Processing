function makeMergedDensityProfiles(site,year,rootdir)
% Find dumped files from the Afk files.
%rootdir = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/'
%d = dir(rootdir'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data_aux\Initial State\density\*.dat')
%%
d = dir([rootdir,filesep,'data_aux',filesep,'Initial States',filesep,'density',filesep,'*.dat'])
%
for i = 1:length(d)
    c = split(d(i).name,'_');
    d(i).site = c(1);
    d(i).year = str2num(string(c(2)));
    d(i).month = str2num(string(c(3)));
    d(i).day = str2num(string(c(4)));
end
%
site = 'B16'
year = 0;
% Find the site and year we want

if year == 0
    disp 'Processing all available years'
    ixx = find(strcmp([d.site],site));
else
    disp 'Processing a single year'
    ixx = find(strcmp([d.site],site) & ([d.year]==year));
end
%
for i = 1:length(ixx)
    ix = ixx(i);
    Year = d(ix).year;

    obs_rho = readtable([d(ix).folder,filesep,d(ix).name]);
    obs_rho = removevars(obs_rho, "volume");

% Set sites as either ablation or accumulation
switch site
    case {'B16','B13'}
        accumulationOrablation = 'accumulation';

    case 'B10'
        accumulationOrablation = 'ablation';
end

switch accumulationOrablation

    case 'accumulation'
        % If we are located in the accumulation area we extent the profile
        % using density profile from Hofsjökull, data from ÞÞ
        hofs_rho = readtable([rootdir,filesep,'data_aux',filesep,'Initial States',filesep,'Hofsjokull_depth_density.csv']);
        %hofs_rho = readtable('C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data_aux\Initial State\Hofsjokull_depth_density.csv')
        hofs_rho.rho = hofs_rho.rho*1000;
     
        % Find the max depth of the obs profile
        maxDepth = obs_rho.depth(end);
        % Remove everything shallower than the max obs depth in Hofs core
        ix = find(hofs_rho.depth<=maxDepth);
        hofs_rho(ix,:) = [];
        % Merged core from Hofs deep core and observed annual density
        mergedCore = [obs_rho;hofs_rho];


    case 'ablation'
        % If we are located in the ablation area we extent the profile
        % using density profile of ice
        ice_rho = table();
        ice_rho.depth = (0:0.1:100)';
        ice_rho.rho = ones(length(ice_rho.depth),1)*913;
            %%
        % Find the max depth of the obs profile
        maxDepth = obs_rho.depth(end);
        % Remove everything shallower than the max obs depth in Hofs core
        ix = find(ice_rho.depth<=maxDepth);
        ice_rho(ix,:) = [];
        % Merged core from Hofs deep core and observed annual density
        mergedCore = [obs_rho;ice_rho];

    otherwise
end
% Write the merged core
fname = [site,'_',num2str(Year),'_mergedDensity.csv']
writetable(mergedCore,...
    [rootdir,filesep,'data_aux',filesep,'Initial States',filesep',fname],...
    'WriteVariableNames',0)

%
figure, hold on
plot(mergedCore.rho,mergedCore.depth)
set(gca, 'YDir','reverse')

end





