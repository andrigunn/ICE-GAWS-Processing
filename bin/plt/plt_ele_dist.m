% plot distribution of stations with elevation and main glacier
if ispc
    dirs.master = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data';
    dirs.img = [dirs.master,filesep,'img',filesep];
    addpath('C:\Users\andrigun\Dropbox\04-Repos\Github_master\geo')
    addpath('C:\Users\andrigun\Dropbox\04-Repos\Github_master\export_fig')
elseif ismac
    dirs.master = '/Users/andrigun/Dropbox/04-Repos/ICE-GAWS-Processing';
    dirs.img = [dirs.master,filesep,'img',filesep];
    addpath('/Users/andrigun/Dropbox/04-Repos/Github_master/geo')
    addpath('/Users/andrigun/Dropbox/04-Repos/Github_master/export_fig/')

end

loc = readtable([dirs.master,filesep,'ICE-GAWS-location.csv'])
loc_summary = readtable([dirs.master,filesep,'ICE-GAWS-location-summary.csv'])
%%
geo = make_geo('C:\Users\andrigun\Dropbox\04-Repos\Github_master\geo\geo_data')
%%
for i = 1:height(loc)
   
    switch string(loc.site_name(i))
        case {'HNA09','HNA13'}
        
            loc.glacier(i) ={'Hofsjökull'};
            loc.gid(i) = 1;
        case {'MyrA'}
            loc.glacier(i) ={'Mýrdalsjökull'};
            loc.gid(i) = 2;
        case {'L01','L05'}
            loc.glacier(i) ={'Langjökull'};
            loc.gid(i) = 3;
        otherwise
            loc.glacier(i) ={'Vatnajökull'};
            loc.gid(i) = 4;
    end
end
%%
close all
set(0,'defaultfigurepaperunits','centimeters');
set(0,'DefaultAxesFontSize',15)
set(0,'defaultfigurecolor','w');
set(0,'defaultfigureinverthardcopy','off');
set(0,'defaultfigurepaperorientation','landscape');
set(0,'defaultfigurepapersize',[29.7 16]);
set(0,'defaultfigurepaperposition',[.25 .25 [29.7 16]-0.5]);
set(0,'DefaultTextInterpreter','none');
set(0, 'DefaultFigureUnits', 'centimeters');
set(0, 'DefaultFigurePosition', [.25 .25 [29.7 16]-0.5]);

figure, hold on
tiledlayout(1,4,'TileSpacing','compact')

cmap = lines(4);
nexttile([1,3])
h = gscatter(loc.year,loc.elevation,loc.gid,cmap,'sox+');
legend(h(1:4),'Hofsjökull','Mýrdalsjökull','Langjökull','Vatnajökull','NumColumns',4,'Location','southoutside','Orientation','vertical')
grid on
xlim([1994,2023])
ylim([0 2100])
h(1).MarkerSize = 10
h(2).MarkerSize = 10
h(3).MarkerSize = 10
h(4).MarkerSize = 10
ylabel('Elevation (m a.s.l.)')
nexttile

tbl = splitvars(table(([[geo.dem.z(geo.G.ind.Hofsjokull),ones(1,length(geo.dem.z(geo.G.ind.Hofsjokull)))'];...
[geo.dem.z(geo.G.ind.Myrdalsjokull),2*ones(1,length(geo.dem.z(geo.G.ind.Myrdalsjokull)))'];...
[geo.dem.z(geo.G.ind.Langjokull),3*ones(1,length(geo.dem.z(geo.G.ind.Langjokull)))'];...
[geo.dem.z(geo.G.ind.Vatnajokull),4*ones(1,length(geo.dem.z(geo.G.ind.Vatnajokull)))']])));

f = boxchart(tbl.Var1_1,'GroupByColor',tbl.Var1_2,'MarkerStyle','none')
f(1).BoxFaceColor=cmap(1,:);
f(2).BoxFaceColor=cmap(2,:);
f(3).BoxFaceColor=cmap(3,:);
f(4).BoxFaceColor=cmap(4,:);
set(gca,'xticklabel',{[]})

ylim([0 2100])
grid on
legend({'Hofsjökull','Mýrdalsjökull','Langjökull','Vatnajökull'},'NumColumns',2,'Location','southoutside')
%%
cd C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data
iname = ['gaws_ele_dist.pdf']
export_fig(iname)

