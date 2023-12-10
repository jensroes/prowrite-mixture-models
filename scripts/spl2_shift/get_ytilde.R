# Extract simulated data and compare to read data
# for all four models

# Load packages
library(tidyverse)
library(rstan)

# Get functions
source("scripts/get_ytilde.R")
source("scripts/spl2 (shift + C)/get_data.R")

# Load data
n_sample <- 100 # number of random data points
file <- "data/spl2.csv"

# Load data
d <- get_data(file, n_sample) %>% 
  mutate(data_idx = 1:n())

# Number of simulations per model
nsims <- 100

# Max number of iterations
maxiter <- 20000

# Sample random idx for simulations
idx <- sample(maxiter, nsims)

# File names
(files <- list.files('stanout/spl2_shift', 
                     pattern = ".rda$", 
                     full.names = T))

# Apply get_ytilde function
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, by = c("data_idx")) %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/spl2_shift/all_sims.csv")

