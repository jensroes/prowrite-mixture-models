rm(list = ls())
library(loo)
library(tidyverse)

path <- "stanout/cato"
(files <- list.files(path, pattern = "^.[^\\_]*.rda$", full.names = T))

for(file in files){
    varname <- str_remove_all(file, ".rda|stanout/cato/")
    m <- readRDS(file)
    log_lik <- extract_log_lik(m, merge_chains = F) 
    r_eff <- relative_eff(exp(log_lik)) 
    assign(paste0("loo_",varname), loo(log_lik, r_eff = r_eff, cores = 2))  
    print(varname); rm(list = "m"); gc()
}

(loos <- ls(pattern = "loo_.*"))
mc1 <- do.call(what = loo_compare, args = lapply(loos[2:1], as.name))
mc2 <- do.call(what = loo_compare, args = lapply(loos[c(1,3)], as.name))
mc3 <- do.call(what = loo_compare, args = lapply(loos[3:4], as.name))
mc4 <- do.call(what = loo_compare, args = lapply(loos[4:5], as.name))

mcs <- map_dfr(.x = list(mc1, mc2, mc3, mc4), ~as.data.frame(.x) %>% 
                 rownames_to_column("model") %>%
                 as_tibble() %>% 
                 slice(2)) %>%
  mutate(model = c("M1 -- M2", "M2 -- M3", "M3 -- M4", "M4 -- M5"),
         elpd_diff_ratio = abs(elpd_diff / se_diff));mcs

write_csv(mcs, "stanout/cato/modelcomparison.csv")
