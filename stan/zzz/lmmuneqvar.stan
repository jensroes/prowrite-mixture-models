/*
  lognormal distribution 
by-subject and by-item intercepts (no random slopes; see Vasishth et al. 2017)
*/
  
data {
  int<lower=1> N;                    // Number of observations
  real<lower=0> y[N];  		            //outcome
  int K;                  // Number of conditions
  int<lower=1, upper=K> condition[N];  //predictor
  int lang[N];
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
  vector<lower=0>[2] sigma_u;
  cholesky_factor_corr[2] L_u; 
  matrix[2,nS] z_u;
  
}

transformed parameters{
  vector[N] mu;
  vector[K] sigma = sigma_mu + sigma_sigma * sigma_raw;
  vector[K] beta;
  matrix[2,nS] u = diag_pre_multiply(sigma_u, L_u) * z_u; //subj random effects
  
  for(n in 1:N){
    beta[condition[n]] = beta_mu + beta_sigma * beta_raw[condition[n]];
    mu[n] = beta[condition[n]] + u[lang[n], subj[n]];
  }

}

model {
  // Priors
  beta_mu ~ normal(5, 2);
  beta_sigma ~ cauchy(0, 1);
  beta_raw ~ normal(0, 1);

  sigma_mu ~ normal(0, 2); 
  sigma_raw ~ normal(0, 1);
  sigma_sigma ~ cauchy(0, 1);

  // REs priors
  L_u ~ lkj_corr_cholesky(2.0);
  to_vector(z_u) ~ normal(0,1);
  sigma_u ~ normal(0,2.5);
  
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


