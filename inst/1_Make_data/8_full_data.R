library(tidyverse)
library(sf)

# ENCODING FUNCTION FOR UTF8
encoding <- function(df) {
    for (col in colnames(df)) {
      if (is.character(df[[col]])) {
        Encoding(df[[col]]) <- "UTF-8"
      }
    }
    return(df)
}

# DATA
env_data <- readRDS("data/data/env_data.RDS") %>% encoding()
tree_data <- readRDS("data/data/tree_data.RDS") %>% encoding()
sap_data <- readRDS("data/data/sap_data.RDS") %>% encoding()
pep_xy <- readRDS("data/data/pep_xy.RDS") %>% encoding()
perturb_data <- readRDS("data/data/perturbation_data.RDS") %>% encoding()
#bioclim <- readRDS("data/bioclim_long.RDS") %>% encoding()
placette_mes <- readRDS("data/data/placette_mes.RDS") %>% encoding()
pep_pe <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "station_pe")

# arbre adulte vivant (de la periode, en comptant les recrues)
adulte_data <- tree_data %>%
    filter(state == "alive") %>% #, !(etat %in% c(40, 42, 44, 46))
    group_by(id_pe_mes, essence) %>%
    summarize(tree_nb_sp = n(), tree_ba_sp = sum(st_tige)) %>%
    ungroup()

adulte_data_recrues <- tree_data %>%
        filter(state == "alive", !(etat %in% c(40, 42, 44, 46))) %>%
        group_by(id_pe_mes, essence) %>%
        summarize(tree_adulte_recrues = n()) %>%
        mutate(is_sp_recrues = ifelse(tree_adulte_recrues > 0, 1, 0)) %>%
        select(id_pe_mes, essence, is_sp_recrues) %>%
        ungroup()
recrues <- recrues <- tree_data %>%
        filter(etat == 40) %>%
        group_by(id_pe_mes, essence) %>%
        summarize(recrues = n()) %>%
        mutate(is_recrues = ifelse(recrues > 0, 1, 0)) %>%
        ungroup()

tree_ba <- tree_data %>%
    filter(state == "alive") %>%
    group_by(id_pe_mes) %>%
    # compter le nombre de ligne dont etat == 26
    summarize(tree_ba = sum(st_tige)) %>%
    ungroup()

nb_coup <- tree_data %>%
    group_by(id_pe_mes) %>%
    # compter le nombre de ligne dont etat == 26
    summarize(nb_coup = sum(ifelse(etat == 26, 1, 0))/n()) %>%
    ungroup()

# merge sap pert avec adulte et recru
data <- sap_data %>%
    merge(adulte_data, all.x = TRUE) %>%
    merge(tree_ba, all.x = TRUE) %>%
    merge(nb_coup, all.x = TRUE) %>%
    merge(recrues, all.x = TRUE) %>%
    merge(adulte_data_recrues, all.x = TRUE)

# in sap pert columns recrues et arbres change na to 0
data[is.na(data$tree_nb_sp), "tree_nb_sp"] <- 0
data[is.na(data$tree_ba_sp), "tree_ba_sp"] <- 0
data[is.na(data$tree_ba), "tree_ba"] <- 0
data[is.na(data$nb_coup), "nb_coup"] <- 0
data[is.na(data$recrues), "recrues"] <- 0
data[is.na(data$is_recrues), "is_recrues"] <- 0
data[is.na(data$is_sp_recrues), "is_sp_recrues"] <- 0

data <- data %>% mutate(is_species = ifelse(tree_nb_sp >0, 1, 0))

# nouvelle colonne presance absence de gaule avec all_gaule > 0
data <- data %>% mutate(presence_gaule = ifelse(all_cl > 0, 1, 0))

### Add environmental data
table(pep_pe$type_eco)
# Add column with soil texture and drainage index (from first number caracter of column type eco)
env_data <- env_data %>%
    left_join(
        pep_pe %>% 
        mutate(soil = ifelse(type_eco== "ND", NA, as.numeric(substr(type_eco, 4, 4)) + 1)) %>% 
        select(id_pe, soil),
        all.x = TRUE)

data <- data %>% merge(env_data, all.x = TRUE)
data <- data %>%
    merge(pep_xy %>%
    data.frame() %>%
    select(id_pe, longitude, latitude, altitude, dom_bio), all.x = TRUE)

# on va prendre pour chaque placette la dernière info non na par placette

data <- data %>%
    arrange(id_pe, no_mes) %>%
    group_by(id_pe) %>%
    tidyr::fill(c("typehumus", "epmatorg", "ph_humus", "ph_horizb",
        "pourcpierr", "cl_age", "cl_drai", "cl_drai2", "dep_sur", #"exposition",
        "longitude", "latitude", "age_mean", "soil"),
        .direction = "downup") %>%
    ungroup() %>%
    encoding()

#### TRIE DES ESPECES
# ABIBAL, PICMAR,PICGLA (Boréales)
#  BETPAP, POPTRE (Mixtes)
# ACERUB, ACESAC, BETALL, ACESPI, THUOCC (Tempérées)
data <- data %>% 
    filter(sp_code %in% c("ABIBAL","ACESAC", "ACERUB","BETALL","PICMAR", "PICGLA", "BETPAP", "POPTRE")) %>%
    filter(dom_bio %in% c(4,5))

################################################################################

#----------------------
## LES PERTURBATIONS
#----------------------

################################################################################

# tableau de perturbation rows id_pe_mes et columns perturb avec year en valeur
perturb_data <- perturb_data %>% mutate(year = as.numeric(year))
merged <- perturb_data %>%
  left_join(placette_mes, by = "id_pe")

# extraire la première mesure après chaque perturbation pour chaque id_pe, perturbation_type, et perturbation_year
result <- merged %>%
  group_by(id_pe, cl_perturb, year.x) %>%
  filter(year.y >= year.x) %>%
  summarise(no_mes = min(no_mes)) %>%
  rename(year = year.x, perturb = cl_perturb)

perturbation <- result %>%
    mutate(id_pe_mes = paste0(id_pe,"0", no_mes)) %>%
    select(id_pe, no_mes, id_pe_mes, perturb, year) %>%
    unique() %>%
    group_by(id_pe_mes) %>%
    pivot_wider(names_from = perturb, values_from = year,
        values_fn = ~ max(.x, na.rm = TRUE)) %>%
    ungroup()

data_pert <- data %>%
    merge(perturbation, all = TRUE) %>%
    arrange(id_pe, no_mes) %>%
    group_by(id_pe) %>%
    tidyr::fill(c("partial_logging", "logging", "burn", "outbreak", "logging_pr"),
        .direction = "downup")


# na from full_data to 0

full_data <- data_pert %>%
    #select(-`NA`) %>%
    mutate(
        partial_logging = as.numeric(partial_logging),
        outbreak = as.numeric(outbreak),
        logging = as.numeric(logging),
        burn = as.numeric(burn),
        logging_pr = as.numeric(logging_pr),
        year_measured = as.numeric(year_measured)
    ) %>%
    mutate(
        partial_logging =
        ifelse(is.na(partial_logging) | partial_logging > year_measured, NA,
            year_measured - partial_logging),
        logging =
        ifelse(is.na(logging) | logging > year_measured, NA,
            year_measured - logging),
        burn =
        ifelse(is.na(burn) | burn > year_measured, NA, 
            year_measured - burn),
        outbreak =
        ifelse(is.na(outbreak) | outbreak > year_measured, NA,
            year_measured - outbreak),
        logging_pr =
        ifelse(is.na(logging_pr) | logging_pr > year_measured, NA,
            year_measured - logging_pr)
    )

full_data <- full_data %>% mutate(
    partial_logging = ifelse(partial_logging == 0 & nb_coup < 0.1, NA, partial_logging),
    logging = ifelse(logging == 0 & nb_coup < 0.1, NA, logging),
    burn = ifelse(burn == 0 & nb_coup < 0.1, NA, burn),
    outbreak = ifelse(outbreak == 0 & nb_coup < 0.1, NA, outbreak),
    logging_pr = ifelse(logging_pr == 0 & nb_coup < 0.1, NA, logging_pr)
)

# Ne garder que la dernier perturbation

full_data <- full_data %>%
    mutate(
        is_logging = ifelse(is.na(logging), 0, 1),
        is_partial_logging = ifelse(is.na(partial_logging), 0, 1),
        is_burn = ifelse(is.na(burn), 0, 1),
        is_outbreak = ifelse(is.na(outbreak), 0, 1),
        is_logging_pr = ifelse(is.na(logging_pr), 0, 1)
    )
#full_data <- full_data %>%
#    merge(bioclim %>% rename(year_measured = year, id_pe = ID_PE), all.x = TRUE)

# categorizer cl_drai et dep_sur
full_data <- full_data %>%
    mutate(cl_drai = case_when(
        cl_drai2 %in% c("bon","modere") ~ "moyen",
        cl_drai2 %in% c("mauvais", "tres_mauvais","imparfait") ~ "faible",
        cl_drai2 %in% c("excessif","rapide","complexe") ~ "fort",
    ))
# read excel file file depot_code_SP.xlsx
library(readxl)
depot_code <- read_excel("data/data/depot_code_SP.xlsx")

full_data <- full_data %>%
    # garder que les 2 premières lettres du code dep_sur
    mutate(dep_sur = substr(dep_sur, 1, 2)) %>%
    mutate(dep_sur = 
        ifelse(dep_sur %in% c("R1", "8C", "R8", "R5"), substr(dep_sur, 1, 1),
        dep_sur),
        dep_sur = ifelse(dep_sur == "M8", "M7T", dep_sur)) %>%
    merge(depot_code %>% rename(dep_sur = depot), all.x = TRUE)

full_data <- full_data %>%
    select(-c(cl2,cl4,cl6,cl8,ph_horizb,pourcpierr,
    cl_age,type_couv, age_mean, cl_drai2, code ,dep_sur))

# supprimer les ph_humus = NA, epmatorg = NA
full_data <- full_data %>%
    filter(!is.na(ph_humus)) %>%
    filter(!is.na(epmatorg))

# enlever les valeurs d'épaisseur de la matière organique qui sont à 99
full_data <- full_data %>% 
    filter(epmatorg != 99)

# scale data
scaling <- full_data %>% 
    filter(sp_code == "ABIBAL") %>%
    select(year_measured, longitude, latitude, altitude, ph_humus,
        epmatorg, tree_ba, partial_logging, logging, logging_pr, burn, outbreak, tree_ba_sp) %>%
    summarise_all(funs(mean(., na.rm = TRUE), sd(., na.rm = TRUE)))
scaling_data <- data.frame(param = colnames(scaling), value = as.numeric(scaling[1,])) %>%
    separate(col = param, into = c("var", "mean_sd"), sep = "_(?!.*_)")

full_data <- full_data %>% group_by(sp_code) %>%
    mutate(
    year_measured_sc = scale(year_measured)[,],
    latitude_sc = scale(latitude)[,],
    longitude_sc = scale(longitude)[,],
    altitude_sc = scale(altitude)[,],
    epmatorg_sc = scale(epmatorg)[,],
    ph_humus_sc = scale(ph_humus)[,],
    tree_ba_sc = scale(tree_ba)[,],
    partial_logging_sc = scale(partial_logging)[,],
    logging_sc = scale(logging)[,],
    logging_pr_sc = scale(logging_pr)[,],
    burn_sc = scale(burn)[,],
    outbreak_sc = scale(outbreak)[,],
    all_cl_sc = scale(all_cl)[,],
    is_burn_sc = scale(is_burn)[,],
    is_outbreak_sc = scale(is_outbreak)[,],
    tree_ba_sp_sc = scale(tree_ba_sp)[,]) %>%
    ungroup() %>%
    arrange(id_pe) %>%
    mutate(
    id_pe_sc = as.numeric(as.factor(id_pe)),
    cl_drai_sc = as.numeric(factor(cl_drai)),
    texture_sc = as.numeric(factor(texture)))

# change all NA in 0
full_data[is.na(full_data) & is.numeric(full_data)] <- 0

# bioclim_data
bioclim <- readRDS("data/final_data/bioclim_345.RDS") %>%
    data.frame() %>%
    select(-c(longitude, latitude, dom_bio, altitude, geometry)) %>%
    rbind(readRDS("data/final_data/bioclim_126789.RDS")) %>%
    filter(id_pe %in% full_data$id_pe) %>% arrange(id_pe)

meanT <- bioclim %>% dplyr::select(id_pe, year,  an_meanT) %>%
    pivot_wider(names_from = year, values_from = an_meanT) %>% arrange(id_pe) %>%
    mutate(`2021` = `2020`)
for (i in (1970-1958):(2021-1958)) {
    meanT[,i] <- meanT[,(i-10):(i-1)] %>% apply(1, mean, na.rm = TRUE)
}
meanT %>% pivot_longer(cols = -id_pe, names_to = "year", values_to = "an_meanT") %>%
    mutate(year = as.numeric(year)) -> meanT
cmi <- bioclim %>% dplyr::select(id_pe, year,  cmi_sum) %>%
    pivot_wider(names_from = year, values_from = cmi_sum) %>% arrange(id_pe) %>%
    mutate(`2019`= `2018`,
        `2020`= `2018`,
        `2021` = `2018`)
for (i in (1970-1958):(2021-1958)) {
    cmi[,i] <- cmi[,(i-10):(i-1)] %>% apply(1, mean, na.rm = TRUE)
}
cmi %>% pivot_longer(cols = -id_pe, names_to = "year", values_to = "cmi_sum") %>%
    mutate(year = as.numeric(year)) -> cmi

full_data %>% left_join(meanT %>% rename(year_measured = year), full.x = TRUE) %>%
    left_join(cmi %>% rename(year_measured = year), full.x = TRUE) -> full_data

scaling_data %>%
    rbind(
    c("tmean", "mean", mean(full_data$an_meanT)),
    c("tmean", "sd", sd(full_data$an_meanT)),
    c("cmi", "mean", mean(full_data$cmi_sum)),
    c("cmi", "sd", sd(full_data$cmi_sum))) -> scaling

full_data <- full_data %>%
    mutate(an_meanT_sc = scale(an_meanT)[,],
        cmi_sum_sc = scale(cmi_sum)[,])

# creation d'une colonne have been species
# en groupant par id_pe have_been_species == 1 si au moins une fois l'espece a ete mesuree avant ou au moment même de la mesure
# QUE FAIRE SI L'ESPECE A ETE MESUREE AVANT LA MESURE !!
# sum ça ne marche pas car ça fait la somme de toutes les mesures, je veux que celles d'avant (des mesures precedantes)

full_data <- full_data %>% 
  arrange(id_pe, no_mes) %>% 
  group_by(id_pe, sp_code) %>% 
  mutate(have_been_species = ifelse(cumsum(is_species) > 0, 1, 0)) %>%
  mutate(have_been_species_recrues = ifelse(cumsum(is_sp_recrues) > 0, 1, 0)) %>%
  ungroup()

# ajouter une colonne cl_logging, cl_partial_logging, cl_burn, cl_outbreak, cl_logging_pr
# avec 1 si la perturbation est entre 5 et 15 et 2 si la perturbation est entre 20 et 30

full_data <- full_data %>% data.frame() %>%
    mutate(cl_logging = case_when(
        is_logging == 0 ~ 6,
        logging <= 5 ~ 4,
        logging <= 15 ~ 1,
        logging <= 25 ~ 2,
        logging <= 35 ~ 3,
        TRUE ~ 5),
    cl_partial_logging = case_when(
        is_partial_logging == 0 ~ 6,
        partial_logging <= 5 ~ 4,
        partial_logging <= 15 ~ 1,
        partial_logging <= 25 ~ 2,
        partial_logging <= 35 ~ 3,
        TRUE ~ 5),
    cl_burn = case_when(
        is_burn == 0 ~ 6,
        burn <= 45 ~ 4,
        burn <= 55 ~ 1,
        burn <= 70 ~ 7,
        burn <= 80 ~ 2,
        burn <= 90 ~ 8,
        burn <= 100 ~ 3,
        TRUE ~ 5),
    cl_outbreak = case_when(
        is_outbreak == 0 ~ 6,
        outbreak <= 5 ~ 4,
        outbreak <= 15 ~ 1,
        outbreak <= 25 ~ 2,
        outbreak <= 35 ~ 3,
        TRUE ~ 5),
    cl_logging_pr = case_when(
        is_logging_pr == 0 ~ 6,
        logging_pr <= 5 ~ 4,
        logging_pr <= 15 ~ 1,
        logging_pr <= 25 ~ 2,
        logging_pr <= 35 ~ 3,
        TRUE ~ 5))

full_data %>% select(- "NA.") %>%
    # change in perturb columns : burn, logging, partial_logging, outbreak, logging_pr NA to 0
    mutate(burn = ifelse(is.na(burn), 0, burn),
        logging = ifelse(is.na(logging), 0, logging),
        partial_logging = ifelse(is.na(partial_logging), 0, partial_logging),
        outbreak = ifelse(is.na(outbreak), 0, outbreak),
        logging_pr = ifelse(is.na(logging_pr), 0, logging_pr)) %>%
    # change in perturb columns : burn, logging, partial_logging, outbreak, logging_pr NA to 0
    mutate(burn_sc = ifelse(is.na(burn_sc), 0, burn),
        logging_sc = ifelse(is.na(logging_sc), 0, logging),
        partial_logging_sc = ifelse(is.na(partial_logging_sc), 0, partial_logging),
        outbreak_sc = ifelse(is.na(outbreak_sc), 0, outbreak),
        logging_pr_sc = ifelse(is.na(logging_pr_sc), 0, logging_pr_sc)) -> full_data

full_data %>% mutate(texture_sc = factor(texture, levels = c("0","Coarse","Fine","Medium", "Organique", "Rock"),
labels = c("6","1","2","3","4","5"))) -> full_data

full_data <- na.omit(full_data)


save(full_data, scaling, file = "data/full_data.RData", compress = "xz")

save(full_data, file = "full_data.rda", compress = "xz")
save(scaling, file = "scaling.rda", compress = "xz")



save(full_data, scaling, file = "data/full_data.RData", compress = "xz")
