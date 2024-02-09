### Formatting PEP saplings data from Quebec ####

### PACKAGES ####
library(sf)
library(dplyr)
library(tidyverse)


### READ DATA ####
tree_data <- readRDS("data/data_mh/tree_data_fev2023.RDS")
seed_mes <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "STATION_SEMIS")
pep_xy <- st_read("data/data_mh/pep_xy32198_fev2023.gpkg")
sps_code <- read.csv2("data/raw_data/ref_spCode.csv")

# Keep only plots kept for tree data
seed_mes <- seed_mes %>%
  filter(id_pe %in% pep_xy$id_pe)

# NOTE - weird certaine PEP_MES sans saplings dans seed_mes mais dans tree_mes
# Reponse à moi-meme = pas de gaule dans la sous-placette

plot_mes <- tree_data %>%
  select(id_pe, no_mes, id_pe_mes, year_measured) %>%
  unique()

seed_mes <- seed_mes %>%
    group_by(id_pe_mes, essence, no_mes, id_pe) %>%
    summarise(nb_semis = sum(nb_semis))

all_gaule <- merge(
  seed_mes %>%
    pivot_wider(names_from = essence, values_from = nb_semis, values_fill = 0),
  plot_mes,
  all = TRUE)
all_gaule[is.na(all_gaule)] <- 0

# remettre les espèce en une colonne, les classes de taille en 4 colonnes
all_gaule <- all_gaule %>%
  pivot_longer(cols = -c(id_pe, id_pe_mes, no_mes, year_measured),
    names_to = "essence", values_to = "nb_tige") # %>%
  #pivot_wider(names_from="cl_dhp", values_from="nb_tige", values_fill=0) %>%
  #select(-`0`) %>%
  #dplyr::rename(cl2 = `002`, cl4 = `004`, cl6 = `006`, cl8 = `008`) %>%
  #mutate(all_cl = cl2 + cl4 + cl6 + cl8)

# NOTE - on ne sait pas qui sont les nouvelles recrues d'un inventaire à l'autre

seed_mes <- all_gaule
### Change species code
seed_mes$sp_code <- sps_code$spCode[match(seed_mes$essence, sps_code$qc_code)]

# SAVE DATA
saveRDS(seed_mes, "data/data_mh/seed_data_fev2023.RDS")
