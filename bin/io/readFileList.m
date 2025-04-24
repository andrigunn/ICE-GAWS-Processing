function FileList = readFileList(filetype,aggregation)
%% L1 ==> L2 Processing
if ispc
    rootdir = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data';
elseif ismac

    rootdir = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/data';
end

filelist = dir(fullfile(rootdir, ['**',filesep,'*.*']));  % get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  % remove folders from list

for i = 1:length(filelist)
  filelist(i).L1_folder = endsWith(filelist(i).folder,[filesep,filetype]);
end

L1_files = filelist([filelist.L1_folder]==1);

%% Make meta data
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

FileList = rmfield(L1_files, {'date', 'bytes', 'isdir', 'datenum', 'L1_folder'});
%
switch filetype
    case 'L1' % Agg er ekki gert fyrir L1 gögn
    otherwise
        switch aggregation
            case 'hourly'
                ixx = find(contains({FileList.name},aggregation));
                FileList = FileList(ixx,:);
        
            case 'daily'
                ixx = find(contains({FileList.name},'daily'));
                FileList = FileList(ixx,:);
        
            case 'monthly'
                ixx = find(contains({FileList.name},'monthly'));
                FileList = FileList(ixx,:);
            
        end
end
