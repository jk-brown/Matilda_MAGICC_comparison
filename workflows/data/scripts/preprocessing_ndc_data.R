## Preprocessing NDC GHG emissions data

# 1 Source set-up and utils -------------------------------------------------------

source("workflows/sourced/set-up.R")
source("workflows/data/utils/preprocessing_utils.R")

# 2 Read in emissions data ----------------------------------------------------------------------

ndc_ghg_emissions <- load_ghg_data("workflows/data/raw-data/global_emissions.csv")

ndc_luc_emissions <- load_luc_data("workflows/data/raw-data/global_LUC.csv")

# 3 Split and save scenarios -------------------------------------------------------

# TODO: want to have this as separate function that will save what we need but it does not
# seem super important right now -- come back to the scneario_pslit function.
ndc_ghg_list <- scenario_split(ndc_ghg_emissions, "workflows/data/input/scenarios_ghg")

ndc_luc_emissions <- scenario_split(ndc_luc_emissions, "workflows/data/input/scenarios_luc")
