library(loo)
library(tidyverse)
options(mc.cores = 1)

path <- "stanout/lift"
(files <- list.files(path, pattern = "^.[^\\_]*.rda$", full.names = T))

# Remove files for which I've already got the log likelihood
files_nopath <- list.files(path, pattern = "^.[^\\_]*.rda$")
logliks <- list.files(str_c(path, "/loglik"), pattern = "^.[^\\_]*.rda$")
files <- files[!files_nopath %in% logliks]

# Get variable names
varnames <- str_remove_all(files, ".rda|stanout/lift/")

# Extract and save log likelihood from models
for(i in 1:length(files)){
    m <- readRDS(files[i])
    log_lik <- extract_log_lik(m, merge_chains = F) 
    saveRDS(log_lik, 
            str_c("stanout/lift/loglik/", varnames[i], ".rda"), 
            compress = "xz")
    rm(list = "m"); gc()
    print(varnames[i])
}

# Iterate over log liklihood and get loo-ic
logliks <- list.files(str_c(path, "/loglik"), 
                      pattern = "^.[^\\_]*.rda$", 
                      full.names = T)

# Get variable names
varnames <- str_remove_all(logliks, ".rda|stanout/lift/loglik/")

log_lik <- readRDS(logliks[1])
r_eff <- relative_eff(exp(log_lik))
gc()
loo <- loo(log_lik, r_eff = r_eff, cores = 1)
saveRDS(loo, 
        str_c("stanout/lift/loos/", varnames[1], ".rda"),
        compress = "xz")
rm(list = c("r_eff", "log_lik")); gc()


for(i in 1:length(varnames)){
  log_lik <- readRDS(logliks[i])
  r_eff <- relative_eff(exp(log_lik)) 
  assign(paste0("loo_",varnames[i]), loo(log_lik, 
                                         r_eff = r_eff, 
                                         cores = 2))
  gc()
  rm(log_lik)
  print(varnames[i])
}

(loos <- ls(pattern = "loo_.*"))
mcs <- do.call(what = loo_compare, args = lapply(loos, as.name))

mcs <- mcs %>% as.data.frame() %>% 
  rownames_to_column("model") %>%
  as_tibble() %>%
  mutate(model = recode(model, model1 = loos[1],
                               model2 = loos[2],
                               model3 = loos[3],
                               model4 = loos[4],
                               model5 = loos[5]),
         model = str_remove(model, "^loo_"));mcs

file_out <- paste0("stanout/lift/modelcomparison.csv")
write_csv(mcs, file_out)
