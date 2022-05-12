# Icelandic Glacier Automatic Weather Station Network.

Processing pipelines used to process the ICE-GAWS data from Level 0 through Level 2. The processing levels are described textually and graphically in the following sections. Overview of the project can be found here [https://github.com/andrigunn/ICE-GAWS](https://github.com/andrigunn/ICE-GAWS)

For data request please contact Andri Gunnarsson at andrigun@lv.is and Finnur Pálsson at fp@hi.is. 

Many processes and data setup are adopted from the PROMICE-AWS-processing [https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing](https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing). 

## ICE-GAWS-Processing

Currently data is collected and stored in 3 levels.

- [Raw data] L0 is the raw data collected by the logger and trasmitted via mobile connection or downloaded directly in areas where mobile coverage is not available as *.csv or *.dat files. These files are generally collected at hourly (older files) or 10 min intervals.

- [Data cleaning] L01 reads the raw data (L0-files) and performs various data checks.
    - `isregular` checks if time is regular in table 
    - `issorted` checks if the table is sorted w.r.t. time   
    - `filterRemoveMaxMin` removes outliers in the data defined for each variable in `constants` file 

- [Data calculations] L02 reads the L01 and calulates derived products 
    - `SurfaceTemperature` calculates surface temeprature from 
