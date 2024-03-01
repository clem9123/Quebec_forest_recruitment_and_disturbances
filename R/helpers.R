#' List species
#'
#' @export
#' @importFrom utils globalVariables
#'
list_species <- function() {
    c("ACERUB", "ACESAC", "ABIBAL", "ACERUB", "ACESAC", "BETALL", "PICMAR", "PICGLA", "BETPAP", "POPTRE") |> sort()
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