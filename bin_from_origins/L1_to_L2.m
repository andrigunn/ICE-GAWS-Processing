% ICE-GAWS
% function L1_to_L2
%% Level 1 to Level 2
% Reads Level 1 data from the file structure
% 


% Author: Andri Gunnarsson (andrigun@lv.is)
% ========================================================================

%% Import constants for the transect-mode run ----------------------------
% originally the surface energy balance was designed to work on transects.
% This functionnality is not working anymore but might be implemented again
% later on.
% 
%
% Read L1 folders to structure
if ispc
    Folder   = 'C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\data';
    fname_location = 'C:\Users\andrigun\Dropbox\01-IcelandicSnowObservatory-ISO\ICE-GAWS\data\gaws_site_location_all_sites.csv'

elseif ismac
    Folder   = '/Volumes/sentinel/Dropbox/01-IcelandicSnowObservatory-ISO/ICE-GAWS/data';
    Folder   = '/Users/andrigunnarsson/Dropbox/01-IcelandicSnowObservatory-ISO/ICE-GAWS/data';
    fname_location = '/Users/andrigunnarsson/Dropbox/01-IcelandicSnowObservatory-ISO/ICE-GAWS/data/gaws_site_location_all_sites.csv'

end
FileList = dir(fullfile(Folder, '**', '*VST*.csv'));
FileList = rmfield(FileList, {'date', 'bytes', 'isdir', 'datenum'});

for i = 1:length(FileList)
    
    newStr = split(FileList(i).name,'_');
    x = size(newStr);
    
    if x(1) == 5
        FileList(i).year = str2num(char(newStr(4)));
        FileList(i).siteName = newStr(2);
        
    elseif x(1) == 6
        FileList(i).year = str2num(char(newStr(5)));
        FileList(i).siteName = newStr(3);
        
    elseif x(1) == 4
        y = char(newStr(4));
        Yr = y(1:4);
        FileList(i).year = str2num(Yr);
        
        FileList(i).siteName = newStr(2);
    end
    newStr = split(FileList(i).folder,filesep);
    FileList(i).mainGlacier = newStr(8);
end
% Add SMB data from observations
addpath('C:\Users\andrigun\Dropbox\Github_master\glacier_smb\afk')
smb = make_smb;
% Add location information
opts = delimitedTextImportOptions("NumVariables", 5, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["year", "lat", "lon", "elevation", "site_name"];
opts.VariableTypes = ["double", "double", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "site_name", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "site_name", "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["year", "lat", "lon", "elevation"], "DecimalSeparator", ",");
opts = setvaropts(opts, ["year", "lat", "lon", "elevation"], "ThousandsSeparator", ".");

loc = readtable(fname_location, opts);

proj = projcrs(3057);
disp('Mapping coordinates to file structure')
for i = 1:length(FileList)
   
        ix = find(FileList(i).year == loc.year & string(FileList(i).siteName) == string(loc.site_name));
    if isempty(ix);
    else
        FileList(i).lat = loc.lat(ix);
        FileList(i).lon = loc.lon(ix);
        FileList(i).ele = loc.elevation(ix);
    
        [x,y] = projfwd(proj,loc.lat(ix),-loc.lon(ix));
        FileList(i).ISN93_x = x;
        FileList(i).ISN93_y = y;
    end
end


% Rename variables
[FileList.name_L1] = FileList.name; FileList = rmfield(FileList,'name');
[FileList.folder_L1] = FileList.folder;  FileList = rmfield(FileList,'folder');
%% 
for i = 1:length(FileList);
    fname = [FileList(i).folder_L1,filesep,FileList(i).name_L1];
    siteName = string(FileList(i).siteName);
    siteYear = string(FileList(i).year);
    
    disp(fname)
    disp(['Running for site: ',char(siteName), ' and year ',  siteYear])
    
    clear Or M
    M = readtable(fname);
    Or = table2timetable(M);
    
    Or.Year = Or.time.Year;
    Or.Month = Or.time.Month;
    Or.DayofMonth = Or.time.Day;
    Or.DayOfYear = day(Or.time,('dayofyear'));
    
    if ismember('f',Or.Properties.VariableNames)
        Or = movevars(Or, 'Year', 'Before', 'f');
    else
        Or = movevars(Or, 'Year', 'Before', 't');
    end
    
    Or = movevars(Or, 'Month', 'After', 'Year');
    Or = movevars(Or, 'DayofMonth', 'After', 'Month');
    Or = movevars(Or, 'DayOfYear', 'After', 'DayofMonth');
    
    if ismember('t',Or.Properties.VariableNames)
        Or = movevars(Or, 't', 'After', 'DayOfYear');
    else
    end
    
    if ismember('f',Or.Properties.VariableNames)
        Or = movevars(Or, 'f', 'After', 't');;
    else
    end
    
    if ismember('d',Or.Properties.VariableNames)
         Or = movevars(Or, 'd', 'After', 'f');
    else
    end
    
    if ismember('rh',Or.Properties.VariableNames) && ismember('d',Or.Properties.VariableNames)
        Or = movevars(Or, 'rh', 'After', 'd');
    else
    end

    vname = Or.Properties.VariableNames;
    
    % Remove QC columns
    k = strfind(vname,'QC');
    
    clear ko
    for ij = 1:length(k)
        ko(ij) = isempty(k{ij});
    end
    
    idel = find(ko==1);
    Or = Or(:,idel);
    
    % TimePeriods to clean for all sites
    switch siteName
        case 'Mariutungur'
            TR = timerange('1997-01-01 00:00:00','1997-05-15 00:00:00'); Or(TR,:) = [];                   
            
        case 'Kokv'
            TR = timerange('2000-01-01 00:00:00','2000-05-01 00:00:00'); Or(TR,:) = [];                   
            TR = timerange('1999-01-01 00:00:00','1999-05-01 00:00:00'); Or(TR,:) = [];                   
            TR = timerange('1998-01-01 00:00:00','1998-04-27 00:00:00'); Or(TR,:) = [];       
            TR = timerange('1997-01-01 00:00:00','1997-05-13 00:00:00'); Or(TR,:) = [];       
            
        case 'E03'
            TR = timerange('2020-01-01 00:00:00','2020-04-30 00:00:00'); Or(TR,:) = [];       

        case 'E01'
            %vantar að bæta við árið 2020 af g0gnum
            TR = timerange('2020-01-25 00:00:00','2020-04-20 00:00:00'); Or(TR,:) = [];       

        case 'Br07'
            TR = timerange('2018-01-01 00:00:00','2018-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2017-01-01 00:00:00','2017-05-01 00:00:00'); Or(TR,:) = [];       

        case 'Br04'
            % Athuga með 1996 árið. Virðist vera mjög hlýtt
            % 2016 og 2017 þarf að endurskoða
            TR = timerange('2015-11-10 00:00:00','2016-01-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2015-01-01 00:00:00','2015-05-01 00:00:00'); Or(TR,:) = [];       

            TR = timerange('2014-11-20 00:00:00','2015-01-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2014-01-01 00:00:00','2014-03-01 00:00:00'); Or(TR,:) = [];       

            TR = timerange('2013-01-01 00:00:00','2013-03-06 00:00:00'); Or(TR,:) = [];       

            TR = timerange('2012-01-01 00:00:00','2012-04-20 00:00:00'); Or(TR,:) = [];       
        case 'Br01'  
            % Þarf að skoða 2011 betur. lofthiti er í rusl
            TR = timerange('2012-01-01 00:00:00','2012-05-23 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2010-09-01 00:00:00','2011-01-31 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2002-10-01 00:00:00','2002-10-31 00:00:00'); Or(TR,:) = [];       

        case 'Bard' 
            TR = timerange('2018-01-01 00:00:00','2018-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2017-01-01 00:00:00','2017-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2016-01-01 00:00:00','2016-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2013-01-01 00:00:00','2013-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2012-01-01 00:00:00','2012-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2009-01-01 00:00:00','2009-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2007-01-01 00:00:00','2007-06-01 00:00:00'); Or(TR,:) = [];      
            TR = timerange('2006-01-01 00:00:00','2006-06-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2005-01-01 00:00:00','2005-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2004-01-01 00:00:00','2004-06-10 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2003-01-01 00:00:00','2003-06-02 00:00:00'); Or(TR,:) = [];       

        case 'T06'
            TR = timerange('2021-01-01 00:00:00','2021-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2020-01-01 00:00:00','2020-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2016-01-01 00:00:00','2016-05-04 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2015-01-01 00:00:00','2015-05-07 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2014-01-01 00:00:00','2014-05-03 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2013-01-01 00:00:00','2013-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2012-01-01 00:00:00','2012-05-08 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2007-01-01 00:00:00','2007-05-02 00:00:00'); Or(TR,:) = [];                   
            TR = timerange('2006-09-19 00:00:00','2006-12-31 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2006-01-01 00:00:00','2006-04-28 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2005-01-01 00:00:00','2005-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2004-01-01 00:00:00','2004-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2003-01-01 00:00:00','2003-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2002-09-07 00:00:00','2002-12-31 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2002-01-01 00:00:00','2002-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2001-01-01 00:00:00','2001-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2000-01-01 00:00:00','2000-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('1999-01-01 00:00:00','1999-05-01 00:00:00'); Or(TR,:) = [];       

        case 'T03'
            TR = timerange('2021-01-01 00:00:00','2021-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2020-01-01 00:00:00','2020-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2016-01-01 00:00:00','2016-05-04 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2015-01-01 00:00:00','2015-05-06 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2014-01-01 00:00:00','2014-05-03 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2013-01-01 00:00:00','2013-05-03 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2007-01-01 00:00:00','2007-05-08 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2005-08-11 00:00:00','2005-08-14 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2005-01-01 00:00:00','2005-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2004-01-01 00:00:00','2004-05-01 00:00:00'); Or(TR,:) = [];       
            TR = timerange('2004-08-01 00:00:00','2004-12-31 00:00:00'); Or(TR,:) = [];
            TR = timerange('2003-01-01 00:00:00','2003-06-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-01-01 00:00:00','2002-06-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2000-01-01 00:00:00','2000-04-10 00:00:00'); Or(TR,:) = [];
            TR = timerange('1999-01-01 00:00:00','1999-05-01 00:00:00'); Or(TR,:) = [];

        case 'T01'
            TR = timerange('2021-03-01 00:00:00','2021-05-01 00:00:00'); Or(TR,:) = [];

            TR = timerange('2020-03-01 00:00:00','2020-05-10 00:00:00'); Or(TR,:) = [];

            TR = timerange('2000-01-01 00:00:00','2000-04-10 00:00:00'); Or(TR,:) = [];

            TR = timerange('1999-01-01 00:00:00','1999-05-01 00:00:00'); Or(TR,:) = [];

        case 'Hoff'
            TR = timerange('2015-01-01 00:00:00','2015-05-09 00:00:00'); Or(TR,:) = [];
            TR = timerange('2014-09-01 00:00:00','2014-12-31 00:00:00'); Or(TR,:) = [];
            TR = timerange('2014-01-01 00:00:00','2014-05-07 00:00:00'); Or(TR,:) = [];
            TR = timerange('2013-01-01 00:00:00','2013-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2011-09-15 00:00:00','2011-12-31 00:00:00'); Or(TR,:) = [];
            TR = timerange('2009-01-01 00:00:00','2009-05-04 00:00:00'); Or(TR,:) = [];
            TR = timerange('2007-01-01 00:00:00','2007-05-02 00:00:00'); Or(TR,:) = [];
            TR = timerange('2006-09-27 00:00:00','2006-12-31 00:00:00'); Or(TR,:) = [];
            TR = timerange('2006-01-01 00:00:00','2006-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2005-01-01 00:00:00','2005-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2004-01-01 00:00:00','2004-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2003-01-01 00:00:00','2003-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-01-01 00:00:00','2002-05-01 00:00:00'); Or(TR,:) = [];
     
        case 'vh'
            TR = timerange('2013-02-05 00:00:00','2013-05-01 00:00:00'); Or(TR,:) = [];

        case 'B16'
            TR = timerange('2021-01-01 00:00:00','2021-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2020-01-01 00:00:00','2020-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2016-01-01 00:00:00','2016-05-06 00:00:00'); Or(TR,:) = [];
            TR = timerange('2015-01-01 00:00:00','2015-05-06 00:00:00'); Or(TR,:) = [];
            TR = timerange('2013-01-01 00:00:00','2013-05-05 00:00:00'); Or(TR,:) = [];
            TR = timerange('2012-01-01 00:00:00','2012-05-05 00:00:00'); Or(TR,:) = [];
            TR = timerange('2009-01-01 00:00:00','2009-05-05 00:00:00'); Or(TR,:) = [];
            TR = timerange('2007-01-01 00:00:00','2007-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2006-01-01 00:00:00','2006-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2005-01-01 00:00:00','2005-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2004-01-01 00:00:00','2004-04-25 00:00:00'); Or(TR,:) = [];
            TR = timerange('2003-01-01 00:00:00','2003-05-03 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-01-01 00:00:00','2002-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2001-01-01 00:00:00','2001-04-23 00:00:00'); Or(TR,:) = [];
            
        case 'B13' 
            TR = timerange('2020-01-01 00:00:00','2020-05-01 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2014-01-01 00:00:00','2014-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2013-01-01 00:00:00','2013-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2012-01-01 00:00:00','2012-05-05 00:00:00'); Or(TR,:) = [];
            TR = timerange('2009-01-01 00:00:00','2009-05-10 00:00:00'); Or(TR,:) = [];
            TR = timerange('2007-01-01 00:00:00','2007-05-04 00:00:00'); Or(TR,:) = [];
            TR = timerange('2006-01-01 00:00:00','2006-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2005-01-01 00:00:00','2005-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2004-01-01 00:00:00','2004-04-20 00:00:00'); Or(TR,:) = [];
            TR = timerange('2003-01-01 00:00:00','2003-05-10 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-01-01 00:00:00','2002-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2001-01-01 00:00:00','2001-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2000-01-01 00:00:00','2000-05-03 00:00:00'); Or(TR,:) = [];
            TR = timerange('1999-01-01 00:00:00','1999-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('1998-01-01 00:00:00','1998-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('1997-01-01 00:00:00','1997-05-18 00:00:00'); Or(TR,:) = [];

        case 'B10'
            TR = timerange('2021-03-10 00:00:00','2021-05-03 00:00:00'); Or(TR,:) = [];
            TR = timerange('2019-09-01 00:00:00','2019-10-20 00:00:00'); Or(TR,:) = [];
            TR = timerange('2003-01-01 00:00:00','2003-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-10-01 00:00:00','2002-12-31 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-01-01 00:00:00','2002-05-01 00:00:00'); Or(TR,:) = [];
            TR = timerange('2001-01-01 00:00:00','2001-05-01 00:00:00'); Or(TR,:) = [];

        case 'MyrA'
            TR = timerange('2018-01-01 00:00:00','2018-05-28 00:00:00'); Or(TR,:) = [];
            TR = timerange('2017-01-01 00:00:00','2017-05-21 00:00:00'); Or(TR,:) = [];
            TR = timerange('2016-01-01 00:00:00','2016-05-16 00:00:00'); Or(TR,:) = [];
        case 'L05'
            TR = timerange('2018-01-01 00:00:00','2018-04-26 00:00:00'); Or(TR,:) = [];
            TR = timerange('2017-01-01 00:00:00','2017-04-26 00:00:00'); Or(TR,:) = [];
            TR = timerange('2016-01-01 00:00:00','2016-04-28 00:00:00'); Or(TR,:) = [];

            TR = timerange('2014-01-01 00:00:00','2014-04-30 00:00:00'); Or(TR,:) = [];

            TR = timerange('2013-01-01 00:00:00','2013-04-24 00:00:00'); Or(TR,:) = [];

            TR = timerange('2012-01-01 00:00:00','2012-04-24 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2001-01-01 00:00:00','2001-04-22 00:00:00'); Or(TR,:) = [];
            TR = timerange('2002-01-01 00:00:00','2002-04-27 00:00:00'); Or(TR,:) = [];
            TR = timerange('2003-01-01 00:00:00','2003-04-25 00:00:00'); Or(TR,:) = [];
            TR = timerange('2004-01-01 00:00:00','2004-05-09 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2005-01-01 00:00:00','2005-04-23 00:00:00'); Or(TR,:) = [];
            TR = timerange('2005-10-13 00:00:00','2005-10-28 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2006-01-01 00:00:00','2006-05-16 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2007-01-01 00:00:00','2007-04-28 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2009-01-01 00:00:00','2009-04-20 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2010-10-04 00:00:00','2010-10-20 00:00:00'); Or(TR,:) = [];
            
        case 'HNA09'
            TR = timerange('2018-01-01 00:00:00','2018-04-17 00:00:00'); Or(TR,:) = [];
            TR = timerange('2016-04-14 00:00:00','2016-04-16 00:00:00'); Or(TR,:) = [];
            
        case 'HNA13'
            TR = timerange('2018-01-01 00:00:00','2018-04-17 00:00:00'); Or(TR,:) = [];
            TR = timerange('2016-12-11 00:00:00','2017-01-01 00:00:00'); Or(TR,:) = [];
            
        case 'L01'
            TR = timerange('2001-01-01 00:00:00','2001-04-20 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2002-01-01 00:00:00','2002-04-26 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2003-01-01 00:00:00','2003-04-25 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2004-01-01 00:00:00','2004-05-08 16:00:00'); Or(TR,:) = [];
            TR = timerange('2004-10-22 00:00:00','2004-10-24 16:00:00'); Or(TR,:) = [];
            
            TR = timerange('2005-01-01 00:00:00','2005-04-25 00:00:00'); Or(TR,:) = [];
            TR = timerange('2005-10-13 00:00:00','2005-10-16 11:00:00'); Or(TR,:) = [];
            
            TR = timerange('2006-01-01 00:00:00','2006-05-16 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2007-01-01 00:00:00','2007-04-29 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2009-01-01 00:00:00','2009-04-20 00:00:00'); Or(TR,:) = [];
            TR = timerange('2009-10-21 00:00:00','2009-10-23 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2011-11-25 00:00:00','2011-12-24 00:00:00'); Or(TR,:) = [];
            
            TR = timerange('2012-01-01 00:00:00','2012-04-01 00:00:00'); Or(TR,:) = [];
            
            
            
    end
    
% Filters for data
Or = MaxMinFilter(Or, 't', -30 ,30);
Or = MaxMinFilter(Or, 't2', -30 ,30);
Or = MaxMinFilter(Or, 'rh', 10 ,100);
Or = MaxMinFilter(Or, 'ps', 650 ,1100);
Or = MaxMinFilter(Or, 'f', 0 ,50);
Or = MaxMinFilter(Or, 'd', 0 ,365);

Or = MaxMinFilter(Or, 'sw_in', -10 ,1500);
Or = MaxMinFilter(Or, 'sw_out', -10 ,1000);
Or = MaxMinFilter(Or, 'lw_in', 50 ,450);
Or = MaxMinFilter(Or, 'lw_out', 50 ,450);
% 
%      close all
%       figure
%       stackedplot(Or,["t",'f']) % "HS_nor"
    
    % Write data
    folderName_L2 = [FileList(i).folder_L1(1:end-2),'L2']
    FileList(i).folderName_L2 = [folderName_L2,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_original.csv']
    folderName_L2_original = [FileList(i).folder_L1(1:end-2),'L2',filesep,'original']
    FileList(i).fileName_L2 = folderName_L2_original
    folderName_L2_hourly = [FileList(i).folder_L1(1:end-2),'L2',filesep,'hourly']
    folderName_L2_daily = [FileList(i).folder_L1(1:end-2),'L2',filesep,'daily']
    %
    if exist(folderName_L2, 'dir')
    else
        mkdir(folderName_L2)
    end
    
    if exist(folderName_L2_original, 'dir')
    else
        mkdir(folderName_L2_original)
    end
    
    if exist(folderName_L2_hourly, 'dir')
    else
        mkdir(folderName_L2_hourly)
    end
    
    if exist(folderName_L2_daily, 'dir')
    else
        mkdir(folderName_L2_daily)
    end
    
    writetimetable(Or,...
        [folderName_L2_original,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_original.csv'],...
        'Delimiter',';')
    
    HH = retime(Or, 'hourly','mean');
    
    writetimetable(HH,...
        [folderName_L2_hourly,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_hourly.csv'],...
        'Delimiter',';')
    
    DM = retime(Or, 'daily','mean');
    
    writetimetable(DM,...
        [folderName_L2_daily,filesep,char(FileList(i).mainGlacier),'_',char(FileList(i).siteName),'_',num2str(FileList(i).year),'_L2_daily.csv'],...
        'Delimiter',';')
    
end























