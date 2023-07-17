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
      . == "lmmgaus" ~ "Unimodal normal",
      . == "lmm" ~ "Unimodal log-normal",
      . == "lmmuneqvar" ~ "Unimodal log-normal (unequal variance)",
      . == "mogbetaunconstr" ~ "Bimodal log-normal (unconstrained)",
       str_detect(., "mogbetacon.+") ~ "Bimodal log-normal (constrained)")),
      across(model, ~str_wrap(., 30)),
      across(model, ~factor(., levels = unique(model)[c(2, 1, 3, 4, 5)], ordered = T)))
  
  plot <- sims %>%
    ggplot(aes(x = value, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model, scales = "free_x", nrow = 1) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "", 
         y = "Density", 
         x = "Transition duration in msecs",
         title = ds) +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
  
  return(plot)
}