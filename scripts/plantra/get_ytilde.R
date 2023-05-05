# Extract simulated data and compare to read data
# for all models

# Load packages
library(tidyverse)
library(rstan)

# Get functions
source("scripts/get_ytilde.R")
source("scripts/plantra/get_data.R")

# Load data
n_sample <- 100 # number of random data points
file <- "data/plantra.csv"

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
path <- "stanout/plantra"
files <- list.files(path = path, pattern = ".rda", full.names = T)

# Apply get_ytilde function
sims <- map_dfr(files, get_ytilde, idx = idx)

# Combine model predictions and data
allsims <- left_join(d, sims, by = c("data_idx"), multiple = "all") %>% 
  arrange(sim_idx, data_idx) %>% 
  rename(y_obs = iki, y_tilde = value) 

# Save simulations
write_csv(allsims, "stanout/plantra/all_sims.csv")

