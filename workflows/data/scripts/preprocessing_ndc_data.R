## Preprocessing NDC GHG emissions data

# 1 Source set-up and utils -------------------------------------------------------

source("workflows/sourced/set-up.R")
source("workflows/data/utils/preprocessing_utils.R")

# 2 Read in data ----------------------------------------------------------------------

ndc_data <- load_gcam_data("workflows/data/raw-data/global_emissions.csv")

# 3 Split and save scenarios -------------------------------------------------------

ndc_list <- scenario_split(ndc_data, "workflows/data/input/scenarios")
