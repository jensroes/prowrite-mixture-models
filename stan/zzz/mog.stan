/*
  Mixture model for pauses
  With by-ppt mixing proportion
  Random intercepts for subject 
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
	vector<lower=0>[K] delta;
  matrix[K,nS] theta_s;

  real beta_mu;
  vector[K] beta_raw;
  real<lower=0> beta_sigma;

	real<lower=0> sigma;		// residual sd
  real<lower=0> sigma_diff;

	vector[K] theta;
  real tau;

   // For random effects
	vector[nS] u; //subj intercepts
  real<lower=0> sigma_u;//subj sd
  
}

transformed parameters{
  vector[K] beta = beta_mu + beta_sigma * beta_raw;
  real<lower=0> sigmap_e = sigma + sigma_diff;
  real<lower=0> sigma_e = sigma - sigma_diff;

  matrix[K,nS] log_theta_s_1;
  matrix[K,nS] log_theta_s_2;

  vector[K] prob = 1 - inv_logit(theta); 
  matrix[K,nS] prob_s = 1 - inv_logit(theta_s);

  log_theta_s_1 = log_inv_logit(theta_s);
  log_theta_s_2 = log1m_inv_logit(theta_s);
}

model {
  vector[2] lp_parts;

  // Priors
  beta_mu ~ normal(5, 2);
  beta_sigma ~ cauchy(0, 1);
  beta_raw ~ normal(0, 1);
  sigma ~ cauchy(0, 2.5);
  delta ~ normal(0, 1);
  
  for(s in 1:nS){
    for(k in 1:K){
     theta_s[k,s] ~ normal(theta[k], tau);  
    }
  }
  
  theta ~ normal(0, 1);
  tau ~ cauchy(0, 1);

	// REs priors
  sigma_u ~ normal(0,2.5);
  u ~ normal(0, sigma_u); //subj random effects

  // likelihood
  for(n in 1:N){
    real mu = beta[condition[n]] + u[subj[n]];
    lp_parts[1] = log_theta_s_1[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu, sigma_e); 
    lp_parts[2] = log_theta_s_2[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu + delta[condition[n]], sigmap_e); 
    target += log_sum_exp(lp_parts);
  }
}

generated quantities{
	vector[N] log_lik;
	vector[N] y_tilde;
  vector[2] lp_parts;
  real<lower=0,upper=1> prob_tilde; 
  vector[K] beta2 = beta + delta;

  for(n in 1:N){
    real mu = beta[condition[n]] + u[subj[n]];
    lp_parts[1] = log_theta_s_1[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu, sigma_e); 
    lp_parts[2] = log_theta_s_2[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu + delta[condition[n]], sigmap_e); 
    log_lik[n] = log_sum_exp(lp_parts);
 		prob_tilde = bernoulli_rng(prob_s[condition[n],subj[n]]); 
    if(prob_tilde) { 
      y_tilde[n] = lognormal_rng(mu + delta[condition[n]], sigmap_e);
    }
    else{
      y_tilde[n] = lognormal_rng(mu, sigma_e);
    }
  }
}
