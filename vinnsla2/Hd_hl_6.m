echo off; clc
disp('Forrit sem reiknar út orkuþáttina Hd og Hl (Orka frá lofthita og raka)')
disp('fyrir Brúarjökul 2010 (850 m y.s.). Notast er við klukkutímagildi veðurþátta')
disp('Notast er við "one-lewel" líkan með "stabíliteti" L og gerir ráð fyrir að zt, zq og') 
disp('zo séu mismunandi (ref: Edgar L. Andreas 1986)')
disp(' ')
disp('Ýttu á einhvern takka til að halda áfram!')
pause; clear; % close all

load kbrune.dat
load thryst.dat
load dbrune.dat
load alb_net.dat


% dagar sem á að reikna frá og til
dagur1=2;
dagur4=300;

i=find(kbrune(:,1)>dagur1&kbrune(:,1)<dagur4);
kbrune=kbrune(i,:);

i=find(thryst(:,1)>dagur1&thryst(:,1)<dagur4);
thryst=thryst(i,:);

i=find(dbrune(:,1)>dagur1&dbrune(:,1)<dagur4);
dbrune=dbrune(i,:);

i=find(alb_net(:,1)>dagur1&alb_net(:,1)<dagur4);
alb_net=alb_net(i,:);


temp=[];
for k=1:size(kbrune,1)
   i=find(thryst(:,1)+thryst(:,2)/2400==kbrune(k,1)+kbrune(k,2)/2400);
   if isempty(i)==0
      j=min(i);
      temp(k,:)=[kbrune(k,1:2) thryst(j,3)];
   elseif k==1
       j=1;
      temp(k,:)=[kbrune(k,1:2) thryst(j,3)];
   else
      temp(k,:)=[kbrune(k,1:2) thryst(j,3)]; 
   end
end

thryst=temp;

z=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reikna stuðulinn A út frá Zo:

for k=1:max(size(kbrune))
if kbrune(k,1)<=150
   N(k,1)=(log(2)-log(exp(-6.3)));
   ln_zt_z0(k,:)=-2;
   ln_zq_z0(k,:)=-2.5;
   zo(k,1)=exp(-6.3);
elseif ((kbrune(k,1)>150)&(kbrune(k,1)<240))
   N(k,1)=(log(z)-log(exp(-4.0)));
   ln_zt_z0(k,:)=-2;
   ln_zq_z0(k,:)=-2;
   zo(k,1)=exp(-4.0);
   
   %N(k,1)=(log(2)-log(exp(-6.3)));
   %ln_zt_z0(k,:)=-2;
   %ln_zq_z0(k,:)=-2.5;
   %zo(k,1)=exp(-6.3);

else
   N(k,1)=(log(2)-log(exp(-6.3)));
   ln_zt_z0(k,:)=-2;
   ln_zq_z0(k,:)=-2.5;
   zo(k,1)=exp(-6.3);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u=kbrune(:,9);
T=kbrune(:,3);
r=kbrune(:,4);
P=thryst(:,3)*100; % í Pa

% Skilgreiningar á föstum:
k0=0.4; beta=7; hro0=1.29; P0=1.013e5; 
Lv=2.5e6; cp=1010; T0=273+T; g=9.8;
v=1.5e-5;

% Reikna út Monin og Obukhov lengdina L

Tz2=T; Tz1=0; uz2=u; 

for k=2:size(uz2,1)
   if uz2(k,1)==0
      uz2(k,1)=uz2(k-1,1);
   end
end

FIz2=Tz2+273+2*g/cp; FIz1=Tz1+273+0*g/cp;


A=beta*2./N;
%B=(g./T0).*((FIz2-FIz1)./((uz2).^2)).*N;
B=(g./T0).*((Tz2-Tz1)./((uz2).^2)).*N;
L=-A+(1./(B));


% Reikna Reynolds number:
n=beta*2./L;

Cd=k0^2./((N+n).^2);

R=sqrt(Cd).*zo.*u./v;

% Mat á hlutföllunum ln(zt/zo) og ln(zq/zt):
medal=0;
if medal==0;
ln_zt_zo=[];
ln_zq_zo=[];
i=find(R<=0.135);
ln_zt_z0(i,:)=1.250;
ln_zq_z0(i,:)=1.610;
i=find(R>0.135&R<2.5);
ln_zt_z0(i,:)=0.149-0.550*log(R(i,:));
ln_zq_z0(i,:)=0.351-0.628*log(R(i,:));
i=find(R>=2.5);
ln_zt_z0(i,:)=0.317-0.565*log(R(i,:))-0.183*(log(R(i,:))).^2;
ln_zq_z0(i,:)=0.396-0.512*log(R(i,:))-0.180*(log(R(i,:))).^2;
end

% Áfram með M&O:
for k=1:size(L,1)
   if ((L(k,1)<=0)|(FIz2-FIz1<0))
      D(k,1)=N(k,1);
      L(k,1)=0;
   else
      D(k,1)=N(k,1)+beta*2/L(k,1);
   end
end   


D=D.^2; N=1./D;
% Reikna út Cd, Chd og Chl


Cd=k0*k0*N;

Chd=k0*Cd.^(1/2)./(k0*Cd.^(-1/2)-ln_zt_z0);

Chl=k0*Cd.^(1/2)./(k0*Cd.^(-1/2)-ln_zq_z0);

% Reikna út klukkutímagildi Hd:

Hd=(1.29e-2)*Chd.*P.*u.*T;

% Reikna út klukkutímagildi Hl:

ew=17.5043*T./(241.2+T);
ew=exp(ew);
ew=611.213*ew;

Hl=r.*ew/100-611.213;
%Hl=22.2.*(A).*u.*Hl;
Hl=19.8.*Chl.*u.*Hl;

e_raki=r.*ew/100;

a=[kbrune(:,1:2) Hd Hl];
kl=a;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finn sólarhringsmeðaltöl Hd og Hl

med=[]; n=0;
for k=min(a(:,1)):max(a(:,1))
   i=find(a(:,1)==k);
   n=n+1;
	med(n,:)=[k mean(a(i,3:4))];
end

Hd=med(:,2); Hl=med(:,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=find((dbrune(:,1)>dagur1&dbrune(:,1)<dagur4));
t=dbrune(i,1);
Qi=dbrune(i,4); Qu=dbrune(i,5);% Qu=dbrune(i,4).*alb_net(i,3);
Ii=dbrune(i,6); Iu=dbrune(i,7);
R=Qi-Qu+Ii-Iu;
%R=alb_net(:,2);
t=alb_net(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a=[t R Hd Hl R+Hl+Hd];


a2=a;

b=[];
i=find(a2(:,5)<0); a2(i,5)=0;
b(1,:)=[a2(1,1) a2(1,5)/(3.3e5/86400)/1000];

for k=2:size(a,1)
    b(k,:)=[a2(k,1) b(k-1,2)+a2(k,5)/(3.3e5/86400)/1000];
end


