# Load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores = 3
n_chain = 3
iterations = 10000

# Load df
d <- read_csv("data/spl2.csv") %>%
  select(-transition_dur) %>% 
  rename(transition_dur = transition_dur_to_mod) %>% 
  filter(!is.na(transition_dur), 
         transition_dur > 50, 
         transition_dur < 30000,
         edit == "noedit") %>%
  group_by(SubNo, Lang, transition_type) %>% 
  mutate(location_count = n()) %>% 
  group_by(SubNo) %>% 
  mutate(enough_sentences = min(location_count) > 10) %>% # at least 10 sentences
  ungroup() %>%
  filter(enough_sentences,
         transition_type == "word_before") %>% 
  mutate(SubNo = as.numeric(factor(SubNo)),
         condition = factor(Lang),
         cond_num = as.integer(condition)) %>% 
  select(ppt = SubNo, iki = transition_dur, condition, cond_num) 

# Sample within each category 100 random data points per loc and ppt
set.seed(365)
d <- d %>% group_by(ppt, condition) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= 100) %>% 
  ungroup() %>% 
  filter(keep) %>% 
  select(-keep)

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

# Initialise start values
start <- function(chain_id = 1){
  list(   beta_mu = 5
          , beta_sigma = .1
          , beta_raw = rep(0, dat$K)
          , sigma_mu = 1
          , sigma_sigma = .1
          , sigma_raw = rep(0.1, dat$K)
          , sigma_u = 0.1)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# --------------
# Stan model  ##
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
        file = "stanout/spl2/lmm_beforeword.rda",
        compress = "xz")


# Select relevant parameters
(param <- c("beta", "sigma", "sigma_u"))

# Summarise posterior
summary(print(m, pars = param, probs = c(.025,.975)))

# Traceplots
traceplot(m, param, inc_warmup = F)

