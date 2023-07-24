get_pdens_plot <- function(file, max_iki, ds){
  sims <- read_csv(file) %>% 
    pivot_longer(cols = c(y_obs, y_tilde)) %>% 
    mutate(across(name, recode_factor, 
                  y_tilde = "Simulated data",
                  y_obs = "Observed data",
                  .ordered = T)) %>% 
    filter(name ==  "Simulated data" |
          (name == "Observed data" & sim_idx == 1),
           value < max_iki) %>% 
    mutate(across(model, ~case_when(
      str_detect(., "mogbetacon.+") ~ "Bimodal (constrained)",
      . == "mogbetaunconstr" ~ "Bimodal (unconstrained)",
      . == "lmmuneqvar" ~ "Unimodal (unequal variance)",
      . == "lmm" ~ "Unimodal log-normal",
      . == "lmmgaus" ~ "Unimodal normal")),
      across(model, ~str_wrap(., 20)),
      across(model, ~factor(., levels = sort(unique(model))[c(5, 4, 3, 1, 2)], ordered = T)))
  
  plot <- sims %>%
    ggplot(aes(x = value / 1000, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model, scales = "free_x", nrow = 1) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "", subtitle = ds) 
  
  return(plot)
}