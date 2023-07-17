/*
Unequal variance model
*/
  
data {
  int<lower=1> N;                    // Number of observations
  real<lower=0> y[N];  		            //outcome
  int K;                  // Number of conditions
  int<lower=1, upper=K> condition[N];  //predictor
}

parameters {
  vector[K] beta;
  vector<lower=0>[K] sigma;
}

model {
  // Priors
  beta ~ normal(5, 2);
  sigma ~ student_t(7, 0, 1);

  // Likelihood
  for(n in 1:N){
    y[n] ~ lognormal(beta[condition[n]], sigma[condition[n]]);
  }
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_tilde;

  for(n in 1:N) {
    log_lik[n] = lognormal_lpdf(y[n] | beta[condition[n]], sigma[condition[n]]);
    y_tilde[n] = lognormal_rng(beta[condition[n]], sigma[condition[n]]);
  }
}
