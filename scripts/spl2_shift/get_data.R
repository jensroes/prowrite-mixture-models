get_data <- function(file, nsamples){
  d <- read_csv(file) %>%
    filter(!is.na(transition_dur), 
           transition_dur > 50, 
           transition_dur < 30000,
           edit == "noedit") %>%
    mutate(location_count = n(), 
           .by = c(SubNo, Lang, transition_type)) %>% 
    mutate(enough_sentences = min(location_count) > 10, 
           .by = SubNo) %>% # at least 10 sentences
    filter(enough_sentences) %>% 
    mutate(SubNo = as.numeric(factor(SubNo)),
           condition = factor(str_c(Lang, transition_type, sep =  "_")),
           cond_num = as.integer(condition),
           location = factor(transition_type),
           loc_num = as.integer(location)) %>% 
    select(ppt = SubNo, iki = transition_dur, condition, cond_num, location, loc_num) 
  
  # Sample within each category 100 random data points per loc and ppt
  set.seed(365)
  d <- d %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= nsamples,
           .by = c(ppt, condition)) %>% 
    filter(keep) %>% 
    select(-keep)
  
  return(d)
}