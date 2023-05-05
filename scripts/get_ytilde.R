# Extract model simulations
get_ytilde <- function(files, idx) {
  # Load model
  m <- readRDS(files)
  
  # Get model name
  model_name <- sub(".*/([^/]+)\\..*", "\\1", files)
  
  # Extract simulations
  y_tilde <- as.matrix(m, pars = "y_tilde")
  
  # Extract 100 simulations
  y_tilde_sims <- y_tilde[idx,]
  
  # Make data frame
  sims <- y_tilde_sims %>% 
    as_tibble() %>% 
    rownames_to_column("sim_idx") %>% 
    pivot_longer(-sim_idx) %>% 
    mutate(data_idx = parse_number(name)) %>% 
    arrange(data_idx) %>% 
    mutate(model = model_name) %>% 
    select(-name)
  
  return(sims)
}
