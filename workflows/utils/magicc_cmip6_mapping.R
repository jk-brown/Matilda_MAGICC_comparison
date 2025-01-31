## Plotting data map 

# Mapping for CMIP6 data 

cmip6_dat <- read.csv("workflows/data/raw-data/cmip6_rslts.csv") %>% 
  select(-X)

# Mapping for Ou and Iyer et al. 2021 data (using MAGICC for median warming trajectory)
ou_data <- read.csv("workflows/data/raw-data/ou_Iyer_global_mean_temperature.csv")

# Mapping for estimated MAGICC median and uncertainty from online MAGICC resource

## Median trajectory for BAU scenario
magicc_bau <- read.csv("workflows/data/raw-data/T_01_BAU_magicc.csv")

## MAGICC uncertainty 
magicc_unc <- read.csv("workflows/data/raw-data/magicc_bau_unc.csv")