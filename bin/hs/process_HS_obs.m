%%%%%%% GAWS - Observation of Snow Height  %%%%%%%
% Author: Thorbjorg Anna Sigurbjornsdottir
% Last modification: 22.12.2022
% Landsvirkjun, fall 2022

% The script first finds a directory with large number of files that 
% contain conducted observations of snow height at glacier automatic 
% weather stations (GAWS) in Iceland. Files for each GAWS are
% identified and then combined into one textfile (one file per GAWS). 
% This file contains all available measurements for snow height for that 
% particular GAWS from begining of measurements to end of 2018. 
% Each textfile containing the observations are then saved in a specific 
% folder. 

% Script outputs: One textfile for each GAWS in Iceland containing all
% avilable observations of snow height measurements until the year 2018. 


clear all; clc;
disp('Extracting file names from directory')
% Set the path to the folder with the data:
% Set if Windows or Linux system
if ispc
   %d = dir(['F:/Þróunarsvið/Rannsóknir/Jöklarannsóknir/30_GAWS/GAVEL/GAVEL1/GlacierAWS/**/RAW/**/*ld.xls'])
    d = dir(['F:/Þróunarsvið/Rannsóknir/Jöklarannsóknir/30_GAWS/GAVEL/GAVEL1/GlacierAWS/**/RAW/**/*hand*']);
%elseif isunix
    %d = dir(['F:/Þróunarsvið/Rannsóknir/Jöklarannsóknir/30_GAWS/GAVEL/GAVEL1/GlacierAWS/**/RAW/**/*hand*']);
end
%% Bara keyrt til að afrita skrárnar einu sinni
for i = 1:length(d)
    d(i).folderTo = 'C:\Users\andrigun\Dropbox\01-Projects\ICE-GAWS-Data\data_aux\hs_obs'

    copyfile([d(i).folder,filesep,d(i).name],[d(i).folderTo,filesep,d(i).name])  
end


%%
% All files in the directory that have hand in their filename are listed 
% in d because that is the only common part of the filename for all 
% stations (i.e. hand from handmaelingar or similar words). 
% Most of the files are .xls files but a few are .dat and thus it is not 
% possible to extract files from the directory based on the file ending. 

% A few station have a file named Snjoh_Handmeald_*.xls where observations
% from several years are combined into one file. First those files
% are removed from d to avoid dulpicate values of observations. 
 index=[];
 for j=1:length(d)
     ind1= strfind((d(j).name), 'Snjoh_Handmaeld_');      
     if isempty(ind1)~=1
          if isempty(index)==1
              index= j;
          else 
           index=[index; j];
          end
     end
 end
 d(index,:)=[];         % Remove lines from d
 

% Get the station name, the year of observation and path from each file
for i = 1:length(d)

    % Extract the station name and year
    C = strsplit([d(i).folder],{'\'});

    d(i).station = C(9);
    if length(C)>10
    d(i).year = C(11);
    end
    d(i).path= append(d(i).folder, '\', d(i).name);   % Path to each file

end


disp(['For each station, all available data is combined in a timetable and saved as .txt file'])

% Extract name of each station in one vector
uqstation= unique([d.station]);
% Loop through the stations and data from each file available is extracted. 
% Then all available data for each station is combined into one timetable. 
% The timetable is then saved as .txt file. 

for iv=1:length(uqstation)
    ix = find([d.station]==string(uqstation(iv)));
    df = d(ix,:);           % Extract subset from d with only lines from station ix
    for im=1:length(df)
        % Extract the data from each file
         D= readmatrix(df(im).path, 'Range', '');          

        % If day of the year (doy) in the oberservation file is a integer 
        % then it gives a timestamp at 00:00. We assume all measurements 
        % are at 12:00 o'clock unless otherwise specified with doy. To 
        % aviod having doy at 00:00 the value 0.5 was added to integer 
        % doy values.  
        isaninteger = @(x)isfinite(x) & x==floor(x);
        clear int
        int=isaninteger(D(:,1));
        for ip= 1:length(D(:,1))
            if int(ip)==1
               D(ip,1)=D(ip,1)+0.5;
            end
        end
        
        clear date Time

     % Remove doy that are larger than 365 or smaller than 0 to remove
     % duplicates
     D((find(D(:,1)<0 | D(:,1)>367)),:)=[];

     date= datenum(str2double(df(im).year),1,D(:,1)); 
 
        % Convert datenum to datetime
        Time=datetime(date, 'ConvertFrom', 'datenum', 'Format','uuuu-MM-dd HH:mm');         

        % Merge the time vector with the data to crete one timetable with
        % all avilable data for each station.
        T=timetable(Time, D(:,2));
        if im==1
            Obs=T;
        else 
            Obs=[Obs; T];
        end
    end
    % Change the column name of the timetable 
    Obs= renamevars(Obs, ["Var1"], ["HS"]);

    
    % If same date is repated (more than one observation was conducted at
    % the same day, for example due to adjustment of the gauge) then two 
    % hours are addedd to the later observation. A while loop makes sure
    % this process is repated if there are more than two observations are 
    % assigned to the same timestamp. 
    Obs= unique(Obs, 'stable');             % First remove identical line (both timestamp and value identical) if they are present. Sometimes files for different years have the same values. 
    [u, iu]=unique(Obs.Time);
    while length(u)<length(Obs.Time)
    
        for k=1:length(Obs.Time)
            if isempty(find(k== iu))==1
                Obs.Time(k)=Obs.Time(k)+hours(2);
            end
        end
     [u, iu]=unique(Obs.Time);
    end

    % Remove lines in the timetable with NaN values
    Obs= rmmissing(Obs);

    % Save the timetable as .txt file
    % The path might need to be changed for different users. 
    if ispc
           savename = ['C:\Users\thorbjorgas\OneDrive - Landsvirkjun\Documents\MATLAB\Haust LV 2022\GAWS\Observations\'...
               char(uqstation(iv)),...
               '_',...
               char('HS'),...
               '_',...
               char('Observations'),...
               '.txt'];

%   elseif isunix
%          savename = ['/data/CMIP6/data/csv/'...
%              char(uqstation(iv)),...
%              '_',...
%              char('HS'),...
%              '_',...
%              char('Observations'),...
%              '.txt'];
      end
    disp(savename)
    writetimetable(Obs,string(savename));

end