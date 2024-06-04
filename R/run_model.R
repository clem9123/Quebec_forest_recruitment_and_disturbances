#' Run a JAGS model
#'
#' Function taking a species name as argument and running the jags model
#' it uploads the data, transform it into a list (the usable object for JAGS)
#' and run the model return a jags.parallel object.
#'
#' @param sp species. See [list_species()].
#' @param model_file JAGS model file see [list_model()].
#' @param filename output filename.
#' @param devel a logical. If `TRUE`, then 2000 random rows are used instead
#' of the entire data set.
#' @param ... further arguments passed to [R2jags::jags.parallel()].
#'
#' @details
#' Note that the name of the model will be used to determibe what parameters
#' are required.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' run_jags_model("ACERUB", "model_time_class_with_ba.bugs",
#'     n.chains = 3, n.iter = 100, devel = TRUE
#' )
#' run_jags_model("ACERUB", "model_time_class_without_ba.bugs",
#'     n.chains = 3, n.iter = 100, devel = TRUE
#' )
#' run_jags_model("ACERUB", "model_continuous_time_gaussian.bugs",
#'     n.chains = 3, n.iter = 100, devel = TRUE
#' )
#' }
#'
run_jags_model <- function(sp, model_file, filename = paste0(sp, ".rds"),
                           devel = FALSE, ...) {
    stopifnot(length(sp) == 1)

    # use basal area submodel
    with_ba <- grepl("with_ba", model_file)
    time_class <- grepl("time_class", model_file)
    if (!time_class && !grepl("continuous_time", model_file)) {
        # safety check
        stop("jags model filename is not valid.")
    }

    # 1. Start timer
    begin <- Sys.time()
    cli::cli_alert_info("Computation starts {begin}")
    # 2. Load data
    jags_data <- make_jags_data(sp, devel, with_ba)
    # 3. Run model
    param <- get_parameters(time_class, with_ba)
    print(param)

    out <- R2jags::jags.parallel(
        model.file = path_to_models(model_file),
        data = jags_data,
        parameters.to.save = param,
        ...
    )

    # 4. Stop timer
    cli::cli_alert_info("Computation done {Sys.time()}")
    out$runtime <- difftime(Sys.time(), begin, units = "secs") |> as.numeric()
    message_duration(out$runtime) |> cli::cli_alert_info()

    # 5. Save results
    saveRDS(out, file = filename)

    invisible(TRUE)
}

#' @describeIn run_jags_model Run analyses
#'
#' @param spec A specification appropriate to the type of cluster (see
#' [parallel::makeCluster()]). Beware the number of core on your computer.
#' @param output_dir output directory, created if missing.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' run_analyses(10, "model_time_class.bug", "output/heavy/withoutBA",
#'     n.chains = 3, n.iter = 2000
#' )
#' }
run_analyses <- function(spec, model_file, output_dir = "output", devel = FALSE, ...) {
    cli::cli_alert_info("Setting up cluster")
    cl <- parallel::makeCluster(spec)
    parallel::clusterEvalQ(cl, c(library(QuebecSaplingsRecruitment)))

    fs::dir_create(output_dir)

    cli::cli_alert_info("Running simulations.")
    parallel::parLapply(
        cl,
        list_species(),
        \(x) run_jags_model(x, model_file, output_dir, devel = devel, ...)
    )
    parallel::stopCluster(cl)

    cli::cli_alert_success("Done")
}


# Prepare data for JAGS
make_jags_data <- function(sp, devel = FALSE, with_ba = TRUE) {
    data <- QuebecSaplingsRecruitment::full_data |>
        dplyr::filter(sp_code == sp)
    if (devel) {
        data <- data |> dplyr::sample_n(2500)
    }

    # create the list of data to be used in the model
    out <- list(
        # data to fit
        N = nrow(data),
        PRESENCE = data$presence_gaule, # is_recrues
        DENSITE = data$all_cl, # recrues
        # variables
        EPMATORG = data$epmatorg_sc,
        PH = data$ph_humus_sc,
        IS_SPECIES = data$have_been_species, # have_been_species_recrues
        NB_SP = data$tree_nb_sp,
        TS_L = data$logging_sc, # TS = Time since
        TS_PL = data$partial_logging_sc,
        TS_LPR = data$logging_pr_sc,
        TS_B = data$burn_sc,
        TS_O = data$outbreak_sc,
        PLACETTE = data$id_pe_sc,
        N_PLACETTE = max(data$id_pe_sc),
        TMEAN = data$an_meanT_sc,
        CMI = data$cmi_sum_sc,
        SOIL = as.numeric(data$soil),
        CL_L = data$cl_logging,
        CL_PL = data$cl_partial_logging,
        CL_LPR = data$cl_logging_pr,
        CL_B = data$cl_burn,
        CL_O = data$cl_outbreak,
        BA = data$tree_ba_sc
    )

    if (with_ba) {
        out <- c(
            out,
            list(
                IS_PL = data$is_partial_logging,
                IS_L = data$is_logging,
                IS_LPR = data$is_logging_pr,
                IS_B = data$is_burn,
                IS_O = data$is_outbreak
            )
        )
    }

    out
}


get_parameters <- function(time_class = TRUE, with_ba = TRUE) {
    out <- c()
    if (with_ba) {
        # ba (basal area)
        out <- c(
            "ba_intercept",
            "ba_l0", "ba_l1",
            "ba_pl0", "ba_pl1",
            "ba_lpr0", "ba_lpr1",
            "ba_b0", "ba_b1", "ba_b2",
            "ba_o0", "ba_o1"
        )
    }
    if (time_class) {
        out <- c(
            out,
            # pa (presence/absence)
            "pa_intercept",
            "pa_epmatorg", "pa_ph", "pa_soil",
            "pa_tmean", "pa_tmean2", "pa_cmi", "pa_cmi2",
            "pa_sp", "pa_sp2", "pa_ba",
            "pa_l", "pa_pl", "pa_lpr", "pa_b", "pa_o",
            # nb (abundance)
            "nb_intercept",
            "nb_epmatorg", "nb_ph", "nb_soil",
            "nb_tmean", "nb_tmean2", "nb_cmi", "nb_cmi2",
            "nb_sp", "nb_sp2", "nb_ba",
            "nb_l", "nb_pl", "nb_lpr", "nb_b", "nb_o"
        )
    } else {
        out <- c(
            out,
            # pa (presence/absence)
            "pa_intercept",
            "pa_epmatorg", "pa_ph", "pa_soil",
            "pa_tmean", "pa_tmean2", "pa_cmi", "pa_cmi2",
            "pa_sp", "pa_sp2", "pa_ba",
            "pa_l", "pa_pl", "pa_lpr", "pa_b", "pa_o",
            # nb (abundance)
            "nb_intercept",
            "nb_epmatorg", "nb_ph", "nb_soil",
            "nb_tmean", "nb_tmean2", "nb_cmi", "nb_cmi2",
            "nb_sp", "nb_sp2", "nb_ba",
            # perturb
            "pa_eff_l",
            "pa_eff_pl",
            "pa_eff_lpr",
            "pa_eff_b",
            "pa_eff_o",
            "pa_peak_l",
            "pa_peak_pl",
            "pa_peak_lpr",
            "pa_peak_b",
            "pa_peak_o",
            "pa_var_l",
            "pa_var_pl",
            "pa_var_lpr",
            "pa_var_b",
            "pa_var_o",
            "nb_eff_l",
            "nb_eff_pl",
            "nb_eff_lpr",
            "nb_eff_b",
            "nb_eff_o",
            "nb_peak_l",
            "nb_peak_pl",
            "nb_peak_lpr",
            "nb_peak_b",
            "nb_peak_o",
            "nb_var_l",
            "nb_var_pl",
            "nb_var_lpr",
            "nb_var_b",
            "nb_var_o"

        )
    }
    out
}