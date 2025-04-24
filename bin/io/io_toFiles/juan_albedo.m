
write_file_dir = 'C:\Users\andrigun\Dropbox\08-Shared-out\juan_albedo\'
% Make the file structure
files = read_file_structure('L2','hourly');

FileList = files;
data = readFileListToStructure(FileList);

JoinedData = JoinDataFromStructureToTimetableAllData(data,'');
%%

fn = fieldnames(JoinedData)
%%

for i = 1:length(fn)

    JoinedData.(string(fn(i)));
    Exist_Column = strcmp('Albedo_acc',...
        JoinedData.(string(fn(i))).Properties.VariableNames);

    if(sum(Exist_Column) == 1)
        filename = [write_file_dir,char(string((fn(i)))),'.csv']
        fprintf('%.3g', A.Albedo_acc)

        A =  JoinedData.(string(fn(i)))(:,Exist_Column);
        writetimetable(A,filename);
    else
    end

end




