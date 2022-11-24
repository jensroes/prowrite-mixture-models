# Load packages
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Sampling parameters
n_cores = 3
n_chain = 3
iterations = 20000

# Load df
d <- read_csv("data/spl2_somedata.csv") %>%
  select(transition_dur, transition_type, edit, Lang, SubNo)

d %>% 
  mutate(transition_dur = log(transition_dur)) %>%
  group_by(transition_type, edit) %>%
  summarise(min = min(transition_dur),
            max = max(transition_dur),
            lo = quantile(transition_dur, 0.025),
            up = quantile(transition_dur, 0.975)) %>%
  ungroup() %>%
  mutate(across(where(is.numeric), exp))

d %>%
  filter(transition_dur > 50, transition_dur < 30000) %>%
  ggplot(aes(x = transition_dur)) +
  geom_histogram() +
  scale_x_log10() +
  facet_wrap(~transition_type + edit, scales = "free")

d <- d %>% 
  filter(!is.na(transition_dur), transition_dur > 50, transition_dur < 30000) %>%
  mutate(SubNo = as.numeric(factor(SubNo))) 

count(d, SubNo, transition_type, edit, Lang)

# Sample within each category 200 random data points
set.seed(365)
d <- d %>% group_by(SubNo, transition_type, Lang, edit) %>%
  mutate(keep = 1:n(),
         keep = sample(keep),
         keep = keep <= 200) # keep 200 samples per ppt

d <- d %>% filter(keep)

count(d, SubNo, transition_type, edit, Lang)

d <- mutate(d, condition = factor(paste(Lang, transition_type, edit, sep = "_")),
            cond_num = as.integer(condition))

#ungroup(d) %>% select(condition, cond_num) %>% unique() %>% arrange(cond_num)
#count(d, condition)

# Data as list
dat <- within( list(), {
  nS <- length(unique(d$SubNo))
  subj <- d$SubNo
  K <- length(unique(d$cond_num))
  condition <- as.numeric(d$cond_num)
  lang <- as.numeric(factor(d$Lang))
  y <- d$transition_dur
  N <- nrow(d)
} );str(dat)


# Initialise start values
start <- function(chain_id = 1){
  list(   beta_mu = 5
          , beta_sigma = .1
          , beta_raw = rep(0, dat$K)
          , delta = rep(.1, dat$K)
          , theta_s = matrix(0, nrow = dat$K, ncol = dat$nS)
          , theta_raw = rep(0, dat$K)
          , theta_mu = 0
          , theta_sigma = .1
          , tau = .01
          , sigma = 1
          , sigma_diff = rep(.1, dat$K)
          , z_u = matrix(0, nrow = 2, ncol = dat$nS)
          , L_u = matrix(0, nrow = 2, ncol = 2)
          , sigma_u = rep(0.1, 2))}

start_ll <- lapply(1:n_chain, function(id) start(chain_id = id) )

# --------------
# Stan models ##
# --------------
#---- 
# Load model
mog <- stan_model(file = "stan/mogrslopes.stan")

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
              control = list(max_treedepth = 14,
                             adapt_delta = 0.96)
)

# Save model
saveRDS(m, 
        file = "stanout/mogrslopes_transdur.rda",
        compress = "xz")


m <- readRDS(file = "stanout/mogrslopes_transdur.rda")

# Select relevant parameters
#param <- c("beta", "delta", "theta", "sigma", "sigma_u", "sigma_w") 
(param <- names(m)[!grepl("log_|y_|n|lp_|_s|w|L_|z_|u|prob_vec|sigma", names(m))])

# Traceplots
summary(print(m, pars = param, probs = c(.025,.975)))
traceplot(m, param, inc_warmup = F)

# Extract posterior
ps <- rstan::extract(m, param) %>% as_tibble()

# Save posterior
write_csv(ps, "stanout/mogrslopes_transdur_all_posterior.csv")

