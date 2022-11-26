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
  model_name <- str_remove_all(files, "stanout\\/|spl2\\/|\\.rda")
  
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
d <- read_csv("data/spl2.csv") %>%
  filter(!is.na(transition_dur), 
         transition_dur > 50, 
         transition_dur < 30000,
         edit == "noedit") %>%
  group_by(SubNo, Lang, transition_type) %>% 
  mutate(location_count = n()) %>% 
  group_by(SubNo) %>% 
  mutate(enough_sentences = min(location_count) > 10) %>% # at least 10 sentences
  ungroup() %>%
  filter(enough_sentences) %>% 
  mutate(SubNo = as.numeric(factor(SubNo)),
         condition = factor(str_c(Lang, transition_type, sep =  "_"))) %>% 
  select(ppt = SubNo, iki = transition_dur, condition) 

# Sample within each category 100 random data points per loc and ppt
set.seed(365)
d <- d %>% 
  group_by(ppt, condition) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= 100) %>% 
  ungroup() %>% 
  filter(keep) %>% 
  select(-keep) %>% 
  rownames_to_column("data_idx") %>% 
  mutate(across(data_idx, as.numeric))

# Number of simulations per model
nsims <- 100

# Max number of iterations
maxiter <- 15000

# Sample random idx for simulations
idx <- sample(maxiter, nsims)

# File names
(files <- str_c("stanout/spl2/", 
                c("mog", "lmm", "lmmgaus", "lmmuneqvar"), 
                ".rda"))

# Apply get_ytilde function
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, by = c("data_idx")) %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/spl2/all_sims.csv")

