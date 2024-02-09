
## library
library(tidyverse)
library(glmmTMB)
library(sjPlot)
library("RColorBrewer")


## DATA
load("data/full_data.RData")


model_sp <- function(sp, part){
    if(part == "presence"){
    return(glmmTMB(
        presence_gaule ~ latitude_sc*year_measured_sc,# + (1|id_pe),
        data = full_data %>% filter(sp_code == sp),
        family = binomial(link = "logit")))
    }
    if(part == "abundance"){
    return(glmmTMB(
    all_cl ~ latitude_sc*year_measured_sc,# + (1|id_pe),
    data = full_data %>% filter(sp_code == sp, presence_gaule == 1),
    family = truncated_poisson(link = "log")))
    }
}


Mysp = c("ACERUB", "ACESAC", "BETALL")

for (s in Mysp){
    for(p in c("presence", "abundance")){
        assign(paste0(s, "_", p), model_sp(s,p))
    }
}

#list_model = list(ACESAC_presence, ACERUB_abundance, ACESAC_presence, ACESAC_abundance, BETALL_presence, BETALL_abundance)
#for (model in list_model) {
#    resid_sim <- simulateResiduals(model, integerResponse = TRUE)
#    plot(resid_sim)
#}


time_grid <- seq(
    min(full_data$year_measured_sc),
    max(full_data$year_measured_sc),
    length.out = 50) #mh
# Créer une grille pour la latitude
latitude_grid <- seq(
    quantile(full_data$latitude_sc,.05), #mh
    quantile(full_data$latitude_sc,.95), #mh
    length.out = 50) #mh
new_data <- expand.grid(
            year_measured_sc = time_grid,
            latitude_sc = latitude_grid,
            latitude2_sc = latitude_grid^2,
            id_pe = 1)
# faire les colonnes latitudes et year_measured unscalled
mean_year = scaling[which(scaling$var == "year_measured" & scaling$mean_sd == "mean"),]$value %>% as.numeric()
sd_year = scaling[which(scaling$var == "year_measured" & scaling$mean_sd == "sd"),]$value %>% as.numeric()
mean_lat = scaling[which(scaling$var == "latitude" & scaling$mean_sd == "mean"),]$value %>% as.numeric()
sd_lat = scaling[which(scaling$var == "latitude" & scaling$mean_sd == "sd"),]$value %>% as.numeric()
new_data$latitude <- new_data$latitude_sc * sd_lat + mean_lat
new_data$year_measured <- new_data$year_measured_sc * sd_year + mean_year

new_data$pred_ACERUB_presence <- predict(ACERUB_presence, newdata = new_data, type = "response", allow.new.levels = TRUE)
new_data$pred_ACERUB_abundance <- predict(ACERUB_abundance, newdata = new_data, type = "response", allow.new.levels = TRUE)
new_data$pred_ACERUB = new_data$pred_ACERUB_presence * new_data$pred_ACERUB_abundance
new_data$pred_ACESAC_presence <- predict(ACESAC_presence, newdata = new_data, type = "response", allow.new.levels = TRUE)
new_data$pred_ACESAC_abundance <- predict(ACESAC_abundance, newdata = new_data, type = "response", allow.new.levels = TRUE)
new_data$pred_ACESAC = new_data$pred_ACESAC_presence * new_data$pred_ACESAC_abundance
new_data$pred_BETALL_presence <- predict(BETALL_presence, newdata = new_data, type = "response", allow.new.levels = TRUE)
new_data$pred_BETALL_abundance <- predict(BETALL_abundance, newdata = new_data, type = "response", allow.new.levels = TRUE)
new_data$pred_BETALL = new_data$pred_BETALL_presence * new_data$pred_BETALL_abundance
# remplacer les 0 par NA
#new_data$pred_ACERUB[new_data$pred_ACERUB == 0] <- NA

#wd <- new_data %>% pivot_longer(cols = c("pred_ACERUB_abundance", "pred_ACESAC_abundance", "pred_BETALL_abundance"), names_to = "sp_code", values_to = "pred")
wd <- new_data %>% pivot_longer(cols = c("pred_ACERUB_presence", "pred_ACESAC_presence", "pred_BETALL_presence"), names_to = "sp_code", values_to = "pred")
#wd <- new_data %>% pivot_longer(cols = c("pred_ACERUB", "pred_ACESAC", "pred_BETALL"), names_to = "sp_code", values_to = "pred")
# colonne sp code : selectionner seulement les 6 derniers caractères
wd$sp_code <- substr(wd$sp_code, 6, 11)


myPalmh <- colorRampPalette(c("white", rev(brewer.pal(10, "Spectral")))) #mh


## ----combination prediction plot------
combination_plot <-
    ggplot(wd) +
        aes(y = latitude, x = year_measured, fill = (pred)) +
        geom_raster(interpolate = TRUE) +
        scale_fill_gradientn(colours = myPalmh(200), labels = function(x) format(x, scientific = TRUE)) +
        facet_wrap(~sp_code, labeller = as_labeller(c("ACERUB" = "Acer rubrum", "ACESAC" = "Acer saccharum",
                        "BETALL" = "Betula alleghaniensis"))) +
        scale_x_continuous(expand=c(0,0)) +
        scale_y_continuous(expand=c(0,0)) +
        # Ecrire les facettes en haut sans background
        theme(strip.background = element_blank(),
              strip.text.x = element_text(size = 14, face = "italic", color = "black", hjust = 0),
              strip.placement = "outside") +
        # afficher les lignes des axes sur toutes les facettes
        theme(panel.border = element_rect(colour = "black", fill=NA, size=0.5)) +
    # limite entre les facettes
        theme(panel.spacing = unit(2, "lines")) +
        # gradiant legend : plot height
        guides(fill = guide_colourbar(barheight = 15)) +
        labs(y = "Latitude", x = "Années", fill = "P(présence)")


combination_plot


### TEST interaction plots with sjPlot ####

#full_data$latitude = full_data$latitude - 46
#full_data$year_measured = full_data$year_measured - 1970

Mysp <- c(
    "ACERUB", "BETALL", "ACESAC",
    "ABIBAL", "PICMAR", "PICGLA",
    "BETPAP", "POPTRE"
)

model_sp <- function(sp, part){
    if(part == "presence"){
    return(glmmTMB(
        presence_gaule ~ latitude_sc*year_measured_sc, # + (1|id_pe),
        data = full_data %>% filter(sp_code == sp),
        family = binomial(link = "logit")))
    }
    if(part == "abundance"){
    return(glmmTMB(
    all_cl ~ latitude_sc*year_measured_sc, # + (1|id_pe),
    data = full_data %>% filter(sp_code == sp, presence_gaule == 1),
    family = truncated_poisson(link = "log")))
    }
}

list_mods <- list()
for (s in Mysp){
    for(p in c("presence", "abundance")){
        list_mods[[paste0(s, "_", p)]] <- assign(paste0(s, "_", p), model_sp(s,p))
    }
}
quantile(full_data$latitude, c(.05,.5, .95))
(46.5-mean_lat)/sd_lat 
(47.5-mean_lat)/sd_lat 
(49-mean_lat)/sd_lat 


list_p <- list()
list_a <- list()
for(s in Mysp) {
    tmp <- paste0(s, "_presence")
    mod <- list_mods[[tmp]]
    list_p[[s]] <- plot_model(mod, type = "pred", 
    terms = c("year_measured_sc", 'latitude_sc [-1.8, -0.38, 1.8]'),
    title = s,
    axis.title = c("Temps (scale)", "P(présence)")) +
    scale_color_discrete(name = "Latitude", labels = c("46.5", "47.5", "49"))

    tmp <- paste0(s, "_abundance")
    mod <- list_mods[[tmp]]
    list_a[[s]] <- plot_model(mod, type = "pred", 
    terms = c("year_measured_sc", 'latitude_sc [-1.8, -0.38, 1.8]'),
    title = s,
    axis.title = c("Temps (scale)", "Abundance")) +
    scale_color_discrete(name = "Latitude", labels = c("46.5", "47.5", "49"))
}


plot_grid(list_p)
plot_grid(list_a)



library(mgcv)
sp = "PICMAR"
x = gam(presence_gaule ~ s(year_measured_sc,latitude_sc), 
        data = full_data %>% filter(sp_code == sp),
        family = binomial(link = "logit"))
x = gam(presence_gaule ~ te(year_measured, latitude),
        data = full_data %>% filter(sp_code == sp),
        family = binomial(link = "logit"))        

plot_model(x, type = "pred", terms = c("year_measured_sc", 'latitude_sc'))
plot(x, scheme = 2, hcolors=heat.colors(999, rev =T))
