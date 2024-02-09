#### Getting non climatic environmental variables from Quebec forest inventory data ####

# Marie-Helene Brice
# June 13th 2018

# The geodatabase containing the PEP tree data (placette-échantillon permanente) is available online at https://www.donneesquebec.ca/recherche/fr/dataset/placettes-echantillons-permanentes-1970-a-aujourd-hui

# Environmental variables of interest:
# Soil variables (humus type, humus ph, pierrosity, drainage)
# Disturbances (logging, burning, windfall, insect outbreak)
# Forest age


### PACKAGES ####

library(sf)
library(dplyr)
library(tidyr)

## DATA ####

### Formatted species data with xy coordinates

tree_data <- readRDS("data/data_mh/tree_data_fev2023.RDS")

# check the list of layers in the gpkg

st_layers("data/raw_data/PEP_GPKG/PEP.gpkg")

# Layer containing soil variables (humus, texture, ph)
pep_sol <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "station_sol")

# Layer containing age of selected trees in all PE MES
pep_arb <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "dendro_arbres_etudes")

# layer with drainage ...
pep_ori <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "pee_ori_sond")
pep_ori <- pep_ori %>%
  select(id_pe, id_pe_mes, cl_age, cl_drai, dep_sur, type_couv)

# SOIL VARIABLES
pep_sol <- pep_sol %>%
  select(id_pe, id_pe_mes, typehumus, epmatorg, ph_humus, ph_horizb, pourcpierr)

# DISTURBANCE VARIABLES
pep_arb <- pep_arb %>%
  select(id_pe, id_pe_mes, id_arbre, id_arb_mes, age)

# XY

pep_xy <- st_read("data/data_mh/pep_xy32198_fev2023.gpkg")

### JOIN VARIBALES ####

env_data <- tree_data %>%
  ungroup() %>%
  select(id_pe, id_pe_mes, year_measured) %>%
  distinct() %>%
  left_join(pep_sol, by = c("id_pe", "id_pe_mes")) %>%
  left_join(pep_ori, by = c("id_pe", "id_pe_mes"))

age_data <- tree_data %>%
  select(id_pe, id_pe_mes, id_arbre, id_arb_mes) %>%
  left_join(pep_arb, by = c("id_pe", "id_pe_mes", "id_arbre", "id_arb_mes"))

## AGE
age_data <- age_data %>%
  ungroup() %>%
  group_by(id_pe_mes) %>%
  summarise(age_mean = mean(as.integer(age), na.rm = TRUE)) %>%
  replace_na(list(age_mean = NA))

env_data <- env_data %>% 
  left_join(age_data, by = "id_pe_mes")

env_data <- env_data %>%
  mutate(cl_drai2 = case_when(cl_drai %in% 0 ~ "excessif",
                              cl_drai %in% c(10:14) ~ "rapide",
                              cl_drai == 16 ~ "complexe",
                              cl_drai %in% c(20:24) ~ "bon",
                              cl_drai %in% c(30:34) ~ "modere",
                              cl_drai %in% c(40:44) ~ "imparfait",
                              cl_drai %in% c(50:54) ~ "mauvais",
                              cl_drai %in% c(60:64) ~ "tres_mauvais"))
env_data$cl_drai2 <- as.factor(env_data$cl_drai2)

saveRDS(env_data, "data/data_mh/env_data_fev2023.RDS")

# Figure : organic matter thickness distribution and humus type

# ggplot(env_data) +
#   geom_jitter(aes(y = epmatorg, x = typehumus), alpha = 0.2) +
#   geom_boxplot(aes(y = epmatorg, x = typehumus, color = typehumus),
#      alpha = 0.3, fill = NA, size = 0.7)
