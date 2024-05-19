get_pdens_plot <- function(file, max_iki){
  #file <- "stanout/c2l1/all_sims.csv
  #max_iki <- 2000
  read_csv(file) %>% 
    filter(sim_idx <= 50) %>% 
    pivot_longer(cols = c(y_obs, y_tilde)) %>% 
    mutate(across(name, recode_factor, 
                  y_tilde = "Simulated data",
                  y_obs = "Observed data",
                  .ordered = T)) %>% 
    filter(name ==  "Simulated data" |
          (name == "Observed data" & sim_idx == 1),
          value <= max_iki,
          model != "mogbetaunconstr") %>% 
    mutate(across(model, ~case_when(
      str_detect(., "mogbetacon.+") ~ "Two log-Gaussians",
#      . == "mogbetaunconstr" ~ "Two log-Gaussians (unconstrained)",
      . == "lmmuneqvar" ~ "Single log-Gaussian (unequal variance)",
      . == "lmm" ~ "Single log-Gaussian",
      . == "lmmgaus" ~ "Single Gaussian")),
      across(model, ~str_wrap(., 20)),
      across(model, ~factor(., levels = sort(unique(model))[c(4, 3, 2, 1)], ordered = T))) %>% 
    ggplot(aes(x = value / 1000, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model, scales = "free_x", nrow = 1) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "") 
}