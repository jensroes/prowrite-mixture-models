# Load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
n_chain = n_core = 3 # number of cores/chains
iterations = 6e3

# Get some fake data (see script for parameter values)
data <- read_csv("data/mogdata.csv")

# Data as list
dat <- within(list(), {
    N <- nrow(data)
    y <- data$value
  }); str(dat)

# Initialise start values
start <-  function(chain_id = 1){
    list(   beta = 5
          , delta = 1
          , theta = 0
          , sigma = .5
          , sigma_diff = .2 ) }

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Check compiling
mog <- stan(file = "stan/mog.stan", data=dat, chains=0)

# Fit model
m <- stan(fit = mog, 
          data = dat, 
          init = start_ll,
          iter = iterations, 
          warmup= iterations/2,
          chains = n_chain, 
          cores = n_core, 
          refresh = 2000, 
          seed = 365,
          control = list(max_treedepth = 16,
                        adapt_delta = 0.99))

# Save posterior samples
saveRDS(m,
        file="stanout/mog_mogdata.rda",
        compress="xz")

# Select relevant parameters
param <- c("beta", "delta", "prob", "sigma_e", "sigmap_e") 

# Traceplot and summary
traceplot(m, param)
summary(m, param, prob = c(.025, .975))$summary %>% round(2)

# Get posterior
#m <- readRDS("stanout/mog_mogdata.rda")

# Extract posterior
as.data.frame(m, param) %>% 
  pivot_longer(everything()) %>% 
  # Save posterior
  write_csv("stanout/mog_mogdata.csv")
