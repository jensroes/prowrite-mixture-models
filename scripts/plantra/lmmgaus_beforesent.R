# Load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores <- 3
n_chain <- 3
iterations <- 10000

# Load df
d <- read_csv("data/plantra.csv") %>%
  filter(!is.na(iki), 
         iki > 50, 
         iki < 30000,
         enough_sentences,
         location == "before sentence") %>%
  mutate(condition = factor(str_c(task, sep = "_")),
         cond_num = as.integer(condition)) %>% 
  select(ppt, iki, condition, cond_num) %>% 
  drop_na() %>% 
  mutate(across(ppt, ~as.numeric(factor(.))))

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
m <- lme4::lmer(iki ~ 1 + (1|ppt), data = d);m

# Initialise start values
start <- function(chain_id = 1){
  list(   beta_mu = 1314
          , beta_sigma = 10
          , beta_raw = rep(0, dat$K)
          , sigma_mu = 3000
          , sigma_sigma = 100
          , sigma_raw = rep(0.1, dat$K)
          , sigma_u = 732)}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# Load model
lmm <- stan_model(file = "stan/lmmgaus.stan")

# Parameters to omit in output
omit <- c("mu",  "_mu", "_raw", "_sigma")

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
        file = "stanout/plantra/lmmgaus_beforesent.rda",
        compress = "xz")


# Select relevant parameters
(param <- c("beta", "sigma", "sigma_u"))

# Traceplots
summary(print(m, pars = param, probs = c(.025,.975)))
traceplot(m, param, inc_warmup = F)

