function [L, LHF, SHF, theta_2m, q_2m , ws_10m, Re] ...
    = SensLatFluxes_bulk (WS, nu, q, snowthick, ...
    Tsurf,theta, theta_v , pres,rho_atm,  z_WS, z_T, z_RH, z_0, c)
% SensLatFluxes: Calculates the Sensible Heat Flux (SHF), Latent Heat Fluxes
% (LHF) and Monin-Obhukov length (L). Corrects for atmospheric stability.
%
% see Van As et al., 2005, The Summer Surface Energy Balance of the High
% Antarctic Plateau, Boundary-Layer Meteorology.
%
% Author: Dirk Van As (dva@geus.dk) & Robert S. Fausto (rsf@geus.dk)
% translated to matlab by Baptiste Vandecrux (bava@byg.dtu.dk)
%==========================================================================
%% Inputs
% WS = windspeed (m/s)
% nu - kinematic viscosity of air (m^2/s)

% Calculated variables
% rho_atm - atmospheric density (kg/m3)
% nu - kinematic viscocity (m2/s) Range = 1.46 · 10^-5 
% RH - relative humidity (0-100)
% q  - specific humidity (kg/kg)
% z_h -  roughness lengths for heat 
% z_h -  roughness lengths for moisture
%% Testing
% snowthick = 1;
% WS = data.L1.f(ki);
% pres_hPa = data.L1.ps(ki);
% pres = pres_hPa;
% RH = data.L1.rh(ki);
% T = data.L1.t(ki);
% T_Kelvin = T+273.15;
% Tsurf = data.L1.Ts(ki)+273.15;

% Fyrsta gisk á þessa stuðla sem eru svo ítraðir
psi_m1 = 0;
psi_m2 = 0;

%%

%theta_vir = theta_pot .* (1 + ((1 - c.es)/c.es).*q) % virtual potential temperature
% https://glossary.ametsoc.org/wiki/Virtual_potential_temperature
q_2m     = q/1000;
ws_10m    =  WS;

%% Selection of z_0 estimation bawsed on snow or ice
%  Check if there is snow or ice
if snowthick > c.smallno
    % fresh snow
    %disp('Fresh snow')
    z_0 = c.z0_fresh_snow;
else
    % old snow from Lefebre et al (2003) JGR
    %    z_0 = max(c.z0_old_snow, ...
    %           c.z0_old_snow + (c.z0_ice -c.z0_old_snow)*(rho(1,k)...
    %          - 600)/(920 - 600));
    %disp('Ice')
    % ice roughness length
    z_0 = c.z0_ice;
end

%% Main loop for SHF and LHF

if WS > c.WS_lim % WS large enough to matter. Ef ekki eru gildin sett sem núll, sjá neðst
    %disp('WS > c.WS_lim')
    % Roughness length scales for snow or ice - initial guess
    if WS<c.smallno
        z_h = 1e-10;    %z_h roughness lengths for heat 
        z_q = 1e-10;    %z_h roughness lengths for moisture
    else
        if snowthick > 0 % if there is snow
            [z_h, z_q, u_star, Re] = SmoothSurf(WS,z_0, psi_m1, psi_m2, nu, z_WS, c);
        else % if there is ice
            [z_h, z_q, u_star, Re] = RoughSurf(WS, z_0, psi_m1, psi_m2, nu, z_WS, c);
        end
    end
    
    es_ice_surf = 10.^(-9.09718 * (c.T_0 / Tsurf - 1.) ...
        - 3.56654 * log10(c.T_0 / Tsurf) + 0.876793 * (1. - Tsurf / c.T_0) ...
        + log10(c.es_0));
    q_surf  = c.es * es_ice_surf/(pres-(1-c.es)*es_ice_surf);
    L = 10e4;
    
    if theta >= Tsurf && WS >= c.WS_lim   % stable stratification Potential temperature 
    %disp('Stable stratification')
        % correction from Holtslag, A. A. M. and De Bruin, H. A. R.: 1988, 
        % ‘Applied Modelling of the Night-Time
        % Surface Energy Balance over Land’, J. Appl. Meteorol. 27, 689–704.
        for i=1:c.iter_max_flux
            psi_m1 = -(c.aa*z_0/L  +  c.bb*(z_0/L-c.cc/c.dd)*exp(-c.dd*z_0/L)  + c.bb*c.cc/c.dd);
            psi_m2 = -(c.aa*z_WS/L + c.bb*(z_WS/L-c.cc/c.dd)*exp(-c.dd*z_WS/L) + c.bb*c.cc/c.dd);
            psi_h1 = -(c.aa*z_h/L  +  c.bb*(z_h/L-c.cc/c.dd)*exp(-c.dd*z_h/L)  + c.bb*c.cc/c.dd);
            psi_h2 = -(c.aa*z_T/L  +  c.bb*(z_T/L-c.cc/c.dd)*exp(-c.dd*z_T/L)  + c.bb*c.cc/c.dd);
            psi_q1 = -(c.aa*z_q/L  +  c.bb*(z_q/L-c.cc/c.dd)*exp(-c.dd*z_q/L)  + c.bb*c.cc/c.dd);
            psi_q2 = -(c.aa*z_RH/L  +  c.bb*(z_RH/L-c.cc/c.dd)*exp(-c.dd*z_RH/L)  + c.bb*c.cc/c.dd);
            %     if psi_m2 <-10000
            %         df = 0;
            %     end
            if WS<c.smallno
                z_h = 1e-10;
                z_q = 1e-10;
            else
                if snowthick > 0
                    [z_h, z_q, u_star, Re] = SmoothSurf(WS,z_0, psi_m1, psi_m2, nu, z_WS, c);
                else
                    [z_h, z_q, u_star, Re] = RoughSurf(WS, z_0, psi_m1, psi_m2, nu, z_WS, c);
                end
            end
            
            th_star =  c.kappa * (theta - Tsurf) / (log(z_T / z_h) - psi_h2 + psi_h1);
            q_star  =  c.kappa * (q - q_surf) / (log(z_RH / z_q) - psi_q2 + psi_q1);
            SHF  = rho_atm * c.c_pd  * u_star * th_star;
            LHF  = rho_atm * c.L_sub * u_star * q_star;
            
            L_prev  = L;
            %             L    = u_star^2 * theta_v ...
            %                 / ( 3.9280 * th_star*(1 + 0.6077*q_star));
            L    = u_star^2 * theta*(1 + ((1 - c.es)/c.es)*q) ...
                / (c.g * c.kappa * th_star*(1 + ((1 - c.es)/c.es)*q_star));
            
            if L == 0 || (abs((L_prev - L)) < c.L_dif)
                % calculating 2m temperature, humidity and wind speed
                theta_2m = Tsurf + th_star/c.kappa * (log(2/z_h) - psi_h2 + psi_h1);
                q_2m     = q_surf + q_star /c.kappa * (log(2/z_q) - psi_q2 + psi_q1);
                ws_10m    =          u_star /c.kappa * (log(10/z_0) - psi_m2 + psi_m1);
                break
            end
        end
        
    end
    
    if theta < Tsurf && WS >= c.WS_lim   % unstable stratification
    %disp('unstable stratification')
        % correction functions as in
        % Dyer, A. J.: 1974, ‘A Review of Flux-Profile Relationships’, Boundary-Layer Meteorol. 7, 363– 372.
        % Paulson, C. A.: 1970, ‘The Mathematical Representation of Wind Speed and Temperature Profiles in the Unstable Atmospheric Surface Layer’, J. Appl. Meteorol. 9, 857–861.

        for i=1:c.iter_max_flux
            
            x1      = (1 - c.gamma * z_0  / L)^0.25;
            x2      = (1 - c.gamma * z_WS / L)^0.25;
            y1      = (1 - c.gamma * z_h  / L)^0.5;
            y2      = (1 - c.gamma * z_T  / L)^0.5;
            yq1     = (1 - c.gamma * z_q  / L)^0.5;
            yq2     = (1 - c.gamma * z_RH  / L)^0.5;
            psi_m1  = log( ((1 + x1)/2)^2 * (1 + x1^2)/2) - 2*atan(x1) + pi/2;
            psi_m2  = log( ((1 + x2)/2)^2 * (1 + x2^2)/2) - 2*atan(x2) + pi/2;
            psi_h1  = log( ((1 + y1)/2)^2 );
            psi_h2  = log( ((1 + y2)/2)^2 );
            psi_q1  = log( ((1 + yq1)/2)^2 );
            psi_q2  = log( ((1 + yq2)/2)^2 );
            
            if WS<c.smallno
                z_h = 1e-10;
                z_q = 1e-10;
            else
                if snowthick > 0
                    [z_h, z_q, u_star, Re] = SmoothSurf(WS,z_0, psi_m1, psi_m2, nu, z_WS, c);
                else
                    [z_h, z_q, u_star, Re] = RoughSurf(WS, z_0, psi_m1, psi_m2, nu, z_WS, c);
                end
            end
            
            th_star = single (c.kappa * (theta - Tsurf) / (log(z_T / z_h) - psi_h2 + psi_h1));
            q_star  = single ( c.kappa * (q  - q_surf) / (log(z_RH / z_q) - psi_q2 + psi_q1) );
            SHF  = single ( rho_atm * c.c_pd  * u_star * th_star)
            LHF  = single( rho_atm * c.L_sub * u_star * q_star)
            
            L_prev  = L;
            L    = u_star^2 * theta*(1 + ((1 - c.es)/c.es)*q) /...
                (c.g * c.kappa * th_star*(1 + ((1 - c.es)/c.es)*q_star));
            % if i ==1
            %     figure
            %     title('Unstable')
            %
            %     hold on
            % end
            % scatter(i,L)
            abs((L_prev - L)) < c.L_dif
            if abs((L_prev - L)) < c.L_dif
                % calculating 2m temperature, humidity and wind speed
                theta_2m = Tsurf + th_star/c.kappa * (log(2/z_h) - psi_h2 + psi_h1);
                q_2m     = q_surf + q_star /c.kappa * (log(2/z_q) - psi_q2 + psi_q1);
                ws_10m    =          u_star /c.kappa * (log(10/z_0) - psi_m2 + psi_m1);
                
                break
            end
        end
    end
    
else
    % threshold in windspeed ensuring the stability of the SHF/THF
    % caluclation. For low wind speeds those fluxes are anyway very small.
    Re = 0;
    u_star = 0;
    th_star = -999;
    q_star = -999;
    L = -999;
    SHF = 0;
    LHF = 0;
    z_h = 1e-10;
    z_q = 1e-10;
    psi_m1 = 0;
    psi_m2 = -999;
    psi_h1 = 0;
    psi_h2 = -999;
    psi_q1 = 0;
    psi_q2 = -999;
    theta_2m = -999;
    
        
end

% SH(ki) = SHF;
% LH(ki) = LHF;
end

