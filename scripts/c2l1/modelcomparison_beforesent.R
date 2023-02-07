library(loo)
library(tidyverse)

path <- "stanout/c2l1"
(files <- list.files(path, pattern = "_beforesent.rda$", full.names = T))

for(file in files){
    varname <- str_remove_all(file, ".rda|stanout/c2l1/")
    m <- readRDS(file)
    log_lik <- extract_log_lik(m, merge_chains = F) 
    r_eff <- relative_eff(exp(log_lik)) 
    assign(paste0("loo_",varname), loo(log_lik, r_eff = r_eff, cores = 2))  
    print(varname); rm(list = "m"); gc()
}

(loos <- ls(pattern = "loo_.*_beforesent"))
mcs <- do.call(what = loo_compare, args = lapply(loos, as.name))

mcs <- mcs %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(model = recode(model, model1 = loos[1],
                               model2 = loos[2],
                               model3 = loos[3],
                               model4 = loos[4]),
         model = str_remove(model, "^loo_")) %>% 
  separate(model, into = c("model", "location"), sep = "_");mcs

file_out <- paste0("stanout/c2l1/modelcomparison_beforesent.csv")
write_csv(mcs, file_out)





