/*
  LMM with random intercepts 
  with random slopes
*/

data {
	int<lower=1> N;          // Number of observations
  int<lower=1> nS;        //number of subjects
  int<lower=1, upper=nS> subj[N];
  int K;                  // Number of conditions
  int condition[N];
  vector[N] y;            //outcome: for each subject one IKI per column/bigram (in 
}

parameters {
	real<lower=0> sigma;		// residual sd

	// Parameters for non-centering
	real beta_mu;
	vector[K] beta_raw;			// distributions
  real<lower =0> beta_sigma;	

   // For random effects
  vector<lower=0>[K] sigma_u;
  cholesky_factor_corr[K] L_u; 
  matrix[K,nS] z_u;
}

transformed parameters{
  vector[K] beta = beta_mu + beta_sigma * beta_raw;
  vector[N] mu;
  matrix[K,nS] u;
  
  u = diag_pre_multiply(sigma_u, L_u) * z_u; //subj random effects
  
  for(n in 1:N){
    mu[n] = beta[condition[n]] + u[condition[n],subj[n]];
  }
}

model {
  // Priors
  beta_mu ~ normal(5, 2);
  beta_sigma ~ cauchy(0, 1);
  beta_raw ~ normal(0, 1);
  sigma ~ cauchy(0, 2.5);
	
	// REs priors
	L_u ~ lkj_corr_cholesky(2.0);
	to_vector(z_u) ~ normal(0,1);
  sigma_u ~ normal(0,2.5);
  
  // likelihood
  y ~ lognormal(mu, sigma); 
}

generated quantities{
	vector[N] log_lik;
	vector[N] y_tilde;
  for(n in 1:N){
    log_lik[n] = lognormal_lpdf(y[n] | mu[n], sigma); 
    y_tilde[n] = lognormal_rng(mu[n], sigma);
  }
}
