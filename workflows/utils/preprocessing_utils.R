

# Pivot GHG emissions data to long format -----------------------------------------------

long_ghg_data <- function(data) {
  
  long_data = data %>% 
    pivot_longer(
      cols = -c(scenario, region, GHG, Units),
      names_to = "year", 
      values_to = "value"
    ) %>% 
    mutate(
      year = as.numeric(year)
    ) %>% 
    select(Units, scenario, region, GHG, year, value)
  
  return(long_data)
}


# Pivot LUC data to long format -----------------------------------------------------------

long_luc_data <- function(data) {
  
  long_data = data %>% 
    pivot_longer(
      cols = -c(scenario, region, Units, LandLeaf),
      names_to = "year", 
      values_to = "value"
    ) %>% 
    mutate(
      year = as.numeric(year)
    ) %>% 
    select(Units, scenario, region, year, value)
  
  return(long_data)
}

# Recode scenario names ---------------------------------------------------

scenario_names <-
  c("T_01_BAU",
    "T_02_CAT_crnt",
    "T_03_CAT_cont",
    "T_04_NDC_cont",
    "T_05_NDC_inc_LTS",
    "T_06_NDC_cont", 
    "T_07_NDC_inc_LTS")

recode_ghg_scenarios <- function(data) {
  
  data$scenario <- recode_factor(
    data$scenario,
    "T_01_BAU,date=2021-22-9T19:23:29+17:00" = scenario_names[1],
    "T_02_CAT_crnt,date=2021-22-9T19:23:29+17:00" = scenario_names[2],
    "T_03_CAT_cont,date=2021-22-9T19:23:29+17:00" = scenario_names[3],
    "T_04_NDC_cont,date=2021-22-9T19:23:29+17:00" = scenario_names[4],
    "T_05_NDC_incr_LTS,date=2021-22-9T19:23:28+17:00" = scenario_names[5],
    "T_06_NDC_cont,date=2021-22-9T19:23:28+17:00" = scenario_names[6],
    "T_07_NDC_incr_LTS,date=2021-22-9T19:23:28+17:00" = scenario_names[7])
  
  data <- data %>% 
    rename(ghg = GHG)
  
  return(data)
}

recode_luc_scenarios <- function(data) {
  
  data$scenario <- recode_factor(
    data$scenario,
    "T_01_BAU,date=2021-22-9T19:23:29+17:00" = scenario_names[1],
    "T_02_CAT_crnt,date=2021-22-9T19:23:29+17:00" = scenario_names[2],
    "T_03_CAT_cont,date=2021-22-9T19:23:29+17:00" = scenario_names[3],
    "T_04_NDC_cont,date=2021-22-9T19:23:29+17:00" = scenario_names[4],
    "T_05_NDC_incr_LTS,date=2021-22-9T19:23:28+17:00" = scenario_names[5],
    "T_06_NDC_cont,date=2021-22-9T19:23:28+17:00" = scenario_names[6],
    "T_07_NDC_incr_LTS,date=2021-22-9T19:23:28+17:00" = scenario_names[7])
  
  return(data)
}

# Load Data Functions --------------------------------------------------------

load_ghg_data <- function(path) {
  
  data <- read.csv(path, check.names = F)
  
  data_long <- long_ghg_data(data)
  
  data_recode <- recode_ghg_scenarios(data_long)
  
}

load_luc_data <- function(path) {
  
  data <- read.csv(path, check.names = F)
  
  data_long <- long_luc_data(data)
  
  data_recode <- recode_luc_scenarios(data_long)
  
}

# Saving scenarios --------------------------------------------------------

scenario_split <- function(data, directory) {
  
  # create a directory if one does not already exist
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = T)
  }
  
  scenario_split <- split(data, data$scenario)
  
  names(scenario_split) <- unique(data$scenario)
  
  for (scenario_name in names(scenario_split)) {
    
    file_path = file.path(directory, paste0(scenario_name, ".csv")) 
    
    write.csv(scenario_split[[scenario_name]], file_path, row.names = F)
  }
  
  # return the split list 
  return(scenario_split)

  }

