
### Icelandic Glaciers Automatic Weather Station Network (ICE-GAWS)
##Release notes: 
#Updated: 18.02.2026:
- The data processing and structure has had a major overhaul. Please re-download the data if you have data from older releases
- All data for the year 2025 has been added
- Gap-filling of data is based on the IceBox RCM. CARRA gap-filling is pending. 
- The data is updated anually and is stored aat  [here](https://data.lv.is/ICE-GAWS-v2/). 

Contact info: Andri Gunnarsson at andrigun@lv.is and Finnur Pálsson at fp@hi.is

*Please cite the following paper when using ICE-GAWS data. More details about the stations and data processing can be found there:*

Gunnarsson, A., Pálsson, F., Björnsson, H., Guðmundsson, S., & Haraldsson, H. H. (2025). Surface climatology of glaciers in Iceland: Icelandic Glaciers Automatic Weather Station Network (ICE-GAWS). Journal of Geophysical Research: Atmospheres. [DOI](https://doi.org/10.1029/2024JD043216).

# Overview

Since 1994, a network of Automatic Weather Stations has been operated by the [National Power Company in Iceland](http://www.lv.is) and [Institute of Earth Sciencis at the University of Iceland](http://earthice.hi.is/) to monitor mass and energy balance of Icelandic glaciers. Generally the stations are deployed during the melting season (May to October) while some deplaoyments extend the full year.

Processing pipelines and code used to process the ICE-GAWS **(Icelandic Glacier Automatic Weather Station Network)** data from raw collected data in the field (Level 0) through end-user data (Level 3). Many processes and data setup are adopted from the PROMICE-AWS-processing which we greatfully acknowledge [https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing](https://github.com/GEUS-Glaciology-and-Climate/PROMICE-AWS-processing). 

## Data Processing overview
The data processing workflow follows a structured pipeline from raw field data to fully processed climate products.

### Pre-Installation & Field Work:
Sensors undergo open-field calibration and inter-comparison to ensure accuracy prior to field installation . Upon installation, functionality is verified in situ, and station coordinates/elevation are recorded via GNSS. Manual measurements (e.g., snow height) are taken for validation. 

Station locations are found in `/ICE-GAWS-Data-v2/locations` in two files, 
`ICE-GAWS-location.csv` and `ICE-GAWS-location-summary.csv`. The former file provides annual locations of the sites while the latter provides "averages" station locations for all the operation years.

Manual snow height measurements are provided in `\ICE-GAWS-Data-v2\data_aux\hs_obs` where one file exists for each site. 

### Data file structure:
The data directory `\ICE-GAWS-Data-v2\data` is organized hierarchically by glacier, individual glacier, and station, with separate folders for each processing level:

```
\ICE-GAWS-Data-v2\data\
├── vatnajokull\
│   ├── vatnajokull_breidamerkurjokull_Br01\
│   │   ├── L0\          # Raw datalogger files
│   │   ├── L1\          # Standardized data
│   │   ├── L2\          # Quality controlled data  
│   │   └── L3\          # Final processed products
│   └── vatnajokull_skaftafellsjokull_Sk01\
├── hofsjokull\
│   └── hofsjokull_mulajokull_Mu01\
└── langjokull\
    └── langjokull_hagafellsjokull_Ha01\
```
**Filename Convention:**
- L1: `ICE-GAWS_[Station]_L1_[Year].csv` (e.g., `ICE-GAWS_Br01_L1_2023.csv`)
- L2: `ICE-GAWS_[Station]_L2_[Year].csv` (e.g., `ICE-GAWS_Br01_L2_2023.csv`) 
- L3: `ICE-GAWS_[Station]_L3_[Aggregation]_[Year].csv` (e.g., `ICE-GAWS_Br01_L3_daily_2023.csv`)

**Auxiliary Data:**
- `\ICE-GAWS-Data-v2\locations\` - Station coordinates and metadata
- `\ICE-GAWS-Data-v2\data_aux\hs_obs\` - Manual snow height observations
- `\ICE-GAWS-Data-v2\data\edits\` - Persistent manual edit records

### Level 0 (Raw Data):
Raw data stored on dataloggers or transmitted via telemetry. No corrections or quality checks are applied; includes testing periods. This is data that should no be used. 

### Level 1 (Standardization):
Converts raw data to a consistent structure, format and variable names. Auxiliary variables (e.g., battery voltage) are removed. Data remains at the original time step with no periods excluded and original units. 

### Level 2 (Quality Control):
The L2 processing transforms standardized L1 data into quality-controlled datasets through a comprehensive two-stage filtering process combining automated algorithms with expert manual inspection.

#### Stage 1: Automated Filtering
**Unit Normalization**: Data units are automatically detected and normalized to standard units (e.g., temperatures converted from Kelvin to Celsius, pressures from Pa to hPa, lengths to appropriate scales).

**Physical Range Limits**: Each variable has scientifically-based physical limits applied that are site specific but genereal values are:
- Temperature: -50°C to 30°C (all temperature sensors)  
- Relative Humidity: 0% to 100%
- Wind Speed: 0 to 75 m/s
- Wind Direction: 0° to 360°
- Snow Height (HS): 25cm to 800cm
- Snow Height Secondary (HS2): -20cm to 500cm (allowing for installation variations)
- Precipitation: 0 to 8000mm per timestep
- Shortwave Radiation: -10 to 1400 W/m²
- Longwave Incoming: 100 to 450 W/m²
- Longwave Outgoing: -200 to 330 W/m²
- Pressure: 600 to 1100 hPa

**Spike Detection**: Variable-specific moving median filters identify and remove statistical outliers:
- Window sizes: 0-24 hours depending on variable characteristics
- Threshold factors: 3-6 standard deviations based on expected variability
- Considers physical constraints (e.g., smoother filtering for temperature, more aggressive for precipitation)

#### Stage 2: Manual Expert Review
**Interactive Visualization**: Experienced researchers review interactive time series plots showing:
- Original raw data (gray points)
- Auto-rejected points (red crosses)  
- Current valid data (blue points)
- Manual field observations when available (red diamonds)

Edits are stored in `\ICE-GAWS-Data-v2\data\edits\` for each file. 

**Manual Editing Capabilities**:
- Visual brushing tool for selecting suspicious data periods
- Ability to remove sensor malfunction periods, calibration intervals, and installation artifacts
- Integration with field observation data to validate or correct automated decisions
- Persistent edit tracking - manual edits are saved and can be reapplied to updated datasets

**Common Manual Corrections**:
- Removing periods when sensors were covered by snow/ice
- Eliminating data during maintenance or calibration activities  
- Correcting for known installation issues
- Filtering out environmental interference (e.g., icing events)
- Height corrections based on manual snow measurements

**Data Preservation**: Snow height variables receive special treatment - both automated (HS_filtered_a) and manually-edited (HS_filtered_m) versions are preserved to allow comparison of filtering approaches.

### Level 3 (Derived Products):
Calculates additional variables (e.g., albedo, surface temperature) and aggregates data into hourly, daily, and monthly means. Monthly means require >85% data availability.

Albedo: Calculated as a 24-hour running integral[^1].

Surface Temp: Derived from longwave radiation (emissivity = 0.97)[^2].

[^1]:Van den Broeke, M., van As, D., Reijmer, C., and Wal, R.: Assessing and Improving the Quality of Unattended Radiation Observations in Antarctica, J. Atmos. Ocean. Tech., 21, 1417–1431, [https://doi.org/10.1175/1520-0426(2004)021%3C1417:AAITQO%3E2.0.CO;2](https://doi.org/10.1175/1520-0426(2004)021%3C1417:AAITQO%3E2.0.CO;2), 2004.

[^2]: Fausto, R. S., van As, D., Mankoff, K. D., Vandecrux, B., Citterio, M., Ahlstrøm, A. P., Andersen, S. B., Colgan, W., Karlsson, N. B., Kjeldsen, K. K., Korsgaard, N. J., Larsen, S. H., Nielsen, S., Pedersen, A. Ø., Shields, C. L., Solgaard, A. M., and Box, J. E.: Programme for Monitoring of the Greenland Ice Sheet (PROMICE) automatic weather station data, Earth Syst. Sci. Data, 13, 3819–3845, [https://doi.org/10.5194/essd-13-3819-2021](https://doi.org/10.5194/essd-13-3819-2021), 2021.  

  

### Variables and instrumentation
As most of the sites are only operated during the extended melt season (AMJJASO) they are stored indoors during the winter months. Prior to installation in spring they are installed, maintained/refurbished and tested. Further description of instruments can be found [here](https://doi.org/10.1029/2024JD043216).   


| Variable Name  | Units                                   | Description  |
|--------------- |:--------------------------------------: |:-------------|
| Time           |YYYY-MM-DD HH:MM:SS   |Timestep of data|
| DrawWire       |mm |Ice melt reletive to station|
| HS             |cm |Surface height change relative to sensor|
| HS2            |cm  |Surface height change relative to station|
| lw_in          |W/m2 |Incoming longwave radiation|
| lw_out         |W/m2|Outgoing longwave radiation|
| precip         |mm/timestep|Precipitation|
| ps             |hPa|barometric pressure|
| ps2            |hPa|secondary barametric pressure |
| rh_2m          |%|Relative humidity|
| rh_4m          |%|Relative humidity at secondary elevation|
| sw_in          |W/m2|Incoming shortwave radiation|
| sw_out         |W/m2|Outgoing shortwave radiation|
| t_2m           |°C|Primary air temeprature (Pt1000)|
| t2_2m          |°C|Secondary air temperature (RH-sensor)|
| t_4m           |°C|Air temperature at secondary elevation|
| t_logger       |°C|Logger enclosure temperature|
| wd_2m          |°|Wind direction measured at 2 m above surface|
| wd_4m          |°|Wind direction measured at 4 m above surface|
| ws_2m          |m/s|Wind speed measured at 2 m above surface|
| ws_4m          |m/s|Wind speed measured at 4 m above surface|

# Notes on variables
Snow height (HS) in some cases, for sites where the HS mast has fallen over might not be completelly aligned within the year. We recommend if using HS variables in detail to have a look at the L1 data and see the filtering and adjustments done with the data. 

# Related puplications
Overview article of the project, data processing and simple analysis: 

Gunnarsson, A., Pálsson, F., Björnsson, H., Guðmundsson, S., & Haraldsson, H. H. (2025). Surface climatology of glaciers in Iceland: Icelandic Glaciers Automatic Weather Station Network (ICE-GAWS). Journal of Geophysical Research: Atmospheres. https://doi.org/10.1029/2024JD043216

Overview presentation of the project from IUGG in June 2019 can be found [here](https://github.com/andrigunn/ICE-GAWS/blob/main/GAWS_IUGG_andrigun_11072019.pdf)

Various publications and research projects have benefited from the program, a few have been collected here: 

Gunnarsson, A., Gardarsson, S. M., Pálsson, F., Jóhannesson, T., and Sveinsson, Ó. G. B.: Annual and inter-annual variability and trends of albedo of Icelandic glaciers, The Cryosphere, 15, 547–570, https://doi.org/10.5194/tc-15-547-2021, 2021.

Schmidt, L.S.; Langen, P.L.; Aðalgeirsdóttir, G.; Pálsson, F.; Guðmundsson, S.; Gunnarsson, A. Sensitivity of Glacier Runoff to Winter Snow Thickness Investigated for Vatnajökull Ice Cap, Iceland, Using Numerical Models and Observations. Atmosphere 2018, 9, 450. [https://www.mdpi.com/2073-4433/9/11/450/htm](https://www.mdpi.com/2073-4433/9/11/450/htm)

Gascoin, S.; Guðmundsson, S.; Aðalgeirsdóttir, G.; Pálsson, F.; Schmidt, L.; Berthier, E.; Björnsson, H. Evaluation of MODIS Albedo Product over Ice Caps in Iceland and Impact of Volcanic Eruptions on Their Albedo. Remote Sens. 2017, 9, 399. [https://www.mdpi.com/2072-4292/9/5/399/htm](https://www.mdpi.com/2072-4292/9/5/399/htm)

Schmidt, L. S., Aðalgeirsdóttir, G., Guðmundsson, S., Langen, P. L., Pálsson, F., Mottram, R., Gascoin, S., and Björnsson, H.: The importance of accurate glacier albedo for estimates of surface mass balance on Vatnajökull: evaluating the surface energy budget in a regional climate model with automatic weather station observations, The Cryosphere, 11, 1665–1684, https://doi.org/10.5194/tc-11-1665-2017, 2017.

Wittmann, M., Groot Zwaaftink, C. D., Steffensen Schmidt, L., Guðmundsson, S., Pálsson, F., Arnalds, O., Björnsson, H., Thorsteinsson, T., and Stohl, A.: Impact of dust deposition on the albedo of Vatnajökull ice cap, Iceland, The Cryosphere, 11, 741–754, https://doi.org/10.5194/tc-11-741-2017, 2017.

Sverrir Guðmundsson, Helgi Björnsson, Finnur Pálsson and Hannes H. Haraldsson, 2009. Energy balance and degree-day models of summer ablation on the Langjökull ice cap, SW Iceland. Jökull, 59, 1-18

Sverrir Guðmundsson, Helgi Björnsson, Finnur Pálsson and Hannes H. Haraldsson, 2006. Energy balance of Brúarjökull and circumstances leading to the August 2004 floods in the river Jökla, N-Vatnajökull. Jökull, 55, pp. 121-138.

Helgi Björnsson,Sverrir Guðmundsson, Finnur Pálsson and Hannes H. Haraldsson, 2006. Glacier winds on Vatnajökull ice cap, Iceland and their relation to temperatures of its environs. Annals of Glaciology, 41.

J. Oerlemans, H. Björnsson, M. Kuhn, F. Obleitner, F. Pálsson, H F. Vugts and J. de Wolde 1999.  A glacio-meteorological experiment on Vatnajökull, Iceland. Boundary Layer Meteorology, vol. 92, No. 1, 3-26.
