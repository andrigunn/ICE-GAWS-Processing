site = 'B16';

Files = read_file_structure('L3','monthly');
filtered_files = filter_files(Files, site, 1900,2100); %'all' for all data
[T] = read_data(filtered_files);
%%
figure, hold on
yrs = fieldnames(T.(string(site)))

cmap = lines(6);
ik = 0;
var = 't';

for im = 5:9
    ik = ik+1;

    for i = 1:length(yrs)
            if ismember(var, T.(string(site)).(string(yrs(i))).Properties.VariableNames) == 1
                ix = find(month(T.(string(site)).(string(yrs(i))).Time)==im);
                scatter(T.(string(site)).(string(yrs(i))).Time(ix),T.(string(site)).(string(yrs(i))).(string(var))(ix),'filled',MarkerFaceColor=cmap(ik,:));
            else
            end
        
    end
end