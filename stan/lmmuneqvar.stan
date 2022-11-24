/*
  lognormal distribution 
by-subject and by-item intercepts (no random slopes; see Vasishth et al. 2017)
*/
  
data {
  int<lower=1> N;                    // Number of observations
  real<lower=0> y[N];  		            //outcome
  int K;                  // Number of conditions
  int<lower=1, upper=K> condition[N];  //predictor
  int<lower=1> nS;                  //number of subjects
  int<lower=1, upper=nS> subj[N];   //subject id

}

parameters {
  
  real beta_mu;
  real beta_raw[K];
  real<lower=0> beta_sigma;
  
  real<lower=0> sigma_mu;
  vector[K] sigma_raw;
  real<lower=0> sigma_sigma;
  
   // For random effects
	vector[nS] u; //subj intercepts
  real<lower=0> sigma_u;//subj sd
  
}

transformed parameters{
  vector[N] mu;
  vector[K] sigma = sigma_mu + sigma_sigma * sigma_raw;
  vector[K] beta;

  for(n in 1:N){
    beta[condition[n]] = beta_mu + beta_sigma * beta_raw[condition[n]];
    mu[n] = beta[condition[n]] + u[subj[n]];
  }

}

model {
  // Priors
  beta_mu ~ normal(6, 2);
  beta_sigma ~ cauchy(0, 2.5);
  beta_raw ~ normal(0, 1);

  sigma_mu ~ normal(0, 2.5); 
  sigma_raw ~ normal(0, 1);
  sigma_sigma ~ cauchy(0, 2.5);

	// REs priors
  sigma_u ~ normal(0,2.5);
  u ~ normal(0, sigma_u); //subj random effects
  
  // Likelihood
  for(n in 1:N){
      y[n] ~ lognormal(mu[n], sigma[condition[n]]);
  }
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_tilde;

  for (n in 1:N) {
    log_lik[n] = lognormal_lpdf(y[n] | mu[n], sigma[condition[n]]);
    y_tilde[n] = lognormal_rng(mu[n], sigma[condition[n]]);
  }
}


