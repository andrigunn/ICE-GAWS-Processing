function data_out = BlacklistVariables(data_in,siteName) 
%% 
Or = data_in;
yr = Or.Time.Year(1);
%% TimePeriods to clean for all sites
    switch siteName

        case 'Hoff'
            TR = timerange('2015-01-01 00:00:00','2015-12-31 00:00:00'); 
            Or.t(TR) = NaN;
        case 'MyrA'
            TR = timerange('2017-01-01 00:00:00','2017-12-31 00:00:00'); 
            Or.t(TR) = NaN;
        case 'T01'
            TR = timerange('2021-01-01 00:00:00','2021-12-31 00:00:00'); 
            Or.t(TR) = NaN;
            
            TR = timerange('2019-01-01 00:00:00','2019-12-31 00:00:00'); 
            Or.ps(TR) = NaN;
        case 'k06'
            TR = timerange('2018-01-01 00:00:00','2018-12-31 00:00:00'); 
            Or.t(TR) = NaN;

        case 'Br07'
            TR = timerange('2017-07-15 00:00:00','2017-12-31 00:00:00'); 
            Or.t(TR) = NaN;

        case 'Br04'
            disp('Blacklisting Br04')
            TR = timerange('2017-01-01 00:00:00','2018-12-31 00:00:00'); 
            Or.t(TR) = NaN;

            TR = timerange('1990-01-01 00:00:00','2020-12-31 00:00:00'); 
            Or.rh(TR) = NaN;

        case 'Br01'
            TR = timerange('2000-01-01 00:00:00','2000-12-31 00:00:00'); 
            Or.sw_in(TR) = NaN;
            
            TR = timerange('2000-01-01 00:00:00','2000-12-31 00:00:00'); 
            Or.sw_out(TR) = NaN;

            TR = timerange('2011-01-01 00:00:00','2001-03-30 00:00:00'); 
            Or.t(TR) = NaN;

        case 'B13'
            TR = timerange('2005-05-01 15:00:00','2005-05-04 19:00:00'); 
            Or.rh(TR) = NaN;

            TR = timerange('1998-01-01 15:00:00','1998-05-06 21:00:00'); 
            Or.rh(TR) = NaN;

            TR = timerange('1998-09-14 18:00:00','1998-12-31 00:00:00'); 
            Or.sw_out(TR) = NaN;

            TR = timerange('1995-01-01 00:00:00','1995-06-11 00:00:00'); 
            Or.sw_in(TR) = NaN;

            TR = timerange('2015-10-23 00:00:00','2015-12-31 00:00:00'); 
            Or.ps(TR) = NaN;
        case 'B16'

            TR = timerange('2014-07-20 00:00:00','2014-12-31 00:00:00'); 
            Or.t(TR) = NaN;
            Or.rh(TR) = NaN;
            Or.lw_in(TR) = NaN;
            Or.lw_out(TR) = NaN;

            TR = timerange('2009-09-25 00:00:00','2009-12-31 00:00:00'); 
            Or.t(TR) = NaN;
            Or.rh(TR) = NaN;
            Or.lw_in(TR) = NaN;
            Or.lw_out(TR) = NaN;

            switch yr

                case 2009
                %%
                rm = load('b16_2009_t');
                %ix = datefind([Or.Time]==rm.b16_2009_t);
                DIF_DATES = intersect(Or.Time, datetime(rm.b16_2009_t));
                Or.t(DIF_DATES) = NaN;
                %%
                otherwise
            end
            
            
    end

     data_out = Or;     