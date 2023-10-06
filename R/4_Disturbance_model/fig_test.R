### Plot model prediction ####

plot_disturb <- function(
    pred, date_perturb, perturb,
    title = NULL, xaxis = FLASE, ylab = NULL, ylim = NULL,
    leg = FALSE, leg_pos = "topright", xax = FALSE, yax = TRUE) {
    tmp <- pred[pred$date_perturb == date_perturb & pred$perturb == perturb, ]

    tmp <- tmp %>% arrange(desc(type_sp), sp_code)

    xx <- c(1:3, 8:9, 14:16)
    colo <- c(rep("#D43650", 3), rep("#FEAC19", 2), rep("#158282", 3))
    gr <- c("Tempéré", "Pionnier", "Boréal")
    Mysp <- c(
        "ACERUB", "ACESAC", "BETALL",
        "BETPAP", "POPTRE", "ABIBAL",
        "PICGLA", "PICMAR"
    )

    if (is.null(ylim)) ylim <- range(tmp$min, tmp$max)

    plot(xx, tmp$mean,
        ylim = ylim, col = "transparent",
        ann = F, xaxt = "n", yaxt = "n", bty = "l", frame.plot = T, , yaxs = "i"
    )

    abline(h = 0, col = "grey65")

    # bars for confidence interval
    arrows(
        x0 = xx,
        y0 = tmp$max,
        y1 = tmp$min,
        col = colo,
        angle = 90, code = 1,
        length = 0, lwd = 1.5, xpd = FALSE
    )

    # pch
    pch_pt <- tmp$significatif

    pch_pt[which(pch_pt == "oui")] <- 19
    pch_pt[which(pch_pt == "non")] <- 1

    # points
    points(xx, tmp$mean,
        pch = as.numeric(pch_pt),
        col = colo, cex = 1.5, lwd = 1.3
    )


    if (xax) {
        axis(1, at = xx, labels = Mysp, las = 2, tick = FALSE, cex.axis = 0.9, font = 2)
    } else {
        axis(1, at = c(2, 8.5, 15), labels = FALSE)
    }
    # axis(1, at = c(2, 13.5, 25), labels = gr, cex.axis = 1.5, font.axis = 2)

    if (yax) {
        axis(2, las = 1, cex.axis = 1)
    } else {
        axis(2, labels = FALSE)
    }



    mtext(title, 3)
    mtext(ylab, 2, line = 2.5, cex = .9)

    if (leg) {
        legend(leg_pos,
            legend = gr,
            bty = "n",
            pch = 19, col = c("#D43650", "#FEAC19", "#158282"),
            cex = 1.3
        )
    }
}


### PLOT species

plot_species <- function(
    pred, date_perturb, sp,
    title = NULL, xaxis = FLASE, ylab = NULL, ylim = NULL,
    xax = FALSE, yax = TRUE) {
    
    tmp <- pred[pred$date_perturb == date_perturb & pred$sp_code == sp, ]
    target <- c("l", "lpr", "pl", "b", "o")
    labs <- c("Coupe\ntotale", "CPRS", "Coupe\npartielle", "Feux", "Épidémies")
    tmp <- tmp[match(target, tmp$perturb), ]

    xx <- 1:5
    colo <- "#D43650"

    if (is.null(ylim)) ylim <- range(tmp$min, tmp$max)

    plot(xx, tmp$mean,
        ylim = ylim, col = "transparent",
        ann = F, xaxt = "n", yaxt = "n", bty = "l", frame.plot = T, , yaxs = "i"
    )

    abline(h = 0, col = "grey65")

    # bars for confidence interval
    arrows(
        x0 = xx,
        y0 = tmp$max,
        y1 = tmp$min,
        col = colo,
        angle = 90, code = 1,
        length = 0, lwd = 1.5, xpd = FALSE
    )

    # pch
    pch_pt <- tmp$significatif

    pch_pt[which(pch_pt == "oui")] <- 19
    pch_pt[which(pch_pt == "non")] <- 1

    # points
    points(xx, tmp$mean,
        pch = as.numeric(pch_pt),
        col = colo, cex = 1.5, lwd = 1.3
    )

    if (xax) {
        # axis(1, at = xx, labels = labs, las = 2, tick = FALSE, 
        # cex.axis = 0.9, font = 2)
        text(x = xx,
            y = par("usr")[3] - .1, adj = 1,
            labels = labs,
            xpd = NA,
            ## Rotate the labels by 35 degrees.
            srt = 45,
            cex = 1)
    } else {
        axis(1, at = c(2, 8.5, 15), labels = FALSE)
    }
    # axis(1, at = c(2, 13.5, 25), labels = gr, cex.axis = 1.5, font.axis = 2)

    if (yax) {
        axis(2, las = 1, cex.axis = 1)
    } else {
        axis(2, labels = FALSE)
    }

    mtext(title, 3)
    mtext(ylab, 2, line = 2.5, cex = .9)

}
