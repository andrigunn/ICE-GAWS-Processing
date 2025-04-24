%% Read data to table for processing
% read_tables_for_processing
clear all
FileList = readFileList('L2','daily')

filtered_files = filter_files(FileList, 'B10', 2000,2024)
data = readFileListToStructure(filtered_files)
%%
JoinedData = JoinDataFromStructureToTimetableAllData(data,'')
%%

B10dm = retime(JoinedData.B10,'daily','mean')
figure, hold on

plot(B10dm.Time,B10dm.HS)

function JoinedData = add_degree_days(JoinedData)
%%
sites = fieldnames(JoinedData)
% Fyrir allar stöðvar
for i = 1:length(sites)

    


end
%%

end