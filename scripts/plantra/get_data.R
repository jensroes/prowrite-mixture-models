get_data <- function(file, n_samples){
  # Load df
  d <- read_csv(file) %>%
    filter(!is.na(iki), 
           iki > 50, 
           iki < 30000,
           !is_edit) %>%
    mutate(across(ppt, ~as.numeric(factor(.))),
           condition = factor(str_c(location, task, sep = "_")),
           cond_num = as.integer(condition),
           location = factor(location),
           loc_num = as.integer(location)) %>% 
    select(ppt, iki, condition, task, location, cond_num, loc_num) 
  
  # keep only participants that did both the pre and post task.
  keep_ppts <- select(d, ppt, task) %>% unique() %>% 
    count(ppt) %>% filter(n == 2) %>% pull(ppt)
  
  d <- d %>% filter(ppt %in% keep_ppts) %>% 
    mutate(across(ppt, ~as.numeric(factor(.))))
  
  # Filter ppts with too few sentences
  keep_ppts <- count(d, ppt, location) %>% 
    filter(location == "before sentence",
           n >= 10) %>% 
    pull(ppt) 

  d <- d %>% filter(ppt %in% keep_ppts) %>% 
    mutate(across(ppt, ~as.numeric(factor(.))))
  
  # Sample within each category random data points
  set.seed(365)
  d <- d %>% group_by(ppt, condition) %>%
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples) %>% 
    ungroup() %>% 
    filter(keep) %>% 
    select(-keep)
  
  return(d)
}