library(tidyverse)
library(janitor)

files <- list.files("data/MarksData/", pattern = "CATO", full.names = T)

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
  select(-id, -dtxn, -starts_with("log"), 
         -condit, -starts_with("pwd"), 
         -event_time, 
         -iki_mod, 
         -w_spell,
         -pword_id,
         -ismodified,
         -ke_code,
         -starts_with("word"), 
         -inword,
         -starts_with("is")) %>% 
  mutate(across(dystyp, recode, 
                D = "dyslexic", 
                K = "non dyslexic"),
         across(xn, recode, 
                X = "masked", 
                N = "unmasked"),
         across(ke_location, recode,
                `a_^a` = "before word",
                `a^a` = "within word",
                `a._^a` = "before sentence"),
         across(subno, ~as.numeric(factor(.)))) %>% 
  rename(location = ke_location) %>% 
  remove_constant() %>% 
  remove_empty() %>% 
  #count(subno, xn, dystyp, location)
  write_csv("data/cato.csv")

  