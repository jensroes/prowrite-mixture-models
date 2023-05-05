get_pdens_plot <- function(file, max_iki){
  sims <- read_csv(file) %>% 
    pivot_longer(cols = c(y_obs, y_tilde)) %>% 
    mutate(across(name, recode_factor, 
                  y_tilde = "Simulated data",
                  y_obs = "Observed data",
                  .ordered = T)) %>% 
    filter(name ==  "Simulated data" |
             (name == "Observed data" & sim_idx == 1)) 
  
  plot_mog <- sims %>%
    filter(model == "mogbetaunconstr", value < max_iki) %>% 
    mutate(model = "Bimodal log-normal (unconstrained)") %>% 
    ggplot(aes(x = value, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "") +
    theme(axis.title = element_blank())
  
  
  plot_mog2 <- sims %>%
    filter(str_detect(model, "mogbetacon.+"), value < max_iki) %>% 
    mutate(model = "Bimodal log-normal (constrained)") %>% 
    ggplot(aes(x = value, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "") +
    theme(axis.title = element_blank())
  
  
  plot_lmm <- sims %>%
    filter(model == "lmm", value < max_iki) %>% 
    mutate(model = "Unimodal log-normal") %>% 
    ggplot(aes(x = value, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "") +
    theme(axis.title = element_blank())
  
  plot_lmmgaus <- sims %>%
    filter(model == "lmmgaus", value < max_iki) %>% 
    mutate(model = "Unimodal normal") %>% 
    ggplot(aes(x = value, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "") +
    theme(axis.title = element_blank())
  
  plot_lmmuneqvar <- sims %>%
    filter(model == "lmmuneqvar", value < max_iki) %>% 
    mutate(model = "Unimodal log-normal (unequal variance)") %>% 
    ggplot(aes(x = value, 
               group = interaction(sim_idx,name), 
               colour = name)) +
    geom_density() +
    facet_wrap(~model) +
    scale_colour_manual(values = c("firebrick3", "black")) +
    scale_x_continuous(labels = scales::comma) +
    labs(colour = "") +
    theme(axis.title = element_blank())
  
  plots <- plot_lmmgaus + plot_lmm + plot_lmmuneqvar + plot_mog + plot_mog2 +
    plot_layout(guide = "collect") +
    plot_annotation(tag_levels = 'A') &
    theme(legend.position = "bottom")
  
  return(plots)
}