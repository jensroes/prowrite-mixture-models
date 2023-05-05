get_data <- function(file, n_samples, n_ppts){
  ppt_keep <- read_csv(file) %>% 
    count(ppt, topic, genre) %>% 
    summarise(n = n(), .by = ppt) %>% 
    filter(n == 4) %>% 
    pull(ppt)
  
  # Load df
  d <- read_csv(file) %>%
    filter(!is.na(iki), 
           iki > 50, 
           iki < 30000,
           enough_sentences,
           ppt %in% ppt_keep) %>%
    drop_na() %>% 
    mutate(across(ppt, ~as.numeric(factor(.))),
           condition = factor(str_c(location, genre, topic, sep = "_")),
           cond_num = as.integer(condition),
           location = factor(location),
           loc_num = as.integer(location)) %>% 
           select(ppt, iki, condition, cond_num, location, loc_num) 

  # Sample within each category random data points
  set.seed(365)
  d <- d %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples, 
           .by = c(ppt, condition)) %>% 
    filter(keep,
           ppt %in% sample(unique(ppt), n_ppts)) %>% 
    select(-keep) %>% 
    mutate(across(ppt, ~as.numeric(factor(.))))
  return(d)
}
