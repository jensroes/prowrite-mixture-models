# Load library
library(tidyverse)
theme_set(theme_bw() +
          theme(legend.position = "top",
                legend.justification = "right"))

# Load data
plantra <- read_csv("data/plantra.csv")

# Check out data
glimpse(plantra)

select(plantra, ppt, task) %>% 
  unique() %>% 
  count(ppt) 

ggplot(plantra, aes(x = iki, colour = location, fill = location)) +
  geom_density(alpha = .25) +
  scale_x_log10() +
  facet_wrap(~task)

ggplot(plantra, aes(x = iki)) +
  geom_density(alpha = .25) +
  scale_x_log10(limits = c(5, 150)) 

count(plantra, location)

plantra %>% group_by(ppt, location) %>% 
  summarise(across(iki, list(iki = mean, 
                             n = length, 
                             pause = ~mean(. > 2000) * 100), .names = "{.fn}")) %>% 
  ungroup() %>% 
  mutate(across(where(is.numeric), signif)) %>% 
  select(-ppt) %>% 
  group_by(location) %>% 
  summarise(across(where(is.numeric), list(mean = mean, sd = sd)))

pull(plantra, ppt) %>% unique() %>% length()
