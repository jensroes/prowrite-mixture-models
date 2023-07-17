library(loo)
library(tidyverse)

path <- "stanout/spl2_shift"
(files <- list.files(path, pattern = "^.[^\\_]*.rda$", full.names = T))

for(file in files){
    varname <- str_remove_all(file, ".rda|stanout/spl2_shift/")
    m <- readRDS(file)
    log_lik <- extract_log_lik(m, merge_chains = F) 
    r_eff <- relative_eff(exp(log_lik)) 
    assign(paste0("loo_",varname), loo(log_lik, r_eff = r_eff, cores = 2))  
    print(varname); rm(list = "m"); gc()
}

(loos <- ls(pattern = "loo_.*"))
mcs <- do.call(what = loo_compare, args = lapply(loos, as.name))

mcs <- mcs %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(across(model, recode, model1 = loos[1],
                               model2 = loos[2],
                               model3 = loos[3],
                               model4 = loos[4],
                               model5 = loos[5]),
         across(model, str_remove_all, "^loo_"));mcs

file_out <- paste0("stanout/spl2_shift/modelcomparison.csv")
write_csv(mcs, file_out)





