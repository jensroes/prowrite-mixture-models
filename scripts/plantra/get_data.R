get_data <- function(file, n_samples){
  # Load df
  d <- read_csv(file) %>%
    filter(!is.na(iki), 
           iki > 50, 
           iki < 30000,
           enough_sentences) %>%
    mutate(across(ppt, ~as.numeric(factor(.))),
           condition = factor(str_c(location, task, sep = "_")),
           cond_num = as.integer(condition),
           location = factor(location),
           loc_num = as.integer(location)) %>% 
    select(ppt, iki, condition, location, cond_num, loc_num) 
  
  # Sample within each category random data points
  set.seed(365)
  d <- d %>% group_by(ppt, condition) %>%
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_sample) %>% 
    ungroup() %>% 
    filter(keep) %>% 
    select(-keep)
  
  return(d)
}