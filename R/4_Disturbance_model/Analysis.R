## Packages
library(dplyr)
library(ggplot2)

#library(patchwork)
#library(R2jags)
#library(boot)
#library(cowplot)

source("R/4_Disturbance_model/function_analysis.R")
source("R/4_Disturbance_model/fig_test.R")


# load data
load("data/full_data.RData")
Mysp <- c(
    "ABIBAL", "ACERUB", "BETALL", "ACESAC",
    "PICMAR", "PICGLA",
    "BETPAP", "POPTRE"
)

x=full_data %>%
    filter(burn == 1)

Temperate <- c("ACERUB", "ACESAC", "BETALL")
Boreal <- c("ABIBAL", "PICGLA", "PICMAR")
Pioneer <- c("BETPAP", "POPTRE")

# Perturbation types
logging <- c("l", "lpr", "pl")
outbreak <- c("o")
burn <- c("b")

# This data countains full_data a dataframe with the data I analysed
# and scaling a dataframe with the scaling factor for each variables (mean and sd)
full_data <- full_data %>%
    filter(sp_code %in% Mysp, dom_bio %in% c(4, 5))

Model_path <- "output/heavy/output_new_withoutBA/" # impossible to upload on github for now because to big
for (sp in Mysp) {
    assign(paste0("Model_", sp), readRDS(paste0(Model_path, sp, ".rds")))
}



disturbance_pa <- disturbance_table("pa", FALSE)
disturbance_nb <- disturbance_table("nb", FALSE)

path1 <- "Figure/mh/no_submodel"
path2 <- "Figure/mh/with_submodel"

png(paste0(path1,"/multi_pred_pa.png"), width = 11, height = 8, res = 300, units = "in")
disturbance_plot(disturbance_pa, 3)
dev.off()
png(paste0(path1,"/multi_pred_nb.png"), width = 11, height = 8, res = 300, units = "in")
disturbance_plot(disturbance_nb, 3)
dev.off()
#disturbance_pa = readRDS("output/disturbance_pa.rds")
#disturbance_nb = readRDS("output/disturbance_nb.rds")

### COUPE TOTALE ####
ylim <- c(-1,3.5)
png(paste0(path1,"/pred_CT_pa.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 1,
    perturb = "l",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "l",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 3,
    perturb = "l",
    title = "t = 30 ans",
    ylim = ylim, yax = FALSE, leg = TRUE
)
mtext("Coupe total - présence", outer = TRUE, font = 2)
dev.off()

## Abondance
ylim <- c(-0.5, 2)
png(paste0(path1,"/pred_CT_nb.png"), width = 8, height = 3, 
res = 300, units = "in")

par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 1,
    perturb = "l",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "l",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 3,
    perturb = "l",
    title = "t = 30 ans",
    ylim = ylim, yax = FALSE, leg = TRUE
)
mtext("Coupe total - Abondance", outer = TRUE, font = 2)
dev.off()

### COUPE PARTIELLE ####
ylim <- c(-1.5, 1.5)
png(paste0(path1,"/pred_CP_pa.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 1,
    perturb = "pl",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "pl",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 3,
    perturb = "pl",
    title = "t = 30 ans",
    ylim = ylim, yax = FALSE, leg = TRUE
)
mtext("Coupe partielle - Présence", outer = TRUE, font = 2)
dev.off()

ylim <- c(-1, 1)
png(paste0(path1,"/pred_CP_nb.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 1,
    perturb = "pl",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "pl",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 3,
    perturb = "pl",
    title = "t = 30 ans",
    ylim = ylim, yax = FALSE, leg = TRUE
)
mtext("Coupe partielle - Abondance", outer = TRUE, font = 2)
dev.off()

### CPRS #####
ylim <- c(-2, 3.5)
png(paste0(path1,"/pred_CPRS_pa.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 1,
    perturb = "lpr",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim 
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "lpr",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE, leg = F
)
mtext("CPRS - Présence", outer = TRUE, font = 2)
dev.off()

ylim <- c(-1, 2)
png(paste0(path1,"/pred_CPRS_nb.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 1,
    perturb = "lpr",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim 
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "lpr",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE, leg = F
)
mtext("CPRS - Abondance", outer = TRUE, font = 2)
dev.off()

### FIRE ####
ylim <- c(-3, 1.5)
png(paste0(path1,"/pred_feu_pa.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 1,
    perturb = "b",
    title = "t = 50 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "b",
    title = "t = 75 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 3,
    perturb = "b",
    title = "t = 100 ans",
    ylim = ylim, yax = FALSE, leg = TRUE
)
mtext("Feu - Présence", outer = TRUE, font = 2)
dev.off()


ylim <- c(-1, 1)
png(paste0(path1,"/pred_feu_nb.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 1,
    perturb = "b",
    title = "t = 50 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "b",
    title = "t = 75 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 3,
    perturb = "b",
    title = "t = 100 ans",
    ylim = ylim, yax = FALSE, leg = TRUE
)
mtext("Feu - Abondance", outer = TRUE, font = 2)
dev.off()

### OUTBREAK ####

ylim <- c(-2, 1.5)
png(paste0(path1,"/pred_insect_pa.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 1,
    perturb = "o",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "o",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 3,
    perturb = "o",
    title = "t = 30 ans",
    ylim = ylim, yax = FALSE, leg = TRUE, leg_pos = "bottomright"
)
mtext("Épidémies - Présence", outer = TRUE, font = 2)
dev.off()

ylim <- c(-1, 1)
png(paste0(path1,"/pred_insect_nb.png"), width = 8, height = 3, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = F, mar = c(1, 2, 2, 0.5), oma = c(0, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 1,
    perturb = "o",
    title = "t = 10 ans", ylab = "Distribution des coefficients",
    ylim = ylim
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "o",
    title = "t = 20 ans",
    ylim = ylim, yax = FALSE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 3,
    perturb = "o",
    title = "t = 30 ans",
    ylim = ylim, yax = FALSE, leg = TRUE, leg_pos = "bottomright"
)
mtext("Épidémies - Abondance", outer = TRUE, font = 2)
dev.off()



### TOUTES LES COUPES PA À T = 20 ans ####

ylim <- c(-2,2)
png(paste0(path1,"/pred_coupes_pa_t20.png"), width = 9, height = 3.6, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = FALSE, mar = c(1, 2, 2, 0.5), oma = c(4, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "l",
    title = "Coupe totale", ylab = "Distribution des coefficients",
    ylim = ylim, xax = TRUE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "lpr",
    title = "CPRS",
    ylim = ylim, yax = FALSE, xax = TRUE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "pl",
    title = "Coupe partielle",
    ylim = ylim, yax = FALSE, xax = TRUE, leg = TRUE, leg_pos = "bottomright"
)
mtext("Effet des coupes sur la P(présence) à t = 20 ans", outer = TRUE, font = 2)
dev.off()

ylim <- c(-1,2)
png(paste0(path1,"/pred_coupes_nb_t20.png"), width = 9, height = 3.6, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = FALSE, mar = c(1, 2, 2, 0.5), oma = c(4, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "l",
    title = "Coupe totale", ylab = "Distribution des coefficients",
    ylim = ylim, xax = TRUE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "lpr",
    title = "CPRS",
    ylim = ylim, yax = FALSE, xax = TRUE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "pl",
    title = "Coupe partielle",
    ylim = ylim, yax = FALSE, xax = TRUE, leg = TRUE
)
mtext("Effet des coupes sur l'abondance à t = 20 ans", outer = TRUE, font = 2)
dev.off()

### FEU À T = 50 + ÉPIDÉMIES À T = 20

ylim <- c(-3,1.5)
png(paste0(path1,"/pred_perturb_pa.png"), width = 9, height = 3.6, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = FALSE, mar = c(1, 2, 2, 0.5), oma = c(4, 2, 2, 0))
plot_disturb(
    pred = disturbance_pa,
    date_perturb = 2,
    perturb = "b",
    title = "Feux (t = 75 ans)", ylab = "Distribution des coefficients",
    ylim = ylim, xax = TRUE
)

plot_disturb(
    pred = disturbance_pa,
    date_perturb = 3,
    perturb = "o",
    title = "Épidémies (t = 30 ans)",
    ylim = ylim, yax = FALSE, xax = TRUE, leg = TRUE, leg_pos = "bottomright"
)

mtext("Effet des perturbations naturelles sur la P(présence)", outer = TRUE, font = 2, adj = 0.2)
dev.off()

ylim <- c(-1,1)
png(paste0(path1,"/pred_perturb_nb.png"), width = 9, height = 3.6, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = FALSE, mar = c(1, 2, 2, 0.5), oma = c(4, 2, 2, 0))
plot_disturb(
    pred = disturbance_nb,
    date_perturb = 2,
    perturb = "b",
    title = "Feux (t = 75 ans)", ylab = "Distribution des coefficients",
    ylim = ylim, xax = TRUE
)

plot_disturb(
    pred = disturbance_nb,
    date_perturb = 3,
    perturb = "o",
    title = "Épidémies (t = 30 ans)",
    ylim = ylim, yax = FALSE, xax = TRUE, leg = TRUE, leg_pos = "bottomright"
)
mtext("Effet des perturbations naturelles sur l'abondance", outer = TRUE, font = 2, adj = 0.2)
dev.off()


### ESPECE ####
ylim <- c(-3,2)
png(paste0(path1,"/pred_temperee_pa.png"), width = 9, height = 3.7, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = FALSE, mar = c(1, 2, 2, 0.5), oma = c(4, 2, 2, 0))
plot_species(
    pred = disturbance_pa,
    date_perturb = 2,
    sp = "ACERUB",
    title = "P(Présence) Acer rubrum", ylab = "Distribution des coefficients",
    ylim = ylim, xax = TRUE
)

plot_species(
    pred = disturbance_pa,
    date_perturb = 2,
    sp = "ACESAC",
    title = "P(Présence) Acer saccharum",
    ylim = ylim, yax = FALSE, xax = TRUE
)

plot_species(
    pred = disturbance_pa,
    date_perturb = 2,
    sp = "BETALL",
    title = "P(Présence) Betula alleghaniensis",
    ylim = ylim, yax = FALSE, xax = TRUE
)

mtext("Effet des perturbations sur la régénération des espèces tempérées",
    outer = TRUE, font = 2)
dev.off()

ylim <- c(-1,2)
png(paste0(path1,"/pred_temperee_nb.png"), width = 9, height = 3.7, res = 300, units = "in")
par(mfrow = c(1, 3), xpd = FALSE, mar = c(1, 2, 2, 0.5), oma = c(4, 2, 2, 0))
plot_species(
    pred = disturbance_nb,
    date_perturb = 2,
    sp = "ACERUB",
    title = "Abondance Acer rubrum", ylab = "Distribution des coefficients",
    ylim = ylim, xax = TRUE
)

plot_species(
    pred = disturbance_nb,
    date_perturb = 2,
    sp = "ACESAC",
    title = "Abondance Acer saccharum",
    ylim = ylim, yax = FALSE, xax = TRUE
)

plot_species(
    pred = disturbance_nb,
    date_perturb = 2,
    sp = "BETALL",
    title = "Abondance Betula alleghaniensis",
    ylim = ylim, yax = FALSE, xax = TRUE
)

mtext("Effet des perturbations sur la régénération des espèces tempérées",
    outer = TRUE, font = 2)
dev.off()

png(paste0(path1,"/tempo_pred_temperee_pa.png"), width = 12, height = 4, res = 300, units = "in")
combination_plot
dev.off()



combination_plot <-
    ggplot(wd) +
        aes(y = latitude, x = year_measured, fill = (pred)) +
        geom_raster(interpolate = TRUE) +
        scale_fill_gradientn(colours = myPalmh(200), labels = function(x) format(x, scientific = TRUE)) +
        facet_wrap(~sp_code) +
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