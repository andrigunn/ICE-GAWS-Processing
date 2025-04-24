function overview_images()
clc
Files = read_file_structure('L1','raw');
snames = unique([Files.station_name]);
%%
for i = 1:length(snames)
    sname = snames(i);
   
    files = read_file_structure('L1','daily');
    filtered_files = filter_files(files, sname, 1900,2100); %'all' for all data
    [L1_T,~,~] = read_data(filtered_files);

    files = read_file_structure('L2','daily');
    filtered_files = filter_files(files, sname, 1900,2100); %'all' for all data
    [L2_T,~,~] = read_data(filtered_files);

    files = read_file_structure('L3','daily');
    filtered_files = filter_files(files, sname, 1900,2100); %'all' for all data
    [L3_T,~,~] = read_data(filtered_files);

    vnames = fieldnames(L1_T.(sname));
    cd('C:\Users\andrigun\Dropbox\Verkefni\ICE-GAWS-Processing\img_overview')

        for iy = 1:length(vnames)
            close all
            yr = vnames(iy);            
        
            figure('Visible','off')
            stackedplot(L1_T.(string(sname)).(string(yr)));
            pname = ([char(sname),'_',char(yr),'_L1' ]);
            title(pname)
            export_fig(pname,'-png')
        
            figure('Visible','off')
            stackedplot(L2_T.(string(sname)).(string(yr)));
            pname = ([char(sname),'_',char(yr),'_L2']);
            title(pname)
            export_fig(pname,'-png')
        
            figure('Visible','off')
            stackedplot(L3_T.(string(sname)).(string(yr)));
            pname = ([char(sname),'_',char(yr),'_L3']);
            title(pname)
            export_fig(pname,'-png')
       
        end
end




