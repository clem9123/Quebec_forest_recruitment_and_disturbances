library(tidyverse)
library(sf)
# Ajouter les zones d'étude

# load data zone
zone <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "classi_eco_pe")
placette_mes <- readRDS("data/data/placette_mes_fev2023.rds")
# pep_xy
pep_xy <- readRDS("data/data/pep_xy_fev2023.rds")
pep_xy <- pep_xy %>%
    merge(zone %>% select(id_pe, dom_bio)) %>%
    select(id_pe, longitude, latitude, dom_bio, altitude, geometry) #%>%
    #filter(!dom_bio %in% c(3,4,5))
saveRDS(pep_xy, "data/data/pep_xy.RDS")

id_etude <- pep_xy %>% pull(id_pe)

nrow(placette_mes) # 4008
length(unique(placette_mes$id_pe)) # 927

# perturbation
perturbation <- readRDS("data/data_mh/perturbation_data_fev2023.rds")
perturbation <- perturbation %>% filter(id_pe %in% id_etude)
table(perturbation$cl_perturb)
perturbation <- perturbation %>%
    filter(!cl_perturb %in% c("winfall", "partial_winfall")) %>%
    mutate(cl_perturb = ifelse(cl_perturb == "partial_outbreak", "outbreak", cl_perturb))
saveRDS(perturbation, "data/data/perturbation_data.RDS")

# tree
tree <- readRDS("data/data_mh/tree_data_fev2023.RDS")
tree <- tree %>% filter(id_pe %in% id_etude)
saveRDS(tree, "data/data/tree_data.RDS")

# sap
sap <- readRDS("data/data_mh/sap_data_fev2023.RDS")
sap <- sap %>% filter(id_pe %in% id_etude)
saveRDS(sap, "data/data/sap_data.RDS")

# seed
seed <- readRDS("data/data_mh/seed_data_fev2023.RDS")
seed <- seed %>% filter(id_pe %in% id_etude)
saveRDS(seed, "data/data/seed_data.RDS")

# env
env <- readRDS("data/data_mh/env_data_fev2023.RDS")
env <- env %>% filter(id_pe %in% id_etude)
saveRDS(env, "data/data/env_data.RDS")

# placette mes
placette_mes <- readRDS("data/data/placette_mes_fev2023.rds")
placette_mes <- placette_mes %>% filter(id_pe %in% id_etude)
saveRDS(placette_mes, "data/data/placette_mes.RDS")