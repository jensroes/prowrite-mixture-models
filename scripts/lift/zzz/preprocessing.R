# Load packages
library(tidyverse)
library(janitor)
source("scripts/functions.R")

# Get log files
files <- list.files(path = "data/WritingPhases/LIFT_Data/data_out", 
                    pattern = "logs", 
                    full.names = TRUE)

ppts <- read_csv("data/WritingPhases/LIFT_Data/data_out/participants.csv") %>% 
  select(logguid, matches("partic")) %>% 
  rename(ppt = ID_Participant)

# Load log files
lift <- map_dfr(files, read_csv) %>% 
  remove_constant() %>% 
  remove_empty() %>% 
  indicate_dels_and_inserts() %>% 
  clean_names()

# Get only writing events
lift_small <- lift %>% 
  filter(type == "keyboard", !arrowkeys,
         !output %in% c("CAPS LOCK", "BACK", "RCTRL", "DELETE", "PAUSE"), 
         !str_detect(output, "OEM|CTRL|SHIFT|ALT")) %>%
  select(-arrowkeys, -type, -starts_with("deleted_")) %>% 
  rename(iki = pause_time,
         location = pause_location_full) %>%
  mutate(output = ifelse(output %in% c("SPACE", "TAB", "RETURN"), "_", output),
     #    ppt = as.numeric(factor(logguid)),
         across(location, str_to_lower),
         across(location, ~str_sub(., 1, nchar(.)-1))) %>% 
  filter(str_detect(location, "before|within")) %>% 
  select(task, logguid, output, iki, location) %>% 
  separate(task, into = c("topic", "genre"), sep = "-") %>% 
  left_join(ppts) %>% 
  mutate(across(ppt, ~as.numeric(factor(.)))) %>% 
  filter(location != "before paragraph") %>% 
  group_by(logguid, location) %>% 
  mutate(location_count = n()) %>% 
  group_by(logguid) %>% 
  mutate(enough_sentences = min(location_count) > 10) %>% # min 10 sentences or more
  ungroup()

glimpse(lift_small)

select(lift_small, ppt, topic, genre) %>% unique() %>% 
  count(ppt, topic, genre)

write_csv(lift_small, "data/lift.csv")

# lift: Nina's phd; writing from sources 13-15 year old students 
# (arg = argumentative; inf = informative) 
# plantra: translation and rewrite text to plain language; professional translators
# References: Nina's phd
# what is type ==  focus: focus is when attention switches to text
# position NA is outside of word document
# select(plantra, position) %>% count(position)
# too many ppts: how can I reduce this: sample 200 obs per location per ppt is still a lot
# -> I don't think the amount of data doesn't make it more useful: before paragraph is too low,
# before sentence is relatively low: biggest problem is that is is unbalanced for COND (not my problem
# but surely not great if you do p-value testing)
# Sample subsets: what should N be for ppt? I've used 200 but that's still kind a lot

# minimum number of setnece? 10 -> remove ppts
# 100 samples for words