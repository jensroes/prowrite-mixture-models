# Indicate deletion and insertion 
indicate_dels_and_inserts <- function(data){
  data %>%
    # remove typing/clicking outside word document
    filter(!(is.na(position) & 
          !type %in% c("replacement", "insert")),
           type %in% c("insert", "keyboard", "replacement")) %>%
    select(task = folder, 
           participant,
           logguid,
           logcreationdate,
           id, type, output, position, position_full, doclength_full, 
           char_production,
           pause_time, pause_location_full, start_time, end_time) %>%
    mutate(arrowkeys = output %in% c("RIGHT", "LEFT", "DOWN", "UP"), 
           leadingedge = (position_full == doclength_full), 
           # Deletion
           deletion = ifelse((
             # backspace key or doclength reduced
             output == "BACK" | lead(doclength_full) < doclength_full) |
               #selection + backspace
               (type == "replacement" & lead(output) == "BACK" & 
                  position_full == lead(position_full) & pause_time != 0 &
                  # selection resulted in reduced doc length
                  lead(doclength_full,2) < lead(doclength_full)), 1, 0),
           # start new deletion if position is changed during deletion
           deletion = ifelse((type == "replacement" &
                                lag(output) == "BACK" & deletion == 1) | 
                               (((type == "replacement" & 
                                    lag(type) == "replacement") | 
                                   (output == "BACK" & 
                                      lag(output) == "BACK")) &
                                  abs(lag(position_full) - position_full) > 1),
                             lag(deletion) + 1, deletion),
           deletion = ifelse(is.na(deletion), 0, deletion),
           # Insertion
           insertion = ifelse(type == "insert" |
                                (((lag(arrowkeys) | !(position_full - lag(position_full)) 
                                   %in% c(0,1)) & !lag(deletion) &
                                    type == "keyboard" &
                                    !arrowkeys & !leadingedge & !deletion)), 1, 0), 
           insertion = ifelse(is.na(insertion), 0, insertion), 
           .by = c(logcreationdate, task)) %>% 
    select(-logcreationdate)
}



# Calculate Bayes Factor
BF <- function(ps, prior_sd = 1){
  fit_posterior <- logspline(ps) 
  posterior <- dlogspline(0, fit_posterior) # Height of the posterior at 0 
  prior <- dnorm(0, 0, prior_sd) # Height of the prior at 0
  BF10 <- prior / posterior 
  return(BF10)
}

logit <- function(p) log(p / (1-p))
ilogit <- function(x) 1 / (1 + exp(-x))
inv_logit <- function(logit) exp(logit) / (1 + exp(logit))

se_bin <- function(x) sqrt((mean(x, na.rm = T)*(1 - mean(x, na.rm = T)))/length(x)) # se for binary data

lower <- function(x) quantile(x, prob = .025)
upper <- function(x) quantile(x, prob = .975)

# Remove leading zeros and round numbers
dezero <- function(x, dp){ # dp is decimal places
  fmt = paste0('%.',dp,'f')
  x = sprintf(fmt,x)
  x = str_replace(x, '(-|^)0\\.','\\1\\.')
  return(x)
}
dezero_plot <- function(x) dezero(x, 1)


MSD <- function(M, SD, dp = 2){
  paste0(dezero(M, dp),' (',dezero(SD, dp), ')')
}

PI_dezero <- function(est, lo, hi, dp = 2){
  paste0(dezero(est,dp),' [', dezero(lo, dp),', ',dezero(hi, dp), ']')
}


PI <- function(est,lo, hi, dp = 2){
  paste0(round(est,dp),' [', round(lo, dp),', ', round(hi, dp), ']')
}

PI_lnum <- function(est,lo, hi, dp = 2){
  paste0(scales::comma(round(est, dp), accuracy = 1),
         ' [', scales::comma(round(lo, dp), accuracy = 1),', ', 
         scales::comma(round(hi, dp), accuracy = 1), ']')
}

plot_mix_comps <- function(x, mu, sigma, lam) lam * dnorm(x, mu, sigma)
