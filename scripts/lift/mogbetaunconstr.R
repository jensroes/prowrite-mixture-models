# Load packages
library(tidyverse)
library(rstan)
source("scripts/lift/get_data.R")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores <- 3
n_chain <- 3
iterations <- 20000
n_samples <- 50 # number of random data points
n_ppts <- 100 # number of random ppts
file <- "data/lift.csv"

# Load data
d <- get_data(file, n_samples, n_ppts)

# Check condition counts
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
  list(     beta = rep(4, dat$K)
          , delta = rep(.1, dat$K)
          , theta_s = matrix(.5, nrow = dat$K, ncol = dat$nS)
          , theta = rep(0, dat$K)
          , tau = .01
          , sigma = 1
          , sigma_diff = rep(.1, dat$K_loc)
          , sigma_u = 0.1)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Load Stan model
mog <- stan_model(file = "stan/mogbetaunconstr.stan")

# Parameters to omit in output
omit <- c("prob_tilde", "mu", "theta_s", 
          "tau", "sigma", "sigma_diff", "sigma_u", 
          "sigmap_e", "sigma_e", "lp_parts",
          "log_theta_s_1", "log_theta_s_2")

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
              seed = 83,
              control = list(max_treedepth = 16,
                             adapt_delta = 0.99))

# Save model
saveRDS(m, 
        file = "stanout/lift/mogbetaunconstr.rda",
        compress = "xz")

# Load model
#m <- readRDS(file = "stanout/lift/mogbetaunconstr.rda")

# Select relevant parameters
param <- c("beta", "delta", "prob") 

# Traceplots
traceplot(m, param, inc_warmup = F)

# Param summary
summary(print(m, pars = param, probs = c(.025,.975)))

# Extract posterior
ps <- as.data.frame(m, c("beta", "delta", "theta", "beta2", "prob")) %>% 
  as_tibble()

# For cond codes
data <- select(d, condition, cond_num) %>% unique()

# Process posterior
ps %>% 
  pivot_longer(everything()) %>% 
  separate(name, into = c("param", "cond_num")) %>% 
  mutate(across(cond_num, as.numeric)) %>% 
  left_join(data, by = "cond_num") %>% 
  select(-cond_num) %>%
  separate(condition, into = c("location", "genre", "topic"), sep = "_") %>% 
  # Save posterior
  write_csv("stanout/lift/mogbetaunconstr.csv")


