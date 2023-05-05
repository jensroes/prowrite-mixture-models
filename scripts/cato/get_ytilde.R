# Extract simulated data and compare to read data
# for all models

# Load packages
library(tidyverse)
library(rstan)

# Get functions
source("scripts/cato/get_data.R")
source("scripts/get_ytilde.R")

# File location and number of random samples
n_samples <- 100 # number of random data points
file <- "data/cato.csv"

# Load df
d <- get_data(file, n_samples) %>% 
  mutate(data_idx = 1:n())

# Number of simulations per model
nsims <- 100

# Max number of iterations
maxiter <- 20000

# Sample random idx for simulations
idx <- sample(maxiter, nsims)

# File names
path <- "stanout/cato"
files <- list.files(path = path, pattern = ".rda", full.names = T)

# Apply get_ytilde function
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, 
                     by = c("data_idx"), 
                     multiple = "all") %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/cato/all_sims.csv")

