## Analysis utilities 

# 1 Running Hector/Matilda in parallel ------------------------------------


# 2 Normalize data to reference period -----------------------------------------------------------------------

normalize_dat <- function(data, ref_start, ref_end) {
  
  # Filter data for the reference period
  ref_period <- subset(
    data,
    year >= ref_start &
      year <= ref_end
  )
  
  # Calculate the mean for the reference period
  mean_ref_dat <- mean(ref_period$value, na.rm = TRUE)
  
  # Normalize values by subtracting the mean_ref_period
  norm_dat <- data$value - mean_ref_dat
  
  # Return the normalized data
  return(norm_dat)
}


# 3 Get data summary ------------------------------------------------------

