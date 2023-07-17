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
  int condition[N];       // conditions including transition location
  int K_loc;                        // number of transition locations
  int<lower=1, upper=K_loc> location[N];  // transition locations
  vector[N] y;            //outcome: for each subject one IKI per column/bigram (in 
}


parameters {
  vector<lower=0>[K] delta;
  real beta;
  vector[K] theta;
  real<lower = 0> tau;
  matrix[K, nS] theta_s;

  real<lower=0> sigma;		// residual sd
  vector<lower=0>[K_loc] sigma_diff;

   // For random effects
	vector[nS] u; //subj intercepts
  real<lower=0> sigma_u;//subj sd

}

transformed parameters{
  vector<lower=0>[K_loc] sigmap_e = sigma + sigma_diff;
  vector<lower=0>[K_loc] sigma_e = sigma - sigma_diff;
  matrix[K, nS] log_theta_s_1 = log_inv_logit(theta_s);
  matrix[K, nS] log_theta_s_2 = log1m_inv_logit(theta_s);
  vector[K] prob = 1 - inv_logit(theta); 
  matrix[K, nS] prob_s = 1 - inv_logit(theta_s); 
}

model {
  vector[2] lp_parts;

  // Priors
  beta ~ normal(5, 1);
  sigma ~ student_t(7, 0, 2);
  sigma_diff ~ normal(0, 1);
  delta ~ normal(0, 1);
  theta ~ normal(0, 1.5);
  tau ~ student_t(7, 0, 1.5);
    
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
    real mu = beta + u[subj[n]];
    lp_parts[1] = log_theta_s_1[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu, sigma_e[location[n]]); 
    lp_parts[2] = log_theta_s_2[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu + delta[condition[n]], sigmap_e[location[n]]); 
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
    real mu = beta + u[subj[n]];
    lp_parts[1] = log_theta_s_1[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu, sigma_e[location[n]]); 
    lp_parts[2] = log_theta_s_2[condition[n], subj[n]] + lognormal_lpdf(y[n] | mu + delta[condition[n]], sigmap_e[location[n]]); 
    log_lik[n] = log_sum_exp(lp_parts);
 		prob_tilde = bernoulli_rng(prob_s[condition[n], subj[n]]); 
    if(prob_tilde) { 
      y_tilde[n] = lognormal_rng(mu + delta[condition[n]], sigmap_e[location[n]]);
    }
    else{
      y_tilde[n] = lognormal_rng(mu, sigma_e[location[n]]);
    }
  }
}
