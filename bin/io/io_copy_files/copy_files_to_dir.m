% Find and filter data and move to a new dir for sharing

write_file_dir = '/Users/andrigun/Dropbox/08-Shared-out/or/'
% Make the file structure
files = read_file_structure('L2','hourly');

FileList = files;

for i = 1:length(FileList)
    source = [FileList(i).folder,filesep,FileList(i).name];
    destination = [write_file_dir,FileList(i).name];

    copyfile(source, destination)

end



