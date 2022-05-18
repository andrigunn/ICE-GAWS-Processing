% ICE-GAWS 
% Constant table

%% Filters for max and min removal 
c.t_max = 25;
c.t_min = -25;

c.f_max = 50;
c.f_min = 0;

c.d_max = 360;
c.d_min = 0;

c.rh_max = 100;
c.rh_min = 40;

c.sw_in_max = 1250;
c.sw_in_min = 0;

c.sw_out_max = 1250;
c.sw_out_min = 0;

c.lw_out_max = 500;
c.lw_out_min = 50;

c.Ts_max = 0;
c.TS_min = -80;

%% Constants for calculatios
c.emissivity_ice = 0.97;
c.es        = 0.622;    % 
c.es_0      = 6.1071    % saturation vapour pressure at the melting point (hPa);
c.es_100    = 1013.246  % saturation vapour pressure at steam point temperature (hPa);
c.em        = 0.98      % longwave surface emissivity;
c.RH_min    = 20;       %
c.WS_lim    = 1;        % 

c.T_0 = 273.15; %melting point temperature (K);
c.T_100 = 373.15; %steam point temperature (K);
c.smallno = 1.00E-12	 % Small number for layer calculations   

c.z0_ice = 0.0032; %surface roughness length for ice (m) as in Lefebvre et al. 2003;
c.z0_fresh_snow = 0.00012; %surface roughness length for snow (m) as in Lefebvre et al. 2003;
c.z0_old_snow = 0.0013; %surface roughness length for snow (m) as in Lefebvre et al. 2003;
c.g = 9.82 %gravitational constant (at sea level). 80 N -> 9.83, 60 N -> 9.82;

c.R_d = 287.05; % gas constant of dry air;
c.c_pd = 1005 %specific heat of dry air (J/kg/K);
c.kappa = 0.4; %Von Karman constant (0.35-0.42);

c.ch1 = [1.25;0.149;0.317]; %used in calculating roughness length for heat z_h over smooth surfaces (Andreas 1987)
c.ch2 = [0;-0.55;-0.565];
c.ch3 = [0;0;-0.183];
c.cq1 = [1.61;0.351;0.396]; %used in calculating roughness length for moisture z_q over smooth surfaces (Andreas 1987)
c.cq2 = [0;-0.628;-0.512];
c.cq3 = [0;0;-0.18];

c.rho_water = 999.8395; %density of water at the melting point (kg/m3);;
c.gamma=16 ;%flux profile correction (Paulson & Dyer);

c.iter_max_flux = 20;

%c.ext_air   = 1.50E-04    % extinction coefficient of shortwave radiation in air for clear-sky conditions (m^-1);
%c.ext_air_cl = 1.50E-04 % cloud-dependent add-on to extinction coefficient of shortwave radiation in air (m^-1);
%c.ext_ice = 1.00E+10    % extinction coefficient of shortwave radiation in ice (m^-1) (no penetration if set to 1e10);
%c.ext_snow = 1.00E+10;extinction coefficient of shortwave radiation in snow (m^-1) (no penetration if set to 1e10);

c.L_sub = 2.83E+06; %latent heat of sublimation (J/kg);
c.L_fus = 3.34E+05; %latent heat of fusion/melting (J/kg);
c.L_vap = 2.50E+06; %latent heat of vaporization (J/kg);
c.L_dif = 0.01; 

%c.R_v;461.51;gas constant of water vapour;
% c.rho_ice;900;density of ice (kg/m3);
% c.rho_snow;500;density of snow (kg/m3);
% c.rho_water;999.8395;density of water at the melting point (kg/m3);
c.sigma = 5.67E-08; %Stefan-Boltzmann's constant;
% c.T_solidprecip;0;Near-surface temperature below which precipitation is solid (C);

c.aa = 0.7;%flux profile correction constants (Holtslag & De Bruin '88);
c.bb = 0.75;%
c.cc = 5;%
c.dd = 0.35;%
c.beta = 2317;%
c.c_w = 4210;%specific heat of water at 0 C (J/kg/K) (Source www.engineeringtoolbox.com);
c.ch1 = [1.25;0.149;0.317];%used in calculating roughness length for heat z_h over smooth surfaces (Andreas 1987)
c.ch2 = [0;-0.55;-0.565];
c.ch3 = [0;0;-0.183];
c.cq1 = [1.61;0.351;0.396];%used in calculating roughness length for moisture z_q over smooth surfaces (Andreas 1987)
c.cq2 = [0;-0.628;-0.512];
c.cq3 = [0;0;-0.18];
c.R = 8.314;
c.kappa_poisson = 0.2854;%for dry air ratio of R;
% 
c.EB_max = 0.1; %surface temperature iteration will stop when the imbalance in the energy budget is less then EB_max (W/m2)




