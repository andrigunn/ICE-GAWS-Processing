# Icelandic Glacier Automatic Weather Station Network (ICE-GAWS).
Contact info: Andri Gunnarsson at andrigun@lv.is and Finnur Pálsson at fp@hi.is

Since 1994, a network of Automatic Weather Stations has been operated by the National Power Company in Iceland (www.lv.is) and Institute of Earth Sciencis at the University of Iceland (http://earthice.hi.is/) to monitor mass and energy balance of Icelandic glaciers. Generally the stations are deployed during the melting season (May to October) while some deplaoyments extend the full year. 

Overview presentation of the project from IUGG in June 2019 can be found [here](https://github.com/andrigunn/ICE-GAWS-Processing/blob/main/GAWS_IUGG_andrigun_11072019.pdf). Overview map of the network with data from 1994 to current date:
![Overview map of the network](https://github.com/andrigunn/ICE-GAWS-Processing/blob/main/img/overview_data_locations.png)

Processing pipelines used to process the ICE-GAWS data from Level 0 through Level 3. The processing levels are described textually and graphically in the following sections. For data request please contact Andri Gunnarsson at andrigun@lv.is and Finnur Pálsson at fp@hi.is. 

Many processes and data setup are adopted from the PROMICE-AWS-processing which we greatfully acknowledge [https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing](https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing). 

## Data availability
The figure below gives an overview stations with data from 1994 to current date. One (1) indicates that the site has data while zero (0) means that no data was collected for that season. ![Overview stations with data from 1994 to current date:](https://github.com/andrigunn/ICE-GAWS-Processing/blob/main/img/overview_data_avalibility.png)


# ICE-GAWS-Processing overview

Currently data is collected and stored in 3 levels.

- [Raw data] L0 is the raw data collected by the logger and trasmitted via mobile connection or downloaded directly in areas where mobile coverage is not available as *.csv or *.dat files. These files are generally collected at hourly (older files) or 10 min intervals.

- [Data conversion and structuring] L01 reads the raw data (L0-files) and removes auxilary variables (voltage etc) and structures the files to a common data format with systematic variable names. No data is removed. These files are at the original timestep (hourly (older files) or 10 min intervals). 

- [Data cleaning and filtering] L02 reads the L1-files and performs various data checks.
    - `isregular` checks if time is regular in table 
    - `issorted` checks if the table is sorted w.r.t. time   
    - `filterRemoveMaxMin` removes outliers in the data defined for each variable in `constants` file 
    - `removePeriods` removes periods manually reviwed containing various errors and calibration periods. 

- [Data calculations] L02 reads the L01 and calulates derived products 
    - `SurfaceTemperature` calculates surface temeprature from incoming and outgoing long wave radiation using the method described in Fausto et al. 2021 [^1]
    - `Albedo`calculates the "raw" surface albedo using the ratio between incoming and outgoing short wave radiation ranging from 0 to 1. Values smaller than 0 and larger than 1 are set to NaN.
    - `Albedo_acc`calculates the accumulated surface albedo using the ratio between incoming and outgoing short wave radiation  over a time window of 24 h centered around the moment of observation[^2].
    - Data resampled to hourly mean values

    [^1]: Fausto, R. S., van As, D., Mankoff, K. D., Vandecrux, B., Citterio, M., Ahlstrøm, A. P., Andersen, S. B., Colgan, W., Karlsson, N. B., Kjeldsen, K. K., Korsgaard, N. J., Larsen, S. H., Nielsen, S., Pedersen, A. Ø., Shields, C. L., Solgaard, A. M., and Box, J. E.: Programme for Monitoring of the Greenland Ice Sheet (PROMICE) automatic weather station data, Earth Syst. Sci. Data, 13, 3819–3845, [https://doi.org/10.5194/essd-13-3819-2021](https://doi.org/10.5194/essd-13-3819-2021), 2021.  

    [^2]:Van den Broeke, M., van As, D., Reijmer, C., and Wal, R.: Assessing and Improving the Quality of Unattended Radiation Observations in Antarctica, J. Atmos. Ocean. Tech., 21, 1417–1431, [https://doi.org/10.1175/1520-0426(2004)021%3C1417:AAITQO%3E2.0.CO;2](https://doi.org/10.1175/1520-0426(2004)021%3C1417:AAITQO%3E2.0.CO;2), 2004.

## Filtering of data

## Variable names

| Long name         | Short name   | unit                   | Description    |
| ----------        | :--------:   | ----                   | ------------   |
| Timestap          | time         | YYYY-MM-DD HH:MM:SS    | Time of observation |
| Windspeed         | f            | m/s                    | Windspeed observed at 3-5 m above ground level |
| Wind direction    | d            | °                      | Wind direction observed at 3-5 m above ground level |
| Air temperature   | t            | °C                     | Primary air temperature at ~2 m above ground level |
| Air temperature   | t2           | °C                     | Secondary air temperature at ~2 m above ground level from RH sensor |




## File naming conventions

- [Raw data] L0 is stored in the original naming format, i.e. *.dat files. In most cases a file named `VST_XX_MET.dat`, where XX is the station name, contains the L0 data used for further processing. In the L0 folder many auxilary files often exist, especially for older observations.   

## Meta data

ICE-GAWS-location.csv
ICE-GAWS-file-overview.csv => 
ICE-GAWS-location-summary.csv

# Relevant publications
Various publications and research projects have benefited from the program, a few have been collected here: 

Gunnarsson, A., Gardarsson, S. M., Pálsson, F., Jóhannesson, T., and Sveinsson, Ó. G. B.: Annual and inter-annual variability and trends of albedo of Icelandic glaciers, The Cryosphere, 15, 547–570, [https://doi.org/10.5194/tc-15-547-2021](https://doi.org/10.5194/tc-15-547-2021), 2021.

Schmidt, L.S.; Langen, P.L.; Aðalgeirsdóttir, G.; Pálsson, F.; Guðmundsson, S.; Gunnarsson, A. Sensitivity of Glacier Runoff to Winter Snow Thickness Investigated for Vatnajökull Ice Cap, Iceland, Using Numerical Models and Observations. Atmosphere 2018, 9, 450. [https://www.mdpi.com/2073-4433/9/11/450/htm](https://www.mdpi.com/2073-4433/9/11/450/htm)

Gascoin, S.; Guðmundsson, S.; Aðalgeirsdóttir, G.; Pálsson, F.; Schmidt, L.; Berthier, E.; Björnsson, H. Evaluation of MODIS Albedo Product over Ice Caps in Iceland and Impact of Volcanic Eruptions on Their Albedo. Remote Sens. 2017, 9, 399. [https://www.mdpi.com/2072-4292/9/5/399/htm](https://www.mdpi.com/2072-4292/9/5/399/htm)

Schmidt, L. S., Aðalgeirsdóttir, G., Guðmundsson, S., Langen, P. L., Pálsson, F., Mottram, R., Gascoin, S., and Björnsson, H.: The importance of accurate glacier albedo for estimates of surface mass balance on Vatnajökull: evaluating the surface energy budget in a regional climate model with automatic weather station observations, The Cryosphere, 11, 1665–1684, https://doi.org/10.5194/tc-11-1665-2017, 2017.

Wittmann, M., Groot Zwaaftink, C. D., Steffensen Schmidt, L., Guðmundsson, S., Pálsson, F., Arnalds, O., Björnsson, H., Thorsteinsson, T., and Stohl, A.: Impact of dust deposition on the albedo of Vatnajökull ice cap, Iceland, The Cryosphere, 11, 741–754, https://doi.org/10.5194/tc-11-741-2017, 2017.

Sverrir Guðmundsson, Helgi Björnsson, Finnur Pálsson and Hannes H. Haraldsson, 2009. Energy balance and degree-day models of summer ablation on the Langjökull ice cap, SW Iceland. Jökull, 59, 1-18

Sverrir Guðmundsson, Helgi Björnsson, Finnur Pálsson and Hannes H. Haraldsson, 2006. Energy balance of Brúarjökull and circumstances leading to the August 2004 floods in the river Jökla, N-Vatnajökull. Jökull, 55, pp. 121-138.

Helgi Björnsson,Sverrir Guðmundsson, Finnur Pálsson and Hannes H. Haraldsson, 2006. Glacier winds on Vatnajökull ice cap, Iceland and their relation to temperatures of its environs. Annals of Glaciology, 41.

J. Oerlemans, H. Björnsson, M. Kuhn, F. Obleitner, F. Pálsson, H F. Vugts and J. de Wolde 1999.  A glacio-meteorological experiment on Vatnajökull, Iceland. Boundary Layer Meteorology, vol. 92, No. 1, 3-26.

