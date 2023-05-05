# Load packages
library(tidyverse)
library(rstan)
source("scripts/plantra/get_data.R")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores <- 3
n_chain <- 3
iterations <- 20000
n_sample <- 100 # number of random data points
file <- "data/plantra.csv"

# Load data
d <- get_data(file)

# Check counts
count(d, ppt, condition)

# Data as list
dat <- within( list(), {
  nS <- length(unique(d$ppt))
  subj <- d$ppt
  K <- length(unique(d$cond_num))
  condition <- as.numeric(d$cond_num)
  K_loc <- length(unique(d$loc_num))
  location <- as.numeric(d$loc_num)
  y <- d$iki
  N <- nrow(d)
} );str(dat)

# Initialise start values
start <- function(chain_id = 1){
  list(   beta = 4
          , delta = rep(.1, dat$K)
          , theta_s = matrix(0, nrow = dat$K, ncol = dat$nS)
          , theta = rep(0, dat$K)
          , tau = .1
          , sigma = 1.25
          , sigma_diff = rep(.1, dat$K_loc)
          , sigma_u = 0.41)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Load model
mog <- stan_model(file = "stan/mogbetaconstr.stan")

# Parameters to omit in output
omit <- c("prob_tilde", "mu", "theta_s")

# Fit model
m <- sampling(mog, 
              data = dat,
              init = start_ll,
              iter = iterations,
              warmup = iterations/2,
              chains = n_chain, 
              cores = n_cores,
              refresh = 2000,
              save_warmup = FALSE, # Don't save the warmup
              include = FALSE, # Don't include the following parameters in the output
              pars = omit,
              seed = 81,
              control = list(max_treedepth = 16,
                             adapt_delta = 0.99))

# Save model
saveRDS(m, 
        file = "stanout/plantra/mogbetacontr.rda",
        compress = "xz")

#m <- readRDS(file = "stanout/plantra/mogbetacontr.rda")

# Select relevant parameters
param <- c("beta", "delta", "prob", "sigma", "sigma_u") 

# Traceplots
traceplot(m, param, inc_warmup = F)

# Param summary
summary(print(m, pars = param, probs = c(.025,.975)))

# Get posterior samples
ps <- as.data.frame(m, c("beta", "beta2", "delta", "prob", "theta")) %>% as_tibble()

# For cond codes
data <- select(d, starts_with("cond")) %>% unique()

# Process posterior
ps_fin <- ps %>%
  pivot_longer(everything()) %>% 
  separate(name, into = c("param", "cond_num")) %>% 
  mutate(across(cond_num, as.numeric)) %>% 
  left_join(data, by = "cond_num") %>% 
  select(-cond_num) %>%
  mutate(across(condition, as.character),
         across(condition, ~replace_na(., "overall"))) %>% 
  separate(condition, into = c("location", "task"), sep = "_") 

# Save posterior
write_csv(ps_fin, "stanout/plantra/mogbetaconstr.csv")

