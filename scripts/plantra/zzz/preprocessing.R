library(tidyverse)
library(janitor)
#source("scripts/functions.R")

# Get log files
files <- list.files(path = "data/WritingPhases/PlanTra_Data/data_out", 
                    full.names = TRUE);files

# Process data: get only typing events
plantra <- map_dfr(files, read_csv) %>% 
  remove_constant() %>% 
  remove_empty() %>% 
  clean_names() %>% 
  mutate(arrowkeys = output %in% c("RIGHT", "LEFT", "DOWN", "UP")) %>% 
  filter(type == "keyboard", 
         !is.na(position),
         !arrowkeys,
       !output %in% c("CAPS LOCK", "BACK", "RCTRL", "DELETE", "PAUSE"), 
       !str_detect(output, "OEM|CTRL|SHIFT|ALT")) %>%
  select(-arrowkeys, -type, -starts_with("deleted_")) %>% 
  rename(iki = pause_time,
         location = pause_location_full) %>% 
  mutate(output = ifelse(output %in% c("SPACE", "TAB", "RETURN"), "_", output),
         ppt = as.numeric(factor(participant)),
         across(c(location, folder), str_to_lower),
         across(location, ~str_sub(., 1, nchar(.)-1))) %>% 
  filter(str_detect(location, "before|within")) %>% 
  select(ppt, task = folder, logguid, output, iki, location) %>% 
  filter(location != "before paragraph") %>% 
  group_by(logguid, location) %>% 
  mutate(location_count = n()) %>% 
  group_by(ppt) %>% 
  mutate(enough_sentences = min(location_count) > 10) %>% # min 10 sentences or more
  ungroup()

glimpse(plantra)
select(plantra, ppt, enough_sentences) %>% unique() %>% count(enough_sentences)
count(plantra, ppt, location_count, enough_sentences) %>% 
  as.data.frame()

write_csv(plantra, "data/plantra.csv")
