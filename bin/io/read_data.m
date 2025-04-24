function [T] = read_data(filtered_files)

uqstation = unique([filtered_files.station_name]);

for is = 1:length(uqstation)

    ix = contains([filtered_files.station_name], uqstation(is),'IgnoreCase',true);

    sub_filtered_files = filtered_files(ix);
    [~,index] = sortrows([sub_filtered_files.year].');
    sub_filtered_files = sub_filtered_files(index); clear index

    for i = 1:length(sub_filtered_files)

        filename = [sub_filtered_files(i).folder,filesep,sub_filtered_files(i).name];
        tabledata = readtable(filename,'ReadVariableNames',true );

        if ismember('time', tabledata.Properties.VariableNames) == 1
            Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.time);
            Timetabledata = removevars(Timetabledata, 'time');
        else
            Timetabledata = table2timetable(tabledata,'RowTimes',tabledata.Time);
            Timetabledata = removevars(Timetabledata, 'Time');
            Timetabledata.Properties.DimensionNames{1} = 'Time';
        end

        T.(string(uqstation(is))).(['Y',num2str(sub_filtered_files(i).year)]) = Timetabledata;

    end
end
