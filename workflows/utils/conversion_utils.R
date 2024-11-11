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

get_hector_emissions <- function(gcam_emissions_data){

  # TODO: Add this with as an option -- only needs to be done if the GCAM data are 
  # broken out by landleaf.
  # 
  # pull out the emissions data from the dat_file
  # gcam_df <- gcam_data$GCAM$`all emissions by region`
  # 
  # # aggregate regional emissions to get global emissions totals
  # global_emissions <- aggregate(value ~ year + ghg,
  #                               data = gcam_df,
  #                               FUN = sum)
  
  # Global data 
  global_emissions <- gcam_emissions_data
  
  # get emissions mapping information
  emissions_map <- read.csv("workflows/data/raw-data/GCAM_hector_emissions_map.csv") 
  
  # merge emissions_map with global_emissions
  gcam_emissions_map <- merge(global_emissions, emissions_map, 
                              by = "ghg", 
                              all.x = TRUE) # all.x = T ensures NAs are added where ghg in global_emissions is not in emissions_map
  setDT(gcam_emissions_map)
  
  # check that expected emissions are being passed to Hector.
  # Expect NAs for:  H2, H2_AWB, PM10, PM2.5, and I think CO2_FUG
  # TODO: what to do in CO2_FUG situation
  missing_ghgs <- unique(gcam_emissions_map[is.na(gcam_emissions_map$agg.gas), ]$ghg)
  expected_missing_ghgs <- c("H2", "H2_AWB")
  
  # check for the presence of expected_missing_ghgs in missing_ghgs.
  # if any of the expected missing ghgs are not found in missing_ghgs, send an error. 
  if(!all(expected_missing_ghgs %in% missing_ghgs)) {
    stop ("Some emissions being passed to Hector are unexpected. These emissions may not be in Hector.")
  }
  
  # convert gcam emissions to to hector emissions:
  # 1 unit conversion
  gcam_emissions_map$converted_value <- gcam_emissions_map$value * gcam_emissions_map$unit.conv
  
  # 2 Halocarbon ghgs can be aggregated into a single halocarbon category
  sum_halocarbon <- gcam_emissions_map[, list(value = sum(converted_value)), 
                                       by = c("scenario", "agg.gas", "hector.name", "year", "hector.units")]
  
  # omit NAs from the halocarbon aggregate
  gcam_emissions_input <- na.omit(sum_halocarbon)
  
  # Check for important columns
  required_columns <- c("year", "value")
  if (!all(required_columns %in% names(gcam_emissions_input))){
    stop("hmmm, there is an important column missing is there a year and value column present?")
  }
  
  # establish data years; 2005:2100. Before 2005 Hector uses GCAM inputs
  data_years <- data.table(year = 1990:2100)
  
  # TODO: Is there a better way to do the following lines?
  # Construct data frame of all the variables for the 2005:2100 year range.
  # This code creates a data frame with NAs when no GCAM emissions are available.
  # The NAs will be subsequently infilled.
  columns_to_save <- names(gcam_emissions_input)[!names(gcam_emissions_input) %in% required_columns]
  data_to_replicate <- distinct(gcam_emissions_input[, ..columns_to_save])
  data_with_target_years <- repeat_add_columns(x = data_to_replicate, y = data_years)
  NA_emissions <- gcam_emissions_input[data_with_target_years, on = names(data_with_target_years), nomatch = NA]
  
  # Replace emission NAs with approximated values 
  approximated_emissions <- NA_emissions %>% 
    group_by(hector.name, hector.units) %>% 
    mutate(value = ifelse(is.na(value), 
                          approx(year, value, xout = year, rule = 2)$y, 
                          value)) %>% 
    ungroup() %>% 
    setDT()
  
  # construct final output
  hector_emissions <- approximated_emissions[, .(scenario = scenario,
                                                 variable = hector.name,
                                                 year = year,
                                                 value = value,
                                                 units = hector.units)]
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
  expected_years <- 2005:2100
  
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

