# Function to get data reduction infos
get_lift <- function(file, n_samples, n_ppts){
  #  file <- "../data/lift.csv"
  # n_samples = 50
  #  n_ppts = 100
  result <- list()
  
  d <- read_csv(file) 
  
  result[[4]] <- d %>% 
    select(ppt, enough_sentences) %>% 
    unique() %>%
    filter(!enough_sentences) %>%
    drop_na() %>% 
    summarise(less_than_10_sentences = length(ppt)) 
  
  ppt_remove <- d %>% 
    select(ppt, enough_sentences) %>% 
    unique() %>%
    filter(!enough_sentences) %>% 
    drop_na() %>% 
    pull(ppt)
  
  full_set <- d %>% 
    filter(!ppt %in% ppt_remove) %>% 
    count(ppt, topic, genre) %>% 
    summarise(n = n(), .by = ppt) %>% 
    mutate(has_full_set = n == 4) 
  
  result[[3]] <- full_set %>% count(has_full_set)
  
  ppt_keep <- full_set %>% 
    filter(has_full_set) %>% 
    pull(ppt)
  
  result[[1]] <- d %>%
    filter(!is.na(iki), 
           !is_edit,
           ppt %in% ppt_keep,
           !ppt %in% ppt_remove,
           enough_sentences) %>%
    select(ppt, iki, location) %>% 
    drop_na() %>% 
    mutate(too_fast = iki <= 50, 
           too_slow = iki >= 30000,
           across(ppt, ~as.numeric(factor(.)))) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt)) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean), 
                     .names = "{.col}"))
  
  # Sample within each category random data points
  set.seed(365)
  result[[2]] <- d %>% 
    filter(!is.na(iki), 
           !is_edit,
           ppt %in% ppt_keep,
           !ppt %in% ppt_remove,
           enough_sentences,
           iki > 50,
           iki < 30000) %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, location, genre, topic)) %>% 
    summarise(across(keep, 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt, location)) %>% 
    summarise(across(starts_with("keep"), 
                     list(mean = mean), 
                     .names = "{.col}"), 
              .by = location) 
  
  return(result)
}
get_c2l1 <- function(file, n_samples){
  #file <- "../data/c2l1.csv"
  #n_samples <- 100
  d <- read_csv(file) %>% 
    filter(!is.na(iki)) %>% 
    mutate(ppt = as.numeric(factor(subno))) %>% 
    select(ppt, iki, location)  
  
  result <- list()
  
  result[[1]] <- d %>% 
    mutate(too_fast = iki <= 50,
           too_slow = iki >= 30000) %>%
    summarise(across(starts_with("too"), 
                     list(mean = mean, se = se_bin)),
              .by = c(ppt)) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean), 
                     .names = "{.col}"))
  
  set.seed(365)
  result[[2]] <- d %>% 
    filter(iki > 50,
           iki < 30000) %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, location)) %>% 
    summarise(across(keep, 
                     list(mean = mean, se = se_bin)),
              .by = c(ppt, location)) %>% 
    summarise(across(starts_with("keep"), 
                     list(mean = mean), 
                     .names = "{.col}"), 
              .by = location)
  
  return(result)
}
get_cato <- function(file, n_samples){
  d <- read_csv(file) %>% 
    filter(!is.na(iki)) %>% 
    mutate(ppt = as.numeric(factor(subno))) %>% 
    select(ppt, iki, location, xn, dystyp)  
  
  result <- list()
  
  result[[1]] <- d %>% 
    mutate(too_fast = iki <= 50,
           too_slow = iki >= 30000) %>%
    summarise(across(starts_with("too"), 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt)) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean), 
                     .names = "{.col}"))
  
  set.seed(365)
  result[[2]] <- d %>% 
    filter(iki > 50,
           iki < 30000) %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, location, xn, dystyp)) %>% 
    summarise(across(keep, 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt, location)) %>% 
    summarise(across(starts_with("keep"), 
                     list(mean = mean), 
                     .names = "{.col}"), 
              .by = location)
  
  return(result)
}
get_plantra <- function(file, n_samples){
  d <- read_csv(file) %>% 
    filter(!is.na(iki), !is_edit) %>% 
    mutate(ppt = as.numeric(factor(ppt))) %>% 
    select(ppt, iki, location, task)  
  
  result <- list()
  
  result[[1]] <- d %>% 
    mutate(too_fast = iki <= 50,
           too_slow = iki >= 30000) %>%
    summarise(across(starts_with("too"), 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt, task)) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean), 
                     .names = "{.col}"))
  
  # keep only participants that did both the pre and post task.
  keep_ppts <- select(d, ppt, task) %>% 
    unique() %>% 
    count(ppt) %>% 
    mutate(both_tasks = n == 2) 
  
  result[[3]] <- count(keep_ppts, both_tasks)
  
  keep_ppts <- keep_ppts %>% filter(both_tasks) %>% pull(ppt)
  d <- filter(d, ppt %in% keep_ppts)
  
  # Filter ppts with too few sentences
  keep_ppts <- count(d, ppt, location) %>% 
    filter(location == "before sentence") %>% 
    mutate(enough_sentences = n >= 10)
  
  result[[4]] <- count(keep_ppts, enough_sentences) %>% 
    rename(more_than_10_sentences = enough_sentences)
  
  keep_ppts <- keep_ppts %>% 
    filter(enough_sentences) %>% 
    pull(ppt)
  
  d <- filter(d, ppt %in% keep_ppts)
  
  set.seed(365)
  result[[2]] <- d %>% 
    filter(iki > 50,
           iki < 30000) %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, location, task)) %>% 
    summarise(across(keep, 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt, location)) %>% 
    summarise(across(starts_with("keep"), 
                     list(mean = mean), 
                     .names = "{.col}"), 
              .by = location)
  return(result)
}
get_spl2 <- function(file, n_samples){
  result <- list()
  #  file <- "../data/spl2.csv"
  d <- read_csv(file) %>% 
    select(-transition_dur) %>% 
    rename(iki = transition_dur_to_mod,
           location = transition_type) %>% 
    filter(!is.na(iki), 
           edit == "noedit") %>% 
    select(ppt = SubNo, iki, location, Lang) %>% 
    drop_na() 
  
  result[[1]] <- d %>% 
    mutate(too_fast = iki <= 50,
           too_slow = iki >= 30000,
           across(ppt, ~as.numeric(factor(.)))) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt)) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean), 
                     .names = "{.col}"))
  
  d <- d %>% filter(iki > 50, iki < 30000)
  
  # Filter ppts with too few sentences
  keep_ppts <- count(d, ppt, location) %>% 
    filter(location == "sentence_before") %>% 
    mutate(enough_sentences = n >= 10)
  
  result[[3]] <- count(keep_ppts, enough_sentences) %>% 
    rename(more_than_10_sentences = enough_sentences)
  
  keep_ppts <- keep_ppts %>% 
    filter(enough_sentences) %>% 
    pull(ppt)
  
  d <- filter(d, ppt %in% keep_ppts)
  
  set.seed(365)
  result[[2]] <- d %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, location, Lang)) %>% 
    summarise(across(keep, 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt, location)) %>% 
    summarise(across(starts_with("keep"), 
                     list(mean = mean), 
                     .names = "{.col}"), 
              .by = location) %>% 
    mutate(across(location, ~str_replace(., "_", " ")),
           across(location, ~recode(., `sentence before` = "before sentence",
                                    `word before` = "before word")))
  
  return(result)
}
get_gunnexp2 <- function(file, n_samples){
  d <- read_csv(file) %>%
    filter(!is.na(iki),
           !is.na(isfluent),
           isfluent == 1) %>%
    mutate(ppt = as.numeric(factor(ppt))) %>% 
    select(ppt, iki, xn, location) 
  
  result <- list()
  
  result[[1]] <- d %>% 
    mutate(too_fast = iki <= 50,
           too_slow = iki >= 30000) %>%
    summarise(across(starts_with("too"), 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt)) %>% 
    summarise(across(starts_with("too"), 
                     list(mean = mean), 
                     .names = "{.col}"))
  # Sample within each category random data points
  set.seed(365)
  result[[2]] <- d %>% 
    filter(iki > 50,
           iki < 30000) %>% 
    mutate(keep = 1:n(),
           keep = sample(keep),
           keep = keep <= n_samples,
           .by = c(ppt, location, xn)) %>% 
    summarise(across(keep, 
                     list(mean = mean, 
                          se = se_bin)),
              .by = c(ppt, location)) %>% 
    summarise(across(starts_with("keep"), 
                     list(mean = mean), 
                     .names = "{.col}"), 
              .by = location)
  return(result)
}