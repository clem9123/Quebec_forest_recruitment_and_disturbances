## ----setup, include=FALSE---------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE)
# directory one up
knitr::opts_knit$set(root.dir = "../../")


## ----library, echo = FALSE, include = FALSE---------------
library(tidyverse)
library(patchwork)
library(R2jags)
library(boot)

library(sf)
library(geodata)
library(ggspatial)
library(factoextra)
library(corrplot)
library(PCAmixdata)


## ----data, echo = FALSE-----------------------------------
# load data
load("data/full_data.RData")
placette_mes <- readRDS("data/data/placette_mes.RDS") %>% select(id_pe_mes, version)
colnames(placette_mes) <- c("id_pe_mes", "inventaire")

# add inventory number
full_data <- full_data %>%
    left_join(placette_mes, by = "id_pe_mes") %>%
    ungroup() %>%
    # version : selectionner la premiere lettre
    mutate(inventaire = substr(inventaire, 1, 1))


## ---------------------------------------------------------
# download maps
us <- gadm(country = "US", level = 0, path = "data/raw_data/map_base/")
can <- gadm(country = "CAN", level = 1, path = "data/raw_data/map_base/")

# us
us <- st_as_sf(us)
us_prj <- st_transform(us, 32188)
us_prj <- st_transform(us, st_crs("+proj=laea +lat_0=30 +lon_0=-95"))
us_simple_prj <- st_simplify(us_prj, dTolerance = 500, preserveTopology = F)

# canada
can <- st_as_sf(can)
can_prj <- st_transform(can, 32188)
#can_prj <- st_transform(can, st_crs("+proj=laea +lat_0=30 +lon_0=-95"))
can_simple_prj <- st_simplify(can_prj, dTolerance = 800, preserveTopology = F)
# quebec
qc <- can_simple_prj %>% subset(NAME_1 %in% c("Québec"))
qc_neigh <- can_simple_prj %>% subset(NAME_1 %in% c("Ontario", "New Brunswick",
    "Newfoundland and Labrador", "Nova Scotia", "Manitoba"))

zone <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "classi_eco_pe")
pep_xy <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "placette")
pep_xy <- pep_xy %>%
  left_join(zone %>% select(id_pe, dom_bio), by = "id_pe")
pep_xy_prj <- st_transform(pep_xy, 32188)
#pep_xy_prj <- st_transform(pep_xy, st_crs("+proj=laea +lat_0=30 +lon_0=-95"))
pep_xy_prj <- pep_xy_prj %>% mutate(
    dom_bio = factor(dom_bio, levels = c(1:8),
    labels = c("Sugar maple-hickory stand", "Basswood maple stand",
        "Yellow birch maple stand", "Yellow birch fir stand",
        "White birch fir stand", "Spruce-moss stand",
        "Lichen spruce stand", "Forest tundra")))
my_placette <- pep_xy_prj %>%
  filter(id_pe %in% full_data$id_pe)


## ---------------------------------------------------------
ggplot() + 
    geom_sf(data = can) +
    geom_sf(data = qc, color = "black") +
    geom_sf(data = us, fill = "darkgrey") +
    annotate(geom = "text", x = -73, y = 54, label = "CANADA",
        color = "black", size = 6) +
    annotate(geom = "text", x = -72, y = 44, label = "UNITED STATES",
        color = "black", size = 6) +
    annotate(geom = "text", x = -71, y = 53, label = "Quebec",
        color = "black", size = 6)+
    geom_sf(data = pep_xy_prj, aes(fill = dom_bio), size = 0.5) +
    geom_sf(data = my_placette, aes(color = "black"), size = 0.5) +
    #annotation_scale(location = "bl", width_hint = 0.5) +
    #changer les couleurs
    coord_sf(xlim = c(-80, -55), ylim = c(43, 55)) +
    theme_bw()


## ---------------------------------------------------------
full_data %>%
    filter(sp_code == "ACERUB") %>%
    summarise(
            n_logging = sum(is_logging),
            n_partial_logging = sum(is_partial_logging),
            n_logging_pr = sum(is_logging_pr),
            n_burn = sum(is_burn),
            n_outbreak = sum(is_outbreak),
            # et les autres
            n_noperturb = n() - n_logging - n_partial_logging - 
                n_logging_pr - n_burn - n_outbreak
            ) %>%
    gather(key = "perturb", value = "n") %>%
    ggplot(aes(x = perturb, y = n)) +
    geom_col() +
    theme_bw() +
    labs(title = "Nombre de perturbations")


## ---------------------------------------------------------
full_data %>% 
  filter(is_logging == 1) %>%
  ggplot(aes(x = logging)) +
  geom_histogram() +
  theme_bw() +
  labs(title = "Date des perturbations de logging") +
full_data %>% 
  filter(is_logging_pr == 1) %>%
  ggplot(aes(x = logging_pr)) +
  geom_histogram() +
  theme_bw() +
  labs(title = "Date des perturbations de logging_pr") +
full_data %>%
    filter(is_partial_logging == 1) %>%
    ggplot(aes(x = partial_logging)) +
    geom_histogram() +
    theme_bw() +
    labs(title = "Date des perturbations de partial_logging") +
full_data %>%
    filter(is_burn == 1) %>%
    ggplot(aes(x = burn)) +
    geom_histogram() +
    theme_bw() +
    labs(title = "Date des perturbations de burn") +
full_data %>%
    filter(is_outbreak == 1) %>%
    ggplot(aes(x = outbreak)) +
    geom_histogram() +
    theme_bw() +
    labs(title = "Date des perturbations de outbreak")


## ---------------------------------------------------------
env_data <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "station_sol") %>% filter(no_mes == 1)


## ---------------------------------------------------------
split <- splitmix(env_data %>% select(-id_pe, -no_mes, -id_pe_mes))
X1 <- split$X.quanti
X2 <- split$X.quali
res.pcamix <- PCAmix(X.quanti=X1, X.quali=X2,rename.level=TRUE,
                     graph=FALSE)


## ---------------------------------------------------------
par(mfrow=c(2,2))
plot(res.pcamix,choice="ind",coloring.ind=X2$houses,label=FALSE,
      posleg="bottomright", main="Observations")
plot(res.pcamix,choice="levels",xlim=c(-1.5,2.5), main="Levels")
plot(res.pcamix,choice="cor",main="Numerical variables")
plot(res.pcamix,choice="sqload",coloring.var=T, leg=TRUE,
     posleg="topright", main="All variables")


## ---------------------------------------------------------
pep_xy = readRDS("data/data/pep_xy.RDS")
bioclim <- readRDS("data/bioclim.RDS") %>%
    mutate(year = as.numeric(year)) %>%
    filter(year < 2019) %>%
    left_join(data.frame(pep_xy) %>% select(id_pe, latitude, longitude))
res.pca <- bioclim %>% select(-id_pe, -year, -geometry, -dom_bio) %>% prcomp()


## ---- fig.height = 10, fig.width = 10---------------------
p1 <- res.pca %>% fviz_pca_var()
p2 <- fviz_screeplot(res.pca, addlabels = TRUE) +
    labs(y = "dim explain(%)")
p3 <- fviz_contrib(res.pca, choice = "var", axes = 1, top = 5) +
    labs(title = "DIM 1")
p4 <- fviz_contrib(res.pca, choice = "var", axes = 2, top = 5) +
    labs(title = "DIM 2")

(p1/p2+ plot_layout(heights = c(2, 1))| (p3/p4)) + plot_layout(width = c(2, 1))


## ---- echo = TRUE-----------------------------------------
bioclim %>% select(gdd_3,gdd_4, an_meanT, an_minT, an_maxT, cmi_sum, year, latitude, longitude) %>% cor() %>% corrplot()


## ---------------------------------------------------------
full_data1 %>% select(longitude, latitude, altitude, year_measured, an_meanT, cmi_sum) %>% cor() %>% corrplot()


## ---------------------------------------------------------
ggplot(full_data1) +
    geom_point(aes(x = longitude, y = latitude, color = an_meanT)) +
    theme_bw() +
    labs(title = "Temperature des parcelles")
ggplot(full_data1) +
    geom_point(aes(x = year_measured, y = latitude, color = an_meanT)) +
    theme_bw() +
    labs(title = "Temperature des parcelles")


## ---------------------------------------------------------
plot_BA <- function(perturb, ba = "tree_ba"){
    full_data1 %>%
        filter(get(paste0("is_",perturb)) == 1) %>%
        ggplot(aes(y = get(ba), x = get(perturb))) +
        geom_point() +
        theme_bw() +
        labs(title = paste0("BA vs date de ", perturb)) +
        #geom_hline(yintercept = mean_ba_noperturb, color = "red", linetype = "dashed") +
        geom_smooth(method = "lm")
}

## ---------------------------------------------------------
plot_BA("logging") +
plot_BA("partial_logging") +
plot_BA("logging_pr") +
plot_BA("burn") +
plot_BA("outbreak")


## ---------------------------------------------------------
# Make the map
p1 <- ggplot(data = data %>% filter(dom_bio == 4,
    !sp_code %in% c("ACESPI", "PINBAN")),
    aes(x = longitude, y = latitude, color = log(all_cl))) +
    geom_point(size = 2) +
    facet_grid(sp_code~inventaire) +
    theme_bw() +
    scale_color_gradient(low = "#fffb00", high = "red", na.value = "#bebebe50")
p1


## ---------------------------------------------------------
# Make data
data <- full_data %>% 
    select(sp_code, dom_bio,presence_gaule,all_cl, id_pe, latitude, longitude, inventaire) %>%
    group_by(sp_code, dom_bio,id_pe, longitude, latitude, inventaire) %>% 
    summarise(presence_gaule = mean(presence_gaule), all_cl = mean(all_cl)) %>%
    mutate(inventaire = ifelse(inventaire == 1, 2, inventaire))

# renames inventory and species
data <- data %>% 
    mutate(
        inventaire = ifelse(inventaire == 2, "1&2nd inventory (1970-1980)", "5th inventory (2000-2010)"),
        sp_code = case_when(sp_code == "ABIBAL" ~ "A. balsamea",
                                            sp_code == "ACESAC" ~ "A. saccharum",
                                            sp_code == "ACERUB" ~ "A. rubrum",
                                            sp_code == "BETPAP" ~ "B. papyrifera",
                                            sp_code == "BETALL" ~ "B. alleghaniensis",
                                            sp_code == "PICGLA" ~ "P. glauca",
                                            sp_code == "PICMAR" ~ "P. mariana",
                                            sp_code == "POPTRE" ~ "P. tremuloides",))


## ---------------------------------------------------------
# Make the 3 maps for each species type : boreal, temperate, pioneer

plot_boreal <- ggplot(data = data %>% filter(
    inventaire %in% c("1&2nd inventory (1970-1980)","5th inventory (2000-2010)"),
    sp_code %in% c("A. balsamea","P. glauca","P. mariana")),
    aes(x = longitude, y = latitude, color = log(all_cl))) +
    geom_point(size = 0.6) +
    facet_grid(sp_code~inventaire, switch = "y") +
    scale_color_gradient(low = "#fffb00", high = "red", na.value = "#bebebe50", limits = c(0,5.25)) +
    scale_y_continuous(position = "right") +
    theme_bw() +
    theme(
        strip.text = element_text(
          size = 12,
          color = "#656565"),
        strip.background = element_blank(),
        strip.placement = "outside",
        strip.text.y = element_text(face = "italic")) +
    labs(title = "Boreal")

plot_temperate <- ggplot(data = data %>% filter(
    inventaire %in% c("1&2nd inventory (1970-1980)","5th inventory (2000-2010)"),
    sp_code %in% c("A. rubrum","A. saccharum","B. alleghaniensis")),
    aes(x = longitude, y = latitude, color = log(all_cl))) +
    geom_point(size = 0.6) +
    facet_grid(sp_code~inventaire, switch = "y") +
    scale_color_gradient(low = "#fffb00", high = "red", na.value = "#bebebe50", limits = c(0,5.25)) +
    scale_y_continuous(position = "right") +
    theme_bw() +
    theme(
        strip.text = element_text(
          size = 12,
          color = "#656565"),
        strip.background = element_blank(),
        strip.placement = "outside",
        strip.text.y = element_text(face = "italic")) +
    labs(title = "Temperate")
    
plot_pionneer <- ggplot(data = data %>% filter(
    inventaire %in% c("1&2nd inventory (1970-1980)","5th inventory (2000-2010)"),
    sp_code %in% c("B. papyrifera", "P. tremuloides")),
    aes(x = longitude, y = latitude, color = log(all_cl))) +
    geom_point(size = 0.6) +
    facet_grid(sp_code~inventaire, switch = "y") +
    scale_color_gradient(low = "#fffb00", high = "red", na.value = "#bebebe50", limits = c(0,5.25)) +
    theme_bw() +
    scale_y_continuous(position = "right") +
    theme(
        strip.text = element_text(
          size = 12,
          color = "#656565"),
        strip.background = element_blank(),
        strip.placement = "outside",
        strip.text.y = element_text(face = "italic")) +
    labs(title = "Pioneer")


## ---------------------------------------------------------
plot_temperate +
(plot_boreal  + plot_layout(guides = "keep")) +
plot_boreal +
plot_layout(ncol = 2, heights = c(3,2), guides = "collect")


## ---------------------------------------------------------
ggplot(full_data, aes(x = cmi_sum, y = is_species, color = sp_code)) +
    geom_smooth(method = "glm", method.args = list(family = "binomial"), formula = y ~ poly(x,2), show.legend = FALSE) +
    ylim(0,1) +
ggplot(full_data, aes(x = cmi_sum, y = presence_gaule, color = sp_code)) +
    geom_smooth(method = "glm", method.args = list(family = "binomial"), formula = y ~ poly(x,2)) +
    ylim(0,1)

