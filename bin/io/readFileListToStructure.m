function data = readFileListToStructure(FileList)

%%
uqs = unique([FileList.station_name]);
data = struct();

for i = 1:length(uqs)
    
    ixx = find(contains([FileList.station_name],uqs(i)));
    sublist = FileList(ixx,:);

    stationName = uqs(i);
    

    for ii = 1:length(sublist)
        %data.(stationName).yr = table();

        filename = [sublist(ii).folder,filesep,sublist(ii).name];
        disp(filename)
        appdata= readtable(filename,'ReadVariableNames',true );

        data.(stationName).(['Y',(num2str(sublist(ii).year))]) = appdata;

    end
    
end
% %% Merge to one file per station
% for i = 2%1%:length(uqs)
%         
%     stationName = uqs(i);
%     
%     yrs = fieldnames(data.(stationName));
% 
%      for ii = 1:length(yrs)
%         % Find the table with max variables
%         tn(ii,1) = numel(data.(stationName).(string(yrs(ii))).Properties.VariableNames)
%         ty(ii,1) = (string(yrs(ii)))
%      end
% 
% 
%     
% end

