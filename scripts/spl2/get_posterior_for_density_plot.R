library(tidyverse)
library(rstan)
source("scripts/functions.R")
source("scripts/spl2/get_data.R")

# Read model
m <- readRDS(file = "stanout/spl2/mogbetaconstr.rda")

# Load df
file <- "data/spl2.csv"
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
  separate(condition, into = c("lang", "loc1", "loc2"), sep = "_") %>%
  unite("loc", loc2:loc1, sep = " ") %>%  
  mutate(across(loc, ~case_when(str_detect(name, "sigma_diff") & cond_num == 2 ~ "within word", 
                                str_detect(name, "sigma_diff") & cond_num == 3 ~ "before word",
                                str_detect(name, "sigma_diff") & cond_num == 1 ~ "before sentence",
                                . == "word within" ~ "within word",
                                TRUE ~ .)),
         across(c(lang,loc), ~replace_na(., "overall")),
         across(loc, ~str_replace(., "NA NA", "overall"))) %>% 
  filter(lang %in% c("EN", "overall")) %>%
  select(param = name, est, loc) %>% 
  # Save posterior
  write_csv("stanout/spl2/mog_constr_posterior_for_densityplot.csv")

