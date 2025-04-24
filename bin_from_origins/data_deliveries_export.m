clc
for i = 1:length(FileList)
    
    fname = [FileList(i).folder_L2,filesep,FileList(i).name_L2]
    
    
    clear Or M
    M = readtable(fname);
    Or = table2timetable(M);
    
    cd 'C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\data_deliveries'
    
    OrM = timetable(Or.t, 'RowTimes',Or.time); 
    OrM.Properties.VariableNames{1} = 'AirTemperature_2m_degC';
    writetimetable(OrM, FileList(i).name_L2,    'Delimiter',';');

end

%%
meta = (struct2table(FileList));

%%
    writetable(meta, 'Ice_GAWS_location_Info.csv',    'Delimiter',';');
