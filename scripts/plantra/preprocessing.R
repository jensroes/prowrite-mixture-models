library(tidyverse)
library(janitor)
source("scripts/functions.R")

# plantra: translation and rewrite text to plain language; professional translators

# Get log files
files <- list.files(path = "data/WritingPhases/PlanTra_Data/data_out", 
                    full.names = TRUE);files

# Process data: get only typing events
plantra <- map_dfr(files, read_csv) %>% 
  remove_constant() %>% 
  remove_empty() %>% 
  clean_names() %>% 
  #count(participant, folder) %>% count(participant) %>% 
  #filter(n == 2)
  indicate_dels_and_inserts() %>% 
  filter(type == "keyboard", 
         !arrowkeys,
         !output %in% c("CAPS LOCK", "RCTRL", "PAUSE"), 
         !str_detect(output, "OEM|CTRL|SHIFT|ALT")) %>%
  select(-arrowkeys, -type, -starts_with("deleted_")) %>% 
  rename(iki = pause_time,
         location = pause_location_full) %>% 
  mutate(output = ifelse(output %in% c("SPACE", "TAB", "RETURN", "BACK", "DELETE"), "_", output),
         ppt = as.numeric(factor(participant)),
         across(c(location, task), str_to_lower),
         across(location, ~ifelse(. != "revision", str_sub(., 1, nchar(.)-1), .))) %>% 
  filter(str_detect(location, "before|within") | location %in% c("revision")) %>% 
  select(ppt, task, output, iki, location) %>% 
  filter(location != "before paragraph") 

# Key transition ends in editing operation
plantra <- plantra %>% 
  mutate(is_edit = lead(location) == "revision", .by = c(ppt, task)) %>% 
  mutate(across(is_edit, ~replace_na(., FALSE))) %>% 
  filter(location != "revision") %>% 
  mutate(streak = sequence(rle(is_edit)$lengths),
         is_end_of_streak = lead(streak) < streak,
         streak_id = lag(cumsum(is_end_of_streak) + 1),
         across(streak_id, ~replace_na(., 1)),
         .by = c(ppt, task)) %>% 
  select(-is_end_of_streak, -streak, -streak_id) 

write_csv(plantra, "data/plantra.csv")
