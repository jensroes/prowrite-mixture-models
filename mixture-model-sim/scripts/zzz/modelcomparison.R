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
mc_mogdata <- loo_compare(loo_mog_mogdata, loo_uvlm_mogdata)
mc_uvlmdata <- loo_compare(loo_mog_uvlmdata, loo_uvlm_uvlmdata)

mc1 <- mc_mogdata %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(across(model, ~recode(., 
                        model1 = "mog",
                        model2 = "uvlm")),
         across(model, ~str_remove(., "^loo_")),
         data = "mog")

mc2 <- mc_uvlmdata %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(across(model, ~recode(., 
                               model1 = "mog",
                               model2 = "uvlm")),
         across(model, ~str_remove(., "^loo_")),
         data = "uvlm")

mcs <- bind_rows(mc1, mc2) %>% 
  relocate(data)

mcs %>% select(1:6) %>% 
  mutate(
    elpd_se_ratio = abs(elpd_diff / se_diff),
    across(where(is.numeric), round, 0),
    across(everything(), as.character),
    across(everything(), str_replace_all, "NaN", "--"),
    across(everything(), ~ifelse(.==0, "--", .))) %>% 
  select(data, model, ends_with("diff"), elpd_se_ratio, ends_with("loo"))

file_out <- paste0("stanout/modelcomparison.csv")
write_csv(mcs, file_out)
