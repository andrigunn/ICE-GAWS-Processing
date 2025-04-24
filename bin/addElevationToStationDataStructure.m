
function T = addElevationToStationDataStructure(T,ICE_GAWS_location)

stations = fieldnames(T);

for i = 1:length(stations)
    station = stations(i);
    yrs = fieldnames(T.(string(station)));

    for ii = 1:length(yrs)
        TF = contains([ICE_GAWS_location.site_name],(string(station)));
        ss = ICE_GAWS_location(TF,:);
        newStr = extractAfter(yrs(ii),'Y');
        yr = str2num(string(newStr));

        ix = find(ss.year == yr);
   
        T.(string(station)).(['E',num2str(yr)]) = ss(ix,:);
   
    end
end
