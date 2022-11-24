/*
  LMM with random intercepts 
  todo: add random slopes
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
	vector[nS] u; //subj intercepts
  real<lower=0> sigma_u;//subj sd
}

transformed parameters{
  vector[K] beta = beta_mu + beta_sigma * beta_raw;
  vector[N] mu;
  
  for(n in 1:N){
    mu[n] = beta[condition[n]] + u[subj[n]];
  }
}

model {
  // Priors
  beta_mu ~ normal(5, 2);
  beta_sigma ~ cauchy(0, 1);
  beta_raw ~ normal(0, 1);
  sigma ~ cauchy(0, 2.5);
	
	// REs priors
  sigma_u ~ normal(0,2.5);
  u ~ normal(0, sigma_u); //subj random effects

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
