library(sf)
library(tidyverse)

# load perturbation data
pep_xy <- st_read("data/data_mh/pep_xy32198_fev2023.gpkg")
pep_ori <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "pee_ori_sond") %>%
    filter(id_pe %in% pep_xy$id_pe)
placette_mes <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "placette_mes") %>%
    filter(id_pe %in% pep_xy$id_pe) %>%
    mutate(year = lubridate::year(date_sond))

# rearange data
p_partielle <- pep_ori %>% select(id_pe, perturb, an_perturb, an_pro_ori) %>%
    unique() %>%
    rename(year = an_perturb, perturb = perturb) %>%
    # supprimer les lignes avec perturb et year NA
    filter(!(is.na(perturb) & is.na(year))) %>%
    mutate(type = "partielle")

p_totale <- pep_ori %>% select(id_pe, origine, an_origine, an_pro_ori) %>%
    unique() %>%
    rename(year = an_origine, perturb = origine) %>%
    # supprimer les lignes avec origine et year NA
    filter(!(is.na(perturb) & is.na(year))) %>%
    mutate(type = "totale")
table(p_totale$perturb)
table(p_partielle$perturb)
# merge data
pep_ori <- rbind(p_partielle, p_totale) %>% arrange(id_pe)

# renommer les perturbations
pep_ori <- pep_ori %>% mutate(
    cl_perturb = case_when(
        perturb %in%
c("CBA","CBT","CEF","CPT","CRB","CRS","CS","CT","ETR", "RPS")~
    "logging",
        perturb %in% c("CPR","CDV","CPH") ~ "logging_pr",
        perturb %in% 
c("CA","CAM","CB","CD","CDL","CE","CEA","CIP","CJ","CJG","CJP","CJT","CP",
"CPC","CPF","CPI","CPM","CPS","CPX","CTR","DEG","DLD","DRM","EC",
"ECE","EPC","ESI","PCP") ~ 
    "partial_logging",
        perturb %in% c("BR", "BRP") ~ "burn",
        #perturb %in% c("BRP") ~ "partial_burn",
        perturb %in% c("ES") ~ "outbreak",
        perturb %in% c("EL") ~ "partial_outbreak",
        perturb %in% c("CHT","DT") ~ "winfall",
        perturb %in% c("CHP", "VEP", "DP") ~ "partial_winfall",
        perturb %in% c("P", "PLN", "PLR", "PRR", "ENS", "REA") ~ "plantation",
        perturb %in% c("ENR", "RR",  "RRG") ~ "partial_plantation",
        perturb %in% c("FR") ~ "wasteland"
    )
)
### 17054

# récupérer toutes les placettes qui ont une plantation
pep_ori %>% filter(cl_perturb %in% c("plantation", "partial_plantation")) %>% 
    select(id_pe) %>% unique() %>% pull() -> id_pe_plantation
pep_ori <- pep_ori %>% filter(!id_pe %in% id_pe_plantation)
## 15147

# pour chaque placette pour la même date de perturbation
# garder celle avec la plus grande an_pro_ori
# si tous les an_pro_ori sont NA garder la dernière ligne
pep_ori <- pep_ori %>% group_by(id_pe, year) %>%
    mutate(an_pro_ori = ifelse(is.na(an_pro_ori), "0", an_pro_ori)) %>%
    filter(an_pro_ori == max(an_pro_ori, na.rm = T)) %>% ungroup()
### 11681 (8007)

# récuperer toutes les id_pe qui ont une perturbation dont la date est inconnue
pep_ori %>% filter(is.na(year)) %>% select(id_pe) %>% unique() %>% pull() -> id_pe_na
pep_ori <- pep_ori %>% filter(!id_pe %in% id_pe_na)
## 2858 (2378)

# récupérer les lignes dont les id ont ont une coupe partielle et une coupe totale la même année
pep_ori %>% group_by(id_pe, year) %>% filter(n() > 1) %>% ungroup() -> id_pe_double
# Ils ne sont pas dans id_pe donc on peut oublier

# load station_pe data
station_pe <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "station_pe")

# rearrange data
station_pe <- rbind(station_pe %>% select(id_pe, no_mes, perturb) %>%
    unique() %>%
    # supprimer les lignes avec perturb et year NA
    filter(!is.na(perturb)) %>%
    mutate(type = "partielle"),
    station_pe %>% select(id_pe, no_mes, origine) %>%
    unique() %>%
    # supprimer les lignes avec perturb et year NA
    filter(!is.na(origine)) %>%
    rename(perturb = origine) %>%
    mutate(type = "totale"))
# ajouter date_sond (qui vient de placette_mes)
station_pe <- station_pe %>% left_join(placette_mes %>% select(id_pe, no_mes, year))

# supprimer les id_pe a partir de la mesure qui a une perturbation dans
# station_pe et qui n'est pas repertoriée dans pep_ori
station_pe <- station_pe %>% filter(id_pe %in% pep_xy$id_pe, !id_pe %in% id_pe_plantation,
!id_pe %in% id_pe_na) %>% unique()
table(unique(station_pe$id_pe) %in% unique(pep_ori$id_pe))
# récupérer les id_pe dans station_pe qui ne sont pas dans pep_ori
station_pe %>% filter(!id_pe %in% pep_ori$id_pe) %>% select(id_pe) %>% unique() %>% pull() -> id_pe_station_pe


# maintenant supprimer toutes les id_pe qui ne sont pas correct
# id_pe_na, id_pe_plantation, id_pe_station_pe
pep_ori <- pep_ori %>% filter(!id_pe %in% c(id_pe_na, id_pe_plantation, id_pe_station_pe))

# faire de même dans pep_xy
pep_xy <- pep_xy %>% filter(!id_pe %in% c(id_pe_na, id_pe_plantation, id_pe_station_pe))

# et dans placette_mes
placette_mes <- placette_mes %>% filter(!id_pe %in% c(id_pe_na, id_pe_plantation, id_pe_station_pe))

# 6 lignes avec et partial logging et logging : garder seuleemnt la ligne avec logging
# je garde la ligne avec partial logging
pep_ori <- pep_ori %>% filter(!(id_pe %in% c("7601704202","7609600102","7609605902") & cl_perturb == "logging"))


# save perturbation data
saveRDS(pep_ori, "data/data_mh/perturbation_data_fev2023.rds")
saveRDS(pep_xy, "data/data/pep_xy_fev2023.rds")
saveRDS(placette_mes, "data/data/placette_mes_fev2023.rds")