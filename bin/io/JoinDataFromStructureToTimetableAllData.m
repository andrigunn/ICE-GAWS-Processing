function JoinedData = JoinDataFromStructureToTimetableAllData(data,site)
% Joines data and all variables to a single file
%site = 'B10'
%%
switch site
    case ''
        site = fieldnames(data);
    otherwise
        site = {site};
end
%%
for i = 1:length(site)
    clear nel
    site2merge = string(site(i));

    yrs = fieldnames(data.(site2merge));

    fn = cell(40,40);
    for ii = 1:length(yrs)
        % Check for max number of columns
        fn(ii,1:length(fieldnames(data.(site2merge).(string(yrs(ii))))))...
            = fieldnames(data.(site2merge).(string(yrs(ii))));

        nel(ii,1) =numel(fieldnames(data.(site2merge).(string(yrs(ii)))))';
    end

    mty = cellfun('isempty',fn);

    fn(mty) = '';
    uqfn = unique(fn);

    if sum(strcmp(uqfn,'Properties'))== 1 
       uqfn(strcmp(uqfn,'Properties')) = [];
    else 
    end
    
    if sum(strcmp(uqfn,'Row'))== 1 
       uqfn(strcmp(uqfn,'Row')) = [];
    else 
    end

    if sum(strcmp(uqfn,'Variables'))== 1 
       uqfn(strcmp(uqfn,'Variables')) = [];
    else 
    end

    
    %[ind,ix] = max(nel);
    ix = length(unique(uqfn));
    %fnames = fieldnames(data.(site2merge).(string(yrs(ix))));
    %fnames = fnames(1:end-3); % Remove unused variables
    fnames = uqfn;
    % Make a timetable to fill
    % from = data.(site2merge).(string(yrs((1)))).Time(1);
    % to = data.(site2merge).(string(yrs((end)))).Time(end)
    % T = timetable(datetime(from:to),nan(length(datetime(from:to)),length(fnames)))

    % Table padding
    TBL = [];

    for ii = 1:length(yrs)

        tbl = data.(site2merge).(string(yrs((ii))));
        fn_tbl = fieldnames(tbl);

        fn_tbl(end-2:end) = []; % var 3 en henti þá út albedo_acc

        for k = 1:length(fnames)
            % Field name checker, pads variables with nan if the dont exist
            fname = fnames(k);
            
            if sum(strcmp(fn_tbl,fname)) > 0 %var contains
                %disp('Variable exists')
                
            else % pads the table with NaN
                %disp('Variable not exists')
                tbl.(string(fname)) = nan(height(tbl),1);
                
            end

        end
        
            % % Henda út öllu HS2 dóti
            % if sum(contains(fn_tbl,'HS2')) > 0
            %     tbl = removevars(tbl, "HS2_mod");
            %     tbl = removevars(tbl, "HS2");
            %     tbl = removevars(tbl, "HS2_nor");
            % else % pads the table with NaN
            % 
            % end

        if ii == 1
            TBL = tbl;
        else
            tbl_vars = tbl.Properties.VariableNames;
            TBL_vars =  data.(site2merge).(string(yrs(ii))).Properties.VariableNames;
            
            if sum(~ismember(tbl_vars,TBL_vars)>0)
                kx = ~ismember(tbl_vars,TBL_vars);
                m = find(kx==1);
                %disp('vars exist in current file')

                for j = 1:length(m)
                    TBL.(string(tbl_vars(m(j)))) = nan(height(TBL),1);
                end

            else

            end
            TBL = [TBL;tbl];
        end
    end
    
    JoinedData.(site2merge) = table2timetable(TBL);

end

disp(['Merging done for: ',site2merge])






