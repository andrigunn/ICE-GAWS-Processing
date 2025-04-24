function data = filterRemoveMaxMin(data)
% ICE-GAWS
% Data filter
%%
disp('## Running filterRemoveMaxMin')

%%

t_over = find(data.t>const.upp_air_temp);
t_under = find(data.t<const.low_air_temp);

scatter(data.time(t_over),data.t(t_over))
scatter(data.time(t_under),data.t(t_under))

disp(['Found ', num2str(numel(t_over)),' value above ', num2str(const.upp_air_temp), '°C'])
disp(['Found ', num2str(numel(t_under)),' value below ', num2str(const.low_air_temp), '°C'])

data.t(t_over) = NaN;
data.t(t_under) = NaN;
%%
