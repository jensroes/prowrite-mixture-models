# Load libraries
library(tidyverse)
se_bin <- function(x, na.rm = T) sqrt((mean(x, na.rm = na.rm)*(1 - mean(x, na.rm = na.rm)))/length(x)) # se for binary data
se <- function(x, na.rm = T) sd(x, na.rm = na.rm) / sqrt(length(x))
  
# LIFT
n_samples <- 50 # number of random data points
n_ppts <- 100 # number of random ppts
file <- "data/lift.csv"

# Load data
get_data <- function(){
  # only ppts that did all 4 tasks
  ppt_keep <- read_csv(file, n_samples, n_ppts) %>% 
    count(ppt, topic, genre) %>% 
    summarise(n = n(), .by = ppt) %>% 
    filter(n == 4) %>% 
    pull(ppt)
  
  # Load df
  read_csv(file) %>%
  filter(!is.na(iki)) %>% 
  mutate(too_short = iki <= 50, 
         too_long = iki >= 30000,
         all_tasks = ppt %in% ppt_keep) %>% 
    
  
    
    select(ppt, iki, condition, cond_num, location, loc_num) 
  
    !is_edit,
    enough_sentences,
    
    
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
  
}

d <- get_data(file, n_samples, n_ppts)


# PlanTra


# CATO


# C2L1


# SPL2
