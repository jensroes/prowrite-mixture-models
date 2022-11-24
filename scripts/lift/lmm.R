# Load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores <- 3
n_chain <- 3
iterations <- 10000
n_samples <- 50 # number of random data points
n_ppts <- 100 # number of random ppts

ppt_keep <- read_csv("data/lift.csv") %>% 
  count(ppt, topic, genre) %>% 
  group_by(ppt) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  filter(n == 4) %>% 
  pull(ppt)

# Load df
d <- read_csv("data/lift.csv") %>%
  filter(!is.na(iki), 
         iki > 50, 
         iki < 30000,
         enough_sentences,
         ppt %in% ppt_keep) %>%
  drop_na() %>% 
  mutate(across(ppt, ~as.numeric(factor(.))),
         condition = factor(str_c(location, genre, topic, sep = "_")),
         cond_num = as.integer(condition)) %>% 
  select(ppt, iki, condition, cond_num) 

# Sample within each category random data points
set.seed(365)
d <- d %>% group_by(ppt, condition) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= n_samples) %>% 
  ungroup() %>% 
  filter(keep,
         ppt %in% sample(unique(ppt), n_ppts)) %>% select(-keep) %>% 
  mutate(across(ppt, ~as.numeric(factor(.))))

count(d, ppt, condition)

# Data as list
dat <- within( list(), {
  nS <- length(unique(d$ppt))
  subj <- d$ppt
  K <- length(unique(d$cond_num))
  condition <- as.numeric(d$cond_num)
  y <- d$iki
  N <- nrow(d)
} );str(dat)

# Check lmer for starting values
m <- lme4::lmer(log(iki) ~ 1 + (1|ppt), data = d);m

# Initialise start values
start <- function(chain_id = 1){
  list(   beta_mu = 5.4
          , beta_sigma = .1
          , beta_raw = rep(0, dat$K)
          , sigma_mu = .8
          , sigma_sigma = .1
          , sigma_raw = rep(0.1, dat$K)
          , sigma_u = 0.2)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# --------------
# Stan model ##
# --------------

# Load model
lmm <- stan_model(file = "stan/lmm.stan")

# Parameters to omit in output
omit <- c("mu",  "_mu", "_raw", "_sigma", "z_u", "L_u")

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
              pars = omit,
              seed = 81,
              control = list(max_treedepth = 14,
                             adapt_delta = 0.96)
)

# Save model
saveRDS(m, 
        file = "stanout/lift/lmm.rda",
        compress = "xz")

# Select relevant parameters
(param <- c("beta", "sigma", "sigma_u"))

# Param summary
summary(print(m, pars = param, probs = c(.025,.975)))

# Traceplots
traceplot(m, param, inc_warmup = F)
