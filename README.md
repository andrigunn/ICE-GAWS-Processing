# Icelandic Glacier Automatic Weather Station Network.

Processing pipelines used to process the ICE-GAWS data from Level 0 through Level 2. The processing levels are described textually and graphically in the following sections. Overview of the project can be found here [https://github.com/andrigunn/ICE-GAWS](https://github.com/andrigunn/ICE-GAWS)

For data request please contact Andri Gunnarsson at andrigun@lv.is and Finnur Pálsson at fp@hi.is. 

Many processes and data setup are adopted from the PROMICE-AWS-processing [https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing](https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing). 

## ICE-GAWS-Processing

Currently data is collected and stored in 3 levels.

- [Raw data] L0 is the raw data collected by the logger and trasmitted via mobile connection or downloaded directly in areas where mobile coverage is not available as *.csv or *.dat files. These files are generally collected at hourly (older files) or 10 min intervals.

- [Data cleaning and filtering] L01 reads the raw data (L0-files) and performs various data checks.
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

| Long name  | Short name | unit | Description |
| ------------- | ------------- | ------------- |
| Timestap  | time  |YYYY-MM-DD HH:MM:SS | Time of observation |


## File naming conventions

- [Raw data] L0 is stored in the original naming format, i.e. *.dat files. In most cases a file named `VST_XX_MET.dat`, where XX is the station name, contains the L0 data used for further processing. In the L0 folder many auxilary files often exist, especially for older observations.   