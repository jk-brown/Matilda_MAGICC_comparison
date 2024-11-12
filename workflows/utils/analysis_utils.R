## Analysis utilities 

# 1 Running Hector/Matilda in parallel ------------------------------------

run_model <- function(input_files, 
                      param_chunks) {
  
  # run the model 
  model_result <- parLapply(cluster, names(input_files), function(scenario_name){
    
    # reset core
    reset(core)
    
    # extract scenario information 
    scenario <- input_files[[scenario_name]]
    
    # initialize a model core for the current scenario
    core <- newcore(scenario, name = scenario_name)
    
    # run the model looking across param_chunks 
    result_list <- lapply(param_chunks, function(chunk) {
      
      iterate_model(core = core, 
                    params = chunk,
                    save_years = 1800:2101,
                    save_vars = c("gmst", 
                                  "CO2_concentration",
                                  "global_tas", 
                                  "ocean_uptake"))
    })
    
    # Convert run_number to continuous among chunks 
    for (i in 2:length(result_list)) {
      
      # calculate the max run_number of the previous element in result_list
      max_run_number <- max(result_list[[i-1]]$run_number)
      
      # Add the max run_number of the previous element to the run_number of the current element
      result_list[[i]]$run_number <- result_list[[i]]$run_number + max_run_number
      
    }
    
    return(result_list)
    
  })
  
  return(model_result)
    
}
