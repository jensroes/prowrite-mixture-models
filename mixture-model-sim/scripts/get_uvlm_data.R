library(tidyverse)

set.seed(123)
N <- 1000 # number of subjects
beta <- c(5, 6) # Population parameter
sigma <- c(.25, .5) # trial-by-trial error

# iterate over subject to generate data for each one
data <- map_dfr(1:2, 
                ~tibble(condition = ., 
                        value = rlnorm(n = N, mean = beta[.], sd = sigma[.]))) 

ggplot(data, aes(x = value, colour = factor(condition))) +
  geom_density() 

write_csv(data, "data/uvlmdata.csv")
