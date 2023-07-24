library(loo)
library(tidyverse)

path <- "stanout"
(files <- list.files(path, pattern = ".rda$", full.names = T))

for(file in files){
    varname <- str_remove_all(file, ".rda|stanout/")
    m <- readRDS(file)
    log_lik <- extract_log_lik(m, merge_chains = F) 
    r_eff <- relative_eff(exp(log_lik)) 
    assign(paste0("loo_",varname), loo(log_lik, r_eff = r_eff, cores = 2))  
    print(varname); rm(list = "m"); gc()
}

(loos <- ls(pattern = "loo_.*"))
mc_mogdata <- loo_compare(loo_mog_mogdata, loo_lm_mogdata)
mc_lmdata <- loo_compare(loo_mog_lmdata, loo_lm_lmdata)

mc1 <- mc_mogdata %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(across(model, ~recode(., model1 = "mog", model2 = "lm")),
         across(model, ~str_remove(., "^loo_")),
         data = "mog")

mc2 <- mc_lmdata %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(across(model, ~recode(., model1 = "mog", model2 = "lm")),
         across(model, ~str_remove(., "^loo_")), 
         data = "lm")

# Save result
file_out <- "stanout/modelcomparison.csv"
bind_rows(mc1, mc2) %>% relocate(data) %>% write_csv(file_out)
