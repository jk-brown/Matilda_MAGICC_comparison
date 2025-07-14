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


# Sampling magicc_emulated params
### df: a data frame that includes mean and sd values for "emulated" parameters. 
sample_emulated_params <- function(df, draws) {
  
  # data frame of random parameter values drawn from normal or lognormal distributions
  data.frame(
    "BETA" = rnorm(draws, mean = df$BETA, sd = df$BETA_sd),
    "Q10_RH" = rlnorm(draws, matilda:::lognorm(df$Q10_RH, df$Q10_RH_sd)[1], matilda:::lognorm(df$Q10_RH, df$Q10_RH_sd)[2]),
    "NPP_FLUX0" = rnorm(draws, mean = df$NPP_FLUX0, sd = df$NPP_FLUX0_sd),
    "AERO_SCALE" = rnorm(draws, mean = df$AERO_SCALE, sd = df$AERO_SCALE_sd),
    "DIFFUSIVITY" = rnorm(draws, mean = df$DIFFUSIVITY, sd = df$DIFFUSIVITY_sd),
    "ECS" = rlnorm(draws, matilda:::lognorm(df$ECS, df$ECS_sd)[1], matilda:::lognorm(df$ECS, df$ECS_sd)[2])
  )
}

# Using LHS smapling 

library(lhs)

lhs_params <- function(core, draws) {
  # Fetch values for the parameters
  beta <- fetchvars(core, NA, BETA())
  q10 <- fetchvars(core, NA, Q10_RH())
  npp <- fetchvars(core, NA, NPP_FLUX0())
  aero <- fetchvars(core, NA, AERO_SCALE())
  ohd <- fetchvars(core, NA, DIFFUSIVITY())
  ecs <- fetchvars(core, NA, ECS())
  
  # Generate Latin Hypercube Samples (LHS)
  lhs_samples <- randomLHS(draws, 6)  # 6 parameters
  
  # Transform LHS samples to appropriate distributions
  data.frame(
    "BETA" = qnorm(lhs_samples[,1], mean = beta$value, sd = 0.1),
    "Q10_RH" = qlnorm(lhs_samples[,2], matilda:::lognorm(q10$value, 1.0)[1], matilda:::lognorm(q10$value, 1.0)[2]),
    "NPP_FLUX0" = qnorm(lhs_samples[,3], mean = npp$value, sd = 14.3),
    "AERO_SCALE" = qnorm(lhs_samples[,4], mean = aero$value, sd = 0.23),
    "DIFFUSIVITY" = qnorm(lhs_samples[,5], mean = ohd$value, sd = 0.118),
    "ECS" = qlnorm(lhs_samples[,6], matilda:::lognorm(ecs$value, 0.65)[1], matilda:::lognorm(ecs$value, 0.65)[2])
  )
}