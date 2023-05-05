/*
  LMM with random intercepts 
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

	real alpha;
	vector[K] beta_e;

   // For random effects
	vector[nS] u; //subj intercepts
  real<lower=0> sigma_u;//subj sd
}

transformed parameters{
  vector[N] mu;
  for(n in 1:N){
    mu[n] = alpha + beta_e[condition[n]] + u[subj[n]];
  }
}

model {
  // Priors
  alpha ~ normal(5, 1);
  beta_e ~ normal(0, 1);
  sigma ~ student_t(7, 0, 2);
	
	// REs priors
  sigma_u ~ normal(0,2.5);
  u ~ normal(0, sigma_u); //subj random effects
  
  // likelihood
  y ~ lognormal(mu, sigma); 
}

generated quantities{
	vector[N] log_lik;
	vector[N] y_tilde;
	vector[K] beta = alpha + beta_e;
  for(n in 1:N){
    log_lik[n] = lognormal_lpdf(y[n] | mu[n], sigma); 
    y_tilde[n] = lognormal_rng(mu[n], sigma);
  }
}
