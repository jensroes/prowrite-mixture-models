library(tidyverse)

files <- list.files("data", pattern = ".csv", full.names = T)

d_ppt <- map_dfr(files[-c(1,2,6)], ~read_csv(.) %>% 
                   clean_names() %>% 
      transmute(n = n(),
            file = .x,
            n_ppts = length(unique(ppt))) %>% 
      unique())

d_subno <- map_dfr(files[c(1,2,6)], ~read_csv(.) %>% 
                     rename_with(.fn = ~str_to_lower(.)) %>% 
                   transmute(n = n(),
                             file = .x,
                             n_ppts = length(unique(subno))) %>% 
                   unique())

bind_rows(d_ppt, d_subno) %>% 
  summarise(across(c(n, n_ppts), list(sum = sum)))
