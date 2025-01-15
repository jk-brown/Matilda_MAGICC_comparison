## Analysis utilities 

# 3 normalize to reference ------------------------------------------------------

# Normalize function
normalize_to_reference <- function(df, reference_start, reference_end) {
  
  # Filter data for the reference period
  reference_data <- df %>% filter(year >= reference_start & year <= reference_end)
  
  # Calculate mean and optionally std for reference period for each run
  reference_mean <- reference_data %>%
    group_by(run_number, variable) %>%
    summarise(reference_mean = mean(value))
  
  # Merge the reference statistics back to the original data
  df <- df %>%
    left_join(reference_mean, by = c("run_number", "variable")) %>%
    mutate(normalized_value = value - reference_mean)  # For mean normalization
  
  return(df)
}


# Normalize a single series -----------------------------------------------

normalize_single_series <- function(df, reference_start, reference_end) {
  # Filter the reference period
  reference_data <- df %>% filter(year >= reference_start & year <= reference_end)
  
  # Calculate the mean value for the reference period
  reference_mean <- mean(reference_data$value, na.rm = TRUE)
  
  # Subtract the reference mean from the original values
  df <- df %>%
    mutate(normalized_value = value - reference_mean)
  
  return(df)
}
