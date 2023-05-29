# Load packages
library(tidyverse)
library(janitor)
source("scripts/functions.R")

# lift: Nina's phd; writing from sources 13-15 year old students 
# (arg = argumentative; inf = informative) 

# Get log files
files <- list.files(path = "data/WritingPhases/LIFT_Data/data_out", 
                    pattern = "logs", 
                    full.names = TRUE)

ppts <- read_csv("data/WritingPhases/LIFT_Data/data_out/participants.csv") %>% 
  select(logguid, matches("partic")) %>% 
  rename(participant = ID_Participant) %>% 
  unique()

# Load log files
#read_csv(files[1]) %>% 
lift <- map_dfr(files, read_csv) %>% 
  clean_names() %>% 
  left_join(ppts, by = "logguid") %>% 
  indicate_dels_and_inserts() %>% 
  # Get only writing events
  filter(type == "keyboard", 
         !arrowkeys,
         !output %in% c("CAPS LOCK", "RCTRL", "PAUSE"), 
         !str_detect(output, "OEM|CTRL|SHIFT|ALT")) %>%
  select(-arrowkeys, -type, -starts_with("deleted_")) %>% 
  rename(iki = pause_time,
         location = pause_location_full) %>%
  mutate(output = ifelse(output %in% c("SPACE", "TAB", "RETURN"), "_", output),
         across(location, str_to_lower),
         across(location, ~ifelse(. != "revision", str_sub(., 1, nchar(.)-1), .))) %>% 
  filter(str_detect(location, "before|within") | location %in% c("revision")) %>% 
  select(ppt = participant, logguid, task, output, iki, location) %>% 
  separate(task, into = c("topic", "genre"), sep = "-") %>% 
  mutate(across(ppt, ~as.numeric(factor(.)))) %>% 
  filter(location != "before paragraph") %>% 
  mutate(location_count = n(), .by = c(logguid, location)) %>% 
  mutate(enough_sentences = min(location_count) > 10, .by = logguid) %>% # min 10 sentences or more
  select(-logguid)
  
glimpse(lift)

select(lift, ppt, topic, genre) %>% unique() %>% 
  count(ppt, topic, genre)

count(lift, location)

# Key transition ends in editing operation
lift <- lift %>% 
  mutate(is_edit = lead(location) == "revision", .by = c(ppt, topic, genre)) %>% 
  mutate(across(is_edit, ~replace_na(., FALSE))) %>% 
  filter(location != "revision") %>% 
  mutate(streak = sequence(rle(is_edit)$lengths),
         is_end_of_streak = lead(streak) < streak,
         streak_id = lag(cumsum(is_end_of_streak) + 1),
         across(streak_id, ~replace_na(., 1)),
         .by = c(ppt, topic, genre)) %>% 
  select(-is_end_of_streak, -streak, -streak_id) 

count(lift, location, is_edit)

write_csv(lift, "data/lift.csv")

