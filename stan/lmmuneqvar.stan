/*
  lognormal distribution 
by-subject and by-item intercepts (no random slopes; see Vasishth et al. 2017)
*/
  
data {
  int<lower=1> N;                    // Number of observations
  real<lower=0> y[N];  		            //outcome
  int K;                  // Number of conditions
  int<lower=1, upper=K> condition[N];  //predictor
  int K_loc;                        // number of transition locations
  int<lower=1, upper=K_loc> location[N];  // transition locations
  int<lower=1> nS;                  //number of subjects
  int<lower=1, upper=nS> subj[N];   //subject id

}

parameters {
  real alpha;
  vector[K] beta;
  vector<lower=0>[K_loc] sigma;

   // For random effects
	vector[nS] u; //subj intercepts
  real<lower=0> sigma_u;//subj sd
  
}

model {
  // Priors
  alpha ~ normal(5, 1);
  beta ~ normal(0, 1);
  sigma ~ student_t(7, 0, 2);

	// REs priors
  sigma_u ~ normal(0,2.5);
  u ~ normal(0, sigma_u); //subj random effects
  
  // Likelihood
  for(n in 1:N){
    real mu = alpha + beta[condition[n]] + u[subj[n]];
    y[n] ~ lognormal(mu, sigma[location[n]]);
  }
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_tilde;
  vector[K] alphabeta = alpha + beta;

  for(n in 1:N) {
    real mu = alpha + beta[condition[n]] + u[subj[n]];
    log_lik[n] = lognormal_lpdf(y[n] | mu, sigma[location[n]]);
    y_tilde[n] = lognormal_rng(mu, sigma[location[n]]);
  }
}


