get_data <- function(file, n_samples){
  d <- read_csv(file) %>%
    filter(!is.na(iki),
           !is.na(isfluent),
           isfluent == 1,
           iki > 50, 
           iki < 30000) %>%
    mutate(ppt = as.numeric(factor(ppt)),
           cond_num = as.integer(factor(condition)),  
           location = factor(location),
           loc_num = as.integer(location)) %>% 
    select(ppt, iki, condition, xn, location, cond_num, loc_num) 
  
  # Sample within each category random data points
  set.seed(365)
  d <- d %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, condition)) %>% 
    filter(keep) %>% 
    select(-keep)
}