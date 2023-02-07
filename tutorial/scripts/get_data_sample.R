library(tidyverse)

read_csv('data/process_data_by_event.csv') %>% 
  filter(location != "post-paragraph", 
         !is.na(location),
         next_event_type != "block-operation",
         event_type != "block-operation",
         event_duration > 50,
         session_no == 1) %>% 
  group_by(token, location) %>% 
  mutate(idx = sample(n())) %>% 
  ungroup() %>% 
  filter(idx <= 20) %>% 
  select(participant, iki = event_duration, location) %>% 
  mutate(across(location, recode, 
                "post-word" = "before-word",
                "post-sentence" = "before-sentence")) %>% 
  filter(participant %in% sample(unique(participant), 10)) %>% 
  write_csv("data/sampledata.csv")
