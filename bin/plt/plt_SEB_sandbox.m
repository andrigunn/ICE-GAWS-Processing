ncdisp B16_rho.nc

rho = ncread("B16_rho.nc",'rho');
Depth = ncread("B16_rho.nc",'Depth');
time = ncread("B16_rho.nc",'time');

%%

figure, hold on
for i = 1:100:length(time)
    plot(rho(:,i),Depth(:,i))
end

%%
ncdisp B16_T_ice.nc



%%
B16 = ncstruct("B16_rfrz.nc")
B16.time = ncdateread("B16_surface.nc", 'time')

%%
close all
figure, hold on
    plot(B16.time,cumsum(B16.snowfall),'DisplayName','snowfall')
    plot(B16.time,cumsum(B16.runoff),'DisplayName','runoff')
    plot(B16.time,cumsum(B16.rainfall),'DisplayName','rainfall')
    plot(B16.time,cumsum(B16.sublimation_mweq),'DisplayName','sublimation_mweq')
legend show

%%
% SMB_mweq(k,j) =  snowfall(k,j) - runoff(k,j) ...
% + rainfall(k,j) + sublimation_mweq(k,j);




%%
snowthick = ncread("B16_surface.nc",'snowthick');
runoff = ncread("B16_surface.nc",'runoff');
H_comp = ncread("B16_surface.nc",'H_comp');
SMB_mweq = ncread("B16_surface.nc",'SMB_mweq');
meltflux = ncread("B16_surface.nc",'meltflux');
