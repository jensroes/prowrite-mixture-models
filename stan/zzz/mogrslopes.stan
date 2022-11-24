/*
  Mixture model for pauses
  With by-ppt mixing proportion
  Random intercepts for subject 
  Random slopes for beta 
*/

data {
	int<lower=1> N;          // Number of observations
  int<lower=1> nS;        //number of subjects
  int<lower=1, upper=nS> subj[N];
  int K;                  // Number of conditions
  int condition[N];
  int lang[N];
  vector[N] y;            //outcome: for each subject one IKI per column/bigram (in 
}


parameters {
  vector<lower=0>[K] delta;

  real beta_mu;
  vector[K] beta_raw;
  real<lower=0> beta_sigma;

  real theta_mu;
  vector[K] theta_raw;
  matrix[K, nS] theta_s;
  real<lower = 0> tau;
  
  real<lower=0> theta_sigma;

  real<lower=0> sigma;		// residual sd
  vector<lower=0>[K] sigma_diff;


  // For random effects
  vector<lower=0>[2] sigma_u;
  cholesky_factor_corr[2] L_u; 
  matrix[2,nS] z_u;
}

transformed parameters{
  vector[N] mu;
  vector[K] theta = theta_mu + theta_sigma * theta_raw;
  vector[K] beta = beta_mu + beta_sigma * beta_raw;
  vector<lower=0>[K] sigmap_e = sigma + sigma_diff;
  vector<lower=0>[K] sigma_e = sigma - sigma_diff;
  matrix[K, nS] log_theta_s_1 = log_inv_logit(theta_s);
  matrix[K, nS] log_theta_s_2 = log1m_inv_logit(theta_s);
  vector[K] prob = 1 - inv_logit(theta); 
  matrix[K, nS] prob_s = 1 - inv_logit(theta_s); 
  
  matrix[2,nS] u = diag_pre_multiply(sigma_u, L_u) * z_u; //subj random effects

  for(n in 1:N){
    mu[n] = beta[condition[n]] + u[lang[n], subj[n]];
  }

}

model {
  vector[2] lp_parts;

  // Priors
  beta_mu ~ normal(5, 2);
  beta_sigma ~ cauchy(0, 1);
  beta_raw ~ normal(0, 1);
  sigma ~ cauchy(0, 2.5);
  sigma_diff ~ normal(0, 1);
  delta ~ normal(0, 1);
  theta_mu ~ normal(0, 1);
  theta_sigma ~ cauchy(0, 1);
  theta_raw ~ normal(0, .5);
  tau ~ cauchy(0, .5);
    
  for(s in 1:nS){
    for(k in 1:K){
     theta_s[k,s] ~ normal(theta[k], tau);  
    }
  }
  
	// REs priors
	L_u ~ lkj_corr_cholesky(2.0);
	to_vector(z_u) ~ normal(0,1);
  sigma_u ~ normal(0,2.5);

  // likelihood
  for(n in 1:N){
    lp_parts[1] = log_theta_s_1[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu[n], sigma_e[condition[n]]); 
    lp_parts[2] = log_theta_s_2[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu[n] + delta[condition[n]], sigmap_e[condition[n]]); 
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
    lp_parts[1] = log_theta_s_1[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu[n], sigma_e[condition[n]]); 
    lp_parts[2] = log_theta_s_2[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu[n] + delta[condition[n]], sigmap_e[condition[n]]); 
    log_lik[n] = log_sum_exp(lp_parts);
 		prob_tilde = bernoulli_rng(prob_s[condition[n], subj[n]]); 
    if(prob_tilde) { 
      y_tilde[n] = lognormal_rng(mu[n] + delta[condition[n]], sigmap_e[condition[n]]);
    }
    else{
      y_tilde[n] = lognormal_rng(mu[n], sigma_e[condition[n]]);
    }
  }
}
