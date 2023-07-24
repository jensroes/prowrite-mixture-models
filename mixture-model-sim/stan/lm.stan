/*
Linear model with log normal distribution
*/
  
data {
  int<lower=1> N;     // Number of observations
  real<lower=0> y[N]; // outcome
}

parameters {
  real beta;
  real<lower=0> sigma;
}

model {
  // Priors
  beta ~ normal(5, 2);
  sigma ~ student_t(7, 0, 1);

  // Likelihood
  y ~ lognormal(beta, sigma);
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_tilde;

  for(n in 1:N) {
    log_lik[n] = lognormal_lpdf(y[n] | beta, sigma);
    y_tilde[n] = lognormal_rng(beta, sigma);
  }
}
