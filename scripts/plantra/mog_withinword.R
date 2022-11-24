# Load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores <- 3
n_chain <- 3
iterations <- 10000
n_sample <- 50 # number of random data points

# Load df
d <- read_csv("data/plantra.csv") %>%
  filter(!is.na(iki), 
         iki > 50, 
         iki < 30000,
         enough_sentences,
         location == "within word") %>%
  mutate(across(ppt, ~as.numeric(factor(.))),
         condition = factor(str_c(task, sep = "_")),
         cond_num = as.integer(condition)) %>% 
  select(ppt, iki, condition, cond_num) 

# Sample within each category random data points
set.seed(365)
d <- d %>% group_by(ppt, condition) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= n_sample) %>% 
  ungroup() %>% 
  filter(keep) %>% 
  select(-keep)

# Data as list
dat <- within( list(), {
  nS <- length(unique(d$ppt))
  subj <- d$ppt
  K <- length(unique(d$cond_num))
  condition <- as.numeric(d$cond_num)
  y <- d$iki
  N <- nrow(d)
} );str(dat)

# Initialise start values
m <- lme4::lmer(log(iki) ~ 1 + (1|ppt), data = d);m

start <- function(chain_id = 1){
  list(   beta_mu = 5
          , beta_sigma = 1
          , beta_raw = rep(0, dat$K)
          , delta = rep(.1, dat$K)
          , theta_s = matrix(0, nrow = dat$K, ncol = dat$nS)
          , theta_raw = rep(0, dat$K)
          , theta_mu = 0
          , theta_sigma = .5
          , tau = .1
          , sigma = .5
          , sigma_diff = rep(.1, dat$K)
          , sigma_u = 0.15)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Stan models 

# Load model
mog <- stan_model(file = "stan/mog.stan")

# Parameters to omit in output
omit <- c("theta", "prob_tilde", "mu",  "_mu", "_raw", "_sigma", "z_u", "theta_s", "L_u")

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
                             adapt_delta = 0.99)
)

# Save model
saveRDS(m, 
        file = "stanout/plantra/mog_withinword.rda",
        compress = "xz")


#m <- readRDS(file = "stanout/plantra/mog_withinword.rda")

# Select relevant parameters
param <- c("beta", "delta", "prob", "sigma", "sigma_u") 

# Traceplots
summary(print(m, pars = param, probs = c(.025,.975)))
traceplot(m, param, inc_warmup = F)
