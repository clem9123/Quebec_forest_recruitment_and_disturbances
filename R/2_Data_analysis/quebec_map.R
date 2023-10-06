### Carte de l'aire d'étude ####

library(sf)
library(geodata)
library(RColorBrewer)
library(scales)
library(graphicsutils)
library(dplyr)
library(tmap)

# load data
load("data/full_data.RData")

full_data <- full_data %>%
    filter(dom_bio %in% c(4, 5))

pep_xy <- st_read("data/raw_data/PEP_GPKG/PEP.gpkg", layer = "placette")
pep_xy <- pep_xy %>%
    filter(id_pe %in% full_data$id_pe) %>%
    st_transform(32188)

# download maps
us <- gadm(country = "US", level = 0, path = "data/raw_data/map_base/")
can <- gadm(country = "CAN", level = 1, path = "data/raw_data/map_base/")

# us
us <- st_as_sf(us)
us_prj <- st_transform(us, 32188)
us_simple_prj <- st_simplify(us_prj, dTolerance = 500, preserveTopology = F)

# canada
can <- st_as_sf(can)
can_prj <- st_transform(can, 32188)
can_simple_prj <- st_simplify(can_prj, dTolerance = 800, preserveTopology = F)

# quebec
qc <- can_simple_prj %>% subset(NAME_1 %in% c("Québec"))
qc_neigh <- can_simple_prj %>% subset(NAME_1 %in% c(
    "Ontario", "New Brunswick",
    "Newfoundland and Labrador", "Nova Scotia", "Manitoba"
))


# Ecoregion
ecoregion <- st_read("data/raw_data/CLASSI_ECO_QC_GDB/CLASSI_ECO_QC.gdb",
    layer = "N3_DOM_BIO"
)

ecoregion <- st_transform(ecoregion, 32188)

ecoregion_simple <- st_simplify(ecoregion, dTolerance = 500, preserveTopology = TRUE)

ecoregion_simple$DOM_BIO <- factor(ecoregion_simple$DOM_BIO,
    levels = ecoregion_simple$DOM_BIO
)

my_region <- ecoregion_simple %>%
    filter(DOM_BIO %in% c(4, 5)) %>%
    st_union()

## Graticule
bb <- st_bbox(qc)
bb <- c(-700000, 4560000, 2000000, 7500000)
grat <- st_graticule(bb, crs = 32188, lon = seq(-100, -50, by = 5))
grat_x <- grat[grat$type == "E", ]
grat_y <- grat[grat$type == "N", ]


### Cartes de la région ####

png("Figure/mh/carte_region.png", width = 5.5, height = 4, res = 400, units = "in")

par(mar = c(1, 1.7, .5, 1), oma = c(0, 0, 0, .1), xpd = F)
plot(st_geometry(ecoregion_simple),
    border = "grey65", lwd = .9, col = "grey95",
    xlim = c(-150800, 1197400), ylim = c(5083691, 5870800)
)

plot(st_geometry(us_simple_prj),
    add = TRUE,
    border = "grey65", lwd = .65, col = "grey75"
)
plot(st_geometry(qc_neigh),
    add = TRUE,
    border = "grey55", lwd = .65, col = "grey85"
)
plot(st_geometry(qc),
    add = TRUE,
    border = "grey35", lwd = 1
)
plot(st_geometry(my_region),
    add = TRUE,
    border = "grey35", lwd = 1
)

plot(st_geometry(grat),
    add = TRUE,
    col = alpha("grey35", .3), lwd = .6
)

plot(st_geometry(pep_xy),
    add = TRUE,
    pch = 21, col = "#222020", bg = "#66656596", cex = .45, lwd = .8
)

axis(1,
    at = grat_x$x_start, labels = paste(abs(grat_x$degree), "°W"),
    cex.axis = .7, line = -1, tick = FALSE
)
axis(2,
    at = grat_y$y_start, labels = paste(grat_y$degree, "°N"),
    cex.axis = .7, las = 1, line = -.9, tick = FALSE
)

text(x = 1e5, y = 56e5, "Québec", cex = .9)
# text(x = 3e4, y = 50e5, "Canada", cex = .8)
# text(x = 9e5, y = 50e5, "USA", cex = .8)

dev.off()
