%% Prep input data
c.iter_max_EB = 60;
dTsurf = 10;
EB_prev = 1;

T2 = Or.t+273.15; % Kelvin
RH = Or.rh;
z_T2 = ones(length(T1),1)*2;
z_RH1 = ones(length(T1),1)*2;
z_WS2 = ones(length(T1),1)*5;
pres = Or.ps; %hPa
SRin = Or.sw_in;
SRout = Or.sw_out;
LRin = Or.lw_in;
LRout = Or.lw_out;
Tsurf_obs = Or.ts+273.15;
WS = Or.f;

rho_atm = 100*pres./c.R_d./T2;                % atmospheric density
Tsurf = T2-2.4;%mean(T2(1:24))-2.4
%%
mu = 18.27e-6.*(291.15+120)./(T2+120).*(T2./291.15).^1.5 ;  % dynamic viscosity of air (Pa s) (Sutherlands' formula using C = 120 K)
nu = mu./rho_atm; %1.467299520347577e-05

[RH, q1] = SpecHumSat(RH, T2, pres, c);

theta2 = T2 + z_T2 * c.g / c.c_pd;
theta2_v = theta2 .* (1 + ((1 - c.es)/c.es).*q1);
% Set roughness based on surface albedo
z_0 = nan(length(Or.albedo),1);
ix = find(Or.albedo_24hrSum>0.45);
z_0(ix) = c.z0_fresh_snow;
ix = find(Or.albedo_24hrSum<=0.45)
z_0(ix) = c.z0_ice;
% Set smow thickness based on surface albedo
snowthick = nan(length(Or.albedo),1);
ix = find(Or.albedo_24hrSum>0.45);
snowthick(ix) = 1;
ix = find(Or.albedo_24hrSum<=0.45)
snowthick(ix) = 0;
%%
clc
iter_max_EB = c.iter_max_EB;
SRnet = Or.sw_in-Or.sw_out;
clear analytics
    j = 1;
    
for k = 1:length(Tsurf_obs)%:5;

    for findbalance = 1 %: iter_max_EB
    
        Tsurf(k,j) = Tsurf_obs(k); 
        % SENSIBLE AND LATENT HEAT FLUX -------------------------------
        % [L(k), LHF(k), SHF(k), theta_2m(k), q_2m(k), ws_10m(k), Re(k)] ...
        %    = SensLatFluxes_bulk (WS(k), nu(k), q1(k), snowthick(k), ...
        %   Tsurf(k), theta2(k),theta2_v(k), pres(k), rho_atm(k),  ...
        %  z_WS2(k), z_T2(k), z_RH1(k), z_0(k), c);
        
        [L(k,j), LHF(k,j), SHF(k,j), theta_2m(k,j), q_2m(k,j), ws_10m(k,j),Re(k,j)] ...
            = SensLatFluxes_bulk (WS(k,j), nu(k,j), q1(k,j), snowthick(k,j), ...
            Tsurf(k,j), theta2(k,j),theta2_v(k,j), pres(k,j), rho_atm(k,j),  ...
            z_WS2(k,j), z_T2(k,j), z_RH1(k,j), z_0(k), c);
        
        % SURFACE ENERGY BUDGET ---------------------------------------
        
        [meltflux(k,j), Tsurf(k,j), dTsurf, EB_prev, stop] ...
            = SurfEnergyBudget_original (SRnet(k,j), LRin(k,j), Tsurf(k,j), 1,1, ...
            1, 1,...
            dTsurf, EB_prev, SHF(k,j), LHF(k,j), 1,c);
        
        analytics(k,:) = [meltflux(k,j),SRnet(k,j),LRin(k,j), - c.em * c.sigma * Tsurf(k,j).^4 - (1 - c.em) * LRin(k,j), SHF(k,j), LHF(k,j),Tsurf(k,j),Tsurf_obs(k,j),T2(k,j)];
        if stop
            break
        end
    end %end loop surface energy balance
    
    
    
    %analytics(k,:) = [meltflux,SRnet(k),LRin(k), - c.em * c.sigma * Tsurf(k).^4 - (1 - c.em) * LRin(k), SHF(k), LHF(k),Tsurf(k),Tsurf_obs(k),T2(k)];
        if iter_max_EB ~= 1 && ...
            (findbalance == c.iter_max_EB && abs(meltflux(k,j)) >= 10*c.EB_max)
            error('Problem closing energy budget')
        end
        clear findbalance
        
        % ========== Step 6/*:  Mass Budget ====================================
        % in mweq
        c.dt_obs = 3600;
        
        melt_mweq(k,j) = meltflux(k,j)*c.dt_obs/c.L_fus/c.rho_water;   
        sublimation_mweq(k,j) = LHF(k,j)*c.dt_obs/c.L_sub/c.rho_water; % in mweq
end




%%
function [L, LHF, SHF, theta_2m, q_2m , ws_10m, Re] ...
    = SensLatFluxes_bulk_original (WS, nu, q, snowthick, ...
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
psi_m1 = 0;
psi_m2 = 0;

% will be updated later
theta_2m = theta;
q_2m     = q;
ws_10m    =  WS;

if WS > c.WS_lim
    % Roughness length scales for snow or ice - initial guess
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
    
    
    es_ice_surf = 10.^(-9.09718 * (c.T_0 / Tsurf - 1.) ...
        - 3.56654 * log10(c.T_0 / Tsurf) + 0.876793 * (1. - Tsurf / c.T_0) ...
        + log10(c.es_0));
    q_surf  = c.es * es_ice_surf/(pres-(1-c.es)*es_ice_surf);
    L = 10e4;
    
    if theta >= Tsurf && WS >= c.WS_lim   % stable stratification
        % correction from Holtslag, A. A. M. and De Bruin, H. A. R.: 1988, ‘Applied Modelling of the Night-Time
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
            
            th_star =  c.kappa * (theta - Tsurf) / (log(z_T / z_h) - psi_h2 + psi_h1) ;
            q_star  =  c.kappa * (q - q_surf) / (log(z_RH / z_q) - psi_q2 + psi_q1) ;
            SHF  = rho_atm * c.c_pd  * u_star * th_star;
            LHF  = rho_atm * c.L_sub * u_star * q_star;
            
            L_prev  = L;
            %             L    = u_star^2 * theta_v ...
            %                 / ( 3.9280 * th_star*(1 + 0.6077*q_star));
            L    = u_star^2 * theta*(1 + ((1 - c.es)/c.es)*q) ...
                / (c.g * c.kappa * th_star*(1 + ((1 - c.es)/c.es)*q_star));
            % if i ==1
            %     figure
            %     title('Stable')
            %     hold on
            % end
            % scatter(i,L)
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
            SHF  = single ( rho_atm * c.c_pd  * u_star * th_star);
            LHF  = single( rho_atm * c.L_sub * u_star * q_star);
            
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
    
    % calculating 2m temperature, humidity and wind speed
    theta_2m = theta;
    q_2m     = q;
    ws_10m    =  WS;
    
end
end

function [meltflux, Tsurf, dTsurf, EB_prev, stop] ...
    = SurfEnergyBudget_original (SRnet, LRin, Tsurf, k_eff, thick_first_lay, T_ice, T_rain,...
    dTsurf, EB_prev, SHF, LHF, rainfall, c)
% SurfEnergyBudget: calculates the surface temperature (Tsurf) and meltflux
% from the different elements of the energy balance. The surface
% temperature is adjusted iteratively until equilibrium between fluxes is
% found.
%
% Author: Dirk Van As (dva@geus.dk) & Robert S. Fausto (rsf@geus.dk)
% translated to matlab by Baptiste Vandecrux (bava@byg.dtu.dk)
%==========================================================================
stop =0;
% SURFACE ENERGY BUDGET -----------------------------------------------------------------------

meltflux = SRnet + LRin ...
    - c.em * c.sigma * Tsurf.^4 - (1 - c.em) * LRin ...
    + SHF + LHF; %...
%-(k_eff(1)) * (Tsurf- T_ice(2)) / thick_first_lay ...
%+ c.rho_water * c.c_w(1) * rainfall * c.dev ...
%/ c.dt_obs *( T_rain - c.T_0);

if meltflux >= 0 && Tsurf == c.T_0
    % stop iteration for melting surface
    stop =1;
    return
end

if abs(meltflux) < c.EB_max
    % stop iteration when energy components in balance
    stop =1;
    meltflux = 0;
    return
end


if meltflux/EB_prev < 0
    dTsurf = 0.5*dTsurf ;
    % make surface temperature step smaller when it overshoots EB=0
end
EB_prev = meltflux;

%Update BV
if meltflux < 0
    Tsurf = Tsurf - dTsurf ;
else
    Tsurf = min(c.T_0,Tsurf + dTsurf);
end

end



