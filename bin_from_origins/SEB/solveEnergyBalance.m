function [SEB] = solveEnergyBalance(data,c)

%% ========== Settings ====================================
c.solve_T_surf = 1;
c.iter_max_EB = 60;
iter_max_EB = c.iter_max_EB; % otherwise just using standard value
EB_prev = 1;
dTsurf = 10;%c.dTsurf_ini ;  % Initial surface temperature step in search for EB=0 (C)
% ========== Input data ====================================
clear LHF SHF meltflux L 

T2 = data.HH.t+273,15;
RH = data.HH.rh;
pres = data.HH.ps;
WS = data.HH.f;
Tsurf = T2-1;
LRin = data.HH.lw_in;
LRout = data.HH.lw_out;
SRin = data.HH.sw_in;
SRout = data.HH.sw_out;
SRnet = data.HH.sw_in-data.HH.sw_out;
albedo = data.HH.Albedo_sum;
% Initlize variables
LHF = zeros(1,length(T2));
SHF = zeros(1,length(T2));
meltflux = zeros(1,length(T2));
%Tsurf = zero(1,length(T2));
%


% Instrument elevations rel. to glacier surface
z_WS2 = 5;
z_T2 = 2;
z_RH2 = 2;
% Make ice/snow mask for roughness lengths
ice_snow = albedo;
ice_snow(ice_snow<0.45) = 1; % 1 for ice
ice_snow(ice_snow>=0.45) = 0; % 0 for snow

% Calculates specific humidity and saturation (needs RH relative to ice!)
% Calc RH and specific humidity
[RH, q2] = SpecHumSat(RH, T2, pres, c);
% Calc potential and virtual temperature
theta2 = T2 + z_T2 * c.g / c.c_pd; % pot temo
theta2_v = theta2 .* (1 + ((1 - c.es)/c.es).*q2); % virt pot temp
%
for k = 1:length(T2)

    % Check if all variables exist to calculate energy balacne
    if (isnan(RH(k))) || (isnan(T2(k))) || (isnan(pres(k))) || (isnan(WS(k))) ||...
            (isnan(LRin(k))) || (isnan(SRin(k))) || (isnan(SRnet(k))) || (isnan(albedo(k)))
        
        L(k) = NaN;
        LHF(k) = NaN;
        SHF(k) = NaN;
        Tsurf(k) = NaN;
        meltflux(k) = NaN;

        
        %disp('Skipping NaN data in input')
        continue
    else
        %disp('data')
    end
    
    rho_atm(k) = 100*pres(k)./c.R_d./T2(k);                % atmospheric density
    mu(k) = 18.27e-6.*(291.15+120)./(T2(k)+120).*(T2(k)./291.15).^1.5;   % dynamic viscosity of air (Pa s) (Sutherlands' formula using C = 120 K)
    nu(k) = mu(k)./rho_atm(k);
    
    if albedo(k) > 0.45 %c.smallno
        % fresh snow
        z_0(k) = c.z0_fresh_snow;
        snowthick = 1;
        
    elseif albedo(k) <= 0.45
        % old snow from Lefebre et al (2003) JGR
        %    z_0 = max(c.z0_old_snow, ...
        %       c.z0_old_snow + (c.z0_ice -c.z0_old_snow)*(rho(1,k) - 600)/(920 - 600));
        
        % ice roughness length
        z_0(k) = c.z0_ice;
        snowthick = 0;
    elseif isnan(albedo(k))
        z_0(k) = c.z0_ice;
    end
    
    for findbalance = 1 : iter_max_EB;
        % SENSIBLE AND LATENT HEAT FLUX -------------------------------
        [L(k), LHF(k), SHF(k), theta_2m(k), q_2m(k), ws_10m(k),Re(k)] ...
            = SensLatFluxes_bulk(WS(k), nu(k), q2(k), snowthick, ...
            Tsurf(k), theta2(k),theta2_v(k), pres(k), rho_atm(k),  ...
            z_WS2, z_T2, z_RH2, z_0(k), c);
        % SURFACE ENERGY BUDGET ---------------------------------------
        
        [meltflux(k), Tsurf(k), dTsurf, EB_prev, stop] ...
            = SurfEnergyBudget (SRnet(k), LRin(k), Tsurf(k), 1,1, ...
            1, 1,...
            dTsurf, EB_prev, SHF(k), LHF(k), 1,c);

        
        if stop
            break
        end
        
    end
end

%         % ========== Step 6/*:  Mass Budget ====================================
%         % in mweq

%         % positive LHF -> deposition -> dH_subl positive

%%
%         if iter_max_EB ~= 1 && ...
%             (findbalance == c.iter_max_EB && abs(meltflux(k,j)) >= 10*c.EB_max)
%             error('Problem closing energy budget')
%         end
%         clear findbalance
%% Energy balance structure
% Timestep info for meltenergy to meltwater conversion

clc
clear SEB
%melt_mweq = meltflux*c.dt_obs/c.L_fus/c.rho_water;
%sublimation_mweq = LHF*c.dt_obs/c.L_sub/c.rho_water; % in mweq

         
SEB.HM = splitvars(timetable([LHF',SHF',meltflux',Tsurf-273.15,...
    LRin,LRout,SRin,SRout,albedo,data.HH.Ts,data.HH.t...
],'RowTimes',data.HH.Time));


SEB.HM.Properties.VariableNames{1} = 'LHF';
SEB.HM.Properties.VariableNames{2} = 'SHF';
SEB.HM.Properties.VariableNames{3} = 'meltFlux';
SEB.HM.Properties.VariableNames{4} = 'Tsurf_opt';
SEB.HM.Properties.VariableNames{5} = 'lw_in';
SEB.HM.Properties.VariableNames{6} = 'lw_out';
SEB.HM.Properties.VariableNames{7} = 'sw_in';
SEB.HM.Properties.VariableNames{8} = 'sw_out';
SEB.HM.Properties.VariableNames{9} = 'albedo';
SEB.HM.Properties.VariableNames{10} = 'Tsurf_obs';
SEB.HM.Properties.VariableNames{11} = 'T_2m';
%%

mf = 0.26; %mm day per w

SEB.DM = retime(SEB.HM,'daily','mean');

ix = find([SEB.DM.meltFlux]>-10000)

SEB.DM.meltwater(ix) = SEB.DM.meltFlux(ix).*mf

 %%
 close all
 figure, hold on
 plot(SEB.DM.Tsurf_obs)
plot(SEB.DM.Tsurf_opt)
plot(SEB.DM.T_2m)
%%
close all
figure, hold on
plot(cumsum(SEB.DM.meltwater))

%         % ========== Step 6/*:  Mass Budget ====================================
%         % in mweq
%         melt_mweq(k,j) = meltflux(k,j)*c.dt_obs/c.L_fus/c.rho_water;
%         sublimation_mweq(k,j) = LHF(k,j)*c.dt_obs/c.L_sub/c.rho_water; % in mweq
%         % positive LHF -> deposition -> dH_subl positive


% in the case of the conduction model, the mass budget is calculated as
% follows
%         if c.ConductionModel == 1
%             smoothed_Surface_Height= smooth(Surface_Height,24*7);
%             if k>1
%                 dSurface_Height= -(smoothed_Surface_Height(k) - smoothed_Surface_Height(k-1)); %in real m
%             else
%                 dSurface_Height= 0;
%             end
%             if dSurface_Height<= 0
%                 % if the surface height increase, it means that snow is
%                 % falling
%                 melt_mweq(k,j) = 0;
%                 snowfall(k,j) = -dSurface_Height*c.rho_snow(k,j)/c.rho_water; %in m weq
%                 sublimation_mweq(k,j) = 0;
%             else
%                 %else we just say it has sublimated (quick way to make the
%                 %matter disappear in the subsurface scheme)
%                 melt_mweq(k,j) = 0; %in m weq
%                 sublimation_mweq(k,j) = -dSurface_Height*rho(1, k)/c.rho_water;
%                 snowfall(k,j) = 0;
%             end
%             c.liqmax =0;
%             c.calc_CLliq = 0;
%             Tsurf(k,j) = ((LRout(k) - (1-c.em)*LRin(k)) /(c.em*c.sigma))^(1/4);
%         end

%         % ========== Step 7/*:  Sub-surface model ====================================
%         GF(2:c.z_ice_max) = -k_eff(2:c.z_ice_max).*(T_ice(1:c.z_ice_max-1,k,j)-T_ice(2:c.z_ice_max,k,j))./c.dz_ice;
%         GFsurf(k,j) =-(k_eff(1)) * (Tsurf(k,j)- T_ice(2,k,j)) / thick_first_lay;
% %         grndhflx = GFsurf(k,j);
%         pTsurf = Tsurf(k,j);
%         ptsoil_in = T_ice(:,k,j);
%         zsn = snowfall(k,j) + sublimation_mweq(k,j);
%         snmel = melt_mweq(k,j);
%         raind = rainfall(k,j);
%         c.rho_fresh_snow = c.rho_snow(k,j);
%
%         if c.retmip
%             zsn = data_AWS.acc_subl_mmweq(k)/1000;
%             snmel = data_AWS.melt_mmweq(k)/1000;
%         end
%
%         if k==1
%             grndc =T_ice(:,k,j);
%             grndd(:) =0;
%         end
%         if strcmp(c.station,'Miege')
%             [slwc] = MimicAquiferFlow(snowc, rhofirn, snic, slwc, k,  c);
%         end
%
%         [snowc, snic, slwc, T_ice(:,k,j), zrfrz, rhofirn,...
%             supimp, pdgrain, runoff(k,j), ~, grndc, grndd, ~, GFsubsurf(k,j),...
%             dH_comp, snowbkt_out(k,j), compaction, c] ...
%             = subsurface(pTsurf, grndc, grndd, slwc, snic, snowc, rhofirn, ...
%             ptsoil_in, pdgrain, zsn, raind, snmel,  Tdeep(j),...
%             snowbkt_out(k,j),c);
%
%         % Update BV 2018
%         if c.track_density
%             density_avg_20(1,k) = c.rhoCC20_aft_comp(1);
%             density_avg_20(2,k) = c.rhoCC20_aft_snow(1);
%             density_avg_20(3,k) = c.rhoCC20_aft_subl(1);
%             density_avg_20(4,k) = c.rhoCC20_aft_melt(1);
%             density_avg_20(5,k) = c.rhoCC20_aft_runoff(1);
%             density_avg_20(6,k) = c.rhoCC20_aft_rfrz(1);
%             CC20(1,k) = c.rhoCC20_aft_comp(2);
%             CC20(2,k) = c.rhoCC20_aft_snow(2);
%             CC20(3,k) = c.rhoCC20_aft_subl(2);
%             CC20(4,k) = c.rhoCC20_aft_melt(2);
%             CC20(5,k) = c.rhoCC20_aft_runoff(2);
%             CC20(6,k) = c.rhoCC20_aft_rfrz(2);
%         end
%
%         % bulk density
%         rho(:,k)= (snowc + snic)./...
%             (snowc./rhofirn + snic./c.rho_ice);
%         refreezing(:,k,j) = zrfrz + supimp;
%         z_icehorizon = floor(snowthick(k,j)/c.dz_ice);
%
%         if k> 1
%             SMB_mweq(k,j) =  snowfall(k,j) - runoff(k,j) ...
%                 + rainfall(k,j) + sublimation_mweq(k,j);
%
%             % Update BV2017: With the layer-conservative model, the surface height
%             % can be calculated outside of the sub-surface scheme assuming that the
%             % bottom of the collumn remains at constant depth
%
%             % cumulative dry compaction
%             H_comp(k,j) = H_comp(k-1,j) + dH_comp; %in real m
%         end
%
%         if(snowthick(k,j) < 0)
%          snowthick(k,j)=0;
%         end
%
%         % for the conduction model the temperature profile can be resetted
%         % at fixed interval
%         if c.ConductionModel == 1
%             if (mod(k-1, 24) == 0)
%                 if sum(~isnan(T_ice_obs(k,:)))>0
%                     [Tsurf(k,j), T_reset] = ...
%                         ResetTemp(depth_thermistor, LRin, LRout, T_ice_obs, ...
%                         rho, T_ice,time, k, c);
%                 end
%             end
%         end
%
%         % MODEL RUN PROGRESS ----------------------------------------------
%         if c.verbose == 1
%         if (mod(k-1 , 24) == 0)
%             fprintf('%.2f,day of the year: %i.\n',time(k), day(k)); % print daily (24) time progress for k being hourly
%         end
%         end
%
%         %SAVING SOME SUBSURFACE VARIABLES --------------------------------------------
%         if k==1
%             sav. z_T = zeros(c.M,1);
%             sav. slwc = zeros(c.jpgrnd,c.M);
%             sav. snic = zeros(c.jpgrnd,c.M);
%             sav. snowc = zeros(c.jpgrnd,c.M);
%             sav. snowc = zeros(c.jpgrnd,c.M);
%             sav. pdgrain = zeros(c.jpgrnd,c.M);
%             sav. rhofirn = zeros(c.jpgrnd,c.M);
%             sav. subsurf_compaction = zeros(c.jpgrnd,c.M);
%         end
%
%         sav. slwc(:,k) = slwc;
%         sav. snic(:,k) = snic;
%         sav. snowc(:,k) = snowc;
%         sav. pdgrain(:,k) = pdgrain;
%         sav. rhofirn(:,k) = rhofirn;
%         sav. subsurf_compaction(:,k) = compaction;
%         sav.z_T(k) = z_T2(k);
%     end  % END OF TIME LOOP -----------------------------------------------------------------------
%
%     rainHF = c.rho_water.*c.c_w(1).*rainfall./c.dt_obs.*(T_rain-Tsurf(:,j));
%
%
% %% Processing few variables
%     thickness_act = sav.snowc.*(c.rho_water./sav.rhofirn )+ ...
%         sav.snic .*(c.rho_water/c.rho_ice);
%     depth_act = cumsum(thickness_act, 1);
%
%     H_surf = depth_act(end,:)'-depth_act(end,1)+snowbkt_out(k,j)*1000/315;
%     for i = 1:length(H_surf)-1
%         if (H_surf(i+1)-H_surf(i))> c.new_bottom_lay-1
%             H_surf(i+1:end) = H_surf(i+1:end) - c.new_bottom_lay*c.rho_water/c.rho_ice;
%         end
%     end
%     if c.retmip
%         meltflux(:,j) = data_AWS.melt_mmweq/1000*c.L_fus*c.rho_water/c.dt_obs;
%         snowfall(:,j) = max(0,data_AWS.acc_subl_mmweq/1000);
%         sublimation_mweq(:,j) = min(0,data_AWS.acc_subl_mmweq/1000);
%     end
%
%     %% Writing data to net cdf
%     data_surf = {year,       day,            hour,   LRin(:,j), ...
%             c.em*c.sigma*Tsurf(:,j).^4+(1-c.em)*LRin(:,j), SHF(:,j), LHF(:,j), ...
%             GFsurf(:,j),    rainHF(:,j),        meltflux(:,j),  ...
%             H_surf(:,j),    SMB_mweq(:,j),    melt_mweq(:,j),    ...
%             sublimation_mweq(:,j),    H_comp(:,j),        runoff(:,j),    snowthick(:,j), ...
%             snowfall(:,j),  rainfall(:,j),      SRin(:,j), SRout(:,j), ...
%             Tsurf(:,j), sav.z_T, snowbkt_out(:,j),...
%             theta_2m(:,j), RHice2water( spechum2relhum(theta_2m(:,j),...
%             pres, q_2m(:,j),c),theta_2m, pres), ws_10m(:,j)};
%
%     data_subsurf = {T_ice(:,:,j) rho sav.rhofirn sav.slwc sav.snic sav.snowc sav.pdgrain...
%         refreezing(:,:,j) sav.subsurf_compaction};
%
% try WritingModelOutput(time,data_surf,depth_act, data_subsurf,j,  c)
% catch me
% 	error('Writing failed')
% end
% end  % END OF SPATIAL LOOP -----------------------------------------------------------------------
%
% save(strcat(c.OutputFolder,'/run_param.mat'),'c')
%
% if c.THF_calc == 3
%     M = [time SHF LHF o_THF SHF2 LHF2 o_THF2 Re Ri err];
%     dlmwrite(sprintf('./Output/THF study/THF_%s_%i.csv',c.station ,c.THF_calc),M,'Delimiter',',','precision',9);
%     % disp ('Done...')
% end
%     toc



