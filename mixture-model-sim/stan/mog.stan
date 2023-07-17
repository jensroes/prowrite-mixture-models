/* 
Finite mixture model
This model is adapted from Vasishth et al. 2007 
*/

data {
	int<lower=1> N;                    // Number of observations
	real y[N];  		            //outcome
  int K;                  // Number of conditions
	int<lower=1, upper=K> condition[N];  //predictor
}


parameters {
	real beta;	// distributions
	real<lower=0> delta;			// distribution + extra component
	real<lower=0> sigma;		// residual sd

	real<lower=0> sigma_diff;
	vector[K] theta;
}


transformed parameters{
	real<lower=0> sigmap_e = sigma + sigma_diff;
	real<lower=0> sigma_e = sigma - sigma_diff;
	vector[K] prob = inv_logit(theta);
	matrix[K,2] log_theta;

	log_theta[1, 1] = log_inv_logit(theta[1]);
  log_theta[1, 2] = log1m_inv_logit(theta[1]);
	log_theta[2, 1] = log_inv_logit(theta[2]);
  log_theta[2, 2] = log1m_inv_logit(theta[2]);

}

model {
  vector[2] lp_parts[N];

  // Priors
	beta ~ normal(5, 2);
  delta ~ normal(0, 1);

  sigma_diff ~ normal(0, 1);
  sigma ~ student_t(7, 0, 1);

  theta ~ normal(0, 1);

  // Likelihood	
	for(n in 1:N){
    lp_parts[n, 1] = log_theta[condition[n],1] + lognormal_lpdf(y[n] | beta + delta, sigmap_e); 
    lp_parts[n, 2] = log_theta[condition[n],2] + lognormal_lpdf(y[n] | beta, sigma_e);
    target += log_sum_exp(lp_parts[n]); 
	}
}


generated quantities{
  vector[N] log_lik;
	vector[N] y_tilde;
  real<lower=0,upper=1> theta_long; 

  // likelihood: 
  for(n in 1:N){
    	log_lik[n] = log_sum_exp(
                  log_theta[condition[n],1] + lognormal_lpdf(y[n] | beta + delta, sigmap_e), 
                  log_theta[condition[n],2] + lognormal_lpdf(y[n] | beta, sigma_e));
    	    theta_long = bernoulli_rng(prob[condition[n]]); 
          if(theta_long) { 
              y_tilde[n] = lognormal_rng(beta + delta, sigmap_e);
          }
          else{
              y_tilde[n] = lognormal_rng(beta, sigma_e);
          }
        }
}

