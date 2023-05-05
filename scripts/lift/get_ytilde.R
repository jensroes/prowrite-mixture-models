# Extract simulated data and compare to read data
# for all models

# Load packages
library(tidyverse)
library(rstan)

# Get functions
source("scripts/lift/get_data.R")
source("scripts/get_ytilde.R")

# File location and number of random samples
n_samples <- 50 # number of random data points
n_ppts <- 100 # number of random ppts
file <- "data/lift.csv"

# Load data
d <- get_data(file, n_samples, n_ppts) %>% 
  mutate(data_idx = 1:n())

# Number of simulations per model
nsims <- 100

# Max number of iterations
maxiter <- 20000

# Sample random idx for simulations
idx <- sample(maxiter, nsims)

# File names
path <- "stanout/lift"
files <- list.files(path = path, pattern = ".rda", full.names = T)

# Apply get_ytilde function (this will take a few mins)
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, by = c("data_idx")) %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/lift/all_sims.csv")

