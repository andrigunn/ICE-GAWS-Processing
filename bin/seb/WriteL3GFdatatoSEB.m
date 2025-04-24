%WriteL3GFdatatoSEB

rootdir = '/Users/andrigun/Dropbox/01-Projects/ICE-GAWS-Data/' 
process_years_from = 2000
process_years_to = 2022
station_filter = 'B16'
filltype = 'carra'

filelist = filterL3GFfiles(rootdir,process_years_from,process_years_to,station_filter,filltype)
%%
convertL3GFtoSEB(filelist)

