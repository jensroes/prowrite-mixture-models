library(tidyverse)
library(rstan)
source("scripts/functions.R")
source("scripts/c2l1/get_data.R")

# Read model
m <- readRDS(file = "stanout/c2l1/mogbetaconstr.rda")

# Load df
file <- "data/c2l1.csv"
n_samples <- 100 # number of random data points
d <- get_data(file, n_samples)

# Get conditions
cond_codes <- select(d, starts_with('cond'), starts_with("loc")) %>% unique()
glimpse(cond_codes)

# Select relevant parameters
param <- c("beta", "delta", "prob", "sigma", "sigma_diff") 

# Extract posterior
as.data.frame(m, param) %>%
  as_tibble() %>%
  mutate(across(starts_with('delta'), ~beta + .)) %>% 
  pivot_longer(everything()) %>% 
  summarise(across(value, list(est = mean), .names = "{.fn}"), .by = name) %>% 
  mutate(cond_num = parse_number(name),
         across(name, ~str_remove_all(., "\\s*\\[[^\\)]+\\]"))) %>%
  left_join(select(cond_codes, cond_num, condition), by = "cond_num", multiple = "all") %>%
  rename(loc = condition) %>% 
  mutate(across(loc, ~case_when(str_detect(name, "sigma_diff") & cond_num == 3 ~ "within word", 
                                str_detect(name, "sigma_diff") & cond_num == 2 ~ "before word",
                                str_detect(name, "sigma_diff") & cond_num == 1 ~ "before sentence",
                                TRUE ~ .)),
         across(loc, ~replace_na(., "overall"))) %>% 
  select(param = name, est, loc) %>% 
  # Save posterior
  write_csv("stanout/c2l1/mog_constr_posterior_for_densityplot.csv")

