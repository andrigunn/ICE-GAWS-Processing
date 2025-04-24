function tbl = readSEBfiles(filename)
%%
data = readtable(filename);
%%
tbl = table2timetable(data,"RowTimes",datetime(data.Year, 1, data.DayOfYear,data.HourOfDayUTC,00,00));


