B13 = readtimetable('\\lv-logernet-01\maelingar\VST\KAR\Bruarjokull_B13\VST_Bruarjokull_B13_MET.dat')
B16 = readtimetable('\\lv-logernet-01\maelingar\VST\KAR\Bruarjokull_B16\VST_Bruarjokull_B16_MET.dat')
T03 = readtimetable('\\lv-logernet-01\maelingar\VST\TJO\Tungnaarjokull_T03\VST_Tungnaarjokull_T03_MET.dat')
T06 = readtimetable('\\lv-logernet-01\maelingar\VST\TJO\Tungnaarjokull_T06\VST_Tungnaarjokull_T06_MET.dat')

B10 = readtimetable('\\LV-LOGERNET-01\Maelingar\VST\KAR\Bruarjokull_B10\VST_Bruarjokull_B10_MET.dat')
HNA09 = readtimetable('\\LV-LOGERNET-01\Maelingar\VST\TJO\Hofsjokull\HNA09\VST_Hofsjokull_HNA09_NEW_MET.dat')
%%
tbl = B10;
figure
vars = {["t","t2"],...
['rh'],...    
['f'],...
['d'],...
['sw_in',"sw_out"],...
['lw_in',"lw_out"],...
}

s = stackedplot(tbl,vars)
grid on

figure
vars = {...
["HS","HS2"]...
["DrawWire"]...
['r']}

s = stackedplot(tbl,vars)
grid on
%%
figure, hold on
    plot(B13.TIMESTAMP,B13.t)
    plot(B16.TIMESTAMP,B16.t)
    plot(T03.TIMESTAMP,T03.t)
    plot(T06.TIMESTAMP,T06.t)
%%
figure, hold on
    plot(B13.TIMESTAMP,B13.t2-B13.t)
%%
figure, hold on
    plot(B16.TIMESTAMP,B16.t2-B16.t)
%%
figure, hold on
    plot(T03.TIMESTAMP,T03.t2-T03.t)

figure, hold on
    plot(T06.TIMESTAMP,T06.t2-T06.t)
    %%
    plot(B16.TIMESTAMP,B16.t2)
    plot(T03.TIMESTAMP,T03.t2)
    plot(T06.TIMESTAMP,T06.t2)

%%
synchronize(B16,B13)









