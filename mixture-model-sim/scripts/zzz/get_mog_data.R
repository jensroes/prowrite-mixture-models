library(tidyverse)

# Create fake data
mog <- function (n, theta, mu1, mu2, sig1, sig2) {
  y0 <- rlnorm(n, mean=mu1, sd = sig1)
  y1 <- rlnorm(n, mean=mu2, sd = sig2)
  flag <- rbinom(n, size=1, prob=theta)
  y <- y0*(1 - flag) + y1*flag 
}

set.seed(123)
Nsubj <- 100 # number of subjects
K <- 50 # number of observations per subject per condition
# assumed data were transformed to proportions
# Population parameters

beta_mean <- 1000
beta_sd <- 50
theta <- c(.1, .4) # mixing proportion for condition 1 and 2
delta_mean <- 50
sigma <- log(c(2, 3)) # trial-by-trial error

SubjBeta <- rnorm(Nsubj, beta_mean, beta_sd)
SubjTheta1 <- replicate(Nsubj, mean(rbinom(100, 1, theta[1])))
SubjTheta2 <- replicate(Nsubj, mean(rbinom(100, 1, theta[2])))

# iterate over subject to generate data for each one
data <- map_dfr(1:Nsubj, 
                ~bind_rows(
                  tibble(
                  id = ., condition = 1, 
                  value = mog(n = K, 
                              theta = SubjTheta1[.],
                              mu1 = log(SubjBeta[.]),
                              mu2 = log(SubjBeta[.] + delta_mean),
                              sig1 = sigma[1],
                              sig2 = sigma[2])),
                  tibble(
                  id = ., condition = 2, 
                  value = mog(n = K, 
                              theta = SubjTheta2[.],
                              mu1 = log(SubjBeta[.]),
                              mu2 = log(SubjBeta[.] + delta_mean),
                              sig1 = sigma[1],
                              sig2 = sigma[2]))))

ggplot(data, aes(x = value, colour = factor(condition))) +
  geom_density() 
  
write_csv(data, "data/mogdata.csv")
