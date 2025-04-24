
function files = read_file_structure(filetype,aggregationtype)
%%
disp(['read_file_structure: Reading files'])
disp(['read_file_structure: File type ',filetype])
disp(['read_file_structure: Aggregationtype type ',aggregationtype])
if ispc
    rootdir = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data';
elseif ismac
    rootdir = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data';
end
filelist = dir(fullfile(rootdir, '**',filesep,'*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,[filesep,filetype]);
end

L1_files = filelist([filelist.L1_folder]==1);

% Make meta data
for i = 1:length(L1_files)
    newStr = split(L1_files(i).folder,filesep);
    newStr = split(newStr(end-1),'_'); 

    x = size(newStr);

    if x(1) == 3
        L1_files(i).main_glacier = string(newStr(1));
        L1_files(i).outlet_glacier = string(newStr(2));
        L1_files(i).station_name = string(newStr(3));
        
    else
        L1_files(i).main_glacier = string(newStr(1));
        L1_files(i).outlet_glacier = string(newStr(1));
        L1_files(i).station_name = string(newStr(2));
    end
    
        newStr = split(L1_files(i).name,'_'); 

        if sum(size(newStr) == 4) == 1
            newStr = split(newStr(4),'.');
            L1_files(i).year = str2num(string(newStr(1)));
        else % case for Gr_vh as the name has two letter name
            newStr = split(newStr(5),'.');
            L1_files(i).year = str2num(string(newStr(1)));
        end
    
end

L1_files = rmfield(L1_files, {'date', 'bytes', 'isdir', 'datenum', 'L1_folder'});

%% Remove hr, daily and month data from list
switch aggregationtype
    case 'raw'
        idx = ~cellfun('isempty',strfind({L1_files.name},'hourly'));
        L1_files(idx,:) = [];

        idx = ~cellfun('isempty',strfind({L1_files.name},'daily'));
        L1_files(idx,:) = [];

        idx = ~cellfun('isempty',strfind({L1_files.name},'monthly'));
        L1_files(idx,:) = [];

    case 'hourly'
        
        idx = ~cellfun('isempty',strfind({L1_files.name},'hourly'));
        L1_files(~idx,:) = [];

    case 'daily'
        
        idx = ~cellfun('isempty',strfind({L1_files.name},'daily'));
        L1_files(~idx,:) = [];

    case 'monthly'
        
        idx = ~cellfun('isempty',strfind({L1_files.name},'monthly'));
        L1_files(~idx,:) = [];

end


files = L1_files;
disp(['read_file_structure: Found ',num2str(length(files)),' files'])