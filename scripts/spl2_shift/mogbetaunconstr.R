# Load packages
library(tidyverse)
library(rstan)
source("scripts/spl2 (shift + C)/get_data.R")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores = 3
n_chain = 3
iterations = 20000
nsamples = 100
file = "data/spl2.csv"

# Load df
d <- get_data(file, nsamples)

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
  list(   beta = 5
          , delta = rep(.1, dat$K)
          , theta_s = matrix(0, nrow = dat$K, ncol = dat$nS)
          , theta = rep(0, dat$K)
          , tau = .1
          , sigma = 1
          , sigma_diff = rep(.1, dat$K_loc)
          , sigma_u = 0.1)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Load model
mog <- stan_model(file = "stan/mogbetaunconstr.stan")

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
              refresh = 5000,
              save_warmup = FALSE, # Don't save the warmup
              include = FALSE, # Don't include the following parameters in the output
              pars = omit,
              seed = 81,
              control = list(max_treedepth = 16,
                             adapt_delta = 0.99))

# Save model
saveRDS(m, 
        file = "stanout/spl2 (shift + C)/mogbetaunconstr.rda",
        compress = "xz")

# Load model
#m <- readRDS(file = "stanout/spl2/mog.rda")

# Select relevant parameters
param <- c("beta", "delta", "prob", "sigma", "sigma_u") 

# Traceplots
traceplot(m, param, inc_warmup = F)

# Param summary
summary(print(m, pars = param, probs = c(.025,.975)))

# Extract posterior
ps <- as.matrix(m, c("beta", "delta", "beta2", "prob", "theta")) %>% as_tibble()

# For cond codes
data <- select(d, condition, cond_num) %>% unique()

# Process posterior
ps_fin <- ps %>% 
  pivot_longer(everything()) %>% 
  separate(name, into = c("param", "cond_num")) %>% 
  mutate(across(cond_num, as.numeric)) %>% 
  left_join(data, by = "cond_num") %>% 
  select(-cond_num) %>%
  separate(condition, into = c("lang", "pos1", "pos2"), sep = "_") %>%
  unite(c(pos1,pos2), col = "location", sep = "_") %>% 
  mutate(across(location, recode, 
                sentence_before = "before sentence", 
                word_before = "before word",
                within_word = "within word"))

# Save posterior
write_csv(ps_fin, "stanout/spl2 (shift + C)/mogbetaunconstr.csv")

