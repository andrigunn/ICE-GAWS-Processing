function FilterFileList = filterFileList(FileList,station,yearfrom,yearto)
%%
% yearfrom = 2000
% yearto = 2022
% station = 'B13'
%%
ixx = find(contains([FileList.station_name],station));
FilterFileList = FileList(ixx,:);

ix = find(([FilterFileList.year]>=yearfrom) & ([FilterFileList.year]<=yearto));
FilterFileList = FilterFileList(ix,:);

