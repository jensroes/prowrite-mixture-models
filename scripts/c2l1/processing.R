library(tidyverse)
library(janitor)

(files <- list.files("data/MarksData/", pattern = "C2L1", full.names = T))

read_delim(files, delim = "\t") %>% 
  clean_names() %>% 
  filter(!is.na(ke_location), 
         ke_location %in% c("a_^a", "a^a", "a._^a"),
         pwd_curs_up == 0,
         pwd_curs_down == 0,
         pwd_curs_left == 0,
         pwd_curs_right == 0,
         pwd_deletes == 0,
         ismodified == 0
         ) %>% 
  select(-id, 
         -starts_with("log"), 
         -starts_with("pwd"), 
         -event_time, 
         -iki_mod, 
         -pword_id,
         -ismodified,
         -ke_code,
         -starts_with("word"), 
         -inword,
         -starts_with("is"),
         -ke_location2) %>%
  mutate(across(ke_location, recode,
                `a_^a` = "before word",
                `a^a` = "within word",
                `a._^a` = "before sentence"),
         across(subno, ~as.numeric(factor(.)))) %>% 
  rename(location = ke_location) %>% 
  remove_constant() %>% 
  remove_empty() %>% 
  write_csv("data/c2l1.csv")
