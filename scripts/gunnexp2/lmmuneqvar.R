# Load packages
library(tidyverse)
library(rstan)
source("scripts/gunnexp2/get_data.R")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores <- 3
n_chain <- 3
iterations <- 20000
n_samples <- 100 # number of random data points
file <- "data/gunnexp2.csv"

# Load df
d <- get_data(file, n_samples)

# Count observations
count(d, ppt, condition)

# Data as list
dat <- within( list(), {
  nS <- length(unique(d$ppt))
  subj <- d$ppt
  K <- length(unique(d$cond_num))
  condition <- as.numeric(d$cond_num)
  K_loc <- max(d$loc_num)
  location <- d$loc_num
  y <- d$iki
  N <- nrow(d)
} );str(dat)

# Initialise start values
start <- function(chain_id = 1){
  list(    beta = rep(0, dat$K)
          , alpha = 5
          , sigma = rep(0.1, dat$K_loc)
          , sigma_u = 0.4)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Load model
lmm <- stan_model(file = "stan/lmmuneqvar.stan")

# Fit model
m <- sampling(lmm, 
              data = dat,
              init = start_ll,
              iter = iterations,
              warmup = iterations/2,
              chains = n_chain, 
              cores = n_cores,
              refresh = 2000,
              save_warmup = FALSE, # Don't save the warmup
              include = FALSE, # Don't include the following parameters in the output
              pars = "mu",
              seed = 81,
              control = list(max_treedepth = 16,
                             adapt_delta = 0.99))

# Save model
saveRDS(m, 
        file = "stanout/gunnexp2/lmmuneqvar.rda",
        compress = "xz")


# Select relevant parameters
(param <- c("alphabeta", "sigma", "sigma_u"))

# Posterior summary
summary(print(m, pars = param, probs = c(.025,.975)))

# Traceplots
traceplot(m, param, inc_warmup = F)

