#' List species
#'
#' @export
#' @importFrom utils globalVariables
#'
list_species <- function() {
    c(
        "ABIBAL", "ACERUB", "ACESAC", "BETALL", "BETPAP", "PICGLA",
        "PICMAR", "POPTRE"
    )
}

#' @describeIn list_species list JAGS model files
list_model <- function() {
    path_to_models() |> list.files()
}

path_to_models <- function(...) {
    fs::path_package("QuebecSaplingsRecruitment", "jags_models", ...)
}

message_duration <- function(nsec) {
    nh <- nsec %/% 3600
    tmp <- nsec - nh * 3600
    nm <- tmp %/% 60
    ns <- tmp %% 60
    cli::pluralize(
        "Duration: ",
        ifelse(nh, "{nh} heure{?//s}, ", ""),
        "{nm} minute{?//s} et {round(ns)} seconde{?//s}"
    )
}

globalVariables(c("sp_code"))


get_means <- function(output, perturb = "l", type = "pa", var = "peak") {
    out <- output$BUGSoutput$mean[paste(type, var, perturb, sep = "_")] 
    names(out)  <- NULL
    out
}

plot_effect <- function(eff, peak, var, ...) {
    x <- seq(0.01, 100, 0.01)
    y <- as.numeric(eff) * stats::dlnorm(x, peak, var)
    plot(x, y, type = "l", ...)
}

plot_effect_gaussian <- function(eff, peak, var, ...) {
    x <- seq(0.01, 100, 0.01)
    y <- as.numeric(eff) * exp(-((x - peak)^2)/var)
    plot(x, y, type = "l", ...)
}

plot_effect_polynomial <- function(coef1, coef2, coef3, ...) {
    x <- seq(0.01, 10, 0.01)
    y <- coef1 * x + coef2 * x^2 + coef3 * x^3
    plot(x, y, type = "l", ...)
}

# plot_effect()
