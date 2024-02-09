#### Extract bioclimatic variables 2km2 resolution #####


# bioclimatic raster data were obtained from Natural Resources Canada: ftp://ftp.nrcan.gc.ca/pub/outgoing/NAM_grids
# This script extract bioclimatic for all Qc forest plots
# Return the mean of the bioclimatic for the year of the plot survey as well as over the last 10 years before the year of the plot survey.

### PACKAGES ####

require(raster)
require(sf)
require(zoo)
require(reshape2)
require(dplyr)


### DATA ####

### xy coordinates

plot_xy <- st_as_sf(readRDS("data/data/pep_xy.RDS") %>% rename(ID_PE = id_pe))


plot_xy <- plot_xy %>% 
  st_transform("+proj=longlat +datum=WGS84 +no_defs")



### Function to download raster of climate data for North America ####

# Modified from https://github.com/inSileco/inSilecoDataRetrieval/blob/master/R/get_climate_nam_grids.R

retrieveClimateData <- function(years = 1900:2022,
                                info =  c("bio", "cmi", "mint", "maxt", "pcp", "sg"), res = 300,
                                path = "data/raw_data/clim", geom) {
  
  stopifnot(res %in% c(60, 300))
  ls_clim <- list()
  
  dir.create(path, showWarnings = FALSE)
  
  #natural-resources.canada.ca
  # basurl <- "ftp://ftp.nrcan.gc.ca/pub/outgoing/NAM_grids/zipfiles"
  basurl <- "https://ftp.maps.canada.ca/pub/nrcan_rncan/Climate-archives_Archives-climatologiques/NAM_monthly/monthly_by_var"
  info <- match.arg(info)
  beg <- paste0(basurl, "/")
  end <- paste0("_", res, "arcsec.zip")
  # year available: from 1900 to 2018
  for (year in years) {
    tmp <- tempfile(fileext = ".zip")
    print(tmp)
    print(paste0(beg, info, year, end))

    # Download
    curl::curl_download(paste0(beg, info, year, end), tmp)
    unzip(tmp, exdir = path)
    unlink(tmp)
    
    # extract data
    ls_tmp <- extract_climate_data(path = path, info = info,
                                                          year = year, geom = geom)
    
    # Save intermediate results just in case it crashes
    saveRDS(ls_tmp, paste0(path, "/", info, year, "_", res, ".rds"))
    ls_clim[[paste0(info, year)]] <- ls_tmp
    unlink(paste0(path, "/", year), recursive = TRUE)
  }
  invisible(NULL)
  
  # Save final results
  saveRDS(ls_clim, paste0(path, "/", info, "_", res, ".rds"))}

### Function to extract data from raster to multipoints ####

# Modified from https://github.com/inSileco/inSilecoDataRetrieval/blob/master/R/get_climate_nam_grids.R

extract_climate_data <- function(path, info, year, geom, pattern = "\\.asc$|\\.tif$") {
  nm_fo <- paste0(path, "/", year)
  fls <- list.files(nm_fo, pattern = pattern, full.names = TRUE)
  
  out <- lapply(lapply(fls, raster), 
                function(x) extract(crop(x, y =  geom), y =  geom))
  
  names(out) <- paste0(gsub(list.files(nm_fo, pattern = pattern), pat = pattern, rep = ""), "_", year)

  out
}


retrieveClimateData(years = 1960:2020, info = "sg", res = 60, geom = plot_xy, path = "data/raw_data/clim")

retrieveClimateData(years = 1960:2018, info = "cmi", res = 60, geom = plot_xy, path = "data/raw_data/clim")

info = "cmi"
res = 60
path = "data/raw_data/clim"
ls_clim <- list()
###### oupsi crash
for (year in 1960:2018) {
  tmp <- readRDS(paste0(path, "/", info, year, "_", res, ".rds"))
  ls_clim[[paste0(info, year)]] <- tmp
  }
saveRDS(ls_clim, paste0(path, "/", info, "_", res, ".rds"))
######

retrieveClimateData(years = 1960:2020, info = "maxt", res = 60, geom = plot_xy, path = "data/raw_data/clim")

retrieveClimateData(years = 1960:2020, info = "mint", res = 60, geom = plot_xy, path = "data/raw_data/clim")

### Format bioclimatic variables ####
sg_60 <- readRDS("data/raw_data/clim/sg_60.rds")
cmi_60 <- readRDS("data/raw_data/clim/cmi_60.rds")

# Find NA values (from plots that are located at the margin of the climate raster)

na_sg <- which(is.na(sg_60$sg1960$sg60_01_1960))
na_cmi <- which(is.na(cmi_60$cmi1960$cmi60_sum_1960))
na_sg_xy <- plot_xy[na_sg,]
na_cmi_xy <- plot_xy[na_cmi,]

# Replace NAs with nearest neighbor

xy_unassign_sg <- st_join(na_sg_xy, plot_xy[-na_sg,], join = st_nearest_feature)
xy_unassign_cmi <- st_join(na_cmi_xy, plot_xy[-na_cmi,], join = st_nearest_feature)

unassign_sg <- unlist(lapply(xy_unassign_sg$ID_PE.y, function(x) which(plot_xy$ID_PE %in% x)))
unassign_cmi <- unlist(lapply(xy_unassign_cmi$ID_PE.y, function(x) which(plot_xy$ID_PE %in% x)))
  
sg_60 <- rapply(sg_60, function(x) replace(x, na_sg, x[unassign_sg]), how = 'list')
cmi_60 <- rapply(cmi_60, function(x) replace(x, na_cmi, x[unassign_cmi]), how = 'list')

### From list to df ####

names(cmi_60) <- 1960:2018
cmi_60 <- rapply(cmi_60, as.data.frame, how = "list")
cmi_60 <- lapply(cmi_60, function(y){lapply(y, function(x) {rownames(x) <- plot_xy$ID_PE; x})})
cmi_60 <- do.call(rbind, lapply(cmi_60, data.frame))
colnames(cmi_60) <- paste0("cmi_", c(1:12, 'sum'))
cmi_60 <- tibble::rownames_to_column(cmi_60)
cmi_60 <- cmi_60 %>%
  tidyr::separate(rowname, c("year", "ID_PE"), "\\.")

names(sg_60) <- 1960:2020
sg_60 <- rapply(sg_60, as.data.frame, how = "list")
sg_60 <- lapply(sg_60, function(y){lapply(y, function(x) {rownames(x) <- plot_xy$ID_PE; x})})
sg_60 <- do.call(rbind, lapply(sg_60, data.frame))
colnames(sg_60) <- paste0("sg_", 1:16)
sg_60 <- tibble::rownames_to_column(sg_60)
sg_60 <- sg_60 %>%
  tidyr::separate(rowname, c("year", "ID_PE"), "\\.")

### Same for maxt and mint ####

maxt_60 <- readRDS("data/raw_data/clim/maxt_60.rds")
mint_60 <- readRDS("data/raw_data/clim/mint_60.rds")

# Same for maxt and mint
na_maxt <- which(is.na(maxt_60$maxt1960$maxt60_01_1960))
na_mint <- which(is.na(mint_60$mint1960$mint60_01_1960))
na_maxt_xy <- plot_xy[na_maxt,]
na_mint_xy <- plot_xy[na_mint,]
xy_unassign_maxt <- st_join(na_maxt_xy, plot_xy[-na_maxt,], join = st_nearest_feature)
xy_unassign_mint <- st_join(na_mint_xy, plot_xy[-na_mint,], join = st_nearest_feature)
unassign_maxt <- unlist(lapply(xy_unassign_maxt$ID_PE.y, function(x) which(plot_xy$ID_PE %in% x)))
unassign_mint <- unlist(lapply(xy_unassign_mint$ID_PE.y, function(x) which(plot_xy$ID_PE %in% x)))
maxt_60 <- rapply(maxt_60, function(x) replace(x, na_maxt, x[unassign_maxt]), how = 'list')
mint_60 <- rapply(mint_60, function(x) replace(x, na_mint, x[unassign_mint]), how = 'list')

names(maxt_60) <- 1960:2020
names(mint_60) <- 1960:2020
maxt_60 <- rapply(maxt_60, as.data.frame, how = "list")
mint_60 <- rapply(mint_60, as.data.frame, how = "list")
maxt_60 <- lapply(maxt_60, function(y){lapply(y, function(x) {rownames(x) <- plot_xy$ID_PE; x})})
mint_60 <- lapply(mint_60, function(y){lapply(y, function(x) {rownames(x) <- plot_xy$ID_PE; x})})
maxt_60 <- do.call(rbind, lapply(maxt_60, data.frame))
mint_60 <- do.call(rbind, lapply(mint_60, data.frame))
colnames(maxt_60) <- paste0("maxt_", 1:12)
colnames(mint_60) <- paste0("mint_", 1:12)
maxt_60 <- tibble::rownames_to_column(maxt_60)
mint_60 <- tibble::rownames_to_column(mint_60)
maxt_60 <- maxt_60 %>%
  tidyr::separate(rowname, c("year", "ID_PE"), "\\.")
mint_60 <- mint_60 %>%
  tidyr::separate(rowname, c("year", "ID_PE"), "\\.")

### Merge all bioclimatic variables ####

colnames(sg_60) <- c("year", "ID_PE", "start_gs", "end_gs", "length_gs",
  "pcp_1", "pcp_2","pcp_3", "pcp_4", "gdd_1", "gdd_2", "gdd_3", "gdd_4",
  "an_meanT", "an_minT", "an_maxT", "an_meanT_3", "an_range_T_3")

# ajouter colonne maxt_sum et mint_sum
mint_60$mint_an <- apply(mint_60 %>% dplyr::select(-year, -ID_PE), 1, min)
maxt_60$maxt_an <- apply(maxt_60 %>% dplyr::select(-year, -ID_PE), 1, max)

bioclim_ally <- left_join(sg_60,cmi_60) %>%
  left_join(cmi_60)

bioclim_ally <- bioclim_ally %>% rename(id_pe = ID_PE)

saveRDS(bioclim_ally, "data/bioclim_126789.RDS")
