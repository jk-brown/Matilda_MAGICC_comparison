## Functions for converting GCAM emissions output to Hector input. 

# 1 Repeat add columns ----------------------------------------------------

# data.table implementation of the gcamdata repeat_add_columns
# Args 
#   x: data.table to add to 
#   y: data.table containing the column that should be repeated and added to dt x
# return: data.table
repeat_add_columns <- function(x, y){
  
  assert_that(is.data.table(x))
  assert_that(is.data.table(y))
  assert_that(!any(names(x) %in% names(y)))
  assert_that(!any(names(y) %in% names(x)))
  
  x$join <- 1
  y$join <- 1
  
  df <- merge(x, y, all = TRUE, by = .EACHI, allow.cartesian=TRUE)
  df$join <- NULL
  return(df)
  
}

# 2 converting GCAM emissions to Hector emissions -------------------------

# Ensure necessary libraries are loaded
library(data.table)
library(dplyr)

# Function to convert GCAM emissions data to Hector emissions format
get_hector_emissions <- function(gcam_emissions_data) {
  
  # Step 1: Validate the input emissions data (make sure it's a data.table)
  if (!is.data.table(gcam_emissions_data)) {
    stop("The input GCAM emissions data must be a data.table.")
  }
  
  # Step 2: Read the emissions mapping information
  emissions_map <- tryCatch({
    read.csv("data/raw-data/GCAM_hector_emissions_map.csv")
  }, error = function(e) {
    stop("Error reading emissions map: ", e$message)
  })
  
  # Ensure required columns exist in the emissions_map
  required_columns_map <- c("ghg", "agg.gas", "unit.conv")
  if (!all(required_columns_map %in% names(emissions_map))) {
    stop("The emissions map CSV is missing required columns.")
  }
  
  # Step 3: Merge the global emissions data with the emissions map
  gcam_emissions_map <- merge(gcam_emissions_data, emissions_map, by = "ghg", all.x = TRUE)
  setDT(gcam_emissions_map)  # Ensure it's a data.table
  
  # Step 4: Check for missing GHGs (e.g., H2, H2_AWB)
  missing_ghgs <- unique(gcam_emissions_map[is.na(agg.gas), ]$ghg)
  expected_missing_ghgs <- c("H2", "H2_AWB")
  
  # Stop if unexpected GHGs are found
  if (!all(expected_missing_ghgs %in% missing_ghgs)) {
    stop("Some emissions being passed to Hector are unexpected. These emissions may not be in Hector.")
  }
  
  # Step 5: Perform unit conversion
  gcam_emissions_map$converted_value <- gcam_emissions_map$value * gcam_emissions_map$unit.conv
  
  # Step 6: Aggregate Halocarbon GHGs into a single category
  sum_halocarbon <- gcam_emissions_map[, .(value = sum(converted_value, na.rm = TRUE)),
                                       by = c("scenario", "agg.gas", "hector.name", "year", "hector.units")]
  
  # Omit NAs from the halocarbon aggregate
  gcam_emissions_input <- na.omit(sum_halocarbon)
  
  # Step 7: Validate required columns (year and value)
  required_columns <- c("year", "value")
  if (!all(required_columns %in% names(gcam_emissions_input))) {
    stop("Required columns 'year' and 'value' are missing.")
  }
  
  # Step 8: Define the target year range (1990-2100) for Hector
  data_years <- data.table(year = 1990:2100)
  
  # Step 9: Replicate data for target years (2005-2100)
  columns_to_save <- setdiff(names(gcam_emissions_input), required_columns)
  data_to_replicate <- distinct(gcam_emissions_input[, ..columns_to_save])
  data_with_target_years <- merge(data_to_replicate, data_years, by = NULL, allow.cartesian = TRUE)
  
  # Merge the target years with the emissions data and add NAs where no data is available
  NA_emissions <- merge(data_with_target_years, gcam_emissions_input, by = names(data_with_target_years), all.x = TRUE)
  
  # Step 10: Replace NAs with approximated values
  approximated_emissions <- NA_emissions %>%
    group_by(hector.name, hector.units) %>%
    mutate(value = ifelse(
      all(is.na(value)), 
      NA, # Skip groups with all NAs
      approx(year, value, xout = year, rule = 2)$y
    )) %>%
    ungroup() %>%
    setDT()
  
  # Step 11: Construct the final Hector emissions data
  hector_emissions <- approximated_emissions[, .(scenario = scenario,
                                                 variable = hector.name,
                                                 year = year,
                                                 value = value,
                                                 units = hector.units)]
  
  # Return the final emissions data
  return(hector_emissions)
}



# 3 converting GCAM LUC emissions to Hector  ------------------------------

get_luc_emissions <- function(gcam_emissions_file) {
  
  # # Check that the gcam data file exists
  # assertthat::assert_that(file.exists(gcam_emissions_file))
  # 
  # # load gcam project from dat_file
  # gcam_proj <- loadProject(gcam_emissions_file)
  
  # # extract the luc_emissions from gcam_emissions_file
  # luc_df <- gcam_proj$GCAM$`LUC emissions by region`
  # luc_df$variable <- "luc_emissions"
  
  # copy over data
  luc_df <- gcam_emissions_file
  luc_df$variable <- "luc_emissions"
  
  # convert gcam luc_emissions to hector luc_emissions
  luc_df$units <- "Pg C/yr"
  conv.factor <- 0.001 # From MT C/yr to Pg C/yr
  luc_df$converted_value <- luc_df$value * conv.factor
  
  # Aggregate regions to global luc_emissions for Hector
  global_luc <- luc_df %>%
    group_by(scenario, variable, year, units) %>%
    summarize(value = sum(converted_value)) %>%
    ungroup()
  
  # Expected years for the Hector luc_emissions will be from 2005:2100
  # wait...am I not using this anywhere?
  expected_years <- 1990:2100
  
  # create rows for years not in gcam data
  annual_luc <- global_luc %>% 
    complete(year = 1975:2100, # use complete() to get complete years in the df and fill with NAs
             nesting(scenario, variable, units), 
             fill = list(value = NA)) %>% 
    filter(year > 1989) %>% 
    # only interested in 2005 -- before 2005 Hector uses gcam emissions?
    # TODO: get confirmation about filtering in line 152
    mutate(value = ifelse(is.na(value), 
                          approx(year, value, xout = year, rule = 2)$y,
                          value)) %>% 
    ungroup() %>% 
    select(scenario, variable, year, value, units)
  
  return(annual_luc)
}

