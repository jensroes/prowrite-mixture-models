library(tidyverse)
library(rstan)

# Load df
d <- read_csv("data/lift.csv") %>%
  mutate(condition = factor(str_c(location, genre, topic, sep = "_")),
         cond_num = as.character(as.integer(condition))) %>% 
  select(condition, cond_num) %>% 
  unique()

count(d, condition, cond_num)

# Load model
m <- readRDS(file = "stanout/lift/mog.rda")

# Select relevant parameters
param <- c("beta", "delta", "prob") 

# Traceplots
traceplot(m, param, inc_warmup = F)

# Extract posterior
ps <- as.matrix(m, param) %>% as_tibble()

# Combine posterior with conditions
ps %>% 
  pivot_longer(everything()) %>% 
  #count(name) %>% as.data.frame()
  separate(name, into = c("param", "cond_num")) %>% 
  left_join(d) %>% 
  separate(condition, into = c("location", "genre", "topic"), sep = "_") %>% 
  select(-cond_num) %>% 
  # Save posterior
  write_csv("stanout/lift/mog.csv")

