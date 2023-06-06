# load libraries
library(tidyverse)
library(janitor)

# get file name
(files <- list.files("data/MarksData", pattern = "Gunn", full.names = T))

# load data
readRDS(files) %>% 
  as_tibble() %>% 
  clean_names() %>% 
  filter(!is.na(ke_location), 
         ke_location %in% c("a_^a", "a^a", "a._^a")) %>% 
  select(word, iki = iki_mod, ppt = subno, xn, topic, 
         location = ke_location,
         isfluent = pwd_isfluent) %>% 
  mutate(across(xn, recode, 
                X = "masked", 
                N = "unmasked"),
         across(location, recode,
                `a_^a` = "before word",
                `a^a` = "within word",
                `a._^a` = "before sentence"),
         across(ppt, ~as.numeric(factor(.))),
         condition = str_c(location, xn, sep = "_")) %>% 
  write_csv("data/gunnexp2.csv")

  