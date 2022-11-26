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
  model_name <- str_remove_all(files, "stanout\\/|lift\\/|\\.rda")
  
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
n_samples <- 50 # number of random data points
n_ppts <- 100 # number of random ppts

ppt_keep <- read_csv("data/lift.csv") %>% 
  count(ppt, topic, genre) %>% 
  group_by(ppt) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  filter(n == 4) %>% 
  pull(ppt)

# Load df
d <- read_csv("data/lift.csv") %>%
  filter(!is.na(iki), 
         iki > 50, 
         iki < 30000,
         enough_sentences,
         ppt %in% ppt_keep) %>%
  drop_na() %>% 
  mutate(across(ppt, ~as.numeric(factor(.))),
         condition = factor(str_c(location, genre, topic, sep = "_"))) %>% 
  select(ppt, iki, condition) 

# Sample within each category random data points
set.seed(365)
d <- d %>% group_by(ppt, condition) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= n_samples) %>% 
  ungroup() %>% 
  filter(keep,
         ppt %in% sample(unique(ppt), n_ppts)) %>% select(-keep) %>% 
  mutate(across(ppt, ~as.numeric(factor(.))),
         data_idx = 1:n())

# Number of simulations per model
nsims <- 100

# Max number of iterations
maxiter <- 15000

# Sample random idx for simulations
idx <- sample(maxiter, nsims)

# File names
(files <- str_c("stanout/lift/", 
                c("mog", "lmm", "lmmgaus", "lmmuneqvar"), 
                ".rda"))

# Apply get_ytilde function (this will take a few mins)
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, by = c("data_idx")) %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/lift/all_sims.csv")

