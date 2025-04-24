clc
% disp('Forrit sem reiknar �t loft�r�sting � Br�arj�kli 2012 (1200 m)')
% disp('�t fr� g�gnum fr� Gr�msfjalli og J�kulheimum.')
% disp(' ')
% disp('�ttu � einhvern takka til a� halda �fram!')
% pause; 
clear; close all

load GRI_12T.dat
grimsf=GRI_12T;
a4=[grimsf(:,3:4) grimsf(:,12:13)];

Ph=(a4(:,3)).*(1-(0.0065*(831-1724))./(a4(:,4)+273)).^5.25;
b4=[a4(:,1) a4(:,2) Ph];

i=find(b4(:,1)+b4(:,2)/2400>=133.792&b4(:,1)+b4(:,2)/2400<=158.8); b4(i,3)=b4(i,3)+903.52-815.55;

figure
plot(b4(:,1)+b4(:,2)/2400,b4(:,3),'g')