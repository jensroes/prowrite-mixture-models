library(tidyverse)

# parameters
N <- 1000 # number of subjects
beta <- 5 # Population parameter
sigma <- .25 # trial-by-trial error

# set seed
set.seed(123)

# iterate over subject to generate data for each one
tibble(value = rlnorm(n = N, mean = beta, sd = sigma)) %>% 
  write_csv("data/lmdata.csv")
