%function HS_cleaner(filename)
files = read_file_structure('L2','raw');

ix = find([files.year] >= 2019)
i = 24
Files = files(ix,:)

fname = [Files(i).folder,filesep,Files(i).name];
clear B
disp(Files(i).name)
B = readtable(fname);
B.time = B.Time;
B = removevars(B, "Time");
B = table2timetable(B,'RowTimes',B.time);
B = removevars(B, 'time');
%
B.HS_mod = B.HS;

% C = [datenum(B.Time),B.HS];
% close all
% figure, hold on
% %plot(B.Time,B.HS)
% plot(C(:,1),C(:,2))
%
filename = Files(i).name

switch filename
    case 'ICE-GAWS_L05_L2_2019.csv' 
        B.HS = nan(height(B),1);
        remove_smaller_than = 0.3;
        remove_larger_than = 6;
    case 'ICE-GAWS_L05_L2_2020.csv' 
        disp('1')
        TR = timerange('2020-01-01 00:00:00','2020-04-24 00:00:00'); B.HS(TR) = NaN;  
        remove_smaller_than = 0.3;
        remove_larger_than = 6;
    case 'ICE-GAWS_L05_L2_2022.csv' 
        remove_smaller_than = 0.3;
        remove_larger_than = 6;
        
    case 'ICE-GAWS_MyrA_L2_2020.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 6;

    case 'ICE-GAWS_B10_L2_2019.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 6;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_B10_L2_2020.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 6;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;
        
    case 'ICE-GAWS_B10_L2_2021.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 6;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;
    case 'ICE-GAWS_B10_L2_2022.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 8;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;
        TR = timerange('2022-08-04 11:00:00','2022-12-31 00:00:00'); 
        B.HS_mod(TR) = B.HS_mod(TR)+3.5+0.386+0.05      

    case 'ICE-GAWS_B13_L2_2019.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 8;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_B13_L2_2020.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 8;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;
    
    case 'ICE-GAWS_B13_L2_2021.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 8;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_B13_L2_2022.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 8;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_B16_L2_2019.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 4;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_B16_L2_2020.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 4;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;
    case 'ICE-GAWS_B16_L2_2021.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 4;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_B16_L2_2022.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 4;
        B.HS_mod = B.HS_mod/100;
        B.HS = B.HS/100;

    case 'ICE-GAWS_Gv_L2_2019.csv'
        remove_smaller_than = 0.3;
        remove_larger_than = 4;


end

        B.HS_mod(B.HS_mod<remove_smaller_than)= NaN;
        B.HS_mod(B.HS_mod>remove_larger_than)= NaN;
        % Fill outliers
        B = rmoutliers(B,"movmedian",days(3),"ThresholdFactor",2.5,"DataVariables","HS_mod");
        % Fill outliers
        HS_mod = filloutliers(B,"linear","movmedian",days(3),"ThresholdFactor",2.5,...
            "DataVariables","HS_mod");
%
figure, hold on
%plot(B.Time,B.HS)
plot(B.Time,B.HS_mod)