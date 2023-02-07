# Extract simulated data and compare to read data
# for all four models

# Load packages
library(tidyverse)
library(rstan)

# Extract model simulations
get_ytilde <- function(files, idx) {
  # Load model
  m <- readRDS(files)
  
  # Get model name
  model_name <- str_remove_all(files, "stanout\\/|c2l1\\/|\\.rda")
  
  # Extract simulations
  y_tilde <- as.matrix(m, pars = "y_tilde")
    
  # Extract 100 simulations
  y_tilde_sims <- y_tilde[idx,]

  # Make data frame
  sims <- y_tilde_sims %>% 
    as_tibble() %>% 
    rownames_to_column("sim_idx") %>% 
    pivot_longer(-sim_idx) %>% 
    mutate(data_idx = parse_number(name)) %>% 
    arrange(data_idx) %>% 
    mutate(model = model_name) %>% 
    select(-name)
  
  return(sims)
}

# Load data
n_sample <- 50 # number of random data points

# Load df
d <- read_csv("data/c2l1.csv") %>%
  filter(!is.na(iki), 
         iki > 50, 
         iki < 30000) %>%
  mutate(ppt = as.numeric(factor(subno)),
         condition = factor(str_c(location, sep = "_")),
         cond_num = as.integer(condition)) %>% 
  select(ppt, iki, condition, cond_num) 

# Sample within each category random data points
set.seed(365)
d <- d %>% group_by(ppt, condition) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= n_sample) %>% 
  ungroup() %>% 
  filter(keep) %>% 
  select(-keep) %>% 
  mutate(data_idx = 1:n())

count(d, ppt, condition)

# Number of simulations per model
nsims <- 100

# Max number of iterations
maxiter <- 15000

# Sample random idx for simulations
idx <- sample(maxiter, nsims)

# File names
(files <- str_c("stanout/c2l1/", 
                c("mog", "lmm", "lmmgaus", "lmmuneqvar"), 
                ".rda"))

# Apply get_ytilde function
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, by = c("data_idx")) %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/c2l1/all_sims.csv")
