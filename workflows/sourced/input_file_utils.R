## Functions for writing and saving emission constraint and initiation files. 


# 1 Creating emission constraints document (csv) --------------------------

build_emissions_constraints_data <- function(hector_emissions_df) {
  
  # load in constraint csv file 
  constraints_data <- read.csv("workflows/data/raw-data/emissions_constraints_editable.csv", 
                               stringsAsFactors = F, 
                               skip = 5)
  
  # create a vector of unique emissions names from the hector emissions data
  emission_names <- unique(hector_emissions_df$variable)
  
  # new copy of emissions constraint data to overwrite
  emissions_constraint_update <- constraints_data
  
  # Loop through each emission species and update the values in the constraints_data with values from the hector_emissions_df 
  
  for( emission in emission_names) {
    # find the emissions in constraints_data
    original_emission <- grep(emission, colnames(constraints_data))
    
    # if the emission species is found, match the date to the corresponding year in hector_emissions_df
    if( length(original_emission > 0)) {
      values_hector_emissions <- hector_emissions_df$value[hector_emissions_df$variable == emission]
      years_hector_emissions <- hector_emissions_df$year[hector_emissions_df$variable == emission]
      
      # loop through each year in hector_emissions_df
      for (i in seq_along(years_hector_emissions)) {
        year <- years_hector_emissions[i]
        
        # find the corresponding date in constraints_data
        original_date <- which(constraints_data$Date == year)
        
        #if the year exists in cosntraints_data, update the value
        if(length(original_date) > 0) {
          emissions_constraint_update[original_date, original_emission] <- values_hector_emissions[i]
        }
      }
    }
  }
  
  # return the updated emissions constraint data frame.
  return(emissions_constraint_update)
}


# 2 Editing emissions constraint document - used to write ini file -------------------------------------

build_emissions_constraints_file <- function(new_constraint_file,
                                             editable_constraint_file = "workflows/data/raw-data/emissions_constraints_editable.csv",
                                             directory) {
  
  # Check that the hector emissions file exists
  assertthat::assert_that(file.exists(new_constraints_file), msg = "A Hector emissions files does not exist.")
 
  # create a directory if one does not already exist
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = T)
  } 
   
  # Read the first five lines of the original emissions constraint data
  header <- readLines(editable_constraint_file, n = 5)
  
  # Read the lines of the new emissions constraint
  new_emissions_data <- readLines(new_constraint_file)
  
  # Extract scenario name from the file name, while removing the .csv extension
  base_name <- basename(new_constraint_file)
  scenario_name <- tools::file_path_sans_ext(base_name)
  
  # Add the header to the new emissions data
  new_emissions_data <- c(header, new_emissions_data)
  
  # change first line to match new emissions information
  new_emissions_data <- gsub("ssp119 from rcmip", paste0(scenario_name, "_NDC_Exp"), new_emissions_data)
  
  # write new lines and save
  file_path = file.path(directory, base_name)
  writeLines(new_emissions_data, file_path)
  
}


# 3 Function to build input file ------------------------------------------

build_input_file <- function(emissions_constraint_file_path, 
                             editable_input_file = system.file("input/hector_ssp119.ini", package = "hector"), 
                             directory) {
  
  # create a directory if one does not already exist
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = T)
  } 
  
  # check that files constraint file exists
  assertthat::assert_that(file.exists(emissions_constraint_file_path),
                          msg = "Emissions constraint file specified does not exist.")
  
  # Read lines of the editable emissions input file
  original_input_file <- readLines(editable_input_file)
  
  # substitute new emissions constraint path for original emissions constraint path
  new_input_file <- gsub("csv:tables/ssp119_emiss-constraints_rf.csv", 
                         paste0("csv:", emissions_constraint_file_path), 
                         original_input_file)
  # substitute scenario name from the new emissions constraint file path
  new_input_file <- gsub("ssp119", 
                         tools::file_path_sans_ext(basename(emissions_constraint_file_path)), 
                         new_input_file)
  
  # write lines for the new emissions input file
  base_name = basename(emissions_constraint_file_path)
  file_path = file.path(directory, paste0(base_name, ".ini"))
  writeLines(new_input_file, file_path)

}
