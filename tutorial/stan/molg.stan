/*
  Mixture model for pauses
  With by-ppt mixing proportion
  Random intercepts for participants 
*/

data {
  int<lower=1> N;               // Number of observations
  int<lower=1> nS;              // Number of subjects
  int<lower=1, upper=nS> ppt[N];// Participant identifiers
  int<lower=1> K;               // Number of conditions
  int<lower=1> condition[N];    // Condition identifiers
  vector[N] y;                  // Outcome: interkey intervals
}


parameters {
  // fixed effects
  real beta; // fluent interkey intervals
  vector<lower=0>[K] delta; // slowdown for long interkey intervals
  vector[K] theta; // hesitation probability

  real<lower = 0> tau; // error for hesitation probability
  real<lower=0> sigma; // residual sd
  vector<lower=0>[K] sigma_diff; 

  // For random effects
  vector[nS] u; // participant intercepts
  real<lower=0> sigma_u; // participant sd
  matrix[K, nS] theta_s; // participant hesitations

}

transformed parameters{
  vector<lower=0>[K] sigmap_e = sigma + sigma_diff;
  vector<lower=0>[K] sigma_e = sigma - sigma_diff;
  matrix[K, nS] log_theta_s_1 = log_inv_logit(theta_s);
  matrix[K, nS] log_theta_s_2 = log1m_inv_logit(theta_s);
  vector[K] prob = inv_logit(theta); 
  matrix[K, nS] prob_s = inv_logit(theta_s); 

}

model {
  vector[2] lp_parts;

  // Priors
  beta ~ normal(5, .5);
  sigma ~ student_t(7, 0, 1);
  sigma_diff ~ normal(0, 1);
  delta ~ normal(0, .5);
  theta ~ normal(0, 1);
  tau ~ student_t(7, 0, .5);
    
  for(s in 1:nS){
    for(k in 1:K){
     theta_s[k,s] ~ normal(theta[k], tau);  
    }
  }
  
  // REs priors
  sigma_u ~ normal(0,2.5);
  u ~ normal(0, sigma_u); //subj random effects

  // likelihood
  for(n in 1:N){
    real mu = beta + u[ppt[n]];
    lp_parts[1] = log_theta_s_1[condition[n], ppt[n]] + lognormal_lpdf(y[n] | mu + delta[condition[n]], sigmap_e[condition[n]]); 
    lp_parts[2] = log_theta_s_2[condition[n], ppt[n]] + lognormal_lpdf(y[n] | mu, sigma_e[condition[n]]); 
    target += log_sum_exp(lp_parts);
  }
}

generated quantities{
  vector[N] log_lik;
  vector[N] y_tilde;
  vector[2] lp_parts;
  real<lower=0,upper=1> prob_tilde; 

  for(n in 1:N){
    real mu = beta + u[ppt[n]];
    lp_parts[1] = log_theta_s_1[condition[n], ppt[n]] + lognormal_lpdf(y[n] | mu + delta[condition[n]], sigmap_e[condition[n]]); 
    lp_parts[2] = log_theta_s_2[condition[n], ppt[n]] + lognormal_lpdf(y[n] | mu, sigma_e[condition[n]]); 
    log_lik[n] = log_sum_exp(lp_parts);
    prob_tilde = bernoulli_rng(prob_s[condition[n], ppt[n]]); 
    if(prob_tilde) { 
      y_tilde[n] = lognormal_rng(mu + delta[condition[n]], sigmap_e[condition[n]]);
    }
    else{
      y_tilde[n] = lognormal_rng(mu, sigma_e[condition[n]]);
    }
  }
}
