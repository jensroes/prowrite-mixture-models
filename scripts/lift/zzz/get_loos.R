library(loo)
library(tidyverse)
options(mc.cores = 1)

path <- "~/prowrite-mixture-models/stanout/lift"

# Iterate over log liklihood and get loo-ic
logliks <- list.files(str_c(path, "/loglik"), 
                      pattern = "^.[^\\_]*.rda$", 
                      full.names = T)

# Get variable names
#varnames <- str_remove_all(logliks, ".rda|prowrite-mixture-models/stanout/lift/loglik/")

log_lik <- readRDS(logliks[1]);gc
r_eff <- relative_eff(exp(log_lik));gc()
loo <- loo(log_lik, r_eff = r_eff, cores = 1);gc
saveRDS(loo, 
        str_c(path, "/loos/", "lmm", ".rda"),
        compress = "xz")