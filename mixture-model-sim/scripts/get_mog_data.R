library(tidyverse)

# Create fake data
mog <- function(n, theta, mu1, mu2, sig1, sig2) {
  y0 <- rlnorm(n, mean = mu1, sd = sig1)
  y1 <- rlnorm(n, mean = mu2, sd = sig2)
  flag <- rbinom(n, size = 1, prob = theta)
  y <- y0 * (1 - flag) + y1 * flag 
}

N <- 1000 # number of subjects
# Population parameters
beta <- 5
theta <- .35 # mixing proportion
delta <- 1
sigma <- c(.25, .5) # trial-by-trial error

# set seed
set.seed(123)

# iterate over subject to generate data for each one
tibble(value = mog(n = N, 
                   theta = theta,
                   mu1 = beta,
                   mu2 = beta + delta,
                   sig1 = sigma[1],
                   sig2 = sigma[2])) %>% 
  write_csv("data/mogdata.csv")
