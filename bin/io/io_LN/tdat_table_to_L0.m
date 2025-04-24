% read_tdat_file_to_L0_data_MyrA

% input is a *t.dat file from FP (some preprocessing from datalogger to dat
% file)

cd C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data
% time,f,HS,HS_mod,HS_nor,HS_obs,lw_out,d,sw_in,lw_in,t,sw_out,rh
%2010-04-17 21:10:00

switch station_year
    case 'MyrA_2019'
        %%
        opts = delimitedTextImportOptions("NumVariables", 20);
        opts.DataLines = [1, Inf];
        opts.Delimiter = " ";
        opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts.LeadingDelimitersRule = "ignore";
        opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
        opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
        tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2019\MyrA19t.dat", opts);

        a = num2str(tdata.time);
        a = strrep(string(a),'  10','0010')
        a = strrep(string(a),'  20','0020')
        a = strrep(string(a),'  30','0030')
        a = strrep(string(a),'  40','0040')
        a = strrep(string(a),'  50','0050')

        a = char(a);
        HH = str2num(a(:,1:2));
        MM = str2num(a(:,3:4));
        t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

        B = table2timetable(tdata,'RowTimes',t);
        B = removevars(B, {'decimalday','year','doy','time'});
        B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

        uqy = unique(B.Time.Year)

        sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
        fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
        writetimetable(B,fname,'Delimiter',',')

    case 'MyrA_2020'
        %%
        opts = delimitedTextImportOptions("NumVariables", 20);
        opts.DataLines = [1, Inf];
        opts.Delimiter = " ";
        opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts.LeadingDelimitersRule = "ignore";
        opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
        opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
        tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2020\MyrA20t.dat", opts);

        a = num2str(tdata.time);
        a = strrep(string(a),'  10','0010')
        a = strrep(string(a),'  20','0020')
        a = strrep(string(a),'  30','0030')
        a = strrep(string(a),'  40','0040')
        a = strrep(string(a),'  50','0050')

        a = char(a);
        HH = str2num(a(:,1:2));
        MM = str2num(a(:,3:4));
        t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

        B = table2timetable(tdata,'RowTimes',t);
        B = removevars(B, {'decimalday','year','doy','time'});
        B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

        uqy = unique(B.Time.Year)

        sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
        fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
        writetimetable(B,fname,'Delimiter',',')

    case 'MyrA_2021'
        %%
        opts = delimitedTextImportOptions("NumVariables", 20);
        opts.DataLines = [1, Inf];
        opts.Delimiter = " ";
        opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts.LeadingDelimitersRule = "ignore";
        opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
        opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
        tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2021\MyrA21t.dat", opts);

        a = num2str(tdata.time);
        a = strrep(string(a),'  10','0010')
        a = strrep(string(a),'  20','0020')
        a = strrep(string(a),'  30','0030')
        a = strrep(string(a),'  40','0040')
        a = strrep(string(a),'  50','0050')

        a = char(a);
        HH = str2num(a(:,1:2));
        MM = str2num(a(:,3:4));
        t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

        B = table2timetable(tdata,'RowTimes',t);
        B = removevars(B, {'decimalday','year','doy','time'});
        B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

        uqy = unique(B.Time.Year)

        sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
        fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
        writetimetable(B,fname,'Delimiter',',')

    case 'MyrA_2022'
        %%
        opts = delimitedTextImportOptions("NumVariables", 20);
        opts.DataLines = [1, Inf];
        opts.Delimiter = " ";
        opts.VariableNames = ["decimalday", "year", "doy", "time", "t", "t2", "rh", "rh1", "sw_in", "sw_out", "f", "f1", "d", "HS", "VarName15", "VarName16", "loggertemp", "volt", "dontknow", "VarName20"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        opts.ConsecutiveDelimitersRule = "join";
        opts.LeadingDelimitersRule = "ignore";
        opts = setvaropts(opts, "decimalday", "TrimNonNumeric", true);
        opts = setvaropts(opts, "decimalday", "ThousandsSeparator", ",");
        tdata = readtable("C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L0\2022\MyrA22t.dat", opts);

        a = num2str(tdata.time);
        a = strrep(string(a),'  10','0010')
        a = strrep(string(a),'  20','0020')
        a = strrep(string(a),'  30','0030')
        a = strrep(string(a),'  40','0040')
        a = strrep(string(a),'  50','0050')

        a = char(a);
        HH = str2num(a(:,1:2));
        MM = str2num(a(:,3:4));
        t = datetime(tdata.year,1,tdata.doy,(HH),(MM),0)

        B = table2timetable(tdata,'RowTimes',t);
        B = removevars(B, {'decimalday','year','doy','time'});
        B = removevars(B, {'VarName15','VarName16','loggertemp','volt','dontknow','VarName20'});

        uqy = unique(B.Time.Year)

        sitename = ['ICE-GAWS_MyrA_L1_',num2str(uqy),'.csv'];
        fname = ['C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Processing\data\myrdalsjokull\myrdalsjokull_MyrA\L1\',sitename]
        writetimetable(B,fname,'Delimiter',',')
end

