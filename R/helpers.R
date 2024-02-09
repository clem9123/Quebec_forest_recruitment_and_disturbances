#' List species
#'
#' @export
#'
list_species <- function() {
    c("ACERUB", "ACESAC", "ABIBAL", "ACERUB", "ACESAC", "BETALL", "PICMAR", "PICGLA", "BETPAP", "POPTRE")
}

#' @describeIn list_species list JAGS model files
list_model <- function() {
    path_to_models() |> list.files()
}


path_to_models <- function(...) {
    fs::path_package("QuebecSaplingsRecruitment", "jags_models", ...)
}
