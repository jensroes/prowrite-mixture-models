library(tidyverse)
theme_set(theme_bw()+
            theme(legend.justification = "top",
                  panel.grid = element_blank()))

files <- list.files("data", full.names = T)

map_dfr(files, ~read_csv(.) %>% 
          mutate(data = str_remove_all(.x, "data|/|.csv" ))) %>% 
  mutate(across(condition, factor),
         across(data, ~recode(., mog = "bimodal", uvlm = "unimodal"))) %>% 
  ggplot(aes(x = value, colour = condition, fill = condition)) +
  geom_density(alpha = .25) +
  facet_grid(~data, labeller = label_both) 
  
