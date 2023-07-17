library(tidyverse)

set.seed(123)
Nsubj <- 100 # number of subjects
K <- 50 # number of observations per subject per condition
# assumed data were transformed to proportions
# Population parameters
beta_mean <- 1000
beta_sd <- 50
beta2_mean <- 1100
sigma <- log(c(2, 3)) # trial-by-trial error
SubjBeta <- log(rnorm(Nsubj, beta_mean, beta_sd))
SubjBeta2 <- log(rnorm(Nsubj, beta2_mean, beta_sd))

# iterate over subject to generate data for each one
data <- map_dfr(1:Nsubj, 
                ~bind_rows(tibble(
                          id = ., condition = 1, 
                          value = rnorm(n = K, 
                                        mean = SubjBeta[.], 
                                        sd = sigma[1])),
                          tibble(
                          id = ., condition = 2, 
                          value = rnorm(n = K, 
                                        mean = SubjBeta2[.], 
                                        sd = sigma[2])))) %>% 
  mutate(across(value, exp))

ggplot(data, aes(x = value, colour = factor(condition))) +
  geom_density() 

write_csv(data, "data/lmmdata.csv")
